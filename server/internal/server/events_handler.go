package server

import (
	"egg-server/internal/services"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

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

func getEvent(w http.ResponseWriter, req *http.Request) {
	clientId, _ := extractAuthData(req)
	event, serviceErr := services.GetNextOutputEvent(clientId)
	if serviceErr != nil {
		w.WriteHeader(500)
		log.Printf("could not retrieve event: %s\n", serviceErr.Error())
	} else {
		responseData, err := json.Marshal(event)
		if err != nil {
			w.WriteHeader(500)
			log.Printf("could not serialize output: %s\n", err.Error())
		} else if event == nil {
			w.WriteHeader(404)
		} else {
			w.WriteHeader(200)
			w.Header().Add("content-type", "application/json") // todo: constant
			fmt.Fprint(w, string(responseData))
		}
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

func commitEvent(w http.ResponseWriter, req *http.Request) {

}
