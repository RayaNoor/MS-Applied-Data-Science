#!/usr/bin/env python
# coding: utf-8

# In[1]:


# STRUCTURED DATA PROCESSING

import csv
import numpy as np
import pandas as pd

infile = 'ted_talks_en.csv'

# create new empty list
IDlist = []

with open(infile, 'r') as csvfile:
    # the csv file reader returns a list of the csv items on each line
    IDreader = csv.reader(csvfile, dialect='excel', delimiter=',')
    
    # from each line, a list of row items, put each element in a dictionary with a key representing the data
    for line in IDreader:
      #skip lines without data, specific for each file to catch non-data lines
      if line[0] == '' or line[0].startswith('talk_id'):
          continue
      else:
          try:
            # create a dictionary for each ID
            ID = {}
            # add each piece of data under a key representing that data
            ID['Talk ID'] = line[0]
            ID['Title'] = line[1]
            ID['Speaker 1'] = line[2]
            ID['All Speakers'] = line[3]
            ID['Occupations'] = line[4]
            ID['About Speakers'] = line[5]
            ID['Views'] = line[6]
            ID['Date Recorded'] = line[7]
            ID['Date Published'] = line[8]
            ID['Event'] = line[9]
            ID['Lang Native'] = line[10]
            ID['Lang Available'] = line[11]                    
            ID['Comments'] = line[12]                    
            ID['Duration'] = line[13]                    
            ID['Topics'] = line[14]                    
            ID['Related Talks'] = line[15]                    
            ID['URL'] = line[16]                    
            ID['Description'] = line[17]                    
            ID['Transcript'] = line[18]

            # add this ID to the list
            IDlist.append(ID)
          # catch errors in file formatting (number items per line)  and print an error message
          except IndexError:
            print ('Error: ', line)
csvfile.close()

df = pd.DataFrame(IDlist, columns = ['Talk ID', 'Title', 'Speaker 1', 'Occupations', 'About Speakers', 'Views', 
                                     'Date Recorded', 'Date Published', 'Comments', 'Duration', 'Topics', 
                                     'Related Talks', 'Description', 'Transcript'])

# Convert columns to appropriate data types

# strip blank spaces from 'Talk ID' column
df['Talk ID'] = df['Talk ID'].str.strip()
# add leading zeros to 'Talk ID' column
df['Talk ID'] = df['Talk ID'].str.rjust(4, "0")
# set df index to 'Talk ID' field
df = df.set_index('Talk ID').sort_values(by = 'Talk ID')

df['Views'] = df['Views'].astype(int)

# convert dates to datetime format using pd.to_datetime()
df['Date Recorded'] = pd.to_datetime(df['Date Recorded'], format = '%Y-%m-%d')
df['Date Published'] = pd.to_datetime(df['Date Published'], format = '%Y-%m-%d')

# define replace function
def item_replace(xstr):
   return xstr.replace('','0') # in a string, replace any occurrence of ‘’ with '0'

# replace blank with 0 in 'Comments' column
df['Comments'] = df['Comments'].map(item_replace).astype(int)

# convert seconds to hours:minutes:seconds using pd.to_datetime()
df['Duration'] = df['Duration'].astype(int)
df['Duration'] = pd.to_datetime(df['Duration'], unit='s').dt.strftime("%H:%M:%S")
df


# In[2]:


# Are there any speakers than gave more than one talk?
speakers_max = df[['Title']].groupby(df['Speaker 1']).count()
speakers_max.sort_values(by = 'Title', ascending = False)


# In[3]:


# what is the most common recording date? (month, year)
recording_max = df[['Title', 'Date Recorded']].groupby(['Date Recorded']).count()
recording_max.sort_values(by = 'Title', ascending = False)


# In[4]:


# is there a pattern with publishing date?
publishing_max = df[['Title', 'Date Published']].groupby(['Date Published']).count()
publishing_max.sort_values(by = 'Title', ascending = False)


# In[5]:


# which talk has the most number of views?
df[['Views']].mean() # average number of views is 2.148006e+06 -> 2,148,006
max_views = df.sort_values(by = 'Views', ascending = False)[:1]
max_views


# In[6]:


# which talk has the most number of comments? least comments? avg comments?
df[['Comments']].mean() # average number of comments is 239073.907615
max_comments = df.sort_values(by = 'Comments', ascending = False)[:1]
max_comments


# In[7]:


# which talk has the longest duration?
df.sort_values(by = 'Duration', ascending = False)[:1]


# In[8]:


# transcript analysis; word cloud, sentiment analysis
ted_transcript = df[['Title', 'Speaker 1', 'Transcript']]
ted_transcript


# In[9]:


# SEMI-STRUCTURED DATA PROCESSING

# This program reads in JSON formatted data from a MongoDB collection.
# This is in a format that is structured with lines of data representing one Tweet for Twitter.
# This program contains the data as lists of JSON structures, which are just Python dictionaries and lists.

# START MONGODB
# brew services start mongodb-community@4.4

# SCRAPE TWEETS 2020 0829 
# !python run_twitter_simple_search_save.py "#TED" 4000 ted tedtweets
# !python run_twitter_simple_search_save.py "#tedtalk" 4000 ted tedtweets
# !python run_twitter_simple_search_save.py "#TEDx" 4000 ted tedtweets

# reran and collected more tweets in anticipation of only analyzing tweet text with 'lang'== 'en'


# In[10]:


import pymongo
client = pymongo.MongoClient('localhost', 27017)

db = client.ted

db.list_collection_names()


# In[11]:


collection = db.tedtweets

tweets = collection.find()

tweetlist = [tweet for tweet in tweets]
len(tweetlist) # as of 08/29/2020


# In[12]:


# Here is a little print function that will help.

def print_tweet_data(tweets):
   for tweet in tweets:
       print('\nDate:', tweet['created_at'])
       print('From:', tweet['user']['name'])
       print('Message:', tweet['text'])
       if not tweet['place'] is None:
           print('Place:', tweet['place']['full_name'])

print_tweet_data(tweetlist[:5])


# In[13]:


# My program contains pandas dataframes for processed data.

# This program does some processing to collect data from some of the fields the questions described below, 
# and write a file with the data suitable for answering each question.

import numpy as np
import pandas as pd

df = pd.DataFrame(tweetlist)

# Test for null values and remove optional fields
df.isna().sum() # sum of NaN


# In[14]:


df.dropna()

# select columns
df = df[['_id',
         'created_at',
         'text',
         'entities', ### hashtag from entities
         'user', ### name from user
         'retweet_count',
         'favorite_count',
         'lang']]

# set index to _id column
# df = df.set_index('_id')


# In[15]:


# convert df[['created_at']] to string; 
df[['created_at']] = df[['created_at']].astype(str)

# convert df[['created_at']] to datetime using pd.to_datetime()
df[['created_at']] = pd.to_datetime(df['created_at'], format = '%a %b %d %H:%M:%S +0000 %Y')


# In[16]:


# convert counts from str to int type
df[['retweet_count']] = df[['retweet_count']].astype(int)
df[['favorite_count']] = df[['favorite_count']].astype(int)


# In[17]:


# bin Tweets by day
created_date = df['created_at'].dt.date
df['created_date'] = created_date

# bin Tweets by hour
created_hour = df['created_at'].dt.hour
df['created_hour'] = created_hour


# In[18]:


# report on the number of Tweets per day
df[['created_date', 'created_at']].groupby(['created_date']).count()


# In[19]:


# What is being Tweeted on 08-22-2020?
df['created_date'] = df['created_date'].astype(str)
max_date = df[(df['created_date'] > '2020-08-21') & (df['created_date'] < '2020-08-23')]
max_date[['created_date', 'text']][:50]

# Do Schools Kill Creativity? - Sir Ken Robinson (1950-03-04 - 2020-08-21)
# https://www.ted.com/talks/sir_ken_robinson_do_schools_kill_creativity?language=en


# In[20]:


# report on the number of Tweets per hour
df[['created_at', 'created_hour']].groupby(['created_hour']).count()


# In[21]:


# report on the number of Tweets per day, per hour
created_date_hour = df[['created_at', 'created_date', 'created_hour']].groupby(['created_date', 'created_hour']).count()
created_date_hour

max_date[['created_at', 'created_date', 'created_hour']].groupby(['created_date', 'created_hour']).count().sort_values(by = 'created_at', ascending = False)[:10]


# In[22]:


# 25 different languages represented in this collection
get_ipython().system('python twitter_lang.py ted tedtweets twitter_lang_results.csv')


# In[23]:


# Using twitter_lang.py as an example, use different fields
get_ipython().system('python Raya_Young_twitter_name.py ted tedtweets twitter_name_results.csv')
# 2645 unique users


# In[24]:


# Top 20 Frequency Hashtags
get_ipython().system('python twitter_hashtags.py ted tedtweets 20')


# In[25]:


# What are the number of English Tweets in this collection?
dfen = df[df['lang']=='en']
len(dfen) # 3418 tweets in English


# In[26]:


dfen[['retweet_count']].mean() # The average number of retweets in this collection is 28.8
max_RT = dfen.sort_values(by = 'retweet_count', ascending = False)[:1] 
max_RT # The maximum number of retweets in this collection is 1235

# Sandeep Ahlawat, Lieutenant Colonel of Indian Army - https://www.youtube.com/watch?v=8wU-cK9G4V8
# https://twitter.com/SandyAhlawat89/status/1175335660162433027


# In[27]:


dfen[['favorite_count']].mean() # The average number of favorites in this collection is 2
max_fave = dfen.sort_values(by = 'favorite_count', ascending = False)[:1]
max_fave # The maximum number of favorites in this collection is 818


# In[28]:


# What are the shared features of the top 1000 most popular Retweets?
topRT = dfen.sort_values(by = 'retweet_count', ascending = False).head(1000) # 1/3 of collection for training
topRT


# In[29]:


# consolidated repeated RTs
topRT = dfen[['text', 'retweet_count']].groupby(topRT['text']).sum().sort_values(by = 'retweet_count', ascending = False)
topRT

# Racism Has a Cost for Everyone - Heather C. McGee
# https://www.ted.com/talks/heather_c_mcghee_racism_has_a_cost_for_everyone?utm_source=t.co&utm_content=2020-8-20&utm_medium=referral&utm_campaign=social


# In[30]:


# What are the number of English Tweets in this collection?
dfen = df[df['lang']=='en']
len(dfen) # 3418 tweets in English


# In[31]:


# Text Tokenization
import nltk

client = pymongo.MongoClient('localhost', 27017)

db = client.ted

db.list_collection_names()


# In[32]:


collection = db.tedtweets

tweets = collection.find()

tweetlist = list(tweets)

textlist = [tweet['text'] for tweet in tweetlist if 'text' in tweet.keys()]
len(textlist)


# In[33]:


all_tokens = [tok for text in textlist for tok in nltk.word_tokenize(text)]
len(all_tokens) #119204
all_tokens[:50]


# In[34]:


textFD = nltk.FreqDist(all_tokens)
textFD.most_common(30)


# In[35]:


import re
def alpha_filter(w):
    pattern = re.compile('^[^a-z]+$')
    if (pattern.match(w)):
        return True
    else: 
        return False
    
token_list = [tok for tok in all_tokens if not alpha_filter(tok)]
token_list[:30]


# In[36]:


textFD = nltk.FreqDist(token_list)

top_words = textFD.most_common(30)

for word, freq in top_words:
    print(word, freq)


# In[63]:


from nltk.tokenize import word_tokenize
from nltk.sentiment.vader import SentimentIntensityAnalyzer

nltk_stopwords = nltk.corpus.stopwords.words('english')
nltk_stopwords

# transcript analysis; word cloud, sentiment analysis
max_views_script = max_views['Transcript'] # Do Schools Kill Creativity? - Sir Ken Robinson

max_comments_script = max_comments['Transcript'] # Militant Atheism - Richard Dawkins

# max_favorites_script = 


# In[64]:


views_tokens = max_views_script.apply(word_tokenize)
views_tokens_list = [word for word in views_tokens if word not in nltk_stopwords]
views_tokens_list


# In[73]:


from textblob import TextBlob

text = str(views_tokens_list)

blob = TextBlob(text)
blob.tags           

blob.noun_phrases   

for sentence in blob.sentences:
    print(sentence.sentiment.polarity)


# In[40]:


comments_tokens = max_comments_script.apply(word_tokenize)
comments_tokens_list = [word for word in comments_tokens if word not in nltk_stopwords]
comments_tokens_list


# In[54]:


words = nltk.tokenize.word_tokenize(str(max_comments_script))
textFD = nltk.FreqDist(words)

top_words = textFD.most_common(30)

for word, freq in top_words:
    print(word, freq)


# In[41]:


text = str(comments_tokens_list)

blob = TextBlob(text)
blob.tags           

blob.noun_phrases  

for sentence in blob.sentences:
    print(sentence.sentiment.polarity)

