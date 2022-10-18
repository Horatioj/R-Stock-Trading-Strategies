import pandas as pd 
import numpy as np 
import json
from tqdm import tqdm

with open('../list.json', 'r') as json_file:
      data = json.load(json_file)
      watch_list = data['sp500']
      missing_data_file = []
      for i in tqdm(range(0, len(watch_list))):
         symbol = watch_list[i]
         df = pd.read_csv(f'./sp500/{symbol}.csv')
         if(not len(df) > 0):
            missing_data_file.append(symbol)
      for s in missing_data_file:
         print(s)