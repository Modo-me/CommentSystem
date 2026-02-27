package main

import (
	"server/handler"
	"server/repository"
	"server/service"

	"github.com/gin-gonic/gin"
)

func main() {
	db := repository.Init()
	PageService := service.NewPageInfoService(db)
	PageHandler := handler.NewPageHandler(PageService)
	TopicService := service.NewTopicInfoService(db)
	TopicHandler := handler.NewTopicHandler(TopicService)
	r := gin.Default()
	r.GET("/community/page/get/:id", func(c *gin.Context) {
		topicId := c.Param("id")
		data := PageHandler.QueryPageInfo(topicId)
		c.JSON(200, data)
	})
	r.GET("/community/page/queryid", func(c *gin.Context) {
		title := c.Query("title")
		data := TopicHandler.QueryTopicId(title)
		c.JSON(200, data)
	})
	err := r.Run()
	if err != nil {
		return
	}

}
