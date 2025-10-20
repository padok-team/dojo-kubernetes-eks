package main

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/go-redis/redis/v8"
	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promauto"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

// =============================================================================
// CLI flags
// =============================================================================

var (
	httpAddr   = flag.String("http", ":8080", "Address to listen for requests on")
	redisNodes = flag.String("redis-nodes", "master:6379,replica-0:6379,replica-1:6379", "Redis nodes to connect to")
	redisKey   = flag.String("redis-key", "daylight", "Redis key to cache data to")
)

// =============================================================================
// Main logic
// =============================================================================

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	flag.Parse()

	client, err := newRedisClient(strings.Split(*redisNodes, ","))
	if err != nil {
		return fmt.Errorf("invalid Redis client configuration: %w", err)
	}

	const locationName = "Europe/Paris"
	location, err := time.LoadLocation(locationName)
	if err != nil {
		return fmt.Errorf("invalid location %q: %w", locationName, err)
	}

	pc := newDaylightChecker(client, *redisKey, location)

	log.Printf("Listening on %s...", *httpAddr)
	if err := http.ListenAndServe(*httpAddr, pc.router); err != nil {
		return fmt.Errorf("unable to listen for requests: %w", err)
	}

	return nil
}

// =============================================================================
// Redis client
// =============================================================================

func newRedisClient(nodes []string) (*redis.ClusterClient, error) {
	slot := redis.ClusterSlot{
		Start: 0,
		End:   16384,
	}
	for _, n := range nodes {
		slot.Nodes = append(slot.Nodes, redis.ClusterNode{Addr: n})
	}

	clusterSlots := func(_ context.Context) ([]redis.ClusterSlot, error) {
		return []redis.ClusterSlot{slot}, nil
	}

	client := redis.NewClusterClient(&redis.ClusterOptions{
		ClusterSlots:   clusterSlots,
		RouteByLatency: true,
	})

	return client, nil
}

// =============================================================================
// HTTP server
// =============================================================================

type daylightChecker struct {
	router *mux.Router

	location   *time.Location
	dateOfMove time.Time

	redisClient *redis.ClusterClient
	redisKey    string

	fetches       *prometheus.CounterVec
	fetchDuration *prometheus.HistogramVec
}

func newDaylightChecker(redisClient *redis.ClusterClient, redisKey string, location *time.Location) *daylightChecker {
	p := daylightChecker{
		router:   mux.NewRouter(),
		location: location,
		// Padok moved to new offices on Monday November 15th 2021.
		dateOfMove:  time.Date(2021, time.November, 15, 0, 0, 0, 0, location),
		redisClient: redisClient,
		redisKey:    redisKey,
		fetches: promauto.NewCounterVec(
			prometheus.CounterOpts{
				Name: "daylight_stats_provided_total",
				Help: "The total number of times stats were provided",
			},
			[]string{"cached"},
		),
		fetchDuration: promauto.NewHistogramVec(
			prometheus.HistogramOpts{
				Name: "daylight_fetch_duration_seconds",
				Help: "How long it takes to fetch stats",
			},
			[]string{"cached"},
		),
	}

	p.router.Handle("/stats", handlers.LoggingHandler(os.Stdout, http.HandlerFunc(p.handleStatsForToday))).Methods("GET")
	p.router.Handle("/stats/{date}", handlers.LoggingHandler(os.Stdout, http.HandlerFunc(p.handleStats))).Methods("GET")
	p.router.HandleFunc("/healthz", p.handleHealthcheck).Methods("GET")
	p.router.Handle("/metrics", promhttp.Handler())

	return &p
}

// =============================================================================
// HTTP handlers
// =============================================================================

func (p *daylightChecker) handleStatsForToday(w http.ResponseWriter, r *http.Request) {
	p.fetchAndWriteStats(r.Context(), w, time.Now().In(p.location))
}

func (p *daylightChecker) handleStats(w http.ResponseWriter, r *http.Request) {
	requestVars := mux.Vars(r)
	rawDate, ok := requestVars["date"]
	if !ok {
		http.Error(w, "Missing day to check", http.StatusBadRequest)
		return
	}
	date, err := time.Parse("2006-01-02", rawDate)
	if err != nil {
		http.Error(w, fmt.Sprintf("Invalid date %q. Provide a date in YYYY-MM-DD format.", rawDate), http.StatusBadRequest)
		return
	}

	p.fetchAndWriteStats(r.Context(), w, date)
}

func (p *daylightChecker) fetchAndWriteStats(ctx context.Context, w http.ResponseWriter, date time.Time) {
	start := time.Now()

	stats, cached, err := p.getStats(ctx, date)
	if err != nil {
		http.Error(w, fmt.Sprintf("An error occured: %s", err.Error()), http.StatusInternalServerError)
		return
	}

	elapsed := time.Since(start)

	p.fetchDuration.WithLabelValues(fmt.Sprintf("%t", cached)).Observe(elapsed.Seconds())
	p.fetches.WithLabelValues(fmt.Sprintf("%t", cached)).Inc()

	fmt.Fprintf(w, "%s\n", date.Format("Monday, January 02 2006"))
	fmt.Fprintf(w, "The sun rises at %s and sets at %s.\n", stats.Sunrise.In(p.location).Format("15:04:05"), stats.Sunset.In(p.location).Format("15:04:05"))
	fmt.Fprintf(w, "The day lasts %s.\n", stats.LengthOfDay)

	fmt.Fprintf(w, "\nStats provided by https://sunrise-sunset.org/.\n")

}

func (p *daylightChecker) handleHealthcheck(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 5*time.Second)
	defer cancel()

	if _, err := p.redisClient.Ping(ctx).Result(); err != nil {
		errMsg := err.Error()
		if errors.Is(err, context.DeadlineExceeded) {
			errMsg = "timed out pinging Redis"
		}
		log.Printf("healthcheck failed: %s", errMsg)
		http.Error(w, errMsg, http.StatusInternalServerError)
		return
	}

	fmt.Fprintf(w, "The server is healthy")
}

// =============================================================================
// Daylight checking
// =============================================================================

type daylightStats struct {
	Sunrise     time.Time     `json:"sunrise"`
	Noon        time.Time     `json:"noon"`
	Sunset      time.Time     `json:"sunset"`
	LengthOfDay time.Duration `json:"lengthOfDay"`
}

func (p *daylightChecker) getStats(ctx context.Context, date time.Time) (stats daylightStats, cached bool, err error) {
	stats, hit, err := p.getStatsFromCache(ctx, date)
	if err != nil {
		log.Printf("failed to read cache: %s", err.Error())
	}
	if hit {
		return stats, true, nil
	}

	stats, err = p.getStatsFromAPI(ctx, date)
	if err != nil {
		return daylightStats{}, false, fmt.Errorf("failed to get stats: %w", err)
	}

	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		if err := p.updateStatsInCache(ctx, date, stats); err != nil {
			log.Printf("failed to update cache: %s", err.Error())
		}
	}()

	return stats, false, nil
}

func (p *daylightChecker) getStatsFromCache(ctx context.Context, date time.Time) (stats daylightStats, hit bool, err error) {
	field := date.Format("2006-01-02")

	value, err := p.redisClient.HGet(ctx, p.redisKey, field).Bytes()
	if err != nil {
		if err == redis.Nil {
			return daylightStats{}, false, nil
		}
		return daylightStats{}, false, fmt.Errorf("HGET failed: %w", err)
	}

	if err := json.Unmarshal(value, &stats); err != nil {
		return daylightStats{}, false, fmt.Errorf("failed to parse cached stats: %w", err)
	}

	return stats, true, nil
}

func (p *daylightChecker) updateStatsInCache(ctx context.Context, date time.Time, stats daylightStats) error {
	field := date.Format("2006-01-02")

	value, err := json.Marshal(stats)
	if err != nil {
		return fmt.Errorf("could not encode stats as JSON: %w", err)
	}

	if err := p.redisClient.HSet(ctx, p.redisKey, field, value).Err(); err != nil {
		return fmt.Errorf("HSET failed: %w", err)
	}

	return nil
}

func (p *daylightChecker) getStatsFromAPI(ctx context.Context, date time.Time) (daylightStats, error) {
	// 1 Rue de Saint-Pétersbourg, 75008 Paris, France
	latitude, longitude := "48.88033660373026", "2.3231320408128355"

	if date.Before(p.dateOfMove) {
		// 48 Boulevard des Batignolles, 75017 Paris, France
		latitude, longitude = "48.88286820649658", "2.322312811515771"
	}

	// In practice, the sunrise-sunset.org API has implemented an agressive rate limiting
	// Therefore, we mock the request, and instead return a static response.

	url := fmt.Sprintf(
		// echo API hosted on a raspberry pi @dixneuf19
		"https://echo.dixneuf19.me/json?lat=%s&lng=%s&date=%s&formatted=0",
		latitude,
		longitude,
		date.Format("2006-01-02"),
	)

	req, err := http.NewRequestWithContext(ctx, "GET", url, nil)
	if err != nil {
		return daylightStats{}, fmt.Errorf("error preparing request: %w", err)
	}

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return daylightStats{}, fmt.Errorf("failed to contact sunrise-sunset.org: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return daylightStats{}, fmt.Errorf("sunrise-sunset.org responded with a status of %q", resp.Status)
	}

	// ignore body
	_, err = io.ReadAll(resp.Body)
	if err != nil {
		return daylightStats{}, fmt.Errorf("failed to read response from sunrise-sunset.org: %w", err)
	}

	// static response from 2021-04-22
	body := []byte("{\"results\":{\"sunrise\":\"2021-04-22T04:43:53+00:00\",\"sunset\":\"2021-04-22T18:54:27+00:00\",\"solar_noon\":\"2021-04-22T11:49:10+00:00\",\"day_length\":51034,\"civil_twilight_begin\":\"2021-04-22T04:11:22+00:00\",\"civil_twilight_end\":\"2021-04-22T19:26:58+00:00\",\"nautical_twilight_begin\":\"2021-04-22T03:28:49+00:00\",\"nautical_twilight_end\":\"2021-04-22T20:09:31+00:00\",\"astronomical_twilight_begin\":\"2021-04-22T02:40:53+00:00\",\"astronomical_twilight_end\":\"2021-04-22T20:57:28+00:00\"},\"status\":\"OK\"}")

	data := struct {
		Status  string `json:"status"`
		Results struct {
			Sunrise   string `json:"sunrise"`
			Sunset    string `json:"sunset"`
			SolarNoon string `json:"solar_noon"`
			DayLength int    `json:"day_length"`
		}
	}{}
	if err := json.Unmarshal(body, &data); err != nil {
		return daylightStats{}, fmt.Errorf("failed to parse response from sunrise-sunset.org: %w", err)
	}

	switch data.Status {
	case "OK":
	case "INVALID_REQUEST":
		return daylightStats{}, fmt.Errorf("invalid request sent to sunrise-sunset.org")
	case "INVALID_DATE":
		return daylightStats{}, fmt.Errorf("invalid date sent to sunrise-sunset.org")
	case "UNKNOWN_ERROR":
		return daylightStats{}, errors.New("an unknown error occurred on the sunrise-sunset.org server")
	default:
		return daylightStats{}, fmt.Errorf("unknown status %q in response from sunrise-sunset.org", data.Status)
	}

	var stats daylightStats

	const iso8601Layout = "2006-01-02T15:04:05-07:00"

	if stats.Sunrise, err = time.Parse(iso8601Layout, data.Results.Sunrise); err != nil {
		return daylightStats{}, fmt.Errorf("could not parse sunrise date %q: %w", data.Results.Sunrise, err)
	}
	if stats.Sunset, err = time.Parse(iso8601Layout, data.Results.Sunset); err != nil {
		return daylightStats{}, fmt.Errorf("could not parse sunset date %q: %w", data.Results.Sunset, err)
	}
	if stats.Noon, err = time.Parse(iso8601Layout, data.Results.SolarNoon); err != nil {
		return daylightStats{}, fmt.Errorf("could not parse solar noon date %q: %w", data.Results.SolarNoon, err)
	}
	stats.LengthOfDay = time.Duration(data.Results.DayLength) * time.Second

	return stats, nil
}
