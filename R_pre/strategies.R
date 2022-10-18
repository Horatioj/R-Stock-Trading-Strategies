# # Clean up workspace -- 
# rm(list=ls())
# 
# # Load or install necessary packages if necessary
# want <- c("quantmod","dplyr", "plyr", "magrittr", "gglpot2", "scales", "reshape2")
# need <- want[!(want %in% installed.packages()[,"Package"])]
# if (length(need)) install.packages(need)
# lapply(want, function(i) require(i, character.only=TRUE))
# rm(want, need)

# strategies
strategies <- c("SMA", "ARBR", "BBANDS", "CCI", "DMI", "MACD", "OBV", "PVT", "ROC", 
                "RSI", "SAR", "SMI", "WPR", "DMISMI","DMIMACD", "SMIRSI", "BBRSI", "MACDCCI",
                "MACDSMI", "MACDRSI", "MACDSAR", "OBVMACD", "OBVSMA", "PVTSMA", "PVTMACD", "PVTSTC")

############### # trading strategies 

# basic strategies ########################################################


# sma / ema / wma / 
strat_sma <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n < 50) {
    print("x should be longer than 50.")
    return(res)
  }
  sma10 <- SMA(Cl, n = 10)
  sma20 <- SMA(Cl, n = 20)
  sma50 <- SMA(Cl, n = 50)
  # from 51
  for (i in 51:(n-1)) {
    if ((sma10[i - 1] < sma20[i - 1] || sma20[i - 1] < sma50[i - 1])
        && (sma10[i] >= sma20[i] && sma20[i] >= sma50[i])) {
      signal <- "buy"
    } else if ((sma10[i - 1] > sma20[i - 1] || sma20[i - 1] > sma50[i - 1])
               && (sma10[i] <= sma20[i] && sma20[i] <= sma50[i])) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# macd
strat_macd <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n < 35) {
    print("x should be longer than 35.")
    return(res)
  }
  # MACD is a function from TTR.
  MACDS <- MACD(Cl, nFast = 12, nSlow = 26, nSig = 9, maType = "EMA")
  macd <- MACDS[, "macd"]
  macdsignal <- MACDS[, "signal"]
  # from 34 = (26 - 1 + 9 - 1) + 1
  for (i in 35:(n-1)) {
    if (macd[i - 1] < macdsignal[i - 1] && macd[i] > macdsignal[i]) {
      signal <- "buy"
    } else if (macd[i - 1] > macdsignal[i - 1] && macd[i] < macdsignal[i]) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# rsi
strat_rsi <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n < 14) {
    print("x should be longer than 14.")
    return(res)
  }
  rsi <- data.frame(RSI(Cl, 14))
  for (i in 35:(n-1)) {
    if (TF30(i,i,rsi$rsi)) {
      signal <- "buy"
    } else if (TF70(i,i,rsi$rsi))
    {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# bollinger's bands
strat_bbands <- function(x, n = 20) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  nlen <- length(Cl)
  if (nlen < n) {
    print(paste("x should be longer than ", n, "."))
    return(res)
  }
  bbands <- BBands(HLC(x), n = n)
  for (i in (n + 1):(nlen-1)) {
    if (Cl[i - 1] > bbands$dn[i - 1] && Cl[i] < bbands$dn[i]) {
      signal <- "buy"
    } else if (Cl[i - 1] < bbands$up[i - 1] && Cl[i] > bbands$up[i])
    {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# dmi
strat_dmi <- function(x, n = 14){
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  nlen <- length(Cl)
  if (nlen < n) {
    print(paste("x should be longer than ", n, "."))
    return(res)
  }
  adx <- ADX(HLC(x))
  DIp <- adx[, "DIp"]  # green positive Direction Index
  DIn <- adx[, "DIn"]  # red negative Direction Index
  for (i in (n + 2):(nlen-1)) {
    if (DIp[i - 1] < DIn[i - 1] && DIp[i] > DIn[i]) {
      signal <- "buy"
    } else if (DIp[i-1] > DIn[i - 1] && DIp[i] < DIn[i])
    {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# roc
strat_roc <- function(x, n = 20){
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  nlen <- length(Cl)
  if (nlen < n) {
    print(paste("x should be longer than ", n, "."))
    return(res)
  }
  roc <- ROC(Cl, n = n)
  for (i in (n + 2):(nlen-1)) {
    if ((roc[i-1] < 0) && (roc[i] > 0)) {
      signal <- "buy"
    } else if ((roc[i-1] > 0) && (roc[i] < 0))
    {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# smi / stochastic / stc
strat_smi <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n < 35) {
    print("x should be longer than 35.")
    return(res)
  }
  # MACD is a function from TTR.
  smi_result <- SMI(HLC(x), n = 13, nFast = 2, nSlow = 25, nSig = 9)
  smi <- smi_result[, "SMI"]
  smisignal <- smi_result[, "signal"]
  # from 34 = (26 - 1 + 9 - 1) + 1
  for (i in 35:(n-1)) {
    if (smi[i - 1] < smisignal[i - 1] && smi[i] > smisignal[i]) {
      signal <- "buy"
    } else if (smi[i - 1] > smisignal[i - 1] && smi[i] < smisignal[i]) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# KDJ
strat_kdj <- function(x, n = 9){
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- as.vector(Cl(x))
  Op <- as.vector(Op(x))
  Hi <- as.vector(Hi(x))
  Lo <- as.vector(Lo(x))
  nlen <- length(Cl)
  list <- c()
  for(i in 1:nlen){
    if(Cl[i]==Lo[i] || Hi[i]==Lo[i]){
      list <- append(list, i)
    }
  }
  if (!is.null(list)){
    x <- x[-list, ]
  }
  Cl <- Cl(x)
  Op <- Op(x)
  Hi <- Hi(x)
  Lo <- Lo(x)
  nlen <- length(Cl)
  if (nlen < n){
    print(paste("x should be longer than ", n, "."))
    return(res)  
  }
  KDJ <- matrix(NA, nlen, 3)
  KDJ <- as.data.frame(KDJ)
  colnames(KDJ) <- c("K", "D", "J")
  KDJ[1:8, ] <- 50  # initial value for first 8 days as 50
  high_max <- runMax(Hi, n = n)  # the highest price of High Price in n days
  low_min <- runMin(Lo, n = n)
  rsv <- ((Cl - Lo)/(Hi - Lo)) * 100
  for (i in n:nlen){
    KDJ[i, 1] <- (2/3) * KDJ[(i-1), 1] + (1/3) * rsv[i]
    KDJ[i, 2] <- (2/3) * KDJ[(i-1), 2] + (1/3) * KDJ[i, 1]
    KDJ[i, 3] <- 3 * KDJ[i, 1] - 2 * KDJ[i, 2]
  }
  KDJ <- as.xts(KDJ, order.by = index(rsv))
  # cols <- c("red", "blue", "darkcyan")
  # chartSeries(x, theme = "white", name="DOW", TA = "addTA(KDJ, col = cols)")
  K <- as.numeric(KDJ[, "K"])
  D <- as.numeric(KDJ[, "D"])
  J <- as.numeric(KDJ[, "J"])
  for (i in (n+1):(nlen-1)){
    if ((K[i]>80 && D[i]>80) || (J[i] < 0 && K[i - 1] <= D[i - 1] && K[i] > D[i])) {
      signal <- "buy"
    } else if ((K[i]<20 && D[i]<20) || (J[i] > 100 && K[i - 1] > D[i - 1] && K[i] <= D[i])) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  
  return(res)
}


# william index
strat_wpr <- function(x, n = 20){
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  nlen <- length(Cl)
  if (nlen < n){
    print(paste("x should be longer than ", n, "."))
    return(res)  
  }
  wpr <- WPR(HLC(x), n = n)
  for (i in (n + 1):(nlen-1)) {
    if (wpr[i] < 0.2) {
      signal <- "buy"
    } else if (wpr[i] > 0.8)
    {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# sar
# Parabolic Stop And Reverse (SAR)
strat_sar <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  sar <- SAR(cbind(Hi(x), Lo(x)), accel = c(0.02, 0.2))
  for (i in 2:(n-1)) {
    if (sar[i-1]>Cl[i-1] && sar[i]<Cl[i]) {
      signal <- "buy"
    } else if (sar[i-1] < Cl[i-1] && sar[i] > Cl[i]) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# cci
strat_cci <- function(x, n = 20, c = 0.015) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  nlen <- length(Cl)
  if (nlen < 20) {
    print("x should be longer than 20.")
    return(res)
  }
  cci <- CCI(HLC(x), n = n, c = c)
  for (i in 20:(nlen-1)) {
    if (is.na(cci[i])){
      next()
    }
    if (cci[i] <= -100) {
      signal <- "buy"
    } else if (cci[i] >= 100) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# obv
strat_obv <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- as.numeric(Cl(x))
  Op <- as.numeric(Op(x))
  n <- length(Cl)
  obv <- data.frame(OBV(Cl, Vo(x)))
  for (i in 10:(n-1)) {
    if ((obv[i,] - obv[i-4,]) > 0 && (Cl[i]-Cl[i-4]) > 0) {
      signal <- "buy"
    } else if ((obv[i,] - obv[i-4,]) < 0 && (Cl[i]-Cl[i-4]) < 0) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

#pvt
strat_pvt <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- as.numeric(Cl(x))
  Op <- as.numeric(Op(x))
  Vo <- as.numeric(Vo(x))
  pvt <- ((Cl-lag(Cl,1))/lag(Cl,1))*Vo
  n <- length(Cl)
  for (i in 9:(n-1)) {
    if ((Cl[i]-Cl[i-7]) > 0 && (pvt[i]-pvt[i-7])>0) {
      signal <- "buy"
    } else if ((Cl[i]-Cl[i-7]) < 0 && (pvt[i]-pvt[i-7])<0) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

strat_arbr <- function(x){
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  # x <- na.omit(data.frame(x))
  # x <- na.omit(x[which(x[, 1] > 0), ])
  # x <- na.omit(x[which(x[, 5] > 0), ])
  # x <- xts(x, order.by = as.Date(rownames(x)))
  Cl <- as.vector(Cl(x))
  Op <- as.vector(Op(x))
  Hi <- as.vector(Hi(x))
  Lo <- as.vector(Lo(x))
  n <- length(Cl)
  BrC <- lag(Cl, 1)   #昨日收盘价
  list <- c()
  for(i in 2:(n-1)){
    if(Hi[i]==Op[i] || Op[i]==Lo[i] || Hi[i]==BrC[i] || BrC[i]==Lo[i]){
      list <- append(list, i)
    }
  }
  x <- x[-list, ]
  Cl <- as.vector(Cl(x))
  Op <- as.vector(Op(x))
  Hi <- as.vector(Hi(x))
  Lo <- as.vector(Lo(x))
  n <- length(Cl)
  if (n < 26) {
    print("x should be longer than 26. The stock has no records under ARBR strategy")
    return(0)
  }
  BrC <- lag(Cl, 1)   #昨日收盘价
  df_HO <- (Hi - Op)   #用于 AR, 最高价减去开盘价
  df_OL <- (Op - Lo)   #用于 AR, 开盘价减去最低价
  df_HCY <- na.omit((Hi - BrC)) #用于 BR, 最高价减去昨日收盘价
  df_CYL <- na.omit((BrC - Lo)) #用于 BR， 昨日收盘价减去最低价
  AR <- (runSum(df_HO, 26)/runSum(df_OL, 26))*100
  BR <- (runSum(df_HCY, 26)/runSum(df_CYL, 26))*100
  atr <- data.frame(ATR(x))[,2]
  price <- Cl[26]
  nrow <- 0
  date <- index(x)
  for(i in 26:(n-1)){
    if(AR[i]>150 && (Cl[i]-price)>2*atr[i]){
      signal <- "sell"
    } else if(BR[i]<AR[i] && (BR[i]<100 || AR[i]<60)){
      signal <- "buy"
      if(!is.null(res)){
        if(res[nrow,2]!=signal){
          price <- Op[i+1]
        }
      }
    } else{
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
    nrow <- nrow(res)
  }
  return (res)
}


# multi-strategies #############################################################

# pvt & stc
strat_pvtstc <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- as.numeric(Cl(x))
  Op <- as.numeric(Op(x))
  Vo <- as.numeric(Vo(x))
  pvt <- ((Cl-lag(Cl,1))/lag(Cl,1))*Vo
  n <- length(Cl)
  smi <- SMI(HLC(x), n = 13, nFast = 2, nSlow = 25, nSig = 9)
  smil <- as.numeric(smi[, 1])
  smisignal <- as.numeric(smi[, 2])
  for (i in 35:(n-1)) {
    if ((Cl[i]-Cl[i-7]) > 0 && (pvt[i]-pvt[i-7])>0 && (smi[i - 1] < smisignal[i - 1]) && (smi[i] > smisignal[i])) {
      signal <- "buy"
    } else if ((Cl[i]-Cl[i-7]) < 0 && (pvt[i]-pvt[i-7])<0 && (smi[i - 1] > smisignal[i - 1]) && (smi[i] < smisignal[i])) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# pvt & macd
strat_pvtmacd <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- as.numeric(Cl(x))
  Op <- as.numeric(Op(x))
  Vo <- as.numeric(Vo(x))
  pvt <- ((Cl-lag(Cl,1))/lag(Cl,1))*Vo
  n <- length(Cl)
  MACDS <- MACD(Cl, nFast = 12, nSlow = 26, nSig = 9, maType = "EMA")
  macd <- MACDS[, "macd"]
  macdsignal <- MACDS[, "signal"]
  for (i in 35:(n-1)) {
    if ((Cl[i]-Cl[i-7]) > 0 && (pvt[i]-pvt[i-7])>0 && macd[i - 1] < macdsignal[i - 1] && macd[i] > macdsignal[i]) {
      signal <- "buy"
    } else if ((Cl[i]-Cl[i-7]) < 0 && (pvt[i]-pvt[i-7])<0 && macd[i - 1] > macdsignal[i - 1] && macd[i] < macdsignal[i]) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# pvt & sma
strat_pvtsma <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- as.numeric(Cl(x))
  Op <- as.numeric(Op(x))
  Vo <- as.numeric(Vo(x))
  pvt <- ((Cl-lag(Cl,1))/lag(Cl,1))*Vo
  n <- length(Cl)
  if (n < 50) {
    print("x should be longer than 50.")
    return(res)
  }
  sma10 <- SMA(Cl, n = 10)
  sma20 <- SMA(Cl, n = 20)
  sma50 <- SMA(Cl, n = 50)
  for (i in 51:(n-1)) {
    if ((Cl[i]-Cl[i-7]) > 0 && (pvt[i]-pvt[i-7])>0 && (sma10[i - 1] < sma20[i - 1] || sma20[i - 1] < sma50[i - 1])
        && (sma10[i] >= sma20[i] && sma20[i] >= sma50[i])) {
      signal <- "buy"
    } else if ((Cl[i]-Cl[i-7]) < 0 && (pvt[i]-pvt[i-7])<0 && (sma10[i - 1] > sma20[i - 1] || sma20[i - 1] > sma50[i - 1])
               && (sma10[i] <= sma20[i] && sma20[i] <= sma50[i])) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# obv & sma
strat_obvsma <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- as.numeric(Cl(x))
  Op <- as.numeric(Op(x))
  n <- length(Cl)
  obv <- data.frame(OBV(Cl, Vo(x)))
  if (n < 50) {
    print("x should be longer than 50.")
    return(res)
  }
  sma10 <- SMA(Cl, n = 10)
  sma20 <- SMA(Cl, n = 20)
  sma50 <- SMA(Cl, n = 50)
  for (i in 51:(n-1)) {
    if ((obv[i,] - obv[i-4,]) > 0 && (Cl[i]-Cl[i-4]) > 0 && (sma10[i - 1] < sma20[i - 1] || sma20[i - 1] < sma50[i - 1])
        && (sma10[i] >= sma20[i] && sma20[i] >= sma50[i])) {
      signal <- "buy"
    } else if ((obv[i,] - obv[i-4,]) < 0 && (Cl[i]-Cl[i-4]) < 0 &&  (sma10[i - 1] > sma20[i - 1] || sma20[i - 1] > sma50[i - 1])
               && (sma10[i] <= sma20[i] && sma20[i] <= sma50[i])) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# obv & macd
strat_obvmacd <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- as.numeric(Cl(x))
  Op <- as.numeric(Op(x))
  n <- length(Cl)
  obv <- data.frame(OBV(Cl, Vo(x)))
  MACDS <- MACD(Cl, nFast = 12, nSlow = 26, nSig = 9, maType = "EMA")
  macd <- MACDS[, "macd"]
  macdsignal <- MACDS[, "signal"]
  for (i in 35:(n-1)) {
    if ((obv[i,] - obv[i-4,]) > 0 && (Cl[i]-Cl[i-4]) > 0 && macd[i - 1] < macdsignal[i - 1] && macd[i] > macdsignal[i]) {
      signal <- "buy"
    } else if ((obv[i,] - obv[i-4,]) < 0 && (Cl[i]-Cl[i-4]) < 0 && macd[i - 1] > macdsignal[i - 1] && macd[i] < macdsignal[i]) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# macd & rsi
strat_macdrsi <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n < 35) {
    print("x should be longer than 35.")
    return(res)
  }
  MACDS <- MACD(Cl, nFast = 12, nSlow = 26, nSig = 9, maType = "EMA")
  macd <- MACDS[, "macd"]
  macdsig <- MACDS[, "signal"]
  rsi <- data.frame(RSI(Cl, 14))
  for (i in 42:(n-1)) {
    if (macd[i-4]<macdsig[i-4] && macd[i]>macdsig[i] && (TF30(i-4,i,rsi$rsi) || (rsi$rsi[i]<50 && rsi$rsi[i]-rsi$rsi[i-3]>15))) {
      signal <- "buy"
    } ## else if #<# #>#
    else if (macd[i-4]>macdsig[i-4] && macd[i]<macdsig[i] && (TF70(i-4,i,rsi$rsi) || (rsi$rsi[i]>50 && rsi$rsi[i-3]-rsi$rsi[i]>15)) && strat_out(x, i)) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame( date = date[i+1],
                                  option = signal,
                                  price = Op[i+1]))
  }
  return(res)
}

# RSI signal function, change the parameter in necessary 
TF70 <- function(i, j, x){
  for(a in i:j){
    if(x[a] > 65){
      return (1)
    }else {
      return (0)
    }
  }
}


TF30 <- function(i, j, x){
  for(a in i:j){
    if(x[a] < 35){
      return (1)
    }else {
      return (0)
    }
  }
}

# macd & parabolic stop & reverse
strat_macdsar <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n < 35) {
    print("x should be longer than 35.")
    return(res)
  }
  MACDS <- MACD(Cl, nFast = 12, nSlow = 26, nSig = 9, maType = "EMA")
  macd <- MACDS[, "macd"]
  macdsig <- MACDS[, "signal"]
  sar <- SAR(cbind(Hi(x), Lo(x)), accel = c(0.02, 0.2))
  for (i in 42:(n-1)) {
    if (macd[i-4]<macdsig[i-4] && macd[i]>macdsig[i] && (sar[i-4]>Cl[i-4] && sar[i]<Cl[i])) {
      signal <- "buy"
    } else if (macd[i-4]<macdsig[i-4] && macd[i]>macdsig[i] && (sar[i-4]>Cl[i-4] && sar[i]>Cl[i])) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame( date = date[i+1],
                                  option = signal,
                                  price = Op[i+1]))
  }
  return(res)
}

# macd & cci
strat_macdcci <- function(x){
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n <= 40) {
    #stop("x should be longer than 35.")
    print("The stock should be longer than 40.")
    return(res)
    
  }
  # MACD is a function from TTR.
  MACDS <- MACD(Cl, nFast = 12, nSlow = 26, nSig = 9, maType = "EMA")
  macd <- MACDS[, "macd"]
  macdsignal <- MACDS[, "signal"]
  cci <- data.frame(CCI(x[,2:4], n = 20, c = 0.015))[, 1]

  # from 34 = (26 - 1 + 9 - 1) + 1
  for (i in 40:(n-1)) {
    if (is.na(cci[i])){
      next()
    }
    if (macd[i - 5] < macdsignal[i - 5] && macd[i] > macdsignal[i] && cci[i] <= -100) {
      signal <- "buy"
    } else if (macd[i - 5] > macdsignal[i - 5] && macd[i] < macdsignal[i] && cci[i] >= 100) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# smi/stc, & rsi
strat_smirsi <- function(x, n = 14, nFast = 2, nSlow = 25, nSig = 9) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  nlen <- length(Cl)
  if (nlen < (nSlow+nSig)) {
    print(paste("x should be longer than", (nSlow+nSig), "."))
    return(res)
  }
  smi <- SMI(HLC(x), n = n, nFast = nFast, nSlow = nSlow, nSig = nSig)
  smil <- smi[, 1]
  smisignal <- smi[, 2]
  rsi <- RSI(Cl, n = n)
  for (i in (nSlow+nSig+9):(nlen-1)) {
    if ((rsi[i] < 35)  && (smil[i-9] < smisignal[i-9] && smil[i] > smisignal[i])) {
      signal <- "buy"
    } else if (rsi[i] > 65 && (smil[i-4] > smisignal[i-4] && smil[i] < smisignal[i]))
    {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# stc & macd
strat_macdsmi <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n < 35) {
    print("x should be longer than 35.")
    return(res)
  }
  MACDS <- MACD(Cl, nFast = 12, nSlow = 26, nSig = 9, maType = "EMA")
  macd <- MACDS[, "macd"]
  macdsig <- MACDS[, "signal"]
  smi <- SMI(HLC(x), n = 13, nFast = 2, nSlow = 25, nSig = 9)
  smil <- smi[, 1]
  smisignal <- smi[, 2]
  for (i in 42:(n-1)) {
    if (macd[i-6]<macdsig[i-6] && macd[i]>macdsig[i] && (smil[i-2] < smisignal[i-2] && smil[i] > smisignal[i])) {
      signal <- "buy"
    } else if (macd[i-6]>macdsig[i-6] && macd[i]<macdsig[i] && (smil[i-2] > smisignal[i-2] && smil[i] < smisignal[i])) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame( date = date[i+1],
                                  option = signal,
                                  price = Op[i+1]))
  }
  return(res)
}

# ema & stc
# sma / ema / wma / 
# bollinger's bands & rsi
strat_bbrsi <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n < 20) {
    print("x should be longer than 20.")
    return(res)
  }
  rsi <- RSI(Cl, 14)
  bbands <- BBands(x[,2:4], n = 20)
  # from 51
  for (i in 35:(n-1)) {
    if (rsi[i] < 35 && Cl[i - 2] > bbands$dn[i - 2] && Cl[i] < bbands$dn[i]) {
      signal <- "buy"
    } else if (rsi[i] > 65 && (Cl[i - 2] < bbands$up[i - 2] && Cl[i] > bbands$up[i]) && strat_out(x, i)) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# dmi & stc
strat_dmismi <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n < 35) {
    print("x should be longer than 35.")
    return(res)
  }
  smi_result <- SMI(HLC(x), n = 13, nFast = 2, nSlow = 25, nSig = 9)
  smi <- smi_result[, "SMI"]
  smisignal <- smi_result[, "signal"]
  adx <- ADX(HLC(x))
  DIp <- adx[, "DIp"]
  DIn <- adx[, "DIn"]
  for (i in 40:(n-1)) {
    if ((smi[i - 4] < smisignal[i - 4] && smi[i] > smisignal[i]) && (DIp[i - 4] < DIn[i - 4] && DIp[i] > DIn[i])) {
      signal <- "buy"
    } else if ((smi[i - 4] > smisignal[i - 4] && smi[i] < smisignal[i]) && (DIp[i - 4] > DIn[i - 4] && DIp[i] < DIn[i])) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  return(res)
}

# dmi & macd/ema   
strat_dmimacd <- function(x) {
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- Cl(x)
  Op <- Op(x)
  n <- length(Cl)
  if (n < 35) {
    print("x should be longer than 35.")
    return(res)
  }
  MACDS <- MACD(Cl, nFast = 12, nSlow = 26, nSig = 9, maType = "EMA")
  macd <- MACDS[, "macd"]
  macdsig <- MACDS[, "signal"]
  adx <- ADX(HLC(x))
  DIp <- adx[, "DIp"]
  DIn <- adx[, "DIn"]
  for (i in 42:(n-1)) {
    if ((macd[i-4]<macdsig[i-4] && macd[i]>macdsig[i]) && (DIp[i - 4] < DIn[i - 4] && DIp[i] > DIn[i])) {
      signal <- "buy"
    } else if ((macd[i-4]>macdsig[i-4] && macd[i]<macdsig[i]) && (DIp[i - 4] > DIn[i - 4] && DIp[i] < DIn[i])) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame( date = date[i+1],
                                  option = signal,
                                  price = Op[i+1]))
  }
  return(res)
}

# bollinger + macd + kdj; n for kdj, nbol for bollinger's band
strat_bmk <- function(x, n = 9, nbol = 20){
  res <- NULL
  if (!is.xts(x)) {
    print(paste0("The class of input should be 'xts' or 'zoo.' while ", x, " is not"))
    return(res)
  } 
  date <- index(x)
  Cl <- as.vector(Cl(x))
  Op <- as.vector(Op(x))
  Hi <- as.vector(Hi(x))
  Lo <- as.vector(Lo(x))
  nlen <- length(Cl)
  list <- c()
  for(i in 1:nlen){
    if(Cl[i]==Lo[i] || Hi[i]==Lo[i]){
      list <- append(list, i)
    }
  }
  if (!is.null(list)){
    x <- x[-list, ]
  }
  Cl <- Cl(x)
  Op <- Op(x)
  Hi <- Hi(x)
  Lo <- Lo(x)
  nlen <- length(Cl)
  if (nlen < n){
    print(paste("x should be longer than ", n, "."))
    return(res)  
  }
  bbands <- BBands(HLC(x), n = nbol)
  MACDS <- MACD(Cl, nFast = 12, nSlow = 26, nSig = 9, maType = "EMA")
  macd <- MACDS[, "macd"]
  macdsignal <- MACDS[, "signal"]
  KDJ <- matrix(NA, nlen, 3)
  KDJ <- as.data.frame(KDJ)
  colnames(KDJ) <- c("K", "D", "J")
  KDJ[1:8, ] <- 50  # initial value for first 8 days as 50
  high_max <- runMax(Hi, n = n)  # the highest price of High Price in n days
  low_min <- runMin(Lo, n = n)
  rsv <- ((Cl - Lo)/(Hi - Lo)) * 100
  for (i in n:nlen){
    KDJ[i, 1] <- (2/3) * KDJ[(i-1), 1] + (1/3) * rsv[i]
    KDJ[i, 2] <- (2/3) * KDJ[(i-1), 2] + (1/3) * KDJ[i, 1]
    KDJ[i, 3] <- 3 * KDJ[i, 1] - 2 * KDJ[i, 2]
  }
  KDJ <- as.xts(KDJ, order.by = index(rsv))
  # cols <- c("red", "blue", "darkcyan")
  # chartSeries(x, theme = "white", name="DOW", TA = "addTA(KDJ, col = cols)")
  K <- as.numeric(KDJ[, "K"])
  D <- as.numeric(KDJ[, "D"])
  J <- as.numeric(KDJ[, "J"])
  for (i in (n+40):(nlen-1)){
    if ((macd[i - 4] < macdsignal[i - 4] && macd[i] > macdsignal[i]) &&
        (Cl[i - 4] > bbands$dn[i - 4] && Cl[i] < bbands$dn[i]) || (K[i]>80 && D[i]>80) || 
        (J[i] < 0 && K[i - 4] <= D[i - 4] && K[i] > D[i])) {
      signal <- "buy"
    } else if ((macd[i - 4] > macdsignal[i - 4] && macd[i] < macdsignal[i]) &&
               (Cl[i - 4] < bbands$up[i - 4] && Cl[i] > bbands$up[i]) || (K[i]<20 && D[i]<20) || 
               (J[i] > 100 && K[i - 4] > D[i - 4] && K[i] <= D[i])) {
      signal <- "sell"
    } else {
      next()
    }
    res <- rbind(res, data.frame(date = date[i+1],
                                 option = signal,
                                 price = Op[i+1]))
  }
  
  return(res)
}

# win rate & return rate function ##############################################

# perf function
# find the first "buy" signal and search for the first "sell" signal iteratively
perf <- function(record){
  start <- 1
  res <- NULL
  type_trade <- record[, 2]
  while (type_trade[start] != "buy"){
    start <- start + 1
    if(start >= length(record$option)){
      return(res)
    }
  }
  price = record[start, 3]
  res <- rbind(res, data.frame(date = record[start, 1],
                               option = record[start, 2],
                               price = price))
  for(i in start:length(record$option)){
    if(record[i,2]==record[start,2]){
      if(i == start || record[i-1, 2]==record[i, 2]){
        next()
      }
      else{
        price = record[i, 3]
        res <- rbind(res, data.frame(date = record[i, 1],
                                     option = record[i, 2],
                                     price = price))
      }
    } else if(record[i-1,2]==record[i,2]){
      next()
    } else {price = record[i, 3]
    res <- rbind(res, data.frame(date = record[i, 1],
                                 option = record[i, 2],
                                 price = price))
    }
  }
  return(res)
}

# ret function will return transaction details. a transaction consists of a buy and a sell;
# if the last row of record is "buy", which means there is no "sell" matches "buy".
# it will use the latest close price to represent "sell" price
# param, record is the return value of perf function above, stock should be the particular stock in calculating

# *****the below include the current stock value*****
# ret <- function(record, stock){
#   ret <- NULL
#   length <- nrow(record)
#   if(length != 1){
#     for (i in seq(1, length - 1, 2)){
#       buy_price = record[i, 3]
#       sell_price = record[i + 1, 3]
#       ret <- rbind(ret, data.frame(buy_date = record[i, 1],
#                                    sell_date = record[i + 1, 1],
#                                    buy_price = buy_price,
#                                    sell_price = sell_price,
#                                    change = sell_price - buy_price,
#                                    return = sell_price / buy_price - 1))
#     }}
#   # consider the current value of stocks, so here import the stock
#   if(length%%2==1 && record[length, 1]!=index(stock)[length(index(stock))]){
#     buy_price = record[length, 3]
#     sell_price = data.frame(stock[length(stock[,4]),4])[,1]
#     ret <- rbind(ret, data.frame(buy_date = record[length, 1],
#                                  sell_date = as.Date(rownames(data.frame(stock[length(stock[,4]),4]))),
#                                  buy_price = buy_price,
#                                  sell_price = sell_price,
#                                  change = sell_price - buy_price,
#                                  return = sell_price / buy_price - 1))
#   }
#   return(ret)
# }

# ****the below exclude the current value, so the param stock overlooked
ret <- function(record){
  ret <- NULL
  length <- nrow(record)
  if(length != 1){
    for (i in seq(1, length - 1, 2)){
      buy_price = record[i, 3]
      sell_price = record[i + 1, 3]
      trading_cost = buy_price * 0.001 + sell_price * 0.001
      return = sell_price / (buy_price+trading_cost) - 1
      buy_date = record[i, 1]
      sell_date = record[i + 1, 1]
      date_change = as.numeric(sell_date) - as.numeric(buy_date)
      ret <- rbind(ret, data.frame(buy_date = buy_date,
                                   sell_date = sell_date,
                                   buy_price = buy_price,
                                   sell_price = sell_price,
                                   change = sell_price - buy_price,
                                   return = return,
                                   ann_return = (return/date_change)*252,
                                   trading_cost = trading_cost))
    }}
  return(ret)
}

# param: stock pool, stock name, win rate table pre-defined, trading strategy
# param: stock pool, stock name, win rate table pre-defined, trading strategy
final <- function(stock_pool, stock_name, FUN, ...){
  r <- list()
  winrate <- NULL
  FUN <- match.fun(FUN)
  length <- length(stock_pool)
  num <- length
  # please replace stock_pool to dj30_pool or nasdaq_pool etc.
  for(i in 1:length){
    name = names(stock_pool[i])
    print(paste(Sys.time(), "is working on stock", i, name))
    # if(any(name==c("JNRFX","LOW", "CEG"))){
    #   print(paste("the stock: ", stock_name[i], "has no full transaction signals under current selected trading strategy"))
    #   num <- num - 1
    #   winrate <- rbind(winrate, data.frame(win_num = 0,
    #                                        trans_num = 0,
    #                                        winrate = 0,
    #                                        return = 0,
    #                                        ann_return = 0))
    #   next()
    # }
    stock <- na.omit(data.frame(stock_pool[i]))
    stock <- na.omit(stock[which(stock[, 1] > 0), ])
    stock <- na.omit(stock[which(stock[, 5] > 0), ])
    stock <- xts(stock, order.by = as.Date(rownames(stock)))
    iterim <- FUN(stock)
    # whether there is no signal or only 1 signal (only 1 "buy" signal)
    if(is.null(iterim) || nrow(perf(iterim))==1 || is.null(perf(iterim))){
      print(paste("the stock: ", stock_name[i], "has no full transaction signals under current selected trading strategy"))
      num <- num - 1
      winrate <- rbind(winrate, data.frame(win_num = 0,
                                           trans_num = 0,
                                           winrate = 0,
                                           return = 0,
                                           ann_return = 0))
      if(i == length){
        winrate <- rbind(winrate, data.frame(
          win_num = sum(winrate$win_num),
          trans_num = sum(winrate$trans_num),
          winrate = sum(winrate$win_num) / sum(winrate$trans_num),
          return = sum(winrate$return) / num,
          ann_return = sum(winrate$ann_return) / num
        ))
        break
      }
      next()
    }
    re <- ret(perf(iterim))
    # re <- ret(perf(iterim), stock) # consider current value, even there is no sell signal now
    r[i] <- list(name = re)
    win_num <- length(which(re$return > threshold))  #threshold = 0.05
    ann_return <- mean(re$ann_return)
    return <- mean(re$return)
    trans_num <- nrow(re)
    winrate <- rbind(winrate, data.frame(win_num = win_num,
                                         trans_num = trans_num,
                                         winrate = win_num / trans_num,
                                         return = return,
                                         ann_return = ann_return))
    if(i == length){
      winrate <- rbind(winrate, data.frame(
        win_num = sum(winrate$win_num),
        trans_num = sum(winrate$trans_num),
        winrate = sum(winrate$win_num) / sum(winrate$trans_num),
        return = sum(winrate$return) / num,
        ann_return = sum(winrate$ann_return) / num
      ))
    }
  }
  # add name to winrate
  rownames(winrate) <- c(stock_name, "overall")
  r[length + 1] <- list(winrate)
  names(r) <- c(stock_name, "winrate")
  return(r)
}

sing.stock <- function(x, FUN, ...){
  FUN <- match.fun(FUN)
  return(ret(perf(FUN(x))))
}

### sell out conditions
strat_out <- function(x, i) {
  if (!any(class(x) %in% c("xts", "zoo"))) {
    stop("The class of input should be 'xts' or 'zoo.'")
  } else {
    date <- index(x)
  }
  Cl <- data.frame(Cl(x))[,1] #close price
  Op <- data.frame(Op(x))[,1] #open price
  Hi <- data.frame(Hi(x))[,1] #high price
  Lo <- data.frame(Lo(x))[,1] #low price
  n <- length(Cl) 
  if (i < 35) stop("x should be longer than 34.")
  # 断头铡刀, 阴线包住三根均线，5，10，30日均线
  sma5 <- SMA(Cl, n = 5)
  sma10 <- SMA(Cl, n = 10)
  sma30 <- SMA(Cl, n = 30)
  count <- rep(0, 11)
  # 阴烛
  if (Cl[i] < Op[i]){
    # 断头铡刀
    if (sma5[i] <= Op[i] && sma10[i] <= Op[i] && sma30[i] <= Op[i]
        && sma5[i] >= Cl[i] && sma10[i] >= Cl[i] && sma30[i] >= Cl[i]) {
      count[1] <- count[1] + 1
    } 
    if (Cl[i-1]>Op[i-1] && (Op[i]-Cl[i])>(Cl[i-1]-Op[i-1])){ # 阴包阳
      count[2] <- count[2] + 1
    } 
    if (Cl[i-1]>Op[i-1] && Op[i] > Cl[i-1]){  #乌云盖顶，前一日为阳烛，今日高开低走
      count[3] <- count[3] + 1
    } 
    if (abs(Cl[i-4]-Cl[i])<1.5 && Op[i-3] > Cl[i-3] && Op[i-3] < min(Cl[i-4], Op[i-4])){ # 相差小于1.5认为股价回复到原来水平
      count[4] <- count[4] + 1
    } 
    if (Cl[i-1] > Op[i-1] && (Cl[i-1]-Op[i-1]) > (Op[i]-Cl[i])){  # 高位孕线，前一日为阳烛，阳烛的范围大于今日阴烛的范围
      count[5] <- count[5] + 1
    } 
    if (Cl[i-2] > Op[i-2] && Cl[i-1] > Op[i-1] && 
               (Hi[i-1]-Lo[i-1])>2*(Cl[i-1]-Op[i-1])){ # 黄昏之星，前两日为阳烛，第二日最高价与最低价的差明显大于收盘价开盘价之差，第三日即今日为阴烛
      count[6] <- count[6] + 1
    } 
    if (Cl[i-2] < Op[i-2] && Cl[i-1] < Op[i-1] && Cl[i-3] > Op[i-3]){  # 三只乌鸦，连着三日阴烛，而前一天为阳烛
      count[7] <- count[7] + 1
    } 
    if (Cl[i-1] > Op[i-1] && Op[i] >= Cl[i-1] && (Hi[i]-Op[i])>2*(Op[i]-Cl[i]) && (Op[i]-Cl[i])>(Cl[i]-Lo[i])){
      count[8] <- count[8] + 1
    }
  }
  # 阳烛
  if (Cl[i] >= Op[i]){
    # 吊颈线, 在上涨的情况下，开盘价相较最低价的差至少是开盘收盘价之差的2倍以上，才有卖出信号
    if (Cl[i] > Cl[i-1] && (Op[i]-Lo[i]) >= 2*(Cl[i]-Op[i])){
      count[9] <- count[9] + 1
    } 
    if (abs(Cl[i-4]-Cl[i])<1.5 && Op[i-3] > Cl[i-3] && Op[i-3] < min(Cl[i-4], Op[i-4])){ # 相差小于1.5认为股价回复到原来水平
      count[10] <- count[10] + 1
    } 
    if ((Hi[i]-Cl[i])>=2*(Cl[i]-Op[i]) && Cl[i-1] > Op[i-1] && Op[i] >= Cl[i-1] && (Cl[i]-Op[i])>(Op[i]-Lo[i])){  #射击之星
      count[11] <- count[11] + 1
    }
  }
  # print(count)
  if (sum(count) >= 2){return(1)}
  else {return(0)}
}

d2xts <- function(x){
  return (xts(x[,7], order.by = as.Date(x[,1])))
}
# then you can use charts.PerformanceSumary to draw the return graph




stat_table <- function(x){
  #result <- NULL
  result <- data.frame(transaction = length(x[,1]),
                   win_transaction = length(which(x[,6]>threshold)),
                   win_rate = mean(x[,6]>threshold),
                   average_return = mean(x[,6]),
                   average_ann_return = mean(x[,7]))
  rownames(result) <- "result"
  return(result)
}
# data.frame(Sharpe = SharpeRatio(d2xts(t1), FUN = "StdDev"), 
#            alpha = CAPM.alpha(d2xts(t1), Return.calculate(GSPC$GSPC.Open, method = "discrete")), 
#            beta = CAPM.beta(d2xts(t1), Return.calculate(GSPC$GSPC.Open, method = "discrete"))) %>% 
#   cbind(stat_table(t1), .) %>% 
#   round(4)

find_function <- function(x){
  if (x == "SMA"){
    f = match.fun(strat_sma)
  }  else if (x == "ARBR"){
    f = match.fun(strat_arbr)
  }  else if (x == "BBANDS"){
    f = match.fun(strat_bbands)
  }  else if (x == "CCI"){
    f = match.fun(strat_cci)
  }  else if (x == "DMI"){
    f = match.fun(strat_dmi)
  }  else if (x == "MACD"){
    f = match.fun(strat_macd)
  }  else if (x == "OBV"){
    f = match.fun(strat_obv)
  }  else if (x == "PVT"){
    f = match.fun(strat_pvt)
  }  else if (x == "DMIMACD"){
    f = match.fun(strat_dmimacd)
  }  else if (x == "ROC"){
    f = match.fun(strat_roc)
  }  else if (x == "RSI"){
    f = match.fun(strat_rsi)
  }  else if (x == "SAR"){
    f = match.fun(strat_sar)
  }  else if (x == "SMI"){
    f = match.fun(strat_smi)
  } else if (x == "WPR"){
    f = match.fun(strat_wpr)
  } else if (x == "DMISMI"){
    f = match.fun(strat_dmismi)
  } else if (x == "SMIRSI"){
    f = match.fun(strat_smirsi)
  } else if (x == "BBRSI"){
    f = match.fun(strat_bbrsi)
  } else if (x == "MACDSMI"){
    f = match.fun(strat_macdsmi)
  } else if (x == "MACDRSI"){
    f = match.fun(strat_macdrsi)
  } else if (x == "MACDSAR"){
    f = match.fun(strat_macdsar)
  } else if (x == "OBVMACD"){
    f = match.fun(strat_obvmacd)
  } else if (x == "OBVSMA"){
    f = match.fun(strat_obvsma)
  } else if (x == "PVTSMA"){
    f = match.fun(strat_pvtsma)
  } else if (x == "PVTMACD"){
    f = match.fun(strat_pvtmacd)
  } else if (x == "PVTSTC"){
    f = match.fun(strat_pvtstc)
  } else if (x == "MACDCCI"){
    f = match.fun(strat_macdcci)
  } else {
    print("Wrong strategy selection!")
  }
  return (f)
}

### 不同策略下指定前number个winrate较大的股票
### param: stocks, strategies, 
### number defines the number of stocks with the highest win rate
monitor <- function(stock_pool, stock_name, number){
  r <- list()
  len <- length(stock_name)
  if(len < number){
    print("Wrong number input!")
    return(NULL)
  }
  for (i in 1:length(strategies)){
    print(paste("working on strategies: No.", i, " ", strategies[i]))
    f <- find_function(strategies[i])
    t <- final(stock_pool, stock_name, f)
    r[i] <- list(t$winrate[order(t$winrate[-(len+1),3], decreasing = TRUE)[1:number],])
  }
  names(r) <- strategies
  return(r)
}

# 告诉现阶段用户第二天根据哪一个策略购买哪一支股票
# to filter current stock buy & sell point based on different strategies
# ret <- function(record, stock){
#   ret <- NULL
#   length <- nrow(record)
#   if(length != 1){
#     for (i in seq(1, length - 1, 2)){
#       buy_price = record[i, 3]
#       sell_price = record[i + 1, 3]
#       ret <- rbind(ret, data.frame(buy_date = record[i, 1],
#                                    sell_date = record[i + 1, 1],
#                                    buy_price = buy_price,
#                                    sell_price = sell_price,
#                                    change = sell_price - buy_price,
#                                    return = sell_price / buy_price - 1))
#     }}
#   # consider the current value of stocks, so here import the stock
#   if(length%%2==1 && record[length, 1]!=index(stock)[length(index(stock))]){
#     buy_price = record[length, 3]
#     sell_price = data.frame(stock[length(stock[,4]),4])[,1]
#     ret <- rbind(ret, data.frame(buy_date = record[length, 1],
#                                  sell_date = as.Date(rownames(data.frame(stock[length(stock[,4]),4]))),
#                                  buy_price = buy_price,
#                                  sell_price = sell_price,
#                                  change = sell_price - buy_price,
#                                  return = sell_price / buy_price - 1))
#   }
#   return(ret)
# }
stock_strat <- function(stock_pool, stock_name){
  r <- NULL
  for (i in 1:length(strategies)){
    print(paste(Sys.time(), "working on strategies:", i, strategies[i]))
    f <- find_function(strategies[i])
    for (j in 1:length(stock_name)){
      stock <- na.omit(data.frame(stock_pool[j]))
      stock <- na.omit(stock[which(stock[, 1] > 0), ])
      stock <- na.omit(stock[which(stock[, 5] > 0), ])
      s.date <- rownames(tail(stock, 1))
      stock <- xts(stock, order.by = as.Date(rownames(stock)))
      t <- f(stock)
      if(is.null(t)){
        next()
      }
      t.date <- tail(t, 1)[1,1]
      if(t.date == s.date){
        r <- rbind(r, data.frame(Strategy = strategies[i],
                                 Date = t.date,
                                 Stock = stock_name[j],
                                 Type = tail(t, 1)[1,2],
                                 Price = tail(t, 1)[1,3]))
      }
    }
  }
  return(r)
}

# same function but using MACDCCI
stock_test <- function(stock_pool, stock_name){
  r <- NULL
  for (j in 1:length(stock_name)){
    stock <- na.omit(data.frame(stock_pool[j]))
    stock <- na.omit(stock[which(stock[, 1] > 0), ])
    stock <- na.omit(stock[which(stock[, 5] > 0), ])
    s.date <- rownames(tail(stock, 1))
    stock <- xts(stock, order.by = as.Date(rownames(stock)))
    print(paste(Sys.time(), "working on stock", j, stock_name[j]))
    t <- strat_macdcci(stock)
    if(is.null(t)){
      next()
    }
    t.date <- tail(t, 1)[1,1]
    r <- rbind(r, data.frame(Strategy = "MACDCCI",
                             Date = t.date,
                             Stock = stock_name[j],
                             Type = tail(t, 1)[1,2],
                             Price = tail(t, 1)[1,3]))
  }
  return(r)
}
