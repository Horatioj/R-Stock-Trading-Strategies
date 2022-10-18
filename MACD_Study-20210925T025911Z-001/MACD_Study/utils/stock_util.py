import pandas as pd
import numpy as np


def rising_stat_after(df, days):
   for d in days:
      df[f'Rising percentage after {d} days'] = (df['Adj Close'].shift(-d) -df['Adj Close'] ) / df['Adj Close']
      df[f'Is Rising after {d} days'] = df['Adj Close'].shift(-d) > df['Adj Close']
      df[f'Is Rising after {d} days'].fillna(False, inplace = True)
   return df


def rising_stat_before(df, days):
   for d in days:
      df[f'Rising percentage within {d} days'] = (df['Adj Close'].shift(d) -df['Adj Close'] ) / df['Adj Close']
      df[f'Is Rising within {d} days'] = df['Adj Close'].shift(d) > df['Adj Close']
      df[f'Is Rising within {d} days'].fillna(False, inplace = True)
   return df