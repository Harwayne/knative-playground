package main

import (
	"flag"
	"fmt"
	"github.com/satori/go.uuid"
	"go.uber.org/zap"
	"io/ioutil"
	"net/http"
	"strings"
)

func main() {
	flag.Parse()

	logger, err := zap.NewProduction()
	if err != nil {
		panic(err)
	}

	s := &http.Server{
		Addr: ":8080",
		Handler: &eventChangerHandler{
			logger: logger,
		},
		ErrorLog:     zap.NewStdLog(logger),
	}
	s.ListenAndServe()
}

type eventChangerHandler struct {
	logger *zap.Logger
}

func (e *eventChangerHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	id := uuid.Must(uuid.NewV4())

	bb, err := ioutil.ReadAll(r.Body)
	if err != nil {
		e.logger.Error("Unable to ready body.", zap.Error(err), zap.Any("id", id))
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	body := string(bb)
	nb := strings.Replace(body, "{", fmt.Sprintf("{ \"I-Have-Changed\": \"%v\",", id), 1)
	w.Write([]byte(nb))
	w.WriteHeader(http.StatusOK)
	e.logger.Error("Successfully modified event", zap.Any("id", id))
}
