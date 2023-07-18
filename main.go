package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"log"
	"time"

	"github.com/alextanhongpin/go-db/pkg/database"
	"github.com/alextanhongpin/go-db/repository"
	"github.com/lib/pq"
)

func main() {
	db, err := database.New()
	if err != nil {
		log.Fatal(err)
	}
	authrepo, err := repository.NewAuth(db)
	if err != nil {
		log.Fatal(err)
	}

	ctx := context.Background()
	{
		// Insert user if not exists.
		user, err := authrepo.UpsertEmailAccount(ctx, repository.UpsertEmailAccountParams{
			Email:    "john.doe@mail.com",
			Password: "12345678",
			Name:     "John Doe",
			Slug:     "john-doe",
		})
		if err != nil {
			log.Println(err)
		}
		log.Println("created user", user)
	}

	// Authenticate.
	user, err := authrepo.Authenticate(ctx, repository.AuthenticateParams{
		Email:    "john.doe@mail.com",
		Password: "12345678",
	})
	if err != nil {
		log.Fatal(err)
	}
	log.Println(user)

	done := make(chan bool)
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	// Run a loop every 5 seconds to request confirmation token.
	// We do this to trigger the LISTEN/NOTIFY event.
	go func() {
		for {
			select {
			case <-done:
				return
			case <-ticker.C:
				confirmationToken, err := authrepo.RequestConfirmation(ctx, "john.doe@mail.com")
				if err != nil {
					log.Fatal(err)
				}
				log.Println("got confirmation token", confirmationToken)

			}
		}
	}()

	// Setup Postgres LISTEN/NOTIFY.
	// https://godoc.org/github.com/lib/pq/example/listen
	cfg, err := database.NewConfig()
	if err != nil {
		log.Fatal(err)
	}

	dsn := cfg.String()
	reportProblem := func(ev pq.ListenerEventType, err error) {
		if err != nil {
			fmt.Println(err.Error())
		}
	}

	minReconn := 10 * time.Second
	maxReconn := time.Minute
	listener := pq.NewListener(dsn, minReconn, maxReconn, reportProblem)

	// For every events that we choose to listen to, specify the channels.
	err = listener.Listen("confirmation_requested")
	if err != nil {
		panic(err)
	}

	err = listener.Listen("reset_password_requested")
	if err != nil {
		panic(err)
	}

	fmt.Println("entering main loop")
	for {
		// Process all available work before waiting for notifications.
		// getWork(db)
		waitForNotification(listener)
	}
	close(done)
}

func waitForNotification(l *pq.Listener) {
	select {
	case n := <-l.Notify:
		fmt.Println("received data from channel:", n.Channel)
		var prettyJSON bytes.Buffer
		err := json.Indent(&prettyJSON, []byte(n.Extra), "", "\t")
		if err != nil {
			fmt.Println("error processing json", err)
			return
		}
		fmt.Println(string(prettyJSON.Bytes()))
		return
	case <-time.After(90 * time.Second):
		fmt.Println("received no events for 90 seconds, checking connection")
		go l.Ping()
		return
	}
}
