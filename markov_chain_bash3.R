
library(foreach)
library(doParallel)
library(dplyr)

load("/home/Vera_Weidmann/Supermarket/00_Data/boing.rda")

num_cores <- detectCores()-10 #number of possible cores - 10, so that others can use them still
cluster <- makeCluster(num_cores) #creating cluster
registerDoParallel(cluster) #initializing cluster

longdata <- foreach(row=1:nrow(boing), .combine=rbind) %dopar% cbind(rep(boing$vector1[[row]], each=length(boing$vector2[[row]])), rep(boing$vector2[[row]],length(boing$vector1[[row]])))

stopCluster(cluster) #cancel cluster

save(longdata, file = "/home/Vera_Weidmann/Supermarket/00_Data/par_longdata.rda")

transMatrix <- longdata %>% group_by(V1,V2) %>% summarise(n=n()) %>% mutate(p=n/max(n)) %>% dcast(V1 ~ V2, value.var="p")
transMatrix[is.na(transMatrix)] = 0

save(transMatrix, file = "/home/Vera_Weidmann/Supermarket/00_Data/transMatrix.rda")
