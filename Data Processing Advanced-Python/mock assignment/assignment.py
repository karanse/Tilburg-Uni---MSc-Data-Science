import numpy as np

def average(x):
    return x.mean()

def predict(beta, X):
    return np.dot(X, beta)

