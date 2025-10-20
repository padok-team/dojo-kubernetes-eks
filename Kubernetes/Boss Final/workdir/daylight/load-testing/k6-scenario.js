import http from 'k6/http';
import { check } from 'k6';

export let options = {
    stages: [
        { duration: '30s', target: 100 },
        { duration: '4m', target: 200 },
        { duration: '30s', target: 0 },
    ],
    // scenarios: {
    //     constant_request_rate: {
    //         executor: 'constant-arrival-rate',
    //         rate: 500,
    //         timeUnit: '1s', // 500 req/s
    //         duration: '10m',
    //         preAllocatedVUs: 1, // how large the initial pool of VUs would be
    //         maxVUs: 1000, // if the preAllocatedVUs are not enough, we can initialize more
    //     },
    // },
};

export default function () {

    let res = http.get(
        'http://daylight.arthurb.k8s.university.padok.cloud/stats',
        null,
        null,
    );
    check(res, { 'status was 200': (r) => r.status == 200 });
}
