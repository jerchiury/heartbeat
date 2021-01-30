
source('helper.R')

data=read.csv('testshort.csv')

shinyServer(function(input, output) {
  output$ecg=renderPlot({ecgplot(input$beat)})
  output$explain=renderUI({
    str1='NN denotes the neural network trained with unbalanced data'
    str2='BNN denotes the neural network trained with down-sampled balanced data'
    str3='Forest denotes the random forest trained with down-sampled balanced data'
    str4='Class denotes the class the cardiologists labeled'
    HTML(paste(str1, str2, str3, str4,'','', sep = '<br/>'))})
  output$result=renderTable({resulttable(input$beat)})
})

