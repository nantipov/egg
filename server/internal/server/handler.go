package server

import (
	"egg-server/internal/services"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func Start() {
	// todo: add heath check
	http.HandleFunc("/events", handleEvents)
	http.ListenAndServe(":8080", nil)
}

func handleEvents(w http.ResponseWriter, req *http.Request) {
	if req.Method == "GET" {
		if auth(w, req) {
			getEvent(w, req)
		}
	} else if req.Method == "POST" {
		if auth(w, req) {
			addEvent(w, req)
		}
	} else {
		w.WriteHeader(408)
	}
}

// todo: extract x-client-id and x-devide-id and check the pair exis
func auth(w http.ResponseWriter, req *http.Request) bool {
	clientId, deviceId := extractAuthData(req)
	if len(clientId) == 0 || len(deviceId) == 0 {
		w.WriteHeader(401)
		return false
	}
	return true
}

func getEvent(w http.ResponseWriter, req *http.Request) {
	event := services.GetEvent("a")
	w.WriteHeader(200)
	responseData, err := json.Marshal(event)
	if err != nil {
		w.WriteHeader(500)
		log.Printf("could not serialize output: %s\n", err.Error())
	} else {
		w.Header().Add("content-type", "application/json") // todo: constant
		fmt.Fprint(w, string(responseData))
	}
}

func addEvent(w http.ResponseWriter, req *http.Request) {
	var event services.Event
	err := json.NewDecoder(req.Body).Decode(&event)
	if err != nil {
		w.WriteHeader(400)
		fmt.Fprintf(w, "Could not read request: %s", err.Error())
	} else {
		clientId, _ := extractAuthData(req)
		err = services.AddInputEvent(clientId, event)
		if err != nil {
			log.Printf("could not accept event: %s\n", err.Error())
			w.WriteHeader(500)
		} else {
			w.WriteHeader(202)
		}
	}
}

func extractAuthData(req *http.Request) (string, string) {
	clientId := req.Header.Get("x-client-id")
	deviceId := req.Header.Get("x-device-id")
	return clientId, deviceId
}
