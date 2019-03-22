package main

import (
	"flag"
	"fmt"
	"github.com/satori/go.uuid"
	"go.uber.org/zap"
	"io/ioutil"
	"log"
	"net/http"
	"strings"
	"go.opencensus.io/plugin/ochttp"
	"go.opencensus.io/plugin/ochttp/propagation/b3"
)

// Copied from MessageReceiver.
var forwardHeaders = []string{
	"content-type",
	// tracing
	"x-request-id",
}

var forwardPrefixes = []string{
	// knative
	"knative-",
	// cloud events
	"ce-",
	// tracing
	"x-b3-",
	"x-ot-",
}

func main() {
	flag.Parse()

	logger, err := zap.NewProduction()
	if err != nil {
		panic(err)
	}

	h := &ochttp.Handler{
		Propagation: &b3.HTTPFormat{},
		Handler: &eventMutatorHandler{
			logger: logger,
		},
	}
	s := &http.Server{
		Addr: ":8080",
		Handler: h,
		ErrorLog:     zap.NewStdLog(logger),
	}
	s.ListenAndServe()
}

type eventMutatorHandler struct {
	logger *zap.Logger
}

func (e *eventMutatorHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h := fromHTTPHeaders(r.Header)
	h["Ce-Eventtype"] = "mutated"
	for n, v := range h {
		w.Header()[n] = []string{v}
		log.Printf("%v: %v", n, v)
	}

	id := uuid.NewV4()

	bb, err := ioutil.ReadAll(r.Body)
	if err != nil {
		e.logger.Error("Unable to ready body.", zap.Error(err), zap.Any("id", id))
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	body := string(bb)
	nb := strings.Replace(body, "{", fmt.Sprintf("{ \"I-Have-Mutated\": \"%v\",", id), 1)
	n, err := w.Write([]byte(nb))
	if err != nil {
		e.logger.Info("Write failed", zap.Error(err))
		return
	}
	e.logger.Info("Successfully mutated event", zap.Any("id", id), zap.Int("n", n), zap.Any("w", w))
}

func fromHTTPHeaders(headers http.Header) map[string]string {
	safe := map[string]string{}

	// TODO handle multi-value headers
	for h, v := range headers {
		// Headers are case-insensitive but test case are all lower-case
		comparable := strings.ToLower(h)
		for _, allowed := range forwardHeaders {
			if comparable == allowed {
				safe[h] = v[0]
				continue
			}
		}
		for _, p := range forwardPrefixes {
			if strings.HasPrefix(comparable, p) {
				safe[h] = v[0]
				break
			}
		}
	}

	return safe
}
