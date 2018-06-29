#!/bin/usr/env python3
# -*- coding: utf-8 -*-

import progressbar
from timeit import default_timer as timer
from termcolor import colored

import pandas
import csv
import math
import numpy as np
from math import sqrt
import matplotlib.pyplot as plt
import seaborn as sns


##############################
#        FBC-KNN             #
##############################



##############################
#        BASELINE            #
##############################
def global_average(ratings):
    size = 0
    total = 0
    for row in ratings:
        for rating in row:
            if (rating != 0):
                total += rating
                size += 1
    return (total / size)


def bias_item(ratings, item, global_avg):
    bias = 0
    Ri = 0
    for i in range(len(ratings)):
        bias += ratings[i][item] - global_avg
        Ri += 1
    if (Ri == 0):
        # no other ratings for this item
        bias = global_avg
    else:
        bias = bias / abs(Ri)
    return bias


def bias_user(ratings, user, global_avg):
    user_ratings = ratings[user]
    bias = 0
    Ru = 0
    for item, rating in enumerate(user_ratings):
        if (rating != 0):
            bi = bias_item(ratings, item, global_avg)
            bias += rating - global_avg - bi
            Ru += 1
    if (Ru == 0):
        # no other items were rated
        bias = global_avg
    else:
        bias = bias / abs(Ru)
    return bias


def baseline(ratings, user, bu, bi, item, global_avg):
    rui = global_avg + bi + bu
    return rui


def main():
    # read dataset
    movies_data = pandas.read_csv("csv/movies_data.csv")
    test_data = pandas.read_csv("csv/test_data.csv")
    train_data = pandas.read_csv("csv/train_data.csv")

    # initialize our data matrix (0 = unknown rating)
    n_users = train_data['user_id'].max()
    n_items = movies_data['movie_id'].max()
    ratings = np.full((n_users, n_items), 0)

    # generate (user x movie) ratings matrix
    print("Generating user x movie ratings matrix...")
    for row in train_data.itertuples():
        user = getattr(row, "user_id")
        movie = getattr(row, "movie_id")
        rating = getattr(row, "rating")
        ratings[user-1][movie-1] = rating

    # choose user to recommend movies to
    print("Choose user (ID): ", end="")
    user = int(input())

    # calculate biases
    print("Calculating biases...")
    global_avg = global_average(ratings)
    bu = bias_user(ratings, user, global_avg)
    bi = []
    with progressbar.ProgressBar(max_value=n_items) as bar:
        for i in range(n_items):
            bi.append(bias_item(ratings, i, global_avg))
            bar.update(i)

    # calculate prediction for every item for chosen user
    print("Predicting ratings with Baseline...")
    predictions = np.zeros(n_items)
    with progressbar.ProgressBar(max_value=n_items) as bar:
        for i in range(n_items):
            predictions[i] = baseline(ratings, user, bu, bi[i], i, global_avg)
            bar.update(i)

    # sorting and getting 20 top rated items
    predictions = predictions.argsort()[-20:]

    print("20 top rated items:")
    for movie in predictions:
        title = movies_data['title'][movie-1]

    # use these for FBC-Knn



if __name__ == '__main__':
    try:
        import IPython.core.ultratb
    except ImportError:
        # No IPython. Use default exception printing.
        pass
    else:
        import sys
        sys.excepthook = IPython.core.ultratb.ColorTB()
        main()
