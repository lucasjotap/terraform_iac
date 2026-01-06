package main

import (
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func TestMetricsEndpoint(t *testing.T) {
	// Create a new ServeMux and register your handlers
	mux := http.NewServeMux()
	mux.HandleFunc("/health", healthCheckHandler)
	mux.HandleFunc("/api/v1/data", dataHandler)
	mux.Handle("/metrics", promhttp.Handler())

	// Create a new test server
	ts := httptest.NewServer(metricsMiddleware(mux))
	defer ts.Close()

	// Make a request to the /metrics endpoint
	resp, err := http.Get(ts.URL + "/metrics")
	if err != nil {
		t.Fatalf("Failed to make request to /metrics endpoint: %v", err)
	}
	defer resp.Body.Close()

	// Check if the status code is 200 OK
	if resp.StatusCode != http.StatusOK {
		t.Errorf("Expected status code %d, but got %d", http.StatusOK, resp.StatusCode)
	}

	// Check if the response body contains the http_requests_total metric
	body := new(strings.Builder)
	_, err = io.Copy(body, resp.Body)
	if err != nil {
		t.Fatalf("Failed to read response body: %v", err)
	}

	if !strings.Contains(body.String(), "http_requests_total") {
		t.Errorf("Expected response body to contain 'http_requests_total', but it didn't")
	}
}
