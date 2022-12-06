library(shiny)
library(tidyverse)
library(ggplot2)

iris_categories <- colnames(dplyr::select(iris, -Species))


ui <- fluidPage(
  titlePanel("Shiny with tidyverse"),
  sidebarLayout(
    sidebarPanel(
      selectInput(inputId = "x_attribute",
                  label   = "select attribute for x axis",
                  choices = iris_categories),
      selectInput(inputId  = "y_attribute",
                  label    = "select attribute for y axis",
                  choices  = iris_categories,
                  selected = iris_categories[2])
    ),
    mainPanel(
      plotOutput("ggplotPlot")
    )
  )
)

server <- function(input, output) {



  output$ggplotPlot <- renderPlot({

    iris %>%
      ggplot(aes(x = .data[[input$x_attribute]],
                 y = .data[[input$y_attribute]])) +
      geom_point()
})
}

shinyApp(ui, server)
