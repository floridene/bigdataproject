library(data.table)
library(dplyr)

load("/home/Vera_Weidmann/Supermarket/00_Data/par_longdata.rda")

longdata<- as.data.frame(longdata)
transMatrix <- longdata %>% group_by(V1,V2) %>% summarise(n=n()) %>% mutate(p=n/max(n)) %>% dcast(V1 ~ V2, value.var="p")

#transMatrix[as.numeric(is.na(transMatrix))] = 0

save(transMatrix, file = "/home/Vera_Weidmann/Supermarket/00_Data/1406transMatrix.rda")


#-> Problem: just values for products until column 15000