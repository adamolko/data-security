# -*- coding: utf-8 -*-
"""
Spyder Editor

Dies ist eine temporäre Skriptdatei.
"""

import pandas as pd
import surprise as sp
from surprise.model_selection import PredefinedKFold


test = pd.read_csv('data/test_df.csv')
train = pd.read_csv('data/train_df.csv', nrows = 5000000)
train.head()
#need to do that for train/test split for suprise package
train.to_csv('data/train_temp_df.csv', index=False)


n_users=int(train.user_id.nunique())
n_movies=int(train.movie_id.nunique())

#Do SVD first:
folds_files = [('data/train_temp_df.csv','data/test_df.csv')]
reader = sp.Reader(rating_scale=(1, 5), line_format="user item rating timestamp", sep ="," , skip_lines=1)
data = sp.Dataset.load_from_folds(folds_files, reader=reader)
pkf = PredefinedKFold()
algo = sp.SVD()
for trainset, testset in pkf.split(data):
    algo.fit(trainset)
    predictions_test= algo.test(testset)
    
sp.accuracy.rmse(predictions_test, verbose=True)


#Get predictions for testset into our dataframe:
temp_df = pd.DataFrame(predictions_test) 
temp_df = temp_df.drop(["r_ui", "details"], axis=1)
temp_df = temp_df.rename(columns={"uid": "user_id", "iid": "movie_id"})
temp_df.head()
#Now want to join them with original test data
#But we can see, that dataframes have different types:
temp_df.dtypes
test.dtypes
temp_df.user_id, temp_df.movie_id= pd.to_numeric(temp_df.user_id), pd.to_numeric(temp_df.movie_id)

#Now join:
test = test.join(temp_df.set_index(keys=["user_id", "movie_id"]), on=["user_id", "movie_id"])
#And rename column:
test = test.rename(columns={"est": "prediction_svd"})     
test.head()   

#To get predictions for our trainset, need to iterate over it manually and generate them:
train['prediction_svd'] = train.apply(lambda x: algo.predict(str(trainset.to_inner_uid("{:.0f}".format(x["user_id"]))),
                                                         str(trainset.to_inner_iid("{:.0f}".format(x["movie_id"]))))[3], axis=1)
train.head()


#Now KNN:
for trainset, testset in pkf.split(data):
    sim_options = {'name': 'MSD',
               'user_based': True  
               }
    algo = sp.KNNBasic(sim_options=sim_options)
    algo.fit(trainset)
    predictions_test= algo.test(testset)
    
sp.accuracy.rmse(predictions_test)

#Again get predictions into our dataframes:

temp_df = pd.DataFrame(predictions_test) 
temp_df = temp_df.drop(["r_ui", "details"], axis=1)
temp_df = temp_df.rename(columns={"uid": "user_id", "iid": "movie_id"})
temp_df.user_id, temp_df.movie_id= pd.to_numeric(temp_df.user_id), pd.to_numeric(temp_df.movie_id)
test = test.join(temp_df.set_index(keys=["user_id", "movie_id"]), on=["user_id", "movie_id"])
test = test.rename(columns={"est": "prediction_knn"})  
test.head()
train['prediction_svd'] = train.apply(lambda x: algo.predict(str(trainset.to_inner_uid("{:.0f}".format(x["user_id"]))),
                                                         str(trainset.to_inner_iid("{:.0f}".format(x["movie_id"]))))[3], axis=1)
train.head()



#TODO:
# Choose best models
# Do hyperparameter optimization for those models
# Do some kind of stacking for best models
