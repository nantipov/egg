package settings

type Settings struct {
	DbUsername       string
	DbPassword       string
	DbHostname       string
	DbName           string
	DbMigrationsPath string
	DbSSLEnabled     string
}

func GetSettings() Settings {
	return getDefaultSettings()
}

func getDefaultSettings() Settings {
	return Settings{
		DbUsername:       "postgres",
		DbPassword:       "postgres",
		DbHostname:       "localhost",
		DbName:           "egg_local_db",
		DbMigrationsPath: "file://resources/sql",
		DbSSLEnabled:     "disable",
	}
}
