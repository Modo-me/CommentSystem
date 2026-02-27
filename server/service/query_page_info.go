package service

import (
	"errors"
	"server/repository"
	"sync"

	"gorm.io/gorm"
)

type PageInfoService struct {
	db *gorm.DB
}

func NewPageInfoService(db *gorm.DB) *PageInfoService {
	return &PageInfoService{
		db: db,
	}
}

type PageInfo struct {
	Topic    *repository.Topic
	PostList []*repository.Post
}

func (s *PageInfoService) QueryPageInfo(topicId int64) (*PageInfo, error) {
	return NewQueryPageInfoFlow(topicId, s.db).Do()
}

func NewQueryPageInfoFlow(topId int64, db *gorm.DB) *QueryPageInfoFlow {
	return &QueryPageInfoFlow{
		topicId: topId,
		db:      db,
	}
}

type QueryPageInfoFlow struct {
	topicId  int64
	pageInfo *PageInfo
	topic    *repository.Topic
	posts    []*repository.Post
	db       *gorm.DB
}

func (f *QueryPageInfoFlow) Do() (*PageInfo, error) {
	if err := f.checkParam(); err != nil {
		return nil, err
	}
	if err := f.prepareInfo(); err != nil {
		return nil, err
	}
	if err := f.packPageInfo(); err != nil {
		return nil, err
	}
	return f.pageInfo, nil
}

func (f *QueryPageInfoFlow) checkParam() error {
	if f.topicId <= 0 {
		return errors.New("topic id must be larger than 0")
	}
	return nil
}

// 给结构体添加对应的topic和post信息
func (f *QueryPageInfoFlow) prepareInfo() error {
	//获取topic信息
	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		topic, err := repository.NewTopicDaoInstance(f.db).QueryTopicById(f.topicId)
		if err != nil {
			return
		}
		f.topic = topic
	}()
	//获取post列表
	go func() {
		defer wg.Done()
		posts, err := repository.NewPostDaoInstance(f.db).QueryPostsByParentId(f.topicId)
		if err != nil {
			return
		}
		f.posts = posts
	}()
	wg.Wait()
	return nil
}

// 打包内部结构体成返回结构体
func (f *QueryPageInfoFlow) packPageInfo() error {
	f.pageInfo = &PageInfo{
		Topic:    f.topic,
		PostList: f.posts,
	}
	return nil
}
