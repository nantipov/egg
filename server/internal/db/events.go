package db

const (
	insertEventStatement                     = "INSERT INTO client_event (event_type, client_id, is_input, color) VALUES (?, ?, ?, ?)"
	updateProcessedEventStatement            = "UPDATE client_event SET is_processed = true WHERE id = ?"
	fetchUnprocessedInputEventsStatement     = "SELECT id, event_type, client_id, color, is_input FROM client_event WHERE is_input AND NOT is_processed"
	fetchNextUnprocessedOutputEventStatement = "SELECT id, event_type, client_id, color, is_input FROM client_event WHERE client_id = ? AND NOT is_input AND NOT is_processed LIMIT 1"
)

type EventEntity struct {
	Id        int64
	EventType string
	ClientId  string
	Color     string
	IsInput   bool
}

func GetUnprocessedInputEvents() ([]EventEntity, error) {
	db, err := GetConnection()
	if err != nil {
		return nil, err
	}
	defer db.Close()

	rows, err := db.Query(fetchUnprocessedInputEventsStatement)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	entities := make([]EventEntity, 0)
	for rows.Next() {
		var entity EventEntity
		rowErr := rows.Scan(&entity.Id, &entity.EventType, &entity.ClientId, &entity.Color, &entity.IsInput)
		if rowErr != nil {
			return nil, rowErr
		}
		entities = append(entities, entity)
	}
	return entities, nil
}

func GetNextOutputEvent(clientId string) (*EventEntity, error) {
	db, err := GetConnection()
	if err != nil {
		return nil, err
	}
	defer db.Close()

	rows, err := db.Query(fetchNextUnprocessedOutputEventStatement, clientId)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	if rows.Next() {
		var entity EventEntity
		rowErr := rows.Scan(&entity.Id, &entity.EventType, &entity.ClientId, &entity.Color, &entity.IsInput)
		if rowErr != nil {
			return nil, rowErr
		}
		return &entity, nil
	} else {
		return nil, nil
	}
}

func AddEvent(eventEntity EventEntity) error {
	db, err := GetConnection()
	if err != nil {
		return err
	}
	defer db.Close()
	_, err = db.Exec(insertEventStatement, eventEntity.EventType, eventEntity.ClientId, eventEntity.Color)
	return err
}

func MarkEventProcessed(id int64) error {
	db, err := GetConnection()
	if err != nil {
		return err
	}
	defer db.Close()
	_, err = db.Exec(updateProcessedEventStatement, id)
	return err
}
