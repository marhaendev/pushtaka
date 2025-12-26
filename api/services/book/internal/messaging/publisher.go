package messaging

import (
	"encoding/json"
	"fmt"
	"log"

	amqp "github.com/rabbitmq/amqp091-go"
)

type bookPublisher struct {
	ch *amqp.Channel
}

func NewBookPublisher(ch *amqp.Channel) *bookPublisher {
	return &bookPublisher{ch: ch}
}

func (p *bookPublisher) PublishBookDeleted(bookID uint) error {
	q, err := p.ch.QueueDeclare(
		"book_deleted_queue", // name
		true,                 // durable
		false,                // delete when unused
		false,                // exclusive
		false,                // no-wait
		nil,                  // arguments
	)
	if err != nil {
		return fmt.Errorf("failed to declare queue: %v", err)
	}

	body, err := json.Marshal(map[string]uint{
		"book_id": bookID,
	})
	if err != nil {
		return fmt.Errorf("failed to marshal event: %v", err)
	}

	err = p.ch.Publish(
		"",     // exchange
		q.Name, // routing key
		false,  // mandatory
		false,  // immediate
		amqp.Publishing{
			ContentType: "application/json",
			Body:        body,
		})
	if err != nil {
		return fmt.Errorf("failed to publish message: %v", err)
	}

	log.Printf("Published BookDeleted event for book_id: %d", bookID)
	return nil
}
