package service

import (
	"server/repository"

	"gorm.io/gorm"
)

type TopicInfoService struct {
	db *gorm.DB
}

func NewTopicInfoService(db *gorm.DB) *TopicInfoService {
	return &TopicInfoService{
		db: db,
	}
}

func (d *TopicInfoService) QueryTopicIdByTitle(title string) (int64, error) {
	topicDao := repository.NewTopicDaoInstance(d.db)
	topic, err := topicDao.QueryTopicByTitle(title)
	if err != nil {
		return 0, err
	}
	return topic.Id, nil
}
