package services

import "egg-server/internal/db"

type Event struct {
	EventType string
}

func GetEvent(clientId string) *Event {
	db.GetEvents(clientId)

	return &Event{
		EventType: "Hey",
	}
}

func AddInputEvent(clientId string, event Event) error {
	eventEntity := db.EventEntity{
		EventType: event.EventType,
		ClientId:  clientId,
		IsInput:   true,
	}
	err := db.AddEvent(eventEntity)
	return err
}
