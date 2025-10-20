# Load testing the Daylight service

This directory contains resources for simulating load on the Daylight service.

## Requirements

You must first [install K6](https://k6.io/docs/getting-started/installation/).

## Usage

First, edit the `k6-scenario.js` file so that it queries your service's URL.

Then, run the scenario:

```bash
k6 run k6-scenario.js
```
