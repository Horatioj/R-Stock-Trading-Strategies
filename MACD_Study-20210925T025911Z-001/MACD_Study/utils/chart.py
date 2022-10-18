import os
import sys

import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib import dates


def heat_map(df, w, h):
   plt.figure(figsize=(w, h))
   sns.heatmap(df, annot=True, cmap='RdYlGn')
   plt.show()

def line_chart(df,w,h,title, plot_columns = None, show = True, save_png = False, path = None):
   plt.figure(figsize=(w,h))
   if(plot_columns == None):
      df.plot()
   else:
      x = df.index
      for c in plot_columns:
         plt.plot(x, df[c], label = c)
   plt.title(title)
   if(save_png):
      plt.savefig(path)
   if(show):
      plt.show()
   

def plot_bar_value(rects, ax, df, column_name):
   for rect, label in zip(rects, df[column_name].values):
      height = rect.get_height()
      ax.text(rect.get_x() + rect.get_width() / 2, height + 5, label, 
      ha='center', va='bottom')

def plot_macd(df, locator_type, strategy_name, show = True, save_png = False, path= None):
   plt.style.use('fivethirtyeight')
   prices = df['Close']
   macd = df['macd']
   sig = df['sig']
   hist = df['hist']
   volume = df['Volume']

   buy_signal = df['buy_price']
   sell_signal = df['sell_price']
   fig, axs = plt.subplots(3,1)
   fig.set_figwidth(10)
   fig.set_figheight(6)
   ax1 = axs[0]
   ax2 = axs[1]
   ax3 = axs[2]
   ax1.set_title(f"{strategy_name} MACD Buy Sell Signals")
   ax1.plot(df.index, prices)
   ax1.set_ylabel('price')
   price_data = df[["Open","High", "Low","Close", "Volume"]]

   #mpf.plot(price_data, type='candle', ax = ax1, volume = ax3, style='charles')
   #candlestick_ohlc(ax1, df.values, width = 0.6, colorup = 'green', colordown='red', alpha = 0.8)
   ax1.plot(df.index, buy_signal, marker = '^', color = 'red', markersize = 10, label ='buy_signal', linewidth = 0)
   ax1.plot(df.index, sell_signal, marker = 'v', color = 'green', markersize = 10, label ='sell_signal', linewidth = 0)

   ax1.tick_params(axis='x', labelrotation=45)
   
  
   if(locator_type == 'day'):
      date_format = dates.DateFormatter("%y-%m-%d")
      for ax in axs:
         ax.xaxis.set_major_locator(dates.DayLocator(bymonthday = range(1,32), interval = 20))
         ax.xaxis.set_major_formatter(date_format)
         ax.set_xlabel('Date')
   elif (locator_type == 'month'):
      date_format = dates.DateFormatter('%y-%m')
      for ax in axs:
         ax.xaxis.set_major_locator(dates.MonthLocator())
         ax.xaxis.set_major_formatter(date_format)
         ax.set_xlabel('Date')
   else:
      date_format = dates.DateFormatter("%Y")
      for ax in axs:
         ax.xaxis.set_major_locator(dates.YearLocator())
         ax.xaxis.set_major_formatter(date_format)
         ax.set_xlabel('Date')

   ax2.bar(df.index, df['Volume'])
   ax2.set_ylabel('volume(M)')
   ax3.plot(macd, color = 'orange', linewidth = 1.5, label = 'MACD')
   ax3.plot(sig, color='deepskyblue', linewidth = 1.5, label = 'Signal(EMA)')
   for i, v in hist.items():
      if v < 0:
         ax3.bar(i, v, color = '#26a69a') # #ef5350'
      else:
         ax3.bar(i, v, color = '#ef5350')
   fig.autofmt_xdate()
   fig.tight_layout()
   ax1.legend()
   ax3.legend()
   ax1.get_shared_x_axes().join(ax1, ax2)
   if(save_png):
      plt.savefig(path)
   if(show):
      plt.show()
   

def plot_strategy_stat_result(df, strategy_name, show = True, save_png = False, path = None):
   plt.figure(figsize=(14,6))
   #plt.style.use('ggplot')
   table = plt.table(cellText = [x for x in df.to_numpy()], rowLoc = 'right',rowLabels = df.index, colLabels = df.columns, colColours =["palegreen"] * len(df.columns), loc = 'best')
   table.set_fontsize(14)
   table.scale(1, 1.5)
   plt.box(on=None)
   plt.axis('off') # hide axes 
   plt.title(f'{strategy_name} Strategy Statistics Result')
   ax = plt.gca()
   if(save_png):
      plt.savefig(path)
   if(show):
      #figMan = plt.get_current_fig_manager()
      #figMan.window.showMaximized()
      plt.show()
   
