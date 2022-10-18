import pandas as pd
import pandas as pd
import numpy as np
import talib as ta
import matplotlib.pyplot as plt 
from matplotlib import dates 
from MacdStrategy.BuyCrossLineStrategy import BuyCrossLineStrategy
from MacdStrategy.BuyCrossZeroStrategy import BuyCrossZeroStrategy
from MacdStrategy.HisgIncreamentStrategy import HisgIncrementStragegy
from utils.chart import plot_macd, plot_strategy_stat_result
from utils.stock_util import rising_stat_after


symbol = '0700.HK'
start_budget = 150000
fixed_share = 400
buy_way = 'forward'
x_tick_format = 'day'

filename = f'{symbol}.csv'
df = pd.read_csv(f'stock_data/{filename}')
df.set_index(pd.DatetimeIndex(df['Date']), inplace = True)
macd, sig, hist = ta.MACD(df['Adj Close'], fastperiod = 12, slowperiod = 26, signalperiod =9)

df['macd'] = macd
df['sig'] = sig
df['hist'] = hist
df = df.loc['2021-01-01' : '2021-07-15']


strategy = HisgIncrementStragegy(df, start_budget, symbol, fixed_share, buy_way)
strategy.get_buy_sell_signal()