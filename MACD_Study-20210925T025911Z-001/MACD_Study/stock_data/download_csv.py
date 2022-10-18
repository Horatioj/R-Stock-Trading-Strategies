import sys, os
current_dir = os.path.dirname(os.path.realpath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.append(parent_dir)
import pandas as pd
import numpy as np 
import yfinance as yf 
import pandas_datareader.data as pdr
from datetime import datetime 
from utils.downloader import Downloader
import argparse
yf.pdr_override()

parser = argparse.ArgumentParser(description='This is a macd strategy console program')
parser.add_argument('-sym','--symbol', help='stock symbol')
parser.add_argument('-start', '--startdate', help ='start date yyyy-mm-dd')
parser.add_argument('-end', '--enddate', help='end date yyyy-mm-dd')


args = parser.parse_args()
start = datetime.strptime(args.startdate, '%Y-%m-%d')
end = datetime.strptime(args.enddate, '%Y-%m-%d')
symbol = args.symbol


downloader = Downloader()
df = downloader.download_from_yahoo(symbol, start, end)
df.to_csv(f'{symbol}.csv')

