package repository

import (
	"sync"

	"gorm.io/gorm"
)

type Post struct {
	Id         int64  `json:"id"`
	ParentId   int64  `json:"parent_id"`
	Content    string `json:"content"`
	CreateTime int64  `json:"create_time"`
}

type PostDao struct {
	db *gorm.DB
}

var (
	postDao  *PostDao
	postOnce sync.Once
)

// NewPostDaoInstance 保证有且仅有一个PostDao单例
func NewPostDaoInstance(db *gorm.DB) *PostDao {
	postOnce.Do(
		func() {
			postDao = &PostDao{
				db: db,
			}
		})
	return postDao
}

func (dao *PostDao) QueryPostsByParentId(parentId int64) ([]*Post, error) {
	var posts []*Post

	err := dao.db.
		Where("parent_id = ?", parentId).
		Order("create_time desc").
		Find(&posts).Error

	return posts, err
}

func (dao *PostDao) AddPost(post *Post) error {
	return dao.db.Create(post).Error
}
