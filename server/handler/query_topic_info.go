package handler

import "server/service"

type QueryData struct {
	Code int64  `json:"code"`
	Msg  string `json:"msg"`
	Id   int64  `json:"id"`
}

type TopicHandler struct {
	topicService *service.TopicInfoService
}

func NewTopicHandler(topicService *service.TopicInfoService) *TopicHandler {
	return &TopicHandler{
		topicService: topicService,
	}
}

func (h *TopicHandler) QueryTopicId(title string) *QueryData {
	topicId, err := h.topicService.QueryTopicIdByTitle(title)
	if err != nil {
		return &QueryData{
			Code: -1,
			Msg:  err.Error(),
		}
	}
	return &QueryData{
		Code: 0,
		Msg:  "success",
		Id:   topicId,
	}
}
