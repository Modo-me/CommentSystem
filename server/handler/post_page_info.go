package handler

import (
	"server/repository"
	"server/service"
)

type PostHandler struct {
	postService *service.PostService
}

func NewPostHandler(postService *service.PostService) *PostHandler {
	return &PostHandler{
		postService: postService,
	}
}

func (h *PostHandler) AddPost(post *repository.Post) error {
	err := h.postService.AddPost(post)
	return err
}

func (h *PostHandler) AddTopic(topic *repository.Topic) error {
	err := h.postService.AddTopic(topic)
	return err
}
