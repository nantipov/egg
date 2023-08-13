package services

import "egg-server/internal/db"

type Event struct {
	EventType string
}

func GetNextOutputEvent(clientId string) (*Event, error) {
	eventEntity, err := db.GetNextOutputEvent(clientId)
	if err != nil {
		return nil, err
	}
	if eventEntity != nil {
		event := &Event{
			EventType: eventEntity.EventType, //todo all fields
		}
		return event, nil
	} else {
		return nil, nil
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
