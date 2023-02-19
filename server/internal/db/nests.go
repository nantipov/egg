package db

const (
	fetchClientsStatement = `SELECT n2.client_id, n2.color
	FROM nest n1, nest n2
	WHERE
	  n1.client_id = ?
	  AND n2.client_id != n1.client_id
	  AND n2.nest_id = n1.nest_id`
)

type ClientColor struct {
	ClientId string
	Color    string
}

func GetNarrowClientIds(clientId string) ([]ClientColor, error) {
	db, err := GetConnection()
	if err != nil {
		return nil, err
	}
	defer db.Close()

	rows, err := db.Query(fetchClientsStatement)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	entities := make([]ClientColor, 0)
	for rows.Next() {
		var entity ClientColor
		rowErr := rows.Scan(&entity.ClientId, &entity.Color)
		if rowErr != nil {
			return nil, rowErr
		}
		entities = append(entities, entity)
	}
	return entities, nil
}
