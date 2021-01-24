# Fake Ratings in Recommender Systems

The Netflix Prize challenge inspired data enthusiasts around the globe to find the best collaborative filtering algorithm for predicting movie ratings.  Their findings had and still have a lasting impact on the industry and research community.  In this work we analyse the shift in performance of two of the central baseline predictors of the winning solution of this challenge when confronted with fake user ratings,  an incident regularly taking place in the real world.  Our results show that the predictive performance significantly decreases for the respective item targeted by such fake reviews.

The benchmark dataset for this project can be found [here](data/ml-100k/u.data) or be downloaded directly from the [Website](https://grouplens.org/datasets/movielens/100k/).

If you want to recreate the analysis you can run following files in this order:

| File                                                 | Content                                                  |
|------------------------------------------------------|----------------------------------------------------------|
| [movielens_descriptives.R](movielens_descriptives.R) | analyze and describe dataset, plot feature distributions |
| [model_selection.ipynb](model_selection.ipynb)       | hyperparametertuning for knn and SVD                     |
| [scenario1.ipynb](scenario1.ipynb)                   | analyze change in prediction for review bombing          |
| [scenario2.ipynb](scenario2.ipynb)                   | analyze change in prediction for paid reviews            |
