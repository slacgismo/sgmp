package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

type ResponseMessage struct {
	Status  string `json:"status"`
	Message string `json:"message,omitempty"`
}

func writeResponse(w http.ResponseWriter, resp *ResponseMessage) {
	jsonBytes, err := json.Marshal(resp)
	if err != nil {
		log.Printf("Failed to serialize response: %s\n", err)
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Write(jsonBytes)
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("Home handler")
	resp := ResponseMessage{
		Status:  "ok",
		Message: "hello world",
	}
	writeResponse(w, &resp)
}

func ingestHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("Ingest handler")
	resp := ResponseMessage{
		Status:  "ok",
		Message: "hello world",
	}
	writeResponse(w, &resp)
}

func main() {
	listenAddr := os.Getenv("LISTEN_ADDR")
	if len(listenAddr) == 0 {
		listenAddr = ":80"
	}
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/ingest", ingestHandler)
	log.Fatal(http.ListenAndServe(listenAddr, nil))
}
