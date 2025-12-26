package messaging

import (
	"context"
	"encoding/json"
	"log"
	"pushtaka/services/book/internal/domain"

	amqp "github.com/rabbitmq/amqp091-go"
)

type StockUpdateMessage struct {
	BookID   uint   `json:"book_id"`
	Action   string `json:"action"` // "borrow" or "return"
	Quantity int    `json:"quantity"`
}

func StartConsumer(conn *amqp.Connection, bookRepo domain.BookRepository) {
	ch, err := conn.Channel()
	if err != nil {
		log.Fatal(err)
	}
	defer ch.Close()

	q, err := ch.QueueDeclare(
		"stock_updates", // name
		true,           // durable
		false,           // delete when unused
		false,           // exclusive
		false,           // no-wait
		nil,             // arguments
	)
	if err != nil {
		log.Fatal(err)
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
		log.Fatal(err)
	}

	forever := make(chan bool)

	go func() {
		for d := range msgs {
			var msg StockUpdateMessage
			if err := json.Unmarshal(d.Body, &msg); err != nil {
				log.Printf("Error decoding message: %v", err)
				continue
			}

			log.Printf("Received stock update: %+v", msg)

			// Update Stock
			// If borrow, quantity is -1. If return, +1.
			// Transaction service sends correct quantity (-1 or 1).
			
			err := bookRepo.UpdateStock(context.Background(), msg.BookID, msg.Quantity)
			if err != nil {
				log.Printf("Error updating stock: %v", err)
			}
		}
	}()

	<-forever
}
