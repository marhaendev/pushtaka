package messaging

import (
	"context"
	"encoding/json"
	"log"
	"pushtaka/services/transaction/internal/domain"

	amqp "github.com/rabbitmq/amqp091-go"
)

type Consumer struct {
	txUsecase domain.TransactionUsecase
}

func NewConsumer(txUsecase domain.TransactionUsecase) *Consumer {
	return &Consumer{txUsecase: txUsecase}
}

func (c *Consumer) Start(conn *amqp.Connection) {
	ch, err := conn.Channel()
	if err != nil {
		log.Printf("Failed to open channel: %v", err)
		return
	}
	defer ch.Close()

	q, err := ch.QueueDeclare(
		"book_deleted_queue", // name
		true,                 // durable
		false,                // delete when unused
		false,                // exclusive
		false,                // no-wait
		nil,                  // arguments
	)
	if err != nil {
		log.Printf("Failed to declare queue: %v", err)
		return
	}

	msgs, err := ch.Consume(
		q.Name, // queue
		"",     // consumer
		true,   // auto-ack
		false,  // exclusive
		false,  // no-local
		false,  // no-wait
		nil,    // args
	)
	if err != nil {
		log.Printf("Failed to register consumer: %v", err)
		return
	}

	log.Println("Waiting for book deleted messages...")

	forever := make(chan bool)

	go func() {
		for d := range msgs {
			var event map[string]uint
			if err := json.Unmarshal(d.Body, &event); err != nil {
				log.Printf("Error decoding JSON: %v", err)
				continue
			}

			bookID, ok := event["book_id"]
			if !ok {
				log.Printf("Invalid event format: missing book_id")
				continue
			}

			log.Printf("Received BookDeleted event: %d", bookID)

			// Process Cascading Soft Delete
			if err := c.txUsecase.DeleteByBookID(context.Background(), bookID); err != nil {
				log.Printf("Failed to delete transactions for book %d: %v", bookID, err)
			} else {
				log.Printf("Successfully soft-deleted transactions for book %d", bookID)
			}
		}
	}()

	<-forever
}
