library(tidyverse)

path ="C:/R - Workspace/data security"

#get ratings 
ratings_path = paste0(path, "/data/training_set")
ratings_df = tibble()
movie_id_counter = 1
files = list.files(ratings_path)
for(movie_rating_path in files){
  print(movie_id_counter)
  temp_ratings = read_delim(paste0(ratings_path, "/", movie_rating_path), delim =",", skip=1, col_names = c("user_id", "rating", "date")) 
  temp_ratings = temp_ratings %>% mutate(movie_id = movie_id_counter)
  ratings_df = bind_rows(ratings_df, temp_ratings)
  movie_id_counter = movie_id_counter + 1
}
#saveRDS(file = paste0(path, "/data/ratings_df.rds"), ratings_df)

#Need to re-define user_ids (starting from 1 and counting), because 
# otherwise numbers get too large (int overflows!) for stuff like spread/gather
ratings_df = readRDS(file = paste0(path, "/data/ratings_df.rds"))
ratings_df = ratings_df %>% mutate(old_user_id = user_id) %>% 
  mutate(user_id = group_indices(.,old_user_id))
#Also to make sure: create a crosswalk between old and new id (maybe we need that for some reason later)
user_id_crosswalk = ratings_df %>% select(user_id, old_user_id) %>%  distinct(user_id, .keep_all = TRUE)
ratings_df = ratings_df %>% select(-old_user_id)

saveRDS(file = paste0(path, "/data/ratings_df.rds"), ratings_df)
saveRDS(file = paste0(path, "/data/user_id_crosswalk.rds"), user_id_crosswalk)


#Get movie info
movies_path = paste0(path, "/data/movie_titles.txt")
#Need to deal with problem, that some names have multiple "," in there, which is at the same time the delim
#So what I did was to read in multiple name columns:
movies_df = read_delim(movies_path, delim =",", skip=0, col_names = c("movie_id", "release_year", "name", "name2", "name3", "name4", "name5")) 
#Now combine columns:
movies_df = movies_df %>% mutate(name = ifelse(!is.na(name2), paste0(name, ",", name2) ,name))
movies_df = movies_df %>% mutate(name = ifelse(!is.na(name3), paste0(name, ",", name3) ,name))
movies_df = movies_df %>% mutate(name = ifelse(!is.na(name4), paste0(name, ",", name4) ,name))
movies_df = movies_df %>% mutate(name = ifelse(!is.na(name5), paste0(name, ",", name5) ,name))
movies_df = movies_df %>% select(-name2, -name3, -name4, -name5)
saveRDS(file = paste0(path, "/data/movies_df.rds"), movies_df)


probe_path = paste0(path, "/data/probe.txt")
probe_data = read_delim(probe_path, delim =",", skip=0, col_names = c("c1")) 
current_movie_id = ""
probe_df = tibble( movie_id = numeric(),
                   user_id = numeric())
for(i in 1:nrow(probe_data)){
  print(i)
  current_row = probe_data[i,] %>% pull(c1)
  last_char = substring(current_row, nchar(current_row))
  if(last_char == ":"){
    current_movie_id = substring(current_row, 1, nchar(current_row)-1)
  }
  else{
    probe_df = add_row(probe_df, movie_id = as.numeric(current_movie_id), user_id =  as.numeric(current_row))
  }
  
}
#saveRDS(file = paste0(path, "/data/probe_df.rds"), probe_df)

probe_df = probe_df %>% mutate(old_user_id = user_id) %>% select(-user_id) %>% 
  left_join(user_id_crosswalk) %>% select(-old_user_id)
saveRDS(file = paste0(path, "/data/probe_df.rds"), probe_df)
#Training/test split:
#1) Take ratings_df which has all ratings that user have made for any movie
#2) Remove all ids listed in probe dataset, because those are suggested to use for testing
# --> gives us training dataset
# --> all removed observations are part of the test dataset

#First need to get ratings (& date) for all observations in probe_df
#This gives us the test dataframe
test_df = probe_df %>% left_join(ratings_df, by=c("user_id", "movie_id"))
#Now remove all observations in ratings_df that are part of test, to get training dataset
train_df = ratings_df %>% anti_join(test_df, by=c("user_id", "movie_id"))

saveRDS(file = paste0(path, "/data/test_df.rds"), test_df)
saveRDS(file = paste0(path, "/data/train_df.rds"), train_df)