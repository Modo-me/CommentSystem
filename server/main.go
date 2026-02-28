package main

import (
	"net/http"
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
	PostService := service.NewPostService(db)
	PostHandler := handler.NewPostHandler(PostService)
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
	r.POST("/community/page/addpost", func(c *gin.Context) {
		var newPost repository.Post
		if err := c.BindJSON(&newPost); err != nil {
			return
		}
		err := PostHandler.AddPost(&newPost)
		if err != nil {
			return
		}
		c.IndentedJSON(http.StatusCreated, newPost)
	})

	r.POST("/community/page/addtopic", func(c *gin.Context) {
		var newTopic repository.Topic
		if err := c.BindJSON(&newTopic); err != nil {
			return
		}
		err := PostHandler.AddTopic(&newTopic)
		if err != nil {
			return
		}
		c.IndentedJSON(http.StatusCreated, newTopic)
	})
	err := r.Run()
	if err != nil {
		return
	}

}
