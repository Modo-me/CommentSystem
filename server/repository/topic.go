package repository

import (
	"sync"

	"gorm.io/gorm"
)

type Topic struct {
	Id         int64  `json:"id"`
	Title      string `json:"title"`
	Content    string `json:"content"`
	CreateTime int64  `json:"create_time"`
}

var (
	topicDao  *TopicDao
	topicOnce sync.Once
)

type TopicDao struct {
	db *gorm.DB
}

func NewTopicDaoInstance(db *gorm.DB) *TopicDao {
	topicOnce.Do(
		func() {
			topicDao = &TopicDao{
				db: db,
			}
		})
	return topicDao
}

func (dao *TopicDao) QueryTopicByTitle(title string) (*Topic, error) {
	var topic Topic
	err := dao.db.
		Where("title = ?", title).
		First(&topic).Error

	return &topic, err
}

func (dao *TopicDao) QueryTopicById(id int64) (*Topic, error) {
	var topic Topic
	err := dao.db.
		Where("id = ?", id).
		First(&topic).Error

	return &topic, err
}

func (dao *TopicDao) AddTopic(topic *Topic) error {
	err := dao.db.Create(topic).Error
	return err
}
