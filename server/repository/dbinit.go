package repository

import (
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func Init() *gorm.DB {
	dsn := "host=127.0.0.1 user=caim password=123456 dbname=commentsDB port=5432 sslmode=disable"
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
