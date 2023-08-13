package services

import (
	"egg-server/internal/db"
	"log"
)

func ScheduleEventsDuty() {

}

func duty() {
	events, err := db.GetUnprocessedInputEvents()
	if err != nil {
		log.Printf("could not process events in duty: %s\n", err.Error())
		return
	}

	for _, event := range events {
		narrowClients, eventErr := db.GetNarrowClientIds(event.ClientId)

		if eventErr != nil {
			log.Printf("could not create output event from client: %s: %s\n", event.ClientId, err.Error())
		}

		for _, client := range narrowClients {
			outputEvent := db.EventEntity{
				Id:        -1,
				EventType: event.EventType, //todo: filter by event type? do we really have different types? fetch it from database.
				ClientId:  event.Color,
				Color:     client.Color,
				IsInput:   false,
			}
			addEventErr := db.AddEvent(outputEvent) //todo: transaction for error handling?
			if addEventErr != nil {
				log.Printf("could not add output event from client %s to client %s: %s\n", event.ClientId, client.ClientId, err.Error())
			}
		}
		db.MarkEventProcessed(event.Id) //todo: transaction for error handling?
	}
}
