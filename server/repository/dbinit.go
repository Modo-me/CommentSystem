package repository

import (
	"fmt"
	"os"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func Init() *gorm.DB {
	host := os.Getenv("DB_HOST")
	dsn := fmt.Sprintf("user=usrnanme password=yourpasswd  host=%s port=5432 dbname=commentsDB sslmode=disable", host)
	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("Failed to connect to database")
	}

	err = db.AutoMigrate(&Topic{}, &Post{})
	if err != nil {
		panic(err)
	}
	return db

}
