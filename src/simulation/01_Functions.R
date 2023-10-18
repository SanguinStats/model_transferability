createDatasets<-function(propdef=0, printresults=F){
  # function that creates three datasets: data_train, data_test, data_val
  # it returns the theoretical proportion of deferrals and the proportion of deferrals
  # in the training and test datasets (and all other settings)
  # PopMean is adapted to match propdef if this value is unequal to 0
  
  # set.seed(1)
  if(propdef!=0) { # set population mean to match the desired deferral rate
    pnorm(threshold, mean=PopMean, PopSd)
    fo<-function(x) (pnorm(threshold, mean=x, sqrt(PopSd^2+MeasSd^2))-propdef)^2
    PopMean <<- optimize(fo, c(0,2*PopMean))$minimum
    # print(threshold)
  }
  # simulate data
  true<-rnorm(n, mean=PopMean, sd=PopSd)
  meas1<-true+rnorm(n, mean=0, sd=MeasSd)
  dat<-as.data.frame(cbind(true, meas1))
  if (nr_meas>1) {
    for(i in 1:(nr_meas-1)) dat<-cbind(dat, true+rnorm(n, mean=0, MeasSd))
    dat$target<-(dat[,nr_meas+1]<threshold)*1
  } else { # only one measurement
    dat$target<-(dat$true<threshold)*1
  }
  dat$target<-as.factor(dat$target)
  colnames(dat)<-c("true", paste0("meas",1:nr_meas), "deferral")
  train<-sample(1:n, n*trainprop, replace=F)
  test<-sample((1:n)[!(1:n %in% train)], n*testprop, replace=F)
  val<-(1:n)[!(1:n %in% train) & !(1:n %in% test) ]
  data_train<<-dat[train,]
  data_test<<-dat[test,]
  data_val<<-dat[val,]
  if (printresults){
    print("Proportion deferrals")
    print(paste("theory:", pnorm(threshold, mean=PopMean, sqrt(PopSd^2+MeasSd^2))))
    print(paste("dataset overall:",sum(dat$deferral==1)/nrow(dat)))
    print(paste("ratio:",sum(dat$deferral==1)/nrow(dat)/pnorm(threshold, mean=PopMean, PopSd)))
    print("")
    print(paste("training  :", sum(data_train$deferral==1)/nrow(data_train)))
    print(paste("testing   :", sum(data_test$deferral==1)/nrow(data_test)))
    if(nrow(data_val)>0) print(paste("validation:", sum(data_val$deferral==1)/nrow(data_val)))
  } else {
    return(c(pnorm(threshold, mean=PopMean, sqrt(PopSd^2+MeasSd^2)), sum(data_train$deferral==1)/nrow(data_train),
      sum(data_test$deferral==1)/nrow(data_test) ))
  }
}

createNewTestDataset<-function(){
  # function that creates a new test dataset: data_test
  # note that it does not adapt PopMean to the propdef (as this takes time)
  # it returns the theoretical proportion of deferrals and the proportion of deferrals
  
  true<-rnorm(n*testprop, mean=PopMean, sd=PopSd)
  meas1<-true+rnorm(n*testprop, mean=0, sd=MeasSd)
  dat<-as.data.frame(cbind(true, meas1))
  if (nr_meas>1) {
    for(i in 1:(nr_meas-1)) dat<-cbind(dat, true+rnorm(n*testprop, mean=0, MeasSd))
    dat$target<-(dat[,nr_meas+1]<threshold)*1
  } else { # only one measurement
    dat$target<-(dat$true<threshold)*1
  }
  dat$target<-as.factor(dat$target)
  colnames(dat)<-c("true", paste0("meas",1:nr_meas), "deferral")
  data_test<<-dat
  # return proportion of deferrals
  #return(sum(data_test$deferral==1)/nrow(data_test))
}

analyseTrainingData<-function(){
  # fit RF model
  RFmodel <<- randomForest(deferral~meas1, data=data_train)
  # calculate AUPR
  pred_train_p = predict(RFmodel, type = "prob")
  perf_train_data = prediction(pred_train_p[,2], data_train$deferral)
  train_aucpr = performance(perf_train_data, "aucpr")
  train_auc = performance(perf_train_data, "auc")
  return(c(train_aucpr@y.values[[1]],train_auc@y.values[[1]]))
}

analyseTestData<-function(){
  # calculate AUPR
  pred_test_p = predict(RFmodel, newdata = data_test, type= "prob")
  perf_test_data = prediction(pred_test_p[,2], data_test$deferral)
  test_aucpr = performance(perf_test_data, "aucpr")
  test_auc = performance(perf_test_data, "auc")
  return(c(test_aucpr@y.values[[1]],test_auc@y.values[[1]]))
}

dosim<-function(nrsim=3){
  lp<-length(props)
  lm<-length(MeasSds)
  # define an array to store deferral rates per sample
  dsc <<-array(0,dim=c(nrsim,lp)) # training data
  dsc2<<-array(0,dim=c(nrsim,lp,lp,lm)) # test data
  # define array to store AUPR and ROC results per sample
  trdao <<-array(0,dim=c(nrsim,lp,2))  # training data
  tedao <<-array(0,dim=c(nrsim,lp,lp,lm,2)) # test data
  for (i in 1:nrsim){
    print(paste(i, "of", nrsim))
    for (j in 1:lp){ # for each level of deferral rate of donors create training dataset and model
      PopMean<<-PopMeans[j]
      MeasSd<<-MeasSds[1]
      d1 <- createDatasets(propdef=props[j])
      dsc[i,j]<<-sum(data_train$deferral==1)/nrow(data_train)
      trdao[i,j,]<<-analyseTrainingData()
      for (k in 1:lp){ # apply the trained model to a dataset for each level of deferral 
        # and level of  measurement variation
        for (l in 1:lm){
          PopMean<<-PopMeans[k,l]
          MeasSd<<-MeasSds[l]
          createNewTestDataset()
          dsc2 [i,j,k,l]<<-sum(data_test$deferral==1)/nrow(data_test)
          tedao[i,j,k,l,]<<-analyseTestData()
        }
      }
    }
  }
}
