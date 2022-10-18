import talib
import numpy
c = numpy.random.randn(100)
print(c)
k, d = talib.STOCHRSI(c)
print(k, d)
rsi = talib.RSI(c)
print(rsi)
k1, d1 = talib.STOCHF(rsi, rsi, rsi)
print(k1, d1)
k2, d2 = talib.STOCH(rsi, rsi, rsi)
print(k2, d2)
