load("/home/Vera_Weidmann/Supermarket/00_Data/par_longdata.rda") 
library(markovchain) 
TransMC <- as.data.frame(markovchainFit(longdata)$estimate@transitionMatrix) 
save(TransMC, file="/home/Vera_Weidmann/Supermarket/00_Data/TransMC.rda")