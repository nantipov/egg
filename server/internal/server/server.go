package server

import (
	"net/http"
)

func Start() {
	// todo: add heath check
	http.HandleFunc("/events", handleEvents)
	http.ListenAndServe(":8080", nil)
}

// todo: extract x-client-id and x-devide-id and check if the pair exis
func auth(w http.ResponseWriter, req *http.Request) bool {
	clientId, deviceId := extractAuthData(req)
	if len(clientId) == 0 || len(deviceId) == 0 {
		w.WriteHeader(401)
		return false
	}
	return true
}

func extractAuthData(req *http.Request) (string, string) {
	clientId := req.Header.Get("x-client-id")
	deviceId := req.Header.Get("x-device-id")
	return clientId, deviceId
}
