library(party)
library(randomForest)
library(caret)
library(keras)
library(ggplot2)
library(stats)

setwd('C:\\Users\\Jerry\\Desktop\\Jerry\\Course\\Course 5\\project 3')

################## data from https://www.kaggle.com/shayanfazeli/heartbeat
data=read.csv('mitbih_train.csv', header = F, col.names = c(1L:187L,'class'))
test=read.csv('mitbih_test.csv', header = F, col.names = c(1L:187L,'class'))

################### last column of data is the class of the ecg as annotated by 2 doctors 
################ classes are N:normal, S:ectopic beat, V:Premature ventricular contraction 
###############  F:Fusion of ventricular and normal beat ,Q:unclassifiable
################### the data seems to be cleaned, but lets check it just in case
################### check for any rows with only constant value (standard deviation of 0)
set.seed(1024)
data=data[sample(1:nrow(data)),]
ecg=data[,colnames(data)!='class']
ecg[apply(ecg,1,sd)==0,] ## there isn't any

test=test[sample(1:nrow(test)),]
ecgtest=test[,colnames(test)!='class']
ecgtest[apply(ecgtest,1,sd)==0,] ## there isn't any

###################### checking the min and max of each row, make sure theey are between 0 and 1
nrow(ecg[apply(ecg,1,max)>1,]) #0
nrow(ecg[apply(ecg,1,min)<0,]) #0

nrow(ecgtest[apply(ecgtest,1,max)>1,]) #0
nrow(ecgtest[apply(ecgtest,1,min)<0,]) #0

##################### checking proportions of classes
prop.table(table(data$class)) ## of training data
## 0           1           2           3           4 
## 0.827729173 0.025390045 0.066107773 0.007321196 0.073451813

prop.table(table(test$class)) ## of test data
## 0           1           2           3           4 
## 0.827608259 0.025397405 0.066142883 0.007399963 0.073451489 
## balanced between test and train sets

################ deep learning
data$class=as.factor(data$class)
test$class=as.factor(test$class)

model=keras_model_sequential()%>%
  layer_dense(units = 256, activation = 'relu', input_shape = c(187), trainable = T) %>% 
  layer_dropout(rate = 0.4) %>% 
  layer_dense(units = 256, activation = 'relu',trainable = T) %>%
  layer_dropout(rate = 0.4) %>%
  layer_dense(units = 256, activation = 'relu',trainable = T) %>%
  layer_dropout(rate = 0.4) %>%
  layer_dense(units = 5, activation = 'softmax')

model %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_adam(),
  metrics = c('accuracy'))

ecg=as.matrix(ecg)
trainclass=to_categorical(data$class,5)
progress <- fit(
  model,
  ecg, trainclass, 
  epochs = 15, batch_size = 128, 
  validation_split = 0.3
)

ecgtest=as.matrix(ecgtest)
testclass=to_categorical(test$class,5)
evaluate(model,ecgtest,testclass)

pred=predict_classes(model,ecgtest)
table(test$class,pred)

save_model_hdf5(model, 'neuralnet.h5')

######################### time series clustering
Dist=dist(ecg[1:1000,], method="DTW")

####################### classification
data$class=as.factor(data$class)
tree=ctree(class~., data=data, controls = ctree_control(minsplit = 20,minbucket = 5, maxdepth = 5))
pred=predict(tree,test)
res=test
res['pred']=pred
table(res$pred,res$class)

## under sampling the data, make class 0 to 7% of the entire set
sampleN=data[sample(which(data$class==0),floor(nrow(data)*0.07)),]
sampleNtest=test[sample(which(test$class==0),floor(nrow(test)*0.07)),]
baldata=rbind(sampleN,data[which(data$class!=0),])
baldata=baldata[1:(nrow(baldata)/2),]
baltest=rbind(sampleNtest,test[which(test$class!=0),])
forest=randomForest(class~., data=baldata)
pred=predict(forest,test)
res['fpred']=pred
table(res$fpred,res$class)

saveRDS(forest,file='forestmodel.rds')

testshort=test[1:(nrow(test)/4),]
write.csv(testshort,'testshort.csv',row.names = F)

################ balanced neural net
model2=keras_model_sequential()%>%
  layer_dense(units = 256, activation = 'relu', input_shape = c(187), trainable = T) %>% 
  layer_dropout(rate = 0.4) %>% 
  layer_dense(units = 256, activation = 'relu',trainable = T) %>%
  layer_dropout(rate = 0.4) %>%
  layer_dense(units = 256, activation = 'relu',trainable = T) %>%
  layer_dropout(rate = 0.4) %>%
  layer_dense(units = 5, activation = 'softmax')

model2 %>% compile(
  loss = 'categorical_crossentropy',
  optimizer = optimizer_adam(),
  metrics = c('accuracy'))


baltrainclass=to_categorical(baldata$class,5)
balecg=as.matrix(baldata[,1:187])
progress <- fit(
  model2,
  balecg, baltrainclass, 
  epochs = 30, batch_size = 128, 
  validation_split = 0.3
)

baltestclass=to_categorical(baltest$class,5)
baltest=as.matrix(baltest)
evaluate(model2,baltest[,1:187],baltestclass)

balpred=predict_classes(model2,baltest[,1:187])
table(baltest[,188],balpred)

# 0    1    2    3    4
# 0 1480   25   22    1    4
# 1  132  407   16    0    1
# 2   32    7 1392   14    3
# 3   21    0   20  120    1
# 4   21    4   13    0 1570

save_model_hdf5(model2, 'balneuralnet.h5')
