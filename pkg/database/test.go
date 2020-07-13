package database

//import (
//"database/sql"
//"fmt"
//"log"
//"strconv"
//"time"

//"github.com/DATA-DOG/go-txdb"
//"github.com/ory/dockertest/v3"
//)

//// NewTestDB returns a new test db with a unique connection string.
//func NewTestDB() (*sql.DB, error) {
//return sql.Open("txdb", fmt.Sprintf("tx-%d", time.Now().UnixNano()))
//}

//// SetupTestDB setups a dockertest postgres container.
//func SetupTestDB() (*sql.DB, func()) {
//var db *sql.DB
//// uses a sensible default on windows (tcp/http) and linux/osx (socket)
//pool, err := dockertest.NewPool("")
//if err != nil {
//log.Fatalf("Could not connect to docker: %s", err)
//}

//// pulls an image, creates a container based on it and runs it
//resource, err := pool.Run("postgres", "12.2-alpine", []string{
//"POSTGRES_DB=test",
//"POSTGRES_PASSWORD=secret",
//"POSTGRES_USER=root",
//})
//if err != nil {
//log.Fatalf("Could not start resource: %s", err)
//}

//// Hard kill the container in 60 seconds.
//_ = resource.Expire(60)

//var cfg Config
//// exponential backoff-retry, because the application in the container might not be ready to accept connections yet
//if err := pool.Retry(func() error {
//port, err := strconv.Atoi(resource.GetPort("5432/tcp"))
//if err != nil {
//return err
//}
//cfg = Config{
//Password: "secret",
//User:     "root",
//Database: "test",
//Host:     "localhost",
//Port:     port,
//}

//db, err = sql.Open("postgres", cfg.String())
//if err != nil {
//return err
//}

//return db.Ping()
//}); err != nil {
//log.Fatalf("Could not connect to docker: %s", err)
//}

//if err := Migrate(db); err != nil {
//log.Fatalf("test migration failed: %v", err)
//}

//txdb.Register("txdb", "postgres", cfg.String())

//return db, func() {
//if err := db.Close(); err != nil {
//log.Printf("Could not close db: %s", err)
//}
//// You can't defer this because os.Exit doesn't care for defer
//if err := pool.Purge(resource); err != nil {
//log.Fatalf("Could not purge resource: %s", err)
//}
//}
//}
