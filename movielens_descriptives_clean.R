# data import & preparation -----------------------------------------------

library(ggplot2)
library(readr)
library(dplyr)
library(gridExtra)

#set theme for ggplots
theme_set(theme_minimal())

#import full data
data <- read.delim("~/R/data-security/data/ml-100k/u.data",
                   header = FALSE)

#add column names
colnames(data) <- c("user", "item", "rating", "timestamp")


#import train and test sets
train <- read.delim("~/R/data-security/data/ml-100k/u1.base", header = FALSE)
test <- read.delim("~/R/data-security/data/ml-100k/u1.test", header = FALSE)

#fix colnames
colnames(train) <- c("user", "item", "rating", "timestamp")
colnames(test) <- c("user", "item", "rating", "timestamp")



#import movie info
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


# import info on users
user <- read_delim("data/ml-100k/u.user", "|", escape_double = FALSE,
                   col_names = FALSE, trim_ws = TRUE)
colnames(user) <- c("id", "age", "gender", "occupation", "zip_code") 
user$gender <- as.factor(user$gender)


# prepare frequency tables ------------------------------------------------

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




# plot rating frequencies per user & per movie ----------------------------


# general info on distribution 
summary(tbl_user$Freq)
table(cut(tbl_user$Freq, breaks = 10))

summary(tbl_movies$Freq)
prop.table(table(cut(tbl_movies$Freq, breaks = c(0,100,230,600))))



# histogram users  ---------------------------------------------------
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
  theme(legend.title = element_blank(),
        legend.position = "bottom")


ggsave("results/descriptives/ratings_per_user.png", hist_user, width = 12, 
       height = 8, units = "cm")




# histogram movies ---------------------------------------------------

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
  theme(legend.title = element_blank(),
        legend.position = "bottom")


ggsave("results/descriptives/ratings_per_movie.png", hist_movies, width = 12, 
       height = 8, units = "cm")


ggsave("results/descriptives/ratings_both.png", 
       arrangeGrob(hist_user, hist_movies, ncol = 2), width = 20, 
       height = 8, units = "cm")



# analyze ratings ---------------------------------------------------------

summary(data$rating)

#calculate avg rating for each movie
mean_rating <- data %>% group_by(item) %>% 
  summarise(avg_rating = mean(rating), n = n(), sd = sd(rating))

summary(mean_rating$avg_rating)



# find users and movies for review bomb -----------------------------------

#257 Men in Black (1997), is known and quite recent and quite many ratings in

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



# descriptives for movies -------------------------------------------------



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




# descriptives for users --------------------------------------------------

user[user$id == 23,]




summary(user)

prop.table(table(user$gender))


ggplot(user, aes(age)) +
  geom_density() +
  xlab("Age") +
  ggtitle("Distribution of Age")
# geom_vline(xintercept = 26.5) +
# geom_vline(xintercept = 48)

ggsave("results/descriptives/dens_age.png", width = 12, 
       height = 8, units = "cm")

# no differnce in age distribution per gender
ggplot(user, aes(age,y = gender, fill = gender)) +
  geom_boxplot()

tab_occ <- as.data.frame(table(user$occupation))

ggplot(user, aes(reorder(occupation,occupation, function(x)-length(x)))) +
  geom_bar() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  xlab("Occupation") +
  geom_text(stat='count', aes(label=..count..), vjust=-0.4) +
  ylim(0,210) +
  ggtitle("Frequency of Occupations")

ggsave("results/descriptives/freq_occupation.png", width = 15, 
       height = 10, units = "cm")

