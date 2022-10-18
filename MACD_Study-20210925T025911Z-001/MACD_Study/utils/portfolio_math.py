import os
import sys
from math import nan

current_dir = os.path.dirname(os.path.realpath(__file__))
sys.path.append(current_dir)
import numpy as np

from constant import PERIODS

# ret = portfolio returns
# risk_free = t note return 



def sharpe_ratio(ret, risk_free = 0, period='daily'):
    annual_factor = PERIODS[period]
    adjust_ret = ret - risk_free
    mean = np.nanmean(adjust_ret)
    std = np.nanstd(adjust_ret, ddof = 1)
    sharpe_ratio = (mean / std) * np.sqrt(annual_factor)
    return sharpe_ratio


def rolling_sharpe_ratio(ret, risk_free = 0, rolling_window = 10, period = 'daily'):
    annual_factor = PERIODS[period]
    _adjust_returns = ret - risk_free 
    nan_mask = np.isnan(_adjust_returns)
    nonnan_ret  = _adjust_returns[~nan_mask]
    rolling_sharpe_ratio = (nonnan_ret.rolling(rolling_window).mean() / nonnan_ret.rolling(rolling_window).std()) * np.sqrt(annual_factor)
    return rolling_sharpe_ratio


def rolling(sharpe_ratio, ret, risk_free =0, period = 'daily'):
    annual_factor = PERIODS[period]
    _adjust_returns = ret - risk_free


def cum_return(ret, start_value = 1):
    nan_mask = np.isnan(ret)
    if(np.any(nan_mask)):
        ret = ret.copy()
        ret[nan_mask] = 0
    ret = ret + 1
    cum_ret = ret.cumprod()
    cum_ret = cum_ret - 1
    return cum_ret

def sortino_ratio(returns, risk_free = 0, periods = 'daily'):
    annual_factor = PERIODS[periods]
    d_risk = downside_risk(returns, risk_free, periods)
    adj_returns = returns - risk_free
    annualize_returns = adj_returns * annual_factor
    ratio = np.nanmean(annualize_returns) / d_risk
    return ratio


def downside_risk(returns, risk_free, periods = 'daily'):
    annual_factor = PERIODS[periods]
    adj_returns = returns - risk_free
    down_risk_diff = np.clip(adj_returns,np.NINF, 0)
    down_risk_diff = np.square(down_risk_diff)
    down_risk_diff_mean = np.nanmean(down_risk_diff)
    sqrt_down_risk_diff_mean = np.sqrt(down_risk_diff_mean)
    return np.sqrt(annual_factor) * sqrt_down_risk_diff_mean

def omega_ratio(returns, risk_free = 0, required_return = 0, period = 'daily'):
    annualization_factor = PERIODS[period]
    if(annualization_factor == 1):
        return_threshold = required_return
    elif required_return <= -1:
        return np.nan
    else:
         return_threshold = (1 + required_return) **  (1. / annualization_factor) - 1
    
    returns_less = returns - risk_free - return_threshold
    numerator = sum(returns_less[returns_less > 0])
    denomerator = -1 * sum(returns_less[returns_less < 0])

    if denomerator >0:
        return numerator /denomerator
    else:
        return np.nan

def tail_ratio(returns):
    ret = returns.copy()
    nan_mask = np.isnan(ret)
    ret = ret[~nan_mask]
    return np.abs(np.percentile(ret, 95)) / np.abs(np.percentile(ret,5))

