import math
import os
import sys
from datetime import datetime, timedelta

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import utils.chart as ChartUtil
import utils.portfolio_math as pf_math
import utils.stock_util


class BaseStrategy:
   def __init__(self, df, budget, symbol, each_position, buy_method = 'average'):
      self.df = df 
      self.buy_method = buy_method
      self.budget = budget 
      self.symbol = symbol 
      self.each_position = each_position
      self.transaction_detail_df = pd.DataFrame()
      self.performance_stat = pd.DataFrame()
      self.transaction_return_percentage_stat = pd.DataFrame()
      self.accumulated_profit = 0
      self.sharpe_ratio = None
      self.sortino_ratio = None
      self.omega_ratio = None
      self.tail_ratio = None
      self.rolling_sharpe_column_name = ''
      self.cum_ret = None
      self.stat_result = pd.DataFrame()

   def _forward_signal_adjustment(self):
      if(self.buy_method == 'forward'):
         self.df['trigger_signal'] = self.df['trigger_signal'].shift(1)
         self.df['position'] = self.df['position'].shift(1)
         self.df['buy_price'] = self.df['buy_price'].shift(1)
         self.df['sell_price'] = self.df['sell_price'].shift(1)

   def _forward_signal_adjustback(self):
      if(self.buy_method == 'forward'):
         self.df['trigger_signal'] = self.df['trigger_signal'].shift(-1)
   
   def get_buy_sell_signal(self):
      raise NotImplementedError()
   

   def simulation(self,slice_interval = False, begin=None, end =None):
      if(slice_interval):
         self.df = self.df.loc[begin:end]
      self.profit = []
      prev_position = self.df.iloc[0]['position']
      prev_holding = 0.0
      prev_cash_holding = self.budget
      self.df['holding'] = 0.0
      self.df['cash_holding'] = self.budget
      self.df['holding_value'] = 0.0
      self.df['market_value'] = 0.0
      for i, row in self.df.iterrows():
         current_position = row['position']
         if((row['trigger_signal']) !=0): #and (current_position != prev_position)):
            if(row['trigger_signal'] == 1 and prev_holding == 0):
               print("")
               print(f"Buying=========== at {i}")
               print(f"Current holding is {prev_holding}")
               print("current cash is ", prev_cash_holding, "buy price is ", row['buy_price'])
               buy_holding = int(prev_cash_holding / (row['buy_price'] * self.each_position)) * self.each_position
               trans_v = (buy_holding * row['buy_price'])
               if(trans_v !=0 and prev_cash_holding >= trans_v):
                  self.df.at[i,'holding'] = buy_holding
                  print("Now, Holding is ", buy_holding)
                  self.df.at[i, 'market_value'] = row['Close'] * buy_holding
                  self.df.at[i,'cash_holding']  = prev_cash_holding - trans_v
                  print("After buying current cash holding is ", (prev_cash_holding - trans_v))
                  self.profit.append({
                     'buy_v': trans_v,
                     'buy_date': i,
                     'buy_shares': buy_holding,
                     'buy_price': row['buy_price']
                  })
                  self.df.at[i,'holding_value'] = row['Close'] * buy_holding
               else:
                  print("We don't have enough to buy the stock")
                  self.df.at[i, 'holding'] = prev_holding
                  self.df.at[i,'cash_holding'] = prev_cash_holding
                  self.df.at[i,'holding_value'] = row['Close'] * buy_holding
            else:
               if(row['trigger_signal'] == -1 and prev_holding > 0):
                  print("")
                  print(f"Selling======== at {i}")
                  print("current cash holding is", prev_cash_holding, "Holding shares is ", prev_holding)
                  self.df.at[i,'holding'] = 0
                  sell_v = row['sell_price'] * prev_holding
                  self.df.at[i,'cash_holding'] = prev_cash_holding + sell_v
                  print("Afer selling, current cash holding is ", row['cash_holding'])
                  current_p = self.profit[-1]
                  current_p['sell_v'] = sell_v
                  current_p['sell_date'] = i
                  current_p['sell_price'] = row['sell_price']
                  current_p['sell_shares'] = prev_holding
               else:
                  self.df.at[i, 'holding'] = prev_holding
                  self.df.at[i,'cash_holding'] = prev_cash_holding
                  self.df.at[i,'holding_value'] = row['Close'] * prev_holding 
         else:
            self.df.at[i,'holding'] = prev_holding
            self.df.at[i,'cash_holding'] = prev_cash_holding
            self.df.at[i, 'holding_value'] = row['Close'] * prev_holding #row['Adj Close'] * row['holding']
         prev_holding = self.df.loc[i]['holding']
         prev_cash_holding = self.df.loc[i]['cash_holding']
         prev_position = self.df.loc[i]['position']
      #self.df.to_csv('check.csv')
      self.df['portfolio_value'] = self.df['cash_holding'] + self.df['holding_value']
      self.df['daily_return'] = (self.df['portfolio_value'] - self.df['portfolio_value'].shift(1) ) / self.df['portfolio_value'].shift(1)
      self.accumulated_profit = 0
      if(len(self.profit) > 0):
         last_profit = self.profit[-1]
         if(not 'sell_v' in last_profit):
            last_profit['sell_v'] = self.df.iloc[-1]['Close'] * self.df.iloc[-1]['holding']
            last_profit['sell_price'] = self.df.iloc[-1]['Close']
            last_profit['sell_shares'] = self.df.iloc[-1]['holding']
            last_profit['sell_date'] = self.df.iloc[-1]['Date']
      for p in self.profit:
         print(p)
         self.accumulated_profit = self.accumulated_profit + p['sell_v'] - p['buy_v']
      self._forward_signal_adjustback()
      return self.accumulated_profit

   def output_file_result(self, folder_name):
      copy = self.df.copy()
      copy.drop(columns = ['Date'], inplace= True)
      copy.to_csv(os.path.join(folder_name, f'{self.symbol}', f'backtest_{self.symbol}_{type(self).__name__}.csv'), float_format = '%.2f')
   
   def stat(self, folder_name):
      period = self.df.index[0].strftime('%Y-%m-%d') + '-' + self.df.index[-1].strftime('%Y-%m-%d')
      buy_signal_count = len(self.df[self.df['trigger_signal'] == 1])
      sell_signal_count = len(self.df[self.df['trigger_signal'] == -1])
      trans_count = len(self.profit)
      profit_trans_count = 0
      loss_trans_count = 0
      total_gain =0 
      total_loss = 0
      for p in self.profit:
         profit = p['sell_v'] - p['buy_v']
         if profit > 0:
            total_gain += profit
            profit_trans_count +=1
         else:
            total_loss += profit
            loss_trans_count += 1
      p_and_l =  (total_gain / profit_trans_count) / (total_loss/ loss_trans_count) if profit_trans_count >0 and loss_trans_count > 0 else 0
      appt =  ((profit_trans_count / trans_count) * (total_gain / profit_trans_count)) - \
            ((loss_trans_count / trans_count) * (total_loss / loss_trans_count)) if profit_trans_count >0 and loss_trans_count > 0 and trans_count > 0 else 0
      self.stat_result = pd.DataFrame({
         'buy_signal_count': [buy_signal_count],
         'sell_signal_count': [sell_signal_count],
         'trans_count': [trans_count],
         'profit_transaction_count':[profit_trans_count],
         'total_gain': [total_gain],
         'profit_transaction_probability': [profit_trans_count / trans_count] if trans_count >0 else [0],
         'loss_transaction_count': [trans_count - profit_trans_count],
         'total_loss': [total_loss],
         'loss_transaction_probability':loss_trans_count / trans_count if trans_count >0 else [0],
         'P&L': [p_and_l],
         'APPT': [appt]
      })
      self.stat_result.index = [period]
      self.stat_result.to_csv(os.path.join(folder_name, f'{self.symbol}', f'{self.symbol}_{type(self).__name__}_stat.csv'), float_format = '%.2f')
      return self.stat_result
   
   def plot_macd_signal(self, locator_type, show = True, save_png = False, folder_name = None):
      strategy_name = f'{self.symbol} {type(self).__name__}'
      if(save_png):
         ChartUtil.plot_macd(self.df, locator_type, strategy_name, show,save_png, \
            os.path.join(folder_name, f'{self.symbol}', f'{strategy_name}_macd_signal.png'))
      else:
         ChartUtil.plot_macd(self.df, locator_type,strategy_name, show)

   def plot_stat_result(self, show = True, save_png = False, folder_name = None):
      strategy_name = f'{self.symbol}  {type(self).__name__} MACD'
      if(save_png):
         ChartUtil.plot_strategy_stat_result(self.stat_result,strategy_name,show,save_png, \
            os.path.join(folder_name, f'{self.symbol}', f'{strategy_name}_statistics.png'))
      else:
         ChartUtil.plot_strategy_stat_result(self.stat_result,strategy_name,show)
   
   def calculate_transaction_detail(self, folder_name):
      if(self.transaction_detail_df.empty and len(self.profit) > 0 ):
         self.transaction_detail_df = pd.DataFrame(self.profit)
         self.transaction_detail_df.index = self.transaction_detail_df.index + 1# set index start from 1
         #self.transaction_detail_df['holding_days'] = self.transaction_detail_df['sell_date'] - self.transaction_detail_df['buy_date']
         self.transaction_detail_df['return_amount'] = self.transaction_detail_df['sell_v'] - self.transaction_detail_df['buy_v']
         self.transaction_detail_df['return'] = (self.transaction_detail_df['return_amount'] / self.transaction_detail_df['buy_v'])
      self.transaction_detail_df.to_csv(os.path.join(folder_name, f'{self.symbol}', f'{self.symbol}_{type(self).__name__}_transaction_detail.csv',\
         ), float_format = '%.2f')
   
   def plot_transaction_detail(self, show = True, save_png = False, folder_name = None):
      strategy_name = f'{self.symbol}  {type(self).__name__} MACD'
      if(save_png):
          ChartUtil.plot_strategy_stat_result(self.transaction_detail_df, strategy_name, show, save_png, \
             os.path.join(folder_name,  f'{self.symbol}', f'{strategy_name}_transaction_detail.png'))
      else:
          ChartUtil.plot_strategy_stat_result(self.transaction_detail_df,strategy_name, show)
   
   def calculate_transaction_return_stat(self, folder_name):
      if(self.transaction_detail_df.empty and len(self.profit) > 0 ):
         self.transaction_detail_df = pd.DataFrame(self.profit)
         #self.transaction_detail_df['holding_days'] = (self.transaction_detail_df['sell_date'] - self.transaction_detail_df['buy_date']).days
         self.transaction_detail_df['return_amount'] = self.transaction_detail_df['sell_v'] - self.transaction_detail_df['buy_v']
         self.transaction_detail_df['return'] = (self.transaction_detail_df['return_amount'] / self.transaction_detail_df['buy_v'])
      if(not self.transaction_detail_df.empty):
         transaction_stat = self.transaction_detail_df.describe()
         self.transaction_return_percentage_stat = transaction_stat['return']
         self.transaction_return_percentage_stat.name = f'{type(self).__name__}_return'
         profit_percentage_stat_df = self.transaction_return_percentage_stat.to_frame().T
         profit_percentage_stat_df.to_csv(os.path.join(folder_name, f'{self.symbol}', f'{self.symbol}_{type(self).__name__}_transaction_return_stat.csv'),\
         float_format = '%.2f')

   def plot_transaction_return_stat(self, show = True, save_png = False, folder_name = None):
      strategy_name = f'{self.symbol}  {type(self).__name__} MACD'
      profit_percentage_stat_df = self.transaction_return_percentage_stat.to_frame().T
      if(save_png):
         ChartUtil.plot_strategy_stat_result(profit_percentage_stat_df, strategy_name, show,save_png,  \
            os.path.join(folder_name, f'{self.symbol}', f'{strategy_name}_transaction_return_stat.png')
         )
      else:
         ChartUtil.plot_strategy_stat_result(profit_percentage_stat_df,strategy_name, show)
   
   def plot_portfolio_value(self, show = True, save_png = False, folder_name = None):
      strategy_name = f'{self.symbol}  {type(self).__name__} MACD'
      if(save_png):
         ChartUtil.line_chart(self.df, 10,8, f'{strategy_name} Portfolio Value', ['portfolio_value'], show,save_png,\
            os.path.join(folder_name,  f'{self.symbol}', f'{strategy_name}_portfolio_value.png'))
      else:      
         ChartUtil.line_chart(self.df, 10,8, f'{strategy_name} Portfolio Value', ['portfolio_value'], show)
   
   def plot_daily_ret(self, show = True, save_png = False, folder_name = None):
      strategy_name = f'{self.symbol}  {type(self).__name__} MACD'
      if(save_png):
         ChartUtil.line_chart(self.df, 10,8, f'{strategy_name} Strategy Daily Return',['daily_return'], show,save_png, \
            os.path.join(folder_name,  f'{self.symbol}', f'{strategy_name}_daily_return.png'))
      else:
         ChartUtil.line_chart(self.df, 10,8, f'{strategy_name} Strategy Daily Return',['daily_return'],show)

   def plot_cumulative_ret(self, show = True, save_png = False, folder_name = None):
      strategy_name = f'{self.symbol}  {type(self).__name__} MACD'
      if(save_png):
         ChartUtil.line_chart(self.df, 10,8, f'{strategy_name} Cumulative Return',['cumulative_ret'], show, save_png, \
            os.path.join(folder_name,  f'{self.symbol}', f'{strategy_name}_cumulative_return.png'))
      else:
         ChartUtil.line_chart(self.df, 10,8, f'{strategy_name} Cumulative Return',['cumulative_ret'], show)

   def plot_rolling_sharpe_ratio(self, show=True, save_png = False, folder_name = None):
      strategy_name = f'{self.symbol}  {type(self).__name__} MACD'
      if(save_png):
         ChartUtil.line_chart(self.df, 10,8, f'{strategy_name} Rolling Sharpe Ratio',[self.rolling_sharpe_column_name], show, save_png, \
            os.path.join(folder_name,  f'{self.symbol}', f'{strategy_name}_rolling_sharpe_ratio.png'))
      else:
         ChartUtil.line_chart(self.df, 10,8, f'{strategy_name} Rolling Sharpe Ratio',[self.rolling_sharpe_column_name], show)

   def calculate_sharpe_ratio(self, risk_free =0, period = 'daily' ):
      self.sharpe_ratio =  pf_math.sharpe_ratio(self.df['daily_return'], risk_free, 'daily')
      return self.sharpe_ratio

   def calculate_cumulative_return(self):
      cumulative_ret = pf_math.cum_return(self.df['daily_return'])
      self.df['cumulative_ret'] = cumulative_ret
      return cumulative_ret
   
   def calculate_sortino_ratio(self, risk_free =0, period = 'daily'):
      self.sortino_ratio =  pf_math.sortino_ratio(self.df['daily_return'],0, 'daily')
      return self.sortino_ratio

   def calculate_omega_ratio(self, risk_free = 0, required_return = 0, period = 'daily'):
      self.omega_ratio = pf_math.omega_ratio(self.df['daily_return'], risk_free, required_return, period)
      return self.omega_ratio

   def calculate_tail_ratio(self):
      self.tail_ratio = pf_math.tail_ratio(self.df['daily_return'])
      return self.tail_ratio

   def calculate_rolling_sharpe_ratio(self, risk_free = 0, rolling_window = 10, period = 'daily'):
      self.rolling_sharpe_column_name = f'{rolling_window}_day_rolling_sharpe_ratio'
      self.df[self.rolling_sharpe_column_name] = pf_math.rolling_sharpe_ratio(self.df['daily_return'], risk_free, rolling_window, period)

   def ouput_mertics_csv(self, folder_name):
      strategy_name = f'{self.symbol}  {type(self).__name__} MACD '
      result_df = pd.DataFrame([
         [self.sharpe_ratio, self.sortino_ratio, self.omega_ratio, self.tail_ratio]], \
            columns = ['sharpe_ratio', 'sortion_ratio', 'omega_ratio', 'tail_ratio'
      ], index=[(type(self).__name__)])
      result_df.to_csv(os.path.join(folder_name,  f'{self.symbol}', f'{strategy_name}_metrics.csv'), float_format='%.2f')
