import math
import os
import sys
from datetime import datetime

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import utils.stock_util
from matplotlib import dates

current_dir = os.path.dirname(os.path.realpath(__file__))
sys.path.append(current_dir)
from BaseStrategy import BaseStrategy


class CrossLineAndAboveZeroStrategy(BaseStrategy):
   def __init__(self, df, budget, symbol, each_position, buy_method = 'average'):
      BaseStrategy.__init__(self, df, budget, symbol, each_position, buy_method)

   def get_buy_sell_signal(self):
      cod_1 = self.df['macd'] > self.df['sig'] 
      cod_2 = self.df['macd'].shift(1) < self.df['sig'].shift(1)
      cod_3 = self.df['macd'] > 0

      self.df.loc[cod_1 & cod_2 & cod_3, 'trigger_signal'] = 1
      cod_1 = self.df['macd'] < self.df['sig']
      cod_2 = self.df['macd'].shift(1) > self.df['sig'].shift(1)
      cod_3 = self.df['macd'] < 0

      self.df.loc[cod_1 & cod_2 & cod_3, 'trigger_signal'] = -1
      self.df['trigger_signal'].fillna(0, inplace = True)

      self.df['buy_price'] = np.NaN
      self.df['sell_price'] = np.NaN
      self.df['position'] = 0
      prev_position = 0
      for i, row in self.df.iterrows():
         if(row['trigger_signal'] == 1 and prev_position ==0 ):
            if(self.buy_method == 'average'):
               self.df.at[i,'buy_price'] =  (row['High'] + row['Low']) / 2
            elif(self.buy_method == 'forward'):
               next_row = self.df[self.df.index > i].head(1)
               if(len(next_row['Open'].values) >0):
                  buy_price = next_row['Open'].values[0]
                  self.df.at[i, 'buy_price'] = buy_price
               else:
                  self.df.at[i, 'buy_price'] = row['Adj Close']
            else:
               self.df.at[i, 'buy_price'] = row['Adj Close']
            self.df.at[i, 'position'] = 1
            prev_position = 1
         elif(row['trigger_signal'] == -1 and prev_position == 1):
            if(self.buy_method == 'average'):
               self.df.at[i,'sell_price'] =  (row['High'] + row['Low']) / 2
            elif(self.buy_method == 'forward'):
               next_row = self.df[self.df.index > i].head(1)
               if(len(next_row['Open'].values) >0):
                  sell_price = next_row['Open'].values[0]
                  self.df.at[i, 'sell_price'] = sell_price
               else:
                  self.df.at[i, 'sell_price'] = row['Adj Close']
            else:
               self.df.at[i, 'sell_price'] = row['Adj Close']
            self.df.at[i, 'position'] = 0
            prev_position = 0
         else:
            self.df.at[i, 'position'] = prev_position
      self._forward_signal_adjustment()

    