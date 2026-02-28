package service

import (
	"server/repository"

	"gorm.io/gorm"
)

type PostService struct {
	db *gorm.DB
}

func NewPostService(db *gorm.DB) *PostService {
	return &PostService{db: db}
}

func (f *PostService) AddPost(post *repository.Post) error {
	err := repository.NewPostDaoInstance(f.db).AddPost(post)
	return err
}

func (f *PostService) AddTopic(topic *repository.Topic) error {
	err := repository.NewTopicDaoInstance(f.db).AddTopic(topic)
	return err
}
