library(ggplot2)
library(readr)
library(dplyr)
library(gridExtra)

#set theme for ggplots
theme_set(theme_minimal())

#import data
data <- read.delim("~/R/data-security/data/ml-100k/u.data",
                   header = FALSE)
# user id | item id | rating | timestamp
# The time stamps are unix seconds since 1/1/1970 UTC
#add column names
colnames(data) <- c("user", "item", "rating", "timestamp")


#prepare tables for plotting
#table how many ratings did each user give
tbl_user <- table(data$user)
tbl_user <- as.data.frame(tbl_user)


#table how many ratings each movie has
tbl_movies <- table(data$item)
tbl_movies <- as.data.frame(tbl_movies)

#table frequency ratings per user and per movie (for plotting)
tbl <- rbind(cbind(Freq = tbl_user$Freq, ratings = "users"),
              cbind(tbl_movies$Freq, "movies"))
tbl <- data.frame(tbl)
tbl$Freq <- as.numeric(tbl$Freq)


# plotting ----------------------------------------------------------------


#histogram users add numbers for mean and median
hist_user <- ggplot(tbl_user, aes(Freq)) +
  geom_histogram(bins = 40) +
  geom_vline(aes(xintercept = mean(Freq), linetype = "mean", col = "mean"),
             size = 1) +
  geom_vline(aes(xintercept = median(Freq), linetype = "median",
                 col = "median"), size = 1) +
  labs(title = "Ratings per User", x = "Number of Ratings", y = "") +
  scale_linetype_manual(name = "statistics", values = c(median = "dashed",
                                                     mean = "solid")) +
  scale_color_manual(name = "statistics", values = c(median = "#FF9900",
                                                     mean = "#000099")) +
  theme_minimal() +
  theme(legend.title = element_blank(),
        legend.position="bottom")


ggsave("results/descriptives/ratings_per_user.png", hist_user, width = 12, 
       height = 8, units = "cm")
  

median(tbl_user$Freq)
mean(tbl_user$Freq)
summary(tbl_user$Freq)

table(cut(tbl_user$Freq, breaks = 10))


#histogram movies
hist_movies <- ggplot(tbl_movies, aes(Freq)) +
  geom_histogram(bins = 40) +
  geom_vline(aes(xintercept = mean(Freq), linetype = "mean", col = "mean"),
             size = 1) +
  geom_vline(aes(xintercept = median(Freq), linetype = "median",
                 col = "median"), size = 1) +
  labs(title = "Ratings per Movies", x = "Number of Ratings", y = "") +
  scale_linetype_manual(name = "statistics", values = c(median = "dashed",
                                                        mean = "solid")) +
  scale_color_manual(name = "statistics", values = c(median = "#FF9900",
                                                     mean = "#000099")) +
  theme_minimal() +
  theme(legend.title = element_blank(),
        legend.position="bottom")


ggsave("results/descriptives/ratings_per_movie.png", hist_movies, width = 12, 
       height = 8, units = "cm")


ggsave("results/descriptives/ratings_both.png", arrangeGrob(hist_user, hist_movies, ncol=2), width = 20, 
       height = 8, units = "cm")


summary(tbl_movies$Freq)
prop.table(table(cut(tbl_movies$Freq, breaks = c(0,100,230,600))))

#boxplot both
ggplot(tbl, aes(x = Freq, y = ratings, fill = ratings)) + 
  geom_boxplot()






# find good movies --------------------------------------------------------

# !! BE CAREFUL !!
# many moevies are in the list with 2 different ids

# TODO which movies twice?

#import train and test sets
train <- read.delim("~/R/data-security/data/ml-100k/u1.base", header = FALSE)
test <- read.delim("~/R/data-security/data/ml-100k/u1.test", header = FALSE)

#fix colnames
colnames(train) <- c("user", "item", "rating", "timestamp")
colnames(test) <- c("user", "item", "rating", "timestamp")


#table how many ratings per movies in train dataset
tbl_train_m <- table(train$item)
tbl_train_m <- as.data.frame(tbl_train_m)
tbl_train_m <- tbl_train_m[order(-tbl_train_m$Freq),]

#table how many ratings per movies in test dataset
tbl_test_m <- table(test$item)
tbl_test_m <- as.data.frame(tbl_test_m)
tbl_test_m <- tbl_test_m[order(-tbl_test_m$Freq),]



# analyze ratings ---------------------------------------------------------
summary(data$rating)


mean_rating <- data %>% group_by(item) %>% 
  summarise(avg_rating = mean(rating), n = n(), sd = sd(rating))

summary(mean_rating$avg_rating)

ggplot(mean_rating, aes(avg_rating))+
  geom_histogram(bins = 20) 

ggplot(mean_rating, aes(avg_rating))+
  geom_boxplot()+ theme(
    axis.text.y = element_blank(),
    axis.ticks.y = element_blank())


ggplot(mean_rating, aes(n)) +
  geom_histogram()


# analyze movies ----------------------------------------------------------


item <- read_delim("data/ml-100k/u.item", "|", escape_double = FALSE,
                   col_names = FALSE, trim_ws = TRUE)
colnames(item) <- c("movie_id", "movie_title", "release_date", 
                    "video_release_date", "IMDb_URL", "unknown", "Action", 
                    "Adventure", "Animation", "Children's", "Comedy", "Crime",
                    "Documentary", "Drama", "Fantasy", "Film-Noir", "Horror",
                    "Musical", "Mystery", "Romance", "Sci-Fi", "Thriller", 
                    "War", "Western")


#make sure date abbreviation is english
Sys.setlocale("LC_TIME", "English")
item$release_date <- as.Date(item$release_date, format = "%d-%h-%Y")

# 50, 100, 286 ,1 check some much rated movies
item[c(1,50, 56, 100, 286),1:2]

#257 Men in Black (1997), is known and quite recent and quite many ratings in
# both datasets
tbl_test_m[tbl_test_m$Var1 == 257,]
tbl_train_m[tbl_train_m$Var1 == 257,]
#it exitst only under one id
item[item$movie_title == "Men in Black (1997)",]
item[item$movie_title == "Toy Story (1995)",]




# find users --------------------------------------------------------------


tbl_train_u <- table(train$user)
tbl_train_u <- as.data.frame(tbl_train_u)
tbl_train_u <- tbl_train_u[order(-tbl_train_u$Freq),]


tbl_test_u <- table(test$user)
tbl_test_u <- as.data.frame(tbl_test_u)
tbl_test_u <- tbl_test_u[order(-tbl_test_u$Freq),]



# =>
#257, Men In Black: has many ratings in general(both train test split), 
# is known and quite recent
#1, toy story, many ratings in test and train


# bomb
mib <- data[data$item == 257, ]
no_mib <- unique(data[!(data$user %in% mib$user),"user"])
no_mib <- sort(no_mib)
write.table(no_mib, "data/ml-100k/users_no_mib.txt", row.names = FALSE,
            col.names = FALSE)


toy <- data[data$item == 1, ]
no_toy <- unique(data[!(data$user %in% toy$user),"user"])
no_toy <- sort(no_toy)
write.table(no_toy, "data/ml-100k/users_no_toy.txt", row.names = FALSE,
            col.names = FALSE)


no_both <- no_mib[no_mib %in% no_toy]
write.table(no_both, "data/ml-100k/users_no_both.txt", row.names = FALSE,
            col.names = FALSE)


tbl_train_u[no_both %in% tbl_train_u$Var1,]




# descriptives movies -----------------------------------------------------

genres <- colnames(item[,6:24])

tab_genres <- as.data.frame(colSums(item[,genres]))

tab_genres$genre <- as.factor(rownames(tab_genres))
colnames(tab_genres)[1] <- "Freq"

ggplot(tab_genres, aes(x = reorder(genre, -Freq), y = Freq)) +
  geom_col() +
  geom_text(label = tab_genres$Freq, vjust = -0.4) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlab("Genre") +
  ylim(0,740) +
  ggtitle("Frequency of Genres")

ggsave("results/descriptives/freq_genres.png", width = 15, 
       height = 10, units = "cm")



ggplot(item, aes(x = format(release_date, "%Y")))+
  geom_bar() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

count.or <- function(dat, n = 2) {
  or.sum <- function(cols) sum(rowSums(dat[cols]) > 0)
  counts <- combn(colnames(dat), n, FUN = or.sum)
  names  <- combn(colnames(dat), n, FUN = paste, collapse = "&")
  setNames(counts, names)
}


count.or(item[,genres], 2)



crosstab_genres <- item[,genres] %>% #dplyr::select(-movie_title) %>% 
  dplyr::mutate_all(function(x) ifelse(x < 1, NA, x)) %>%
  psych::pairwiseCount()


heatmap(crosstab_genres)




crosstab_genres[lower.tri(crosstab_genres)] <- NA

diag(crosstab_genres) <- NA
library(reshape2)
melted_cormat <- melt(crosstab_genres)
head(melted_cormat)


ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()


item[item$movie_id==257, 6:24]


# user --------------------------------------------------------------------
user <- read_delim("data/ml-100k/u.user", "|", escape_double = FALSE,
                   col_names = FALSE, trim_ws = TRUE)
colnames(user) <- c("id", "age", "gender", "occupation", "zip_code") 




user[user$id == 23,]
user$gender <- as.factor(user$gender)

summary(user)

prop.table(table(user$gender))


ggplot(user, aes(age)) +
  #geom_bar()
  geom_histogram(bins = 25)


ggplot(user, aes(age)) +
  geom_density() +
  xlab("Age") +
  ggtitle("Distribution of Age")
  # geom_vline(xintercept = 26.5) +
  # geom_vline(xintercept = 48)

ggsave("results/descriptives/dens_age.png", width = 12, 
       height = 8, units = "cm")


ggplot(user, aes(age,y = gender, fill = gender)) +
  geom_boxplot()

tab_occ <- as.data.frame(table(user$occupation))

ggplot(user, aes(reorder(occupation,occupation, function(x)-length(x)))) +
  geom_bar() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))+
  xlab("Occupation") +
  geom_text(stat='count', aes(label=..count..), vjust=-0.4)+
  ylim(0,210)+
  ggtitle("Frequency of Occupations")

ggsave("results/descriptives/freq_occupation.png", width = 15, 
       height = 10, units = "cm")

mean_rating[mean_rating$item == 1,]


item[item$movie_id == 12,]


test[test$item == 1,]



# SD change after fake ratings --------------------------------------------



sd_change <- function(movie_id = 257, pct_fake = 0.1) {
  #its 934
  max(data$user)
  max(data$timestamp)
  num_users <- length(unique(train$user))
  pct_fake <- pct_fake
  num_fake <- floor(pct_fake*num_users)
  
  
  # create fake ratings for man in black
  fake <- data.frame(user = (num_users + 1):(num_users + num_fake), 
                     item = movie_id, rating = 5, 
                     timestamp = max(data$timestamp))
  
  train_fake <- rbind(train, fake)
  
  

  

  #sd of ratings in train dataset
  old_sd <- sd(train[train$item == movie_id, "rating"])
  
  #sd of ratings in train dataset after bomb
  new_sd <- sd(train_fake[train_fake$item == movie_id, "rating"])
  
  return(list("movie_id" = movie_id, 
              "pct_fake" = pct_fake,
           "movie_title" = item[item$movie_id == movie_id,
                                "movie_title"][[1]],
           "old_sd" = old_sd,
           "new_sd" = new_sd,
           "sd_change_rel" = (new_sd - old_sd)/old_sd
))
}

sd_change(movie_id = 257, pct_fake = 0.1)
sd_change(movie_id = 257, pct_fake = 0.5)

sd_change(movie_id = 1, pct_fake = 0.1)
sd_change(movie_id = 1, pct_fake = 0.5)
