library(ggplot2)
library(stats)
library(randomForest)
library(keras)
library(shiny)

data=read.csv('testshort.csv')
NNmodel=load_model_hdf5('neuralnet.h5')
BNNmodel=load_model_hdf5('balneuralnet.h5')
forestmodel=readRDS('forestmodel.rds')

ecgplot=function(n){ggplot()+
    geom_line(aes(x=1:187,y=as.matrix(data)[n,1:187]),color='Red')+
    xlab('')+
    ylab('')}

nnpred=function(n){predict_classes(NNmodel,as.matrix(data[n,1:187]))}
bnnpred=function(n){predict_classes(BNNmodel,as.matrix(data[n,1:187]))}
forestpred=function(n){as.numeric(predict(forestmodel,as.matrix(data[n,1:187])))-1}
classes=c('Normal beat','Ectopic beat','Premature ventricular contraction',
              'Fusion of ventricular and normal beat','Unclassifiable')
classname=function(n){return(classes[n+1])}
resulttable=function(n){
  result=matrix(nrow=1, ncol=4, 0)
  result=as.data.frame(result)
  colnames(result)=c('NN','BNN','Forest','Class')
  result[,1]=classname(nnpred(n))
  result[,2]=classname(bnnpred(n))
  result[,3]=classname(forestpred(n))
  result[,4]=classname(data$class[n])
  
  return(result)
  }
