#!/usr/bin/env python
# coding: utf-8

# In[ ]:


from requests import Request, Session
from requests.exceptions import ConnectionError, Timeout, TooManyRedirects
import json

url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
#Original Sandbox Environment: 'https://sandbox-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'

parameters = {
  'start':'1',
  'limit':'15',
  'convert':'USD'
}
headers = {
  'Accepts': 'application/json',
  'X-CMC_PRO_API_KEY': '5b4c7e66-afe9-4b18-83ad-c545236aef1c',
}

session = Session()
session.headers.update(headers)

try:
  response = session.get(url, params=parameters)
  data = json.loads(response.text)
  print(data)
except (ConnectionError, Timeout, TooManyRedirects) as e:
  print(e)


# In[ ]:


type(data)


# In[ ]:


import pandas as pd

pd.set_option('display.max_columns', None)
pd.set_option('display.max_row', None)


# In[ ]:


df = pd.json_normalize(data['data'])
df['Timestamp'] = pd.to_datetime('now')
df


# In[ ]:


def api_runner():
    global df
    url = 'https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
    #Original Sandbox Environment: 'https://sandbox-api.coinmarketcap.com/v1/cryptocurrency/listings/latest'
    parameters = {
      'start':'1',
      'limit':'15',
      'convert':'USD'
    }
    headers = {
      'Accepts': 'application/json',
      'X-CMC_PRO_API_KEY': '5b4c7e66-afe9-4b18-83ad-c545236aef1c',
    }

    session = Session()
    session.headers.update(headers)

    try:
      response = session.get(url, params=parameters)
      data = json.loads(response.text)
      #print(data)
    except (ConnectionError, Timeout, TooManyRedirects) as e:
      print(e)


    df2 = pd.json_normalize(data['data'])
    df2['Timestamp'] = pd.Timestamp('now')

    #Original statement: 'df = df2.append(df2)'
    #This original statement had to be replaced as it did not work.
    df_append = pd.DataFrame(df2)
    df = pd.concat([df,df_append])
    
    #df = pd.json_normalize(data['data'])
    #df['timestamp'] = pd.to_datemine('now')
    #df
    
    if not os.path.isfile(r'C:\Users\pccra\OneDrive\Documents\Python Scripts\API.csv'):
        df.to_csv(r'C:\Users\pccra\OneDrive\Documents\Python Scripts\API.csv', header='column_names')
    else:
        df.to_csv(r'C:\Users\pccra\OneDrive\Documents\Python Scripts\API.csv', mode='a', header=False)
        


# In[ ]:


import os
from time import time
from time import sleep

for i in range(333):
    api_runner()
    print('API Runner completed')
    sleep(60) #sleep for 1 minute
exit()


# In[ ]:


df


# In[ ]:


pd.set_option('display.float_format', lambda x: '%.5f' % x)


# In[ ]:


df


# In[ ]:


df3 = df.groupby('name', sort=False)[['quote.USD.percent_change_1h', 'quote.USD.percent_change_24h', 'quote.USD.percent_change_7d', 'quote.USD.percent_change_30d', 'quote.USD.percent_change_60d', 'quote.USD.percent_change_90d']].mean()
df3


# In[ ]:


df4 = df3.stack()
df4


# In[ ]:


type(df4)


# In[ ]:


df5 = df4.to_frame(name='values')
df5


# In[ ]:


type(df5)


# In[ ]:


df5.count()


# In[ ]:


index = pd.Index(range(90))

df6 = df5.reset_index()
df6


# In[ ]:


df7 = df6.rename(columns={'level_1': 'percent_change'})
df7


# In[ ]:


df7['percent_change'] = df7['percent_change'].replace(['quote.USD.percent_change_1h', 'quote.USD.percent_change_24h', 'quote.USD.percent_change_7d', 'quote.USD.percent_change_30d', 'quote.USD.percent_change_60d', 'quote.USD.percent_change_90d'], ['1h', '24h', '7d', '30d', '60d', '90d'])
df7


# In[ ]:


import seaborn as sns
import matplotlib.pyplot as plt


# In[ ]:


sns.catplot(x = 'percent_change', y = 'values', hue = 'name', data = df7, kind = 'point')


# In[ ]:


df10 = df[['name', 'quote.USD.price', 'Timestamp']]
df10 = df10.query("name == 'Bitcoin'")
df10


# In[ ]:


df[df.index.duplicated()]


# In[ ]:


sns.set_style('darkgrid')

sns.lineplot(x='Timestamp', y='quote.USD.price', data = df10)

