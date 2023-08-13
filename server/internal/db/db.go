package db

import (
	"database/sql"
	"egg-server/internal/settings"
	"fmt"
	"log"

	_ "github.com/lib/pq"

	"github.com/golang-migrate/migrate/v4"
	migratepostgres "github.com/golang-migrate/migrate/v4/database/postgres"
	_ "github.com/golang-migrate/migrate/v4/source/file"
)

func GetConnection() (*sql.DB, error) {
	//  psqlInfo := fmt.Sprintf("host=%s port=%d user=%s "+
	// "password=%s dbname=%s sslmode=disable",
	// host, port, user, password, dbname)
	settings := settings.GetSettings()
	db, err := sql.Open(
		"postgres",
		fmt.Sprintf(
			"host=%s user=%s password=%s dbname=%s sslmode=%s",
			settings.DbHostname, settings.DbUsername,
			settings.DbPassword, settings.DbName, settings.DbSSLEnabled,
		),
	)
	if err != nil {
		return nil, err
	}
	err = db.Ping()

	if err != nil && db != nil {
		db.Close()
	}

	return db, err
}

func ApplyMigrations() {
	db, err := GetConnection()
	HandleDbError(err)
	driver, err := migratepostgres.WithInstance(db, &migratepostgres.Config{})
	if err != nil {
		log.Fatalf("could not apply database migration: %s", err.Error())
	}
	settings := settings.GetSettings()
	m, err := migrate.NewWithDatabaseInstance(settings.DbMigrationsPath, "postgres", driver)

	if err != nil {
		log.Fatalf("could not apply database migration: %s", err.Error())
	}

	err = m.Up() // todo check if migration is not necessary (no change)

	if err != nil {
		log.Fatalf("could not apply database migration: %s", err.Error())
	}
}

func HandleDbError(err error) {
	if err != nil {
		log.Fatalf("could not connect to database: %s", err.Error())
	}
}
