import pandas as pd
import yfinance as yf
from pandas_datareader import data as pdr

yf.pdr_override()


class Downloader:

   def download_from_yahoo_to_file(self, trickers, start, end, filename, extract_col=None):
      df = pdr.get_data_yahoo(trickers, start , end)
      if extract_col != None:
         df = df[extract_col]
      df.to_csv(filename)
   
   def download_from_yahoo(self, trickers, start, end, extract_col = None):
      df = pdr.get_data_yahoo(trickers, start, end)
      if extract_col != None:
         df = df[extract_col]
      return df
