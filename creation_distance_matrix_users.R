load("/home/Max_Philipp/bigdataproject/product_frequency_per_user.rda")
d <- dist(scale(dataforclustering))
d <- as.matrix(d)
save(d,file="/home/Vera_Weidmann/Supermarket/00_Data/distrancematrix_users.rda")