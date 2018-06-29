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
    tfidf_matrix =  tf.fit_transform([review for index, review in enumerate(corpus)])

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


def baseline(bu, bi, global_avg):
    rui = global_avg + bi + bu
    return rui


def main():
    # read dataset
    movies_data = pandas.read_csv("csv/movies_data.csv")
    test_data = pandas.read_csv("csv/test_data.csv")
    train_data = pandas.read_csv("csv/train_data.csv")
    movie_reviews = pandas.read_csv("csv/movie_reviews.csv")

    # initialize our data matrix (0 = unknown rating)
    n_users = train_data['user_id'].max()
    n_items = movies_data['movie_id'].max()

    # generate (user x movie) ratings matrix
    print("Generating user x movie ratings matrix...")
    ratings = np.full((n_users, n_items), 0)
    for row in train_data.itertuples():
        user = getattr(row, "user_id")
        movie = getattr(row, "movie_id")
        rating = getattr(row, "rating")
        ratings[user-1][movie-1] = rating

    # choose user to recommend movies to
    print("\nChoose user (ID): ", end="")
    user = int(input())

    # calculate biases
    print("\nCalculating biases...")
    global_avg = global_average(ratings)
    bu = bias_user(ratings, user, global_avg)
    bi = []
    with progressbar.ProgressBar(max_value=n_items) as bar:
        for i in range(n_items):
            bi.append(bias_item(ratings, i, global_avg))
            bar.update(i)

    # calculate prediction for every item for chosen user
    print("\nPredicting ratings with Baseline...")
    predictions = np.zeros(n_items)
    with progressbar.ProgressBar(max_value=n_items) as bar:
        for i in range(n_items):
            predictions[i] = baseline(bu, bi[i], global_avg)
            bar.update(i)

    # sorting and getting 20 top rated items
    predictions = predictions.argsort()[-5:]

    print("\nBaseline top predictions:")
    for movie in predictions:
        title = movies_data['title'][movie-1]
        print("* " + title)

    # use these for FBC-Knn
    start = timer()
    fbc_knn(predictions, movie_reviews, movies_data)
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
