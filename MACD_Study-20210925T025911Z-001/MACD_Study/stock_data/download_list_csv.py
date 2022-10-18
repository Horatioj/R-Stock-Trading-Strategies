import sys, os
current_dir = os.path.dirname(os.path.realpath(__file__))
parent_dir = os.path.dirname(current_dir)
sys.path.append(parent_dir)
import yfinance as yf 
from datetime import datetime 
from utils.downloader import Downloader
import json 
import argparse 
from tqdm import tqdm 
yf.pdr_override()


parser = argparse.ArgumentParser(description='This is a macd strategy console program')
parser.add_argument('-l','--list', help='stock symbol')
parser.add_argument('-market', '--market', help='stock market')
parser.add_argument('-start', '--startdate', help ='start date yyyy-mm-dd')
parser.add_argument('-end', '--enddate', help='end date yyyy-mm-dd')


args = parser.parse_args()
start = datetime.strptime(args.startdate, '%Y-%m-%d')
end = datetime.strptime(args.enddate, '%Y-%m-%d')
watch_list = args.list
market = args.market if args.market != None else  'USA'

if( market == 'HK'):
   with open('../hk_list.json', 'r') as json_file:
      data = json.load(json_file)
      stock_dict = data[watch_list]
      stock_list = list(stock_dict.keys())
else:
   with open('../list.json', 'r') as json_file:
      data = json.load(json_file)
      stock_list = data[watch_list]

done_list = []

if(not os.path.exists(watch_list)):
      os.makedirs(watch_list)

for i in tqdm(range(0, len(stock_list))):
   symbol = stock_list[i]
   print(symbol)
   downloader = Downloader()
   df = downloader.download_from_yahoo(symbol, start, end)
   df.to_csv(os.path.join(watch_list, f'{symbol}.csv'))
   done_list.append(symbol)
print(done_list)
print("completed======================")
