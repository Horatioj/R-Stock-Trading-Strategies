import argparse
import json
import os
import sys
from datetime import datetime, timedelta

# import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import talib as ta

from MacdStrategy.BuyCrossLineStrategy import BuyCrossLineStrategy
from MacdStrategy.BuyCrossZeroStrategy import BuyCrossZeroStrategy
from MacdStrategy.CrosslineAndAboveZeroStrategy import \
    CrossLineAndAboveZeroStrategy
from MacdStrategy.HisgIncreamentStrategy import HisgIncrementStragegy
from utils.chart import line_chart
from utils.portfolio_math import omega_ratio, sharpe_ratio
from utils.stock_util import rising_stat_after

pd.options.display.float_format = '{:.2f}'.format

def do_statistic(strategy, start_budget, plot=False, plot_format= None, show = True, save_png= False, folder_name = None):
   strategy.get_buy_sell_signal()
   accumulated_profit = strategy.simulation() 
   strategy.calculate_transaction_detail(folder_name)
   strategy.calculate_transaction_return_stat(folder_name)
   sharpe_ratio = strategy.calculate_sharpe_ratio()
   sortino_ratio = strategy.calculate_sortino_ratio()
   omega_ratio = strategy.calculate_omega_ratio()
   tail_ratio = strategy.calculate_tail_ratio()
   cum_ret = strategy.calculate_cumulative_return()
   stat_result = strategy.stat(folder_name)
   #strategy.calculate_rolling_sharpe_ratio(rolling_window = 10)
  
   if(plot):
      if(save_png):
         strategy.plot_macd_signal(plot_format, show, save_png, folder_name)
         #depreciated
         #strategy.plot_stat_result(show, save_png, folder_name)
         #strategy.plot_transaction_detail(show,save_png,folder_name)
         #strategy.plot_transaction_return_stat(show, save_png, folder_name)
         strategy.plot_portfolio_value(show,save_png, folder_name)
         strategy.plot_daily_ret(show,save_png, folder_name)
         strategy.plot_cumulative_ret(show, save_png,folder_name)
      else:
         strategy.plot_macd_signal(plot_format, show)
         #depreciated
         # strategy.plot_stat_result(show)
         # strategy.plot_transaction_detail(show)
         # strategy.plot_transaction_return_stat(show)
         strategy.plot_portfolio_value(show)
         strategy.plot_daily_ret(show)
         strategy.plot_cumulative_ret(show)
   strategy.ouput_mertics_csv(folder_name)
   strategy.output_file_result(folder_name)
   print(f"sharpe ratio is {sharpe_ratio:.2f}")
   print(f"sortino ratio is {sortino_ratio:.2f}")
   print(f"omgea ratio is {omega_ratio:.2f}")
   print(f"tail ratio is {tail_ratio:.2f}")
   print(f"I got {accumulated_profit:.2f} profit")
   print(f"Profit% is {round((accumulated_profit / start_budget ),2) * 100}%")


def stock_simulation(symbol, start_budget, fixed_share, buy_way, signal_strategy, plot_fig, x_tick_format, show, save_png, root, start_date = None, end_date = None):
   check_path  = os.path.join(root, f'{symbol}')
   if(not os.path.exists(check_path)):
      os.makedirs(check_path)

   filename = f'{symbol}.csv'
   if(root != 'BackTestResult'):
      base_dir = os.path.basename(root)
      df = pd.read_csv(os.path.join('stock_data', base_dir, filename))
   else:
      df = pd.read_csv(f'stock_data/{filename}')
   df.set_index(pd.DatetimeIndex(df['Date']), inplace = True)
   df = df.loc[start_date: end_date]
   macd, sig, hist = ta.MACD(df['Close'], fastperiod = 12, slowperiod = 26, signalperiod =9)

   df['macd'] = macd
   df['sig'] = sig
   df['hist'] = hist

   if(signal_strategy == 'crossline'):
         strategy = BuyCrossLineStrategy(df, start_budget, symbol, fixed_share, buy_way)
   elif(signal_strategy == 'crosszero'):
         strategy = BuyCrossZeroStrategy(df, start_budget, symbol, fixed_share, buy_way)
   elif(signal_strategy == 'hist'):
         strategy = HisgIncrementStragegy(df, start_budget, symbol, fixed_share, buy_way)
   elif(signal_strategy == 'crosslineand0'):
         strategy = CrossLineAndAboveZeroStrategy(df, start_budget, symbol, fixed_share, buy_way)
   else:
         strategy = None

   if(strategy != None):
      do_statistic(strategy, start_budget, plot_fig, x_tick_format, show, save_png, root)
   else:
      strategies = [
         BuyCrossLineStrategy(df.copy(), start_budget, symbol, fixed_share, buy_way),
         BuyCrossZeroStrategy(df.copy(), start_budget, symbol, fixed_share, buy_way),
         HisgIncrementStragegy(df.copy(), start_budget, symbol, fixed_share, buy_way),
         CrossLineAndAboveZeroStrategy(df.copy(), start_budget, symbol, fixed_share, buy_way)
      ]
      for strategy in strategies:
         do_statistic(strategy, start_budget, plot_fig, x_tick_format, show, save_png, root)
      strategies_profit_percentage_df = pd.concat(
         [  strategies[0].transaction_return_percentage_stat.to_frame().T,
            strategies[1].transaction_return_percentage_stat.to_frame().T,
            strategies[2].transaction_return_percentage_stat.to_frame().T,
            strategies[3].transaction_return_percentage_stat.to_frame().T,
         ]
      )
      print(strategies_profit_percentage_df)
      strategies_profit_percentage_df.to_csv(os.path.join(root, f'{symbol}', 'macd_strategies_profit_%_stat.csv'))
   print(f"{symbol} MACD simulation completed===================")        


def merge_list_stock_stat_result(out, path):
   stat_df = pd.read_csv(path)
   out = pd.concat([out, stat_df])
   return out

def overall_stat(df):
   overall_stat_df = pd.DataFrame(np.array([[0,0,0,0,0,0]]), columns = ['buy_signal_count', 'sell_signal_count', 'trans_count', 'profit_transaction_count', 'loss_transaction_count', 'profit_probability'])
   overall_stat_df['buy_signal_count'] = df['buy_signal_count'].sum()
   overall_stat_df['sell_signal_count'] = df['sell_signal_count'].sum()
   overall_stat_df['trans_count'] = df['trans_count'].sum()
   overall_stat_df['profit_transaction_count'] = df['profit_transaction_count'].sum()
   overall_stat_df['total_gain'] = df['total_gain'].sum()
   overall_stat_df['profit_probability'] = overall_stat_df['profit_transaction_count'] / overall_stat_df['trans_count']
   overall_stat_df['loss_transaction_count'] = df['loss_transaction_count'].sum()
   overall_stat_df['total_loss'] = df['total_loss'].sum()
   overall_stat_df['loss_probability'] = overall_stat_df['loss_transaction_count'] / overall_stat_df['trans_count']
   overall_stat_df['P&L'] = (overall_stat_df['total_gain'] / overall_stat_df['profit_transaction_count']) / (overall_stat_df['total_loss'] / overall_stat_df['loss_transaction_count'])
   overall_stat_df['APPT'] = ((overall_stat_df['profit_probability'] * (overall_stat_df['total_gain']/ overall_stat_df['profit_transaction_count'])) - \
      (overall_stat_df['loss_probability'] * overall_stat_df['total_loss']/ overall_stat_df['loss_transaction_count']))
   return overall_stat_df


parser = argparse.ArgumentParser(description='This is a macd strategy console program')
parser.add_argument('-sym','--symbol', help='stock symbol')
parser.add_argument('-l', '--list', help='stock list')
parser.add_argument('-b', '--budget', help='start_budget')
parser.add_argument('-ma', '--minimal_amount', help='minimum buying amount')
parser.add_argument('-bw', '--buy_way', help='buy way')
parser.add_argument('-f', '--format', help='x tick format')
parser.add_argument('-st', '--strategy', help='signal strategy')
parser.add_argument('-s', '--save_pict', help = 'save picture')
parser.add_argument('-p', '--plot_fig', help='plot graph')
parser.add_argument('-sh', '--show', help='show graph')
parser.add_argument('-start', '--startdate', help ='start date yyyy-mm-dd')
parser.add_argument('-end', '--enddate', help='end date yyyy-mm-dd')
parser.add_argument('-market', '--market', help='stock market')


args = parser.parse_args()

start_budget = float(args.budget) if args.budget != None else 150000.00
buy_way = args.buy_way if args.buy_way != None else 'forward'
x_tick_format = args.format if args.format != None else 'day'
symbol = args.symbol
fixed_share = int(args.minimal_amount)
signal_strategy = args.strategy.lower()
save_png = True if (args.save_pict == 'True' or args.save_pict == 'true') else False
plot_fig = True if (args.plot_fig == 'True' or args.plot_fig == 'true') else False
show = False if (args.show == 'False' or args.show == 'false') else True
stock_list = args.list
market = args.market if args.market != None else  'USA'


start = datetime.strptime(args.startdate, "%Y-%m-%d")
end = datetime.strptime(args.enddate, '%Y-%m-%d')

start = datetime.strftime(start,"%Y-%m-%d")
end = datetime.strftime(end - timedelta(days=1), "%Y-%m-%d")




if(symbol == None):
   root = os.path.join('BackTestResult', stock_list)
   if(market == 'HK'):
      with open('hk_list.json', 'r') as json_file:
         data = json.load(json_file)
         watch_dict = data[stock_list]
         watch_list = list(watch_dict.keys())
         for symbol in watch_list:
            fixed_share = watch_dict[symbol]
            stock_simulation(symbol, start_budget, fixed_share, buy_way, signal_strategy, plot_fig, x_tick_format, show,  save_png, root,\
            start_date = start, end_date= end
         )
   else:
      with open('list.json', 'r') as json_file:
         data = json.load(json_file)
         watch_list = data[stock_list]
         for symbol in watch_list:
            stock_simulation(symbol, start_budget, fixed_share, buy_way, signal_strategy, plot_fig, x_tick_format, show,  save_png, root,\
            start_date = start, end_date= end
         )

   list_stat_result = pd.DataFrame()
   for symbol in watch_list:
      if(signal_strategy == 'crossline'):
         file_name = f'{symbol}_BuyCrossLineStrategy_stat.csv'
      elif(signal_strategy == 'crosszero'):
         file_name = f'{symbol}_BuyCrossZeroStrategy_stat.csv'
      elif(signal_strategy == 'hist'):
         file_name = f'{symbol}_HisgIncreamentStrategy_stat.csv'
      elif(signal_strategy == 'crosslineand0'):
         file_name = f'{symbol}_CrosslineAndAboveZeroStrategy_stat.csv'
      path = os.path.join(root, symbol, file_name)
      list_stat_result = merge_list_stock_stat_result(list_stat_result, path)


   overall_result_df = overall_stat(list_stat_result)
   overall_result_df.to_csv(os.path.join(root, f'{start}_to_{end}_{stock_list}_overall_stat.csv'), float_format = '%.2f')
else:
   root = 'BackTestResult'
   stock_simulation(symbol, start_budget, fixed_share, buy_way, signal_strategy, plot_fig, x_tick_format, show,  save_png, root,\
      start_date = start, end_date= end
   )
