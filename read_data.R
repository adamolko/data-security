library(tidyverse)


path ="C:/R - Workspace/data security"

#get ratings 
ratings_path = paste0(path, "data/training_set")
ratings_df = tibble()
movie_id_counter = 1
files = list.files(ratings_path)
for(movie_rating_path in files){
  print(movie_id_counter)
  temp_ratings = read_delim(paste0(ratings_path, "/", test[1]), delim =",", skip=1, col_names = c("user_id", "rating", "date")) 
  temp_ratings = temp_ratings %>% mutate(movie_id = movie_id_counter)
  ratings_df = bind_rows(ratings_df, temp_ratings)
  movie_id_counter = movie_id_counter + 1
}
saveRDS(file = paste0(path, "/data/ratings_df.rds"), ratings_df)

ratings_df = readRDS(file = paste0(path, "/data/ratings_df.rds"))

#get movie info
movies_path = paste0(path, "data/movie_titles.txt")
movies_df = read_delim(movies_path, delim =",", skip=0, col_names = c("movie_id", "release_year", "name")) 
#--> 343 parsing failures: movie names with "," in there -.-
saveRDS(file = paste0(path, "/data/movies_df.rds"), movies_df)

