
## PLEASE MAKE SURE THAT"dev.csv" and "test.csv" DATA FILES ARE IN THE SAME FOLDER WITH THIS SCRIPT 


## -------Load the libraries--------------------------------------

import pandas as pd  # to read the data, to transform the data  and write to csv
import numpy as np
import string    # to remove punctuations
from scipy import sparse # to convert to sparse matrix
import nltk
from nltk.corpus import stopwords # to process the text (for removing the stopwords in English)
from nltk.stem import PorterStemmer # process the text (for stemming the words)
from nltk.corpus import wordnet # To get words in dictionary with their parts of speech
from nltk.stem import WordNetLemmatizer # to lemmatize the words based on it's parts of speech
from sklearn.feature_extraction.text import CountVectorizer # to convert text data into document term matrix
from sklearn.feature_extraction.text import TfidfTransformer # to convert document term matrix to tif-idf format
from sklearn.metrics.pairwise import cosine_similarity # to calculate the similarities for each text pair


## -------Read the data with Pandas-----------------------------------

questions = pd.read_csv("dev.csv", delimiter=',')

## -------Text pre-processing------------------------------------------

# defining a function to identify "part of speech" in lemmatization step
def get_wordnet_pos(word):
    """Map POS tag to first character lemmatize() accepts"""
    tag = nltk.pos_tag([word])[0][1][0].upper()
    tag_dict = {"J": wordnet.ADJ,
                "N": wordnet.NOUN,
                "V": wordnet.VERB,
                "R": wordnet.ADV}

    return tag_dict.get(tag, wordnet.NOUN)


# defining a function for cleaning process
def clean_text(text):
    """
    Takes a string of text and performs the following:
    1. remove all punctuation
    2. remove stopwords
    3. stemming
    4. lemmatization
    5. return a list of words clened after one of the previous processes
    """
    
    # Removes punctuation
    nopunc = [char for char in text if char not in string.punctuation]

    # Join the charachters again to form the string
    nopunc = "".join(nopunc)
    
    # Removes stopwords
    #stp = [word for word in nopunc.split() if word.lower() not in stopwords.words('english')]
    
    # Stemming
    ps = PorterStemmer()
    stemmed = [ps.stem(word) for word in nopunc.split()]
    
    
    # Lemmatization
    # lem = WordNetLemmatizer()
    # lm = [lem.lemmatize(word) for word in nopunc.split()]
    
    return stemmed

## -------Vectorization------------------------------------------

# Transforming all of the questions to bag-of-words format(bow)
bow_transformer = CountVectorizer(analyzer=clean_text).fit(questions['TEXT'])
questions_bow = bow_transformer.transform(questions['TEXT'])

# Checking the sparsity
sparsity = (100.0 * questions_bow.nnz / (questions_bow.shape[0] * questions_bow.shape[1]))

## -------TF-IDF transformation------------------------------------------

# Calculating TF-IDF for all questions
tfidf_transformer = TfidfTransformer().fit(questions_bow)
questions_tfidf = tfidf_transformer.transform(questions_bow)

## -------Cossine Similarity Metric------------------------------------------

# Creating the pairwise cossine similarity metric for each question combination & converting to a sparse matrix
questions_cossine = cosine_similarity(questions_tfidf)
ques_cos_csc = sparse.csc_matrix(questions_cossine)

## -------Final data transformation & Results------------------------------------------

# Converting the cossine matrix to a dataframe
coo = ques_cos_csc.tocoo(copy=False) # tocoo is the function that gets the coordinates and convert them to the columns

# Access `row`, `col` and `data` properties of coo matrix.
cossine_data = pd.DataFrame({'question_id': coo.row, 'mapped_id': coo.col, 'cos_sim': coo.data}
                 )[['question_id', 'mapped_id', 'cos_sim']].sort_values(['question_id', 'mapped_id']
                 ).reset_index(drop=True)


# Filtering the diagonal values (same question overlaps)
b = cossine_data[cossine_data['question_id']!=cossine_data['mapped_id']] 

# Filtering to get the max cossine distance value for each question
final_data = b.loc[b.groupby(["question_id"])["cos_sim"].idxmax(axis=1)]

# adding the index as a column in original data to be able join in our final mapped data
questions['index1'] = questions.index

# joining the original data with cos_sim + mapped_id data
mapped = pd.merge(questions, final_data, how='right', left_on='index1', right_on= 'question_id')

# making sure that added columns are int, not float
mapped = mapped.astype({"question_id": int, "mapped_id": int}) 

# index in train.csv starts from 0 whereas question IDs starts with 10000, just to make them identical
mapped['mapped_id'] = mapped['mapped_id']+10000

# Comparing the cos_sim results with real "PARA_ID" column
mapped['check'] = (mapped['PARA_ID'] == mapped['mapped_id'])

# Calculating the accuracy
accuracy = mapped['check'].mean()
print(accuracy)

# Calculating  the error
error = 1- mapped['check'].mean()
print(error)
# Getting the results as csv
mapped.to_csv("train_result.csv", sep=',', index= False, header=True)


## -------Applying the text processing & cossine similarity on Test Data------------------------------------------

questions = pd.read_csv("test.csv", delimiter=',')
bow_transformer = CountVectorizer(analyzer=clean_text).fit(questions['TEXT'])
questions_bow = bow_transformer.transform(questions['TEXT'])
tfidf_transformer = TfidfTransformer().fit(questions_bow)
questions_tfidf = tfidf_transformer.transform(questions_bow)
questions_cossine = cosine_similarity(questions_tfidf)
ques_cos_csc = sparse.csc_matrix(questions_cossine)

coo = ques_cos_csc.tocoo(copy=False) 
cossine_data = pd.DataFrame({'question_id': coo.row, 'mapped_id': coo.col, 'cos_sim': coo.data}
                 )[['question_id', 'mapped_id', 'cos_sim']].sort_values(['question_id', 'mapped_id']
                 ).reset_index(drop=True)

b = cossine_data[cossine_data['question_id']!=cossine_data['mapped_id']] 

final_data = b.loc[b.groupby(["question_id"])["cos_sim"].idxmax(axis=1)]
questions['index1'] = questions.index
mapped = pd.merge(questions, final_data, how='right', left_on='index1', right_on= 'question_id')
mapped["PARA_ID"] = mapped['mapped_id']
mapped.drop(mapped.columns[[2, 3, 4,5]], axis=1, inplace=True)
mapped.to_csv("result.csv", sep=',', index= False, header=True)















