package main

import (
	"egg-server/internal/db"
	"egg-server/internal/server"
	"egg-server/internal/services"
)

func main() {
	db.ApplyMigrations()
	services.ScheduleEventsDuty()
	server.Start()
}
