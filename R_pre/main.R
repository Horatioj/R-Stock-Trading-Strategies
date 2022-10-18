# Clean up workspace -- 
rm(list=ls())

# Load or install necessary packages if necessary
want <- c("quantmod","dplyr", "plyr", "magrittr", "gglpot2", "scales", "reshape2", "PerformanceAnalytics")
need <- want[!(want %in% installed.packages()[,"Package"])]
if (length(need)) install.packages(need)
lapply(want, function(i) require(i, character.only=TRUE))
rm(want, need)

# Working directories
dir <- list()
dir$root <- dirname(getwd())
dir$source <- paste(dir$root,"/data",sep="")
dir$output <- paste(dir$root,"/figures",sep="")
dir$result <- paste(dir$root, "/output", sep="")
lapply(dir, function(i) dir.create(i, showWarnings = F))

source("strategies.R")
from = "1980-01-01"
# to = "2021-11-30"
threshold <- 0.05
options(warn = -1)

### Examples
BABA <- getSymbols("BABA", from = from, auto.assign = FALSE)
#change strategies as you prefer, here we use bollinger bands
t1 <- strat_bbands(BABA)
t2 <- perf(t1) # perf() is to select transactions in pair, find the first "buy" and "sell"
t3 <- ret(t2) # ret() is to calculate transactions in detail

# winrate, threshold is set as 0.05
mean(t3$return > threshold)

### final() is to calculate stock pool in detail
# the 1st param is stock pool, the 2nd param is names of stock pool, the 3rd param is strategies
# return: each stock's transactions and win rate
t <- final(dj30_pool, dj30, strat_bbands)

# monitor
# number defines the number of stocks with the highest win rate
m <- monitor(dj30_pool, dj30, 10)
