# Prove yourself

During this exercise, you will put everything you have learned so far into practice.

You will need a Kubernetes cluster, start with building the [lab-environment with Terraform](../00-lab-environment/lab-environment). While it is deploying, you will be able to start the first tasks.

This document lists a set of acceptance criteria for each level. Once you have fulfilled all of them, have a member of the Padok University team check your work. If you did well, you get your badge!

You can use all tools availables, for example:

- help trough structured _andons_ to you colleagues, teacher, etc...
- internal resources such as the [Kubernetes Library](https://github.com/padok-team/library-kubernetes-catalog)
- external resources such as blogs, public Helm charts, etc...
- code snippets from the previous exercises

## Level 1 Acceptance Criteria

### The Daylight service is containerised

You have to login on artifact-registry before building images:

```bash
gcloud auth configure-docker \
    europe-west9-docker.pkg.dev
```

- [ ] I have a container image tagged `europe-west9-docker.pkg.dev/padok-university/container-public/<my_name>/daylight:<version>`
- [ ] I have scripts and/or a `Makefile` that enable this workflow :

  ```bash
  make build VERSION=v1.0.0  # Builds a container image
  make push VERSION=v1.0.0   # Pushes the image to a registry
  make run VERSION=v1.0.0    # Runs the container locally
  ```

- [ ] The microservice responds to requests sent to `/stats`.
- [ ] The microservice responds to requests sent to `/metrics`.

### The Daylight container image is very small

- [ ] The Daylight container image is less than 20MB in size.

### The Daylight service runs on Kubernetes

- [ ] The Daylight service is running inside the cluster.

  - [ ] I have 5 replicas of the Daylight service running in the `daylight`
        namespace.
  - [ ] A public endpoint responds to requests to the `/stats` endpoint at this URL:
        <http://daylight.YOUR_NAME.k8s.university.padok.cloud>.
  - [ ] The endpoint does not responds the the `/metrics` or `/healthz` endpoints
  - [ ] I have a script and/or `Makefile` that enable this workflow :

    ```bash
    ./scripts/deploy-daylight.sh
    ```

- [ ] Redis is running inside the cluster.

  - [ ] I have 1 master and 3 replicas.
  - [ ] I have a Helm release called `redis` in the `daylight` namespace with
        status "deployed".
  - [ ] I have a script and/or `Makefile` that enable this workflow :

    ```bash
    ./scripts/deploy-redis.sh
    ```

- [ ] The Daylight service is fully functionnal.

  - [ ] Requests to the `/stats` endpoint produce no errors in the service's
        logs.
  - [ ] Requests to the `/stats/2018-11-05` produce no errors in the service's
        logs.

### The Daylight service autoscales horizontally

- [ ] The Daylight service scales between 3 and 10 replicas.
- [ ] The Daylight service uses 0.1 CPU cores per instance on average.
- [ ] Running the Daylight load test scales the Daylight service to more than
      3 replicas.
  > You have a load-test script ready in `/daylight/load-testing/`.

### I have fine-tuned deployment topology

- [ ] Inside the Kubernetes cluster, the daylight and redis stack runs on a dedicated node pool `padok.fr/nodepool=blue`
  - [ ] All Pods in the `daylight` namespace run on this dedicated node pool.
  - [ ] No other Pods outside run on the same node pool as the Daylight service.

- [ ] The Daylight service is resilient to node failures.
  - [ ] The Daylight instances are spread out accross the cluster, in term of zones and nodes.
  - [ ] In case of a voluntary node disruption, the Daylight service has at least 50% of its replicas running.
- [ ] The Daylight service has proper resource requests and limits.
- [ ] The Redis replicas are spread out accross the cluster.
  - [ ] All Redis replicas run on different nodes.
  - [ ] All Redis replicas run in different zones.
- [ ] The Daylight service runs close to its cache.
  - [ ] Daylight instances only run on nodes with a Redis replica.

## Level 2 Acceptance Criteria

### I have a local development environment for the Daylight service

- [ ] I can use Docker Compose to manage my local environment:

  ```bash
  docker-compose up -d  # Starts the local environment
  docker-compose down   # Shuts the environment down
  ```

- [ ] I can access the Daylight service at `service.localhost`
- [ ] The Daylight service is fully functional:
  - [ ] Requests to the `/stats` endpoint produce no errors in the service's
        logs.
  - [ ] Requests to the `/stats/2018-11-05` produce no errors in the service's
        logs.
- [ ] The Daylight service reloads when I make changes to its source code.
- [ ] I can access a Prometheus UI at `prometheus.localhost`
- [ ] I can see metrics about my Redis instance in the Prometheus UI
- [ ] I can see metrics about my Daylight instance in the Prometheus UI
- [ ] I can access a Grafana UI at `grafana.localhost`
- [ ] I can see metrics about my Redis instance in the Grafana UI

### I have a Helm chart for the Daylight service

> Remember that for a Helm chart, Keep It Simple St****!

- [ ] I have a Helm release called `daylight` in the `daylight` namespace.
- [ ] All Kubernetes resources for Daylight are managed with Helm.

### Prometheus is monitoring my cluster and services

> Prometheus is a complex piece of software, don't forget that you can _andon_ or use
> other resources such as the library!

- [ ] The Prometheus operator is running inside the cluster.
- [ ] I have a Helm release called `prometheus` in the `prometheus` namespace
      with status "deployed".
- [ ] I have a script and/or `Makefile` that enable this workflow :

  ```bash
  ./scripts/deploy-prometheus.sh
  ```

- [ ] Inside the Kubernetes cluster, the Prometheus stack runs on a dedicated node pool `padok.fr/nodepool=green`
  - [ ] All Pods in the `prometheus` namespace run on this dedicated node pool.
  - [ ] No other Pods run on the same node pool as the Prometheus stack.

- [ ] I can access the Prometheus UI in my web browser at this URL:
      <http://prometheus.YOUR_NAME.k8s.university.padok.cloud>.
- [ ] I can see metrics about my Redis instances in the Prometheus UI.
- [ ] I can see metrics about my Daylight instances in the Prometheus UI.
