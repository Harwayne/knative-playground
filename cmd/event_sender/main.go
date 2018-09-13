package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"strings"
	"time"
	"github.com/satori/go.uuid"
)

const (
	post = "POST"
	url = "http://localhost:11235"
)

func main() {
	time.Sleep(3 * time.Second)
	for  {
		sendRequest()
		time.Sleep(1 * time.Minute)
	}
}

func sendRequest() {
	id := uuid.Must(uuid.NewV4())
	req, err := http.NewRequest(post, url, body(id))
	if err != nil {
		log.Printf("Unable to create request: %v, %+v", id, err)
		return
	}
	req.Header = headers(id)

	client := http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		log.Printf("Unable to make request: %v, %+v", id, err)
		return
	}
	defer resp.Body.Close()
	log.Printf("Request made successfully: %v, %+v", id, resp)
}

func headers(id uuid.UUID) http.Header {
	h := http.Header{}
	h.Add("X-Playground-Unique-Id", id.String())
	return h
}

func body(id uuid.UUID) io.Reader {
	return strings.NewReader(fmt.Sprintf("{\"id\": \"%s\"}", id))
}

