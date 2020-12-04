library(rrecsys)
library(tidyverse)
library(Metrics)
library(purrr)

path ="C:/R - Workspace/data security"
test_df = readRDS(paste0(path, "/data/test_df.rds"))
train_df = readRDS(paste0(path, "/data/train_df.rds")) %>% select(-date)


#
#-------------------------------
#testing the rrecsys package, specifically user based KNN
data("ml100k")
d <- defineData(ml100k)
# e <- evalModel(d, folds = 2)
# evalPred(e, "ubknn", simFunct = "Pearson", neigh = 10)
model_ubknn = rrecsys(data = d, alg = "UBKNN", simFunct="Pearson", neigh = 10)
pre_ubknn <- predict(model_ubknn, Round = TRUE)
#--> works fine, now do it with our data
#------------------------------

#-------------------------------
#Now do it for out dataset

#Unfortunately, our dataset is too large, to do a spread/pivot_wider directly on dataframe
#So let's split it to convert it to matrix
#But cant even do that for splitting


# so first, get a list of all movie_ids
movie_ids = train_df %>% distinct(movie_id) %>% pull(movie_id)
summary(movie_ids)
# ---> movie ids exactly from 1:17770
user_ids = train_df %>% distinct(user_id) %>% pull(user_id)
summary(user_ids)
# ---> user ids exactly from 1:480189

#Now create a matrx:
#matrix_df = matrix(, nrow = length(user_ids), ncol = length(movie_ids))
# ---> doesnt work, still far too large to use

#So let's only use a subset of our data:
df = train_df  %>% arrange(user_id) %>% slice(1:500000)
#then we can even use pivot_wider and create a matrix
df = df %>%  pivot_wider(id_cols = "user_id", names_from = "movie_id", values_from = "rating") %>% 
  remove_rownames() %>%
  column_to_rownames(var = "user_id")
df = as.matrix(df)
df <- defineData(df)
gc()
model_ubknn = rrecsys(data = df, alg = "UBKNN", simFunct="Pearson", neigh = 10)
result <- predict(model_ubknn, Round = TRUE)
result = as_tibble(result, rownames=NA) %>% rownames_to_column(var = "user_id") %>% 
  pivot_longer(cols = !(all_of("user_id")), names_to = "movie_id")
result = result %>% mutate(user_id = as.double(user_id), movie_id = as.double(movie_id))
comp_df = test_df %>% left_join(result, by=c("movie_id","user_id")) %>% filter(!is.na(value))
#Calculate error:
rmse(comp_df$rating, comp_df$value)
#-------------------------------
 

