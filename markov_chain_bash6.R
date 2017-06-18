#markov chain just for test users

library(foreach)
library(doParallel)
library(markovchain)

load("/home/Vera_Weidmann/Supermarket/00_Data/test_orders.rda")
load("/home/Vera_Weidmann/Supermarket/00_Data/boing.rda")
boing_test <- boing[boing$user_id %in% test_orders$user_id,]
rm(boing)
rm(test_orders)
save(boing_test, file="/home/Vera_Weidmann/Supermarket/00_Data/boing_test.rda")

#load("/home/Vera_Weidmann/Supermarket/00_Data/boing_test.rda")
num_cores <- detectCores()-10 #number of possible cores - 10, so that others can use them still
cluster <- makeCluster(num_cores) #creating cluster
registerDoParallel(cluster) #initializing cluster

#added user_id to the longdata df for use of markov chain later on
longdata_test <- foreach(row=1:nrow(boing_test), .combine=rbind) %dopar% cbind(rep(boing_test$vector1[[row]],                                                                                   each=length(boing_test$vector2[[row]])),rep(boing_test$vector2[[row]],length(boing_test$vector1[[row]])),                                                                          rep(boing_test$user_id[row],length.out=length(boing_test$vector2[[row]])*length(boing_test$vector1[[row]])))

stopCluster(cluster) #cancel cluster

longdata_test <- as.data.frame(longdata_test)
save(longdata_test, file = "/home/Vera_Weidmann/Supermarket/00_Data/par_longdata_test.rda")

#load("/home/Vera_Weidmann/Supermarket/00_Data/par_longdata_test.rda")
TransMC_test <- as.data.frame(markovchainFit(longdata_test[,-3])$estimate@transitionMatrix)
save(TransMC_test, file="/home/Vera_Weidmann/Supermarket/00_Data/TransMC_test.rda")
