#library(data.table)
library(dplyr)
library(reshape2)

load("/home/Vera_Weidmann/Supermarket/00_Data/par_longdata_as_df.rda")

#longdata<- as.data.frame(longdata)
longdata_df$V1 <- as.numeric(longdata_df$V1)
longdata_df$V2 <- as.numeric(longdata_df$V2)

transMatrix <- longdata_df %>% group_by(V1,V2) %>% summarise(n=n()) %>% mutate(p=n/max(n)) %>% dcast(V1 ~ V2, value.var="p")

save(transMatrix, file = "/home/Vera_Weidmann/Supermarket/00_Data/1406_2transMatrix.rda")

transMatrix[is.na(transMatrix)] = 0

#-> Problem: just values for products until column 15000