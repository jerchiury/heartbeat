library(shiny)
library(rsconnect)

data=read.csv('testshort.csv')

shinyUI(fluidPage(
  titlePanel("Heart Beat Categorization"),
  sidebarLayout(
    sidebarPanel(
           numericInput("beat", label = h4("Choose a heart beat"), value=1,min=1,max=nrow(data))
    ),
    mainPanel(
      plotOutput("ecg", width= "100%"),
      htmlOutput('explain'),
      tableOutput("result")
  )
)))