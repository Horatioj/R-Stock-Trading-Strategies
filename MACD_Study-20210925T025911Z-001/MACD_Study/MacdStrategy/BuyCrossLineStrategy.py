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


class BuyCrossLineStrategy(BaseStrategy):
   def __init__(self, df, budget, symbol, each_position, buy_method = 'average'):
      BaseStrategy.__init__(self, df, budget, symbol, each_position, buy_method)

   def get_buy_sell_signal(self):
      signal = None
      self.df['buy_price'] = np.NaN
      self.df['sell_price'] = np.NaN
      self.df['trigger_signal'] = 0
      self.df['position'] = 0
      prev_position = 0
      for i, row in self.df.iterrows():
         if (row['macd'] > row['sig'] and signal != 1):
            if(self.buy_method == 'average'):
               self.df.at[i,'buy_price'] =  (row['High'] + row['Low']) / 2
            elif(self.buy_method == 'forward'):
               next_row = self.df[self.df.index > i].head(1)
               if(len(next_row['Open'].values) >0):
                  buy_price = next_row['Open'].values[0]
                  self.df.at[i, 'buy_price'] = buy_price
               else:
                  self.df.at[i, 'buy_price'] = row['Close']
            else:
               self.df.at[i, 'buy_price'] = row['Close']
            signal = 1
            self.df.at[i, 'trigger_signal'] =  1
            self.df.at[i, 'position'] = 1
            prev_position = 1
         elif (row['macd']< row['sig'] and signal != -1):
            if(self.buy_method == 'average'):
               self.df.at[i,'sell_price'] =  (row['High'] + row['Low']) / 2
            elif(self.buy_method == 'forward'):
               next_row = self.df[self.df.index > i].head(1)
               if(len(next_row['Open'].values) >0):
                  sell_price = next_row['Open'].values[0]
                  self.df.at[i, 'sell_price'] = sell_price
               else:
                  self.df.at[i, 'sell_price'] = row['Close']
            else:
               self.df.at[i, 'sell_price'] = row['Close']
            signal = -1
            self.df.at[i, 'trigger_signal'] = -1
            if(prev_position == 1):
               self.df.at[i, 'position'] = 0
               prev_position = 0
         else:
            self.df.at[i, 'position'] = prev_position
      self._forward_signal_adjustment()
