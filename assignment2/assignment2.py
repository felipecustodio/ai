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

from heapq import nlargest

from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import linear_kernel


##############################
#        FBC-KNN             #
##############################
def fbc_knn(biggest_rated, movie_reviews, movies_data):
    # for each movie:
        # generate a TF/IDF vector of the terms in the movie reviews
        # calculate the cosine similarity of each movie's TF/IDF vector with every other movie's TF/IDF vector

    # corpus consists of all reviews
    corpus = ["" for x in range(len(movies_data))]

    # concatenate movie reviews to generate corpus
    print("\nGenerating reviews corpus...")
    for row in movie_reviews.itertuples():
        movie = getattr(row, "movie_id")
        review = getattr(row, "text")
        corpus[movie-1] += str(review)

    # initialize vectorizer and matrix for each movie review
    print("Generating TF-IDF vectorizer...")
    tf = TfidfVectorizer(analyzer='word', ngram_range=(1,3), min_df = 0, stop_words = 'english')
    tfidf_matrix = tf.fit_transform([review for index, review in enumerate(corpus)])

    # calculate vector of similarities for each of the movies from the first recommender
    # recommend the most similar for each one for the user
    most_similar = []
    top_n = 1
    print("Finding most similar movies...")
    for index, movie in enumerate(biggest_rated):
        cosine_similarities = linear_kernel(tfidf_matrix[movie:movie+1], tfidf_matrix).flatten()
        related_docs_indices = [i for i in cosine_similarities.argsort()[::-1] if i != movie]
        most_similar.append([(movie, cosine_similarities[movie]) for movie in related_docs_indices][0:top_n])

    print("\n\nRecommended movies for you:")
    for movie in most_similar:
        print("* " + movies_data['title'][movie[0][0]-1])


###########
# RF-REC #
###########
def RF_Rec(ratings, user, item):
    # get all user and item ratings
    user_ratings = ratings[user]
    item_ratings = ratings[:, item]
    # initialize frequencies + 1
    frequencies_user = [1, 1, 1, 1, 1]
    frequencies_item = [1, 1, 1, 1, 1]
    rui = [0, 0, 0, 0, 0]
    # get frequency of all possible ratings
    # by user 'user' and by item 'item'
    for i in range(1, 6):
        for rating in user_ratings:
            if (rating == i):
                frequencies_user[i-1] += 1
        for rating in item_ratings:
            if (rating == i):
                frequencies_item[i-1] += 1
        # rating frequency = frequency that user gave
        # that rating * frequency that item was given that rating
        rui[i-1] = frequencies_user[i-1] * frequencies_item[i-1]
    # pred = arg max freq(user) x freq(item)
    prediction = rui.index(max(rui)) + 1
    return prediction


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
        bias = -1
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
        bias = -1
    else:
        bias = bias / abs(Ru)
    return bias


def baseline(bu, bi, global_avg):
    rui = global_avg + bi + bu
    return rui


def main():

    print("WELCOME TO ZEPHYRUS.")
    # choose user to recommend movies to
    print("\nChoose user (ID): ", end="")
    user = int(input())

    # read dataset
    movies_data = pandas.read_csv("csv/movies_data.csv")
    test_data = pandas.read_csv("csv/test_data.csv")
    train_data = pandas.read_csv("csv/train_data.csv")
    movie_reviews = pandas.read_csv("csv/movie_reviews.csv")

    # initialize our data matrix (0 = unknown rating)
    n_users = train_data['user_id'].max()
    n_items = movies_data['movie_id'].max()

    # generate (user x movie) ratings matrix
    print("\nGenerating user x movie ratings matrix...")
    ratings = np.full((n_users, n_items), 0)
    for row in train_data.itertuples():
        user_id = getattr(row, "user_id")
        movie = getattr(row, "movie_id")
        rating = getattr(row, "rating")
        ratings[user_id-1][movie-1] = rating

    # calculate biases
    # print("Calculating biases...")
    # global_avg = global_average(ratings)
    # print("Global Average: {}".format(global_avg))
    # bu = bias_user(ratings, user, global_avg)
    # print("Bias User: {}".format(bu))
    # bi = []
    # print("Calculating biases for every item...")
    # with progressbar.ProgressBar(max_value=n_items) as bar:
    #     for i in range(n_items):
    #         bi.append(bias_item(ratings, i, global_avg))
    #         bar.update(i)

    # calculate prediction for every item for chosen user
    print("\nPredicting ratings with RF_Rec...")
    predictions = np.zeros(n_items)
    with progressbar.ProgressBar(max_value=n_items) as bar:
        for i in range(n_items):
            # predictions[i] = baseline(bu, bi[i], global_avg)
            predictions[i] = RF_Rec(ratings, user, i)
            bar.update(i)

    # sorting and getting top rated items
    # sorted_predictions = predictions.argsort()[:5]
    sorted_predictions = nlargest(10, enumerate(predictions), key=lambda x: x[1])
    print("Top 10 predictions:")
    print(sorted_predictions)

    rf_rec_results = []
    for prediction in sorted_predictions:
        rf_rec_results.append(prediction[0])

    print("\nRF_Rec results:")
    for movie in rf_rec_results:
        title = movies_data['title'][movie]
        print("* " + title)

    # use these for FBC-Knn
    start = timer()
    fbc_knn(rf_rec_results, movie_reviews, movies_data)
    end = timer()
    time_elapsed = end - start
    print("\nElapsed time for FBC-Knn: {}".format(time_elapsed))


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
