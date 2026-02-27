package handler

import (
	"server/service"
	"strconv"
)

type PageHandler struct {
	pageService *service.PageInfoService
}

func NewPageHandler(pageService *service.PageInfoService) *PageHandler {
	return &PageHandler{
		pageService: pageService,
	}
}

type PageData struct {
	Code int64       `json:"code"`
	Msg  string      `json:"msg"`
	Data interface{} `json:"data"`
}

func (h *PageHandler) QueryPageInfo(topicIdStr string) *PageData {
	topicId, err := strconv.ParseInt(topicIdStr, 10, 64)
	if err != nil {
		return &PageData{
			Code: -1,
			Msg:  err.Error(),
		}
	}

	pageInfo, err := h.pageService.QueryPageInfo(topicId)
	if err != nil {
		return &PageData{
			Code: -1,
			Msg:  err.Error(),
		}
	}
	return &PageData{
		Code: 0,
		Msg:  "success",
		Data: pageInfo,
	}

}
