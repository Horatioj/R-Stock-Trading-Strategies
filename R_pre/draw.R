# Load or install necessary packages if necessary
want <- c("magrittr", "gglpot2", "scales", "reshape2")
need <- want[!(want %in% installed.packages()[,"Package"])]
if (length(need)) install.packages(need)
lapply(want, function(i) require(i, character.only=TRUE))
rm(want, need)


ggplot() +
  geom_line(aes(x=index(BABA), y=Cl(BABA)), data = fortify(data.frame(data.frame(BABA)[,4])))+
  #geom_line(aes(x=index(bands), y=data.frame(bands)[,1], color="down"), data = fortify(data.frame(data.frame(bands)[,1])))+
  #geom_line(aes(x=index(bands), y=data.frame(bands)[,3], color="up"), data = fortify(data.frame(data.frame(bands)[,3])))+
  geom_point(aes(x=result[,1], y=result[,3], color="buy"), data = result, size = 3)+
  geom_point(aes(x=result[,2], y=result[,4], color="sell"), data = result, size = 3)+
  scale_x_date(labels = date_format("%Y-%m"),date_breaks="6 month", limits = c(index(BABA)[1], last(index(BABA))))+
  xlab("")+
  ylab("Price")+
  ggtitle("BABA")

ggplot() + 
  geom_line(aes(x=result[,1], y= result[, 6], color="cumula return"),  data = result) +
  geom_line(aes(x=result[,1], y=cumprod(1 + result[, 6]), color="tranx return"),  data = result)
mutate(cr = cumprod(1 + result[, 6]))
# after using ret(perf(strategy(xxxx)))