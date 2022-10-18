# # Clean up workspace -- 
# rm(list=ls())
# 
# # Load or install necessary packages if necessary
# want <- c("quantmod","dplyr", "plyr", "magrittr", "gglpot2", "scales", "reshape2", "PerformanceAnalytics")
# need <- want[!(want %in% installed.packages()[,"Package"])]
# if (length(need)) install.packages(need)
# lapply(want, function(i) require(i, character.only=TRUE))
# rm(want, need)

# # Working directories
dir <- list()
dir$root <- dirname(getwd())
dir$source <- paste(dir$root,"/data",sep="")
dir$output <- paste(dir$root,"/figures",sep="")
dir$result <- paste(dir$root, "/output", sep="")
lapply(dir, function(i) dir.create(i, showWarnings = F))
# 
# source("strategies.R")
# stocks pool, 100 stocks from nasdaq
from = "1980-01-01"
# to = "2021-11-30"
threshold <- 0.05
options(warn = -1)

nasdaq <- c("ATVI", "ADBE", "AMD", "ALGN", "GOOG", "AMZN", "AEP", "AMGN", "ABNB",  
            "ADI", "ANSS", "AAPL", "AMAT", "ASML", "TEAM", "ADSK", "ADP", "BIDU",  
            "BIIB", "BKNG", "AVGO", "CDNS", "CHTR", "CTAS", "CSCO", "CTSH", "CMCSA", 
            "CPRT", "COST", "CRWD", "CSX", "DXCM", "DOCU", "DDOG", "FTNT", "PANW",
            "DLTR", "EBAY", "EA", "EXC", "FB", "FAST", "FISV", "GILD", "GOOGL",
            "HON", "IDXX", "ILMN", "INTC", "INTU", "ISRG", "JD", "KDP", "LCID",  
            "KLAC", "KHC", "LRCX", "LULU", "MAR", "MRVL", "MTCH", "MELI", "MCHP",  
            "MU", "MSFT", "MRNA", "MDLZ", "MNST", "NTES", "NFLX", "NVDA", "NXPI",  
            "ORLY", "OKTA", "ODFL", "PCAR", "PAYX", "PYPL", "PEP", "PDD", "QCOM",  
            "REGN", "ROST", "SGEN", "SIRI", "SWKS", "SPLK", "SBUX", "SNPS", "TMUS",  
            "TSLA", "TXN", "VRSN", "VRSK", "VRTX", "WBA", "WDAY", "XEL", "ZS", "ZM")

dj30 <- c ("AXP", "AMGN", "AAPL", "BA", "CAT", "CSCO", "CVX", "GS", "HD", "HON", 
           "IBM", "INTC", "JNJ", "KO", "JPM", "MCD", "MMM", "MRK", "MSFT", "NKE",
           "PG", "TRV", "UNH", "CRM", "VZ", "V", "WBA", "WMT", "DIS", "DOW")

sp500 <- c("ABT",	"AMD",	"APD", "SWKS",	"HWM",	"HES",	"AEP",	"AXP",	"AFL",	"AIG",
           "AAL",	"ADI",	"APA",	"AMAT",	"ADM",	"ADP",	"AVY",	"BLL",	"BAX",	"BDX",
           "WRB",	"BIO",	"BA",	"BMY",	"BF-B",	"CPB",	"STZ",	"CAT",	"LUMN",	"JPM",	"CINF",	
           "CLX",	"KO",	"CL",	"CAG",	"TAP",	"GLW",	"CMI",	"TGT",	"DAL",	"CMA", "DG",	
           "DOV",	"OMC",	"ECL",	"PKI",	"EMR",	"EFX",	"XOM",	"FRT",	"FITB",	"USB",	"MTB",
           "FMC",	"F",	"BEN",	"GD",	"GE",	"GIS",	"GPC",	"HAL",	"HAS",	"HSY",	"HPQ",	"HRL",	
           "HUM",	"HBAN",	"ITW",	"INTC",	"IBM",	"IFF",	"IP",	"IPG",	"J",	"K",	"KMB",	"KR",	
           "LLY",	"LNC",	"L",	"LOW",	"MMC",	"MAS",	"MKC",	"MCD",	"SPGI",	"CVS",	"ETR",	
           "MMM",	"MSI",	"BAC",	"NDSN",	"ES",	"XEL",	"WFC",	"NTRS",	"NUE",	"UDR",	"PCAR",	
           "PKG",	"PH",	"PNR",	"PEP",	"PFE",	"PVH",	"BRO",	"PPG",	"PG",	"PGR",	"ROL",	"TRV",
           "SLB",	"SHW",	"AOS",	"SJM",	"SNA",	"KEY",	"SO",	"TFC",	"LUV",	"CVX",	"SWK",	"STT",
           "SYY",	"TFX",	"TER",	"TXN",	"TMO",	"TSN",	"UAL",	"UNP",	"MRO",	"RTX",	"VFC",	"WMT",
           "WST",	"WDC",	"WY",	"WHR",	"WMB",	"TJX",	"ZION",	"JNJ",	"LHX",	"TXT",	"GWW",	"CSX",
           "MRK",	"SYK",	"DHR",	"CHD",	"DE",	"RHI",	"AON",	"SCHW",	"AMGN",	"KLAC",	"NKE",	"AAPL",
           "GL",	"LNT",	"UHS",	"AJG",	"HD",	"BBWI",	"NSC",	"LRCX",	"COO",	"EA",	"PNC",	"D",
           "ATVI",	"SIVB",	"RJF",	"CAH",	"MU",	"CTAS",	"PAYX",	"O",	"JBHT",	"UNH",	"ATO",	"VZ",	
           "T",	"VTR",	"ROST",	"EXPD",	"IT",	"NEE",	"CFG",	"MO",	"BBY",	"PNW",	"PEAK",	"ALK",	
           "WELL",	"ADSK",	"HON",	"JKHY",	"DRE",	"WEC",	"PEG",	"MSFT",	"MGM",	"ADBE",	"OXY",
           "FISV",	"QCOM",	"CERN",	"CMS",	"CDNS",	"PARA",	"NWL",	"ABMD",	"CCL",	"FAST",	"XRAY",
           "AMP",	"APH",	"EOG",	"PHM",	"WM",	"EIX",	"MCHP",	"SBUX",	"C",	"FCX",	"IEX",	"JCI",
           "TECH",	"NLOK",	"MHK",	"PTC",	"CTRA",	"CSCO",	"HOLX",	"HCA",	"TYL",	"TRMB",	"MNST",	
           "AZO",	"REGN",	"IDXX",	"AES",	"HIG",	"BIIB",	"VRTX",	"ZBRA",	"CTXS",	"ODFL",	"KIM",	
           "INCY",	"GILD",	"DHI",	"ROP",	"SNPS",	"RCL",	"BSX",	"GS",	"MTCH",	"MS",	"CB",	"INTU",	
           "ORLY",	"ALL",	"VNO",	"CPRT",	"EQR",	"NVR",	"BWA",	"COST",	"REG",	"MAA",	"IVZ",
           "EMN",	"AVB",	"ALB",	"MLM",	"TSCO",	"LH",	"ESS",	"LEN",	"PENN",	"PPL",	"DVA",	"COF",
           "MCK",	"DLTR",	"DTE",	"LMT",	"DRI",	"WAB",	"RMD",	"POOL",	"TTWO",	"HSIC",	"WAT",
           "DISH",	"EL",	"NTAP",	"AEE",	"SEE",	"FDS",	"ANSS",	"NRG",	"VRSN",	"AMZN",	"IRM", "DGX",
           "ROK",	"FE",	"SRE",	"SBAC",	"VLO",	"ISRG",	"ARE",	"RL",	"BXP",	"MTD",	"AME", "PXD",	
           "OKE",	"YUM",	"CHRW",	"JNPR",	"PLD",	"NVDA",	"ED",	"MAR",	"FFIV",	"FDX",	"PWR", "CCI",	
           "AMT",	"CMG",	"CTSH",	"MCO",	"RSG",	"SPG",	"EBAY",	"NFLX",	"LKQ",	"URI", "BRK-B",	"HST",	
           "CNC",	"BKNG",	"AKAM",	"DVN",	"UPS",	"A",	"CHTR",	"DXCM",	"TDY", "RE",	"ALGN",	"MET", 
           "EW",	"CRL",	"EQIX",	"MDLZ",	"CRM",	"EXC",	"ILMN",	"NI",	"IPGP", "TROW",	"TPR",	"NDAQ",	
           "GRMN",	"GPN",	"PFG",	"CNP",	"FRC",	"NOC",	"ZBH",	"FIS", "PRU",	"STX",	"CBRE",	"WTW",
           "ABC",	"MA",	"ANTM",	"CME",	"AAP",	"COP",	"NEM", "CMCSA", "KMX",	"WYNN",	"FLT", "MOH",	"TDG",
           "FTNT", "AIZ", "MKTX",	"MPWR",	"RF",	"TMUS", "MOS", "DPZ", "SBNY",	"EXR", "DLR", "LVS", "CE",	
           "TSLA",	"CF",	"EXPE",	"DUK", "FB",	"LYV",	"UAA",	"UA",	"LDOS",	"ORCL",	"EPAM",	"BLK", "ETSY", 
           "NOW",	"CBOE",	"PBCT", "BR",	"TEL",	"BK",	"PSA",	"DFS",	"VMC",	"CDW",	"V",	"ULTA",	"MSCI",	
           "AWK",	"PM",	"NXPI",	"TWTR",	"SEDG",	"DISCA",	"DISCK",	"VRSK",	"ENPH",	"TT",	"ACN",	"GM",	"GNRC",	
           "IQV",	"LYB",	"NLSN",	"HII",	"KMI",	"MPC",	"NCLH",	"FBHS",	"APTV",	"XYL",	"PSX", "CEG",
           "FANG",	"ABBV",	"ETN",	"ZTS",	"NWSA",	"NWS",	"ICE",	"ALLE",	"HLT",	"CZR",	"PAYC",	"OGN",
           "ANET",	"CTLT",	"KEYS",	"SYF",	"QRVO",	"MDT",	"WBA",	"PYPL",	"KHC",	"HPE",	"GOOGL",
           "GOOG",	"FTV",	"DD",	"LW",	"MRNA",	"DXC",	"IR",	"BKR",	"LIN",	"EVRG",	"CDAY",	"AVGO",
           "WRK",	"CI",	"DIS",	"AMCR",	"DOW",	"FOXA",	"FOX",	"CTVA",	"STE",	"OTIS",	"CARR",	"VTRS")

rusell_1 <- c("AAPL",	"MSFT",	"GOOG",	"GOOGL",	"AMZN",	"TSLA",	"BRK-B",	"NVDA",	"FB",	"UNH",	"JNJ",	
              "V",	"WMT",	"JPM",	"XOM",	"PG",	"CVX",	"HD",	"BAC",	"MA",	"PFE",	"ABBV",	"LLY",	
              "KO",	"DIS",	"AVGO",	"COST",	"CSCO",	"VZ",	"PEP",	"ORCL",	"TMO",	"ACN",	"CMCSA",	"ABT",	
              "MRK",	"ADBE",	"CRM",	"NKE",	"DHR",	"INTC",	"WFC",	"UPS",	"QCOM",	"MCD",	"UNP",	"T",	
              "TXN",	"TMUS",	"NEE",	"MS",	"SCHW",	"NFLX",	"BMY",	"LOW",	"RTX",	"MDT",	"PM",	"CVS",	
              "AMGN",	"COP",	"AXP",	"AMD",	"HON",	"INTU",	"LMT",	"DE",	"CAT",	"ANTM",	"PYPL",	"IBM",	
              "GS",	"PLD",	"AMAT",	"C",	"AMT",	"BLK",	"BA",	"NOW",	"GE",	"CHTR",	"ISRG",	"TGT",	"EL",	
              "SBUX",	"SYK",	"MO",	"SPGI",	"ZTS",	"ADP",	"CB",	"BKNG",	"MDLZ",	"DUK",	"MU",	"CME",	"HCA",
              "MMM",	"BX",	"USB",	"ADI",	"PNC",	"CSX",	"TFC",	"MMC",	"CCI",	"TJX",	"SO",	"CI",	"GILD",	
              "BDX",	"ICE",	"EOG",	"FCX",	"NOC",	"REGN",	"NSC",	"LRCX",	"D",	"AON",	"EW",	"GD",	"PSA",	
              "ITW",	"F",	"EQIX",	"WM",	"ATVI",	"FISV",	"CL",	"PGR",	"TEAM",	"NEM",	"SHW",	"SLB",	"GM",	
              "VRTX",	"BSX",	"ETN",	"SCCO",	"UBER",	"FDX",	"PXD",	"MCO",	"MRNA",	"COF",	"EMR",	"FIS",	
              "OXY",	"HUM",	"PANW",	"MRVL",	"MET",	"MAR",	"KDP",	"SNOW",	"SRE",	"KLAC",	"APD",	"CNC",	
              "LHX",	"AEP",	"ILMN",	"DG",	"AIG",	"ADM",	"NXPI",	"VMW",	"CTSH",	"KHC",	"ROP",	"ECL",	
              "SNPS",	"ORLY",	"FTNT",	"DOW",	"APH",	"WDAY",	"MPC",	"PAYX",	"SQ",	"SPG",	"EXC",	"HSY",	
              "JCI",	"ADSK",	"MCK",	"IDXX",	"TRV",	"CMG",	"KR",	"KMI",	"WBA",	"WELL",	"IQV",	"BK",	"CDNS",	
              "RSG",	"STZ",	"SYY",	"PRU",	"CRWD",	"KMB",	"HLT",	"A",	"CTVA",	"BKR",	"AFL",	"DVN",	"WMB",
              "MNST",	"O",	"DLR",	"BAX",	"AZO",	"MCHP",	"CTAS",	"XEL",	"HPQ",	"DXCM",	"DELL",	"GIS",	"VLO",	
              "MSI",	"DD",	"MSCI",	"ANET",	"CARR",	"NUE",	"LULU",	"GPN",	"PSX",	"ODFL",	"PH",	"RMD",	"TT",	
              "SBAC",	"TDG",	"EA",	"ALL",	"RIVN",	"LYB",	"AVB",	"HAL",	"YUM",	"DDOG",	"DLTR",	"PEG",	"LNG",	
              "EQR",	"AJG",	"TSN",	"ED",	"ALGN",	"GFS",	"SIVB",	"TROW",	"FAST",	"ROST",	"GLW",	"OTIS",	"KKR",	
              "ABC",	"ARE",	"AMP",	"IFF",	"FITB",	"STT",	"MTD",	"ROK",	"DFS",	"PCAR",	"WEC",	"WY",	"OKE",	
              "EBAY",	"VRSK",	"HES",	"AME",	"BF-B",	"BF-A",	"LSXMA",	"LSXMK",	"FWONK",	"FWONA",	"CBRE",	"BIIB",	
              "ES",	"APTV",	"DHI",	"PPG",	"ZS",	"ZM",	"LVS",	"CMI",	"DASH",	"FRC",	"AWK",	"HRL",	"BLL",	
              "CPRT",	"CERN",	"EFX",	"NET",	"NDAQ",	"WST",	"EXPE",	"PCG",	"KEYS",	"TWTR",	"EXR",	"WTW",	"MKC",	
              "ANSS",	"TSCO",	"SGEN",	"LEN-B",	"LEN",	"MTCH",	"FE",	"TTD",	"ZBH",	"LH",	"EIX",	"DTE",	"SIRI",
              "LYV",	"VEEV",	"ON",	"GWW",	"MAA",	"INVH",	"SWK",	"LUV",	"VTR",	"URI",	"VMC",	"U",	"MLM",	
              "CHD",	"HZNP",	"OKTA",	"IT",	"FANG",	"CDW",	"ENPH",	"MOS",	"LBRDA",	"LBRDK",	"BBY",	"TWLO",	
              "AEE",	"SPOT",	"VRSN",	"MTB",	"HIG",	"PLTR",	"STE",	"CSGP",	"ESS",	"NTRS",	"ETR",	"DOV",	"ALB",	
              "HPE",	"FOX",	"FOXA",	"PARAA",	"PARA",	"HBAN",	"KEY",	"CLR",	"GRMN",	"MDB",	"PKI",	"SWKS",	
              "CTRA",	"JBHT",	"VFC",	"AVTR",	"RF",	"DRE",	"DAL",	"ZBRA",	"SUI",	"K",	"VICI",	"COO",	"FTV",	
              "RJF",	"ULTA",	"CF",	"TDY",	"CFG",	"HUBS",	"CINF",	"BILL",	"SPLK",	"IR",	"PPL",	"BXP",	"SSNC",	
              "CMS",	"WAT",	"CCL",	"NTAP",	"ALNY",	"MPWR",	"TRU",	"MOH",	"SYF",	"PAYC",	"UDR",	"GNRC",	"CNP",
              "FLT",	"POOL",	"HEI",	"HEI-A",	"TTWO",	"MKL",	"BRO",	"AKAM",	"MGM",	"PWR",	"SBNY",	"PEAK",	
              "RCL",	"TER",	"HOLX",	"ACGL",	"AGR",	"GPC",	"CTLT",	"CPT",	"PFG",	"MRO",	"BR",	"EXPD",	"WRB",	
              "RPRX",	"AMCR",	"WAB",	"DRI",	"TYL",	"TRMB",	"ENTG",	"INCY",	"DGX",	"OMC",	"J",	"CEG",	"NVR",	
              "ACI",	"NLOK",	"KMX",	"CZR",	"BIO",	"CLX",	"IP",	"YUMC",	"ROL",	"DISH",	"TFX",	"TECH",	"TRGP",	
              "BG",	"FMC",	"PODD",	"FDS",	"ATO",	"ETSY",	"UI",	"WLK",	"WPC",	"CG",	"CCK",	"L",	"LNT",	"XYL",
              "TXT",	"CE",	"DOCU",	"AES",	"EVRG",	"AA",	"IRM",	"KIM",	"CAH",	"CAG",	"IEX",	"HWM",	"LDOS",	
              "PINS",	"PKG",	"ELS",	"WDC",	"PLUG",	"BMRN",	"SJM",	"DPZ",	"ZEN",	"STLD",	"ALLY",	"BEN",	"EMN",	
              "CLF",	"APA",	"QRVO",	"AVY",	"JKHY",	"FNF",	"CHRW",	"ROKU",	"BURL",	"BLDR",	"CRL",	"GDDY",	"ABMD",	
              "IPG",	"MKTX",	"MAS",	"HST",	"AMH",	"UHS",	"CPB",	"CTXS",	"LYFT",	"LKQ",	"LPLA",	"ELAN",	"AAP",
              "NDSN",	"NWS",	"NWSA",	"FHN",	"PTC",	"FICO",	"DISCK",	"DISCA",	"CBOE",	"CNA",	"VTRS",	"CSL",
              "NI",	"BBWI",	"RHI",	"HAS",	"MPW",	"RS",	"DAR",	"ARES",	"WTRG",	"FFIV",	"Z",	"ZG",	"EQH",	
              "AFG",	"HSIC",	"CMA",	"PHM",	"GGG",	"CGNX",	"REG",	"UHAL",	"DT",	"WRK",	"EPAM",	"WOLF",	"UAL",
              "FBHS",	"MORN",	"JLL",	"BAH",	"REXR",	"TAP",	"SNA",	"WSO",	"LSI",	"CUBE",	"LUMN",	"EXAS",	"ACM",
              "EWBC",	"WHR",	"JNPR",	"RE",	"FCNCA",	"AOS",	"XRAY",	"GLPI",	"DVA",	"SNX",	"RRX",	"LNC",	"PCTY",
              "NLY",	"DOX",	"WSM",	"CNXC",	"ZNGA",	"RPM",	"TPL",	"EQT",	"VST",	"QGEN",	"WBS",	"BSY",	"ALLE",
              "CLVT",	"MTN",	"AGCO",	"ZION",	"HUBB",	"AIZ",	"FND",	"SCI",	"GL",	"SEE",	"JAZZ",	"BRKR",	"GLOB",	
              "LAMR",	"LAD",	"LII",	"OLPX",	"CDAY",	"NRG",	"FRT",	"AZPN",	"RGEN",	"IVZ",	"PSTG",	"NWL",	"AAL",
              "W",	"OGN",	"MIDD",	"ARMK",	"TPR",	"RGLD",	"OC",	"WAL",	"PNR",	"TW",	"VNO",	"AXON",	"CABO",	"CFR",
              "BKI",	"TDOC",	"RNG",	"PBCT",	"BWA",	"X",	"Y",	"FIVE",	"CBSH",	"AGL",	"KRC",	"KNX",	"MHK",	
              "NBIX",	"TTC",	"TREX",	"UPST",	"WYNN",	"CIEN",	"PNW",	"WMS",	"NOV",	"ST",	"AIRC",	"MANH",	"HII",	
              "IAC",	"CHDN",	"HUN",	"ARW",	"LEA",	"XPO",	"STOR",	"FSLR",	"JBL",	"MAT",	"ORI",	"MKSI",	"ERIE",
              "RL",	"SYNH",	"PAG",	"UTHR",	"SITE",	"OGE",	"SEIC",	"WWD",	"USFD",	"BERY",	"WH",	"G",	"BFAM",	"FR",	
              "OLED",	"OLN",	"ACC",	"NNN",	"MASI",	"NYT",	"GXO",	"CHH",	"KSS",	"DXC",	"COUP",	"BEPC",	"BRX",
              "LECO",	"ATR",	"JEF",	"WEX",	"NVST",	"FAF",	"CPRI",	"LW",	"NXST",	"PEN",	"PNFP",	"GWRE",	"PENN",	
              "OSK",	"BLD",	"AVLR",	"GME",	"BYD",	"CACI",	"CHE",	"DECK",	"HTA",	"STWD",	"COLD",	"RH",	"GMED",
              "UGI",	"SNV",	"PLNT",	"BOKF",	"NVCR",	"PCOR",	"OHI",	"BC",	"PLAN",	"SF",	"UA",	"UAA",	"RGA",	"AN",	
              "SRPT",	"AGNC",	"WU",	"DKS",	"DNB",	"PLTK",	"TNDM",	"ESTC",	"EHC",	"COTY",	"EXEL",	"CHNG",	"GNTX",	
              "VOYA",	"CACC",	"LITE",	"DKNG",	"MTZ",	"ITT",	"PB",	"BPOP",	"CASY",	"PTON",	"COHR",	"SMG",	"PII",	
              "VAC",	"NFE",	"AYI",	"NLSN",	"RNR",	"DCI",	"RYN",	"ALK",	"RUN",	"NFG",	"DBX",	"FIVN",	"IBKR",
              "PEGA",	"TOL",	"SRC",	"REYN",	"CFX",	"HOG",	"CUZ",	"LFUS",	"CR",	"SMAR",	"IPGP",	"ADT",	"AZTA",
              "ACHC",	"DEI",	"GPK",	"EEFT",	"TXG",	"CLH",	"NVT",	"LPX",	"LSTR",	"TPX",	"PPC",	"CW",
              "CDK",	"NVAX",	"IDA",	"GH",	"INGR",	"TWKS",	"COLM",	"CHPT",	"UNM",	"JHG",	"OMF",	"SHC",	"DTM",	
              "HBI",	"SON",	"IART",	"ICUI",	"CVNA",	"ESI",	"AXTA",	"VVV",	"OZK",	"GPS",	"WTFC",	"EXP",	"UNVR",
              "AMG",	"NYCB",	"HHC",	"FLO",	"PACW",	"OSH",	"MDU",	"SLG",	"SRCL",	"MNDT",	"NCR",	"PVH",	"PRGO",	
              "SAIC",	"SKX",	"NTNX",	"NATI",	"MSA",	"ATUS",	"YETI",	"ASH",	"MRVI",	"FCN",	"QS",	"PRI",	"THG",	
              "TMX",	"ALGM",	"AMED",	"VMI",	"LEG",	"BWXT",	"SLM",	"IAA",	"NRZ",	"AMBP",	"SLGN",	"TDC",	"CRUS",	
              "MAN",	"THO",	"HXL",	"DLB",	"HIW",	"TFSL",	"TNL",	"TKR",	"WEN",	"IONS",	"H",	"HE",	"PYCR",	
              "RARE",	"UMPQ",	"SPR",	"SEB",	"MRTX",	"GTES",	"VRT",	"MCW",	"FLS",	"AXS",	"MTG",	"KEX",	"PK",	
              "DRVN",	"WIX",	"AWI",	"AL",	"R",	"OPEN",	"EVR",	"CC",	"PINC",	"NCNO",	"WOOF",	"HPP",	"VSCO",	
              "QDEL",	"POST",	"FNB",	"CHGG",	"AVT",	"JBLU",	"HRB",	"FRPT",	"INFA",	"SWCH",	"JAMF",	"EPR",	"HAYW",
              "NEWR",	"ALSN",	"CRI",	"AZEK",	"AGO",	"VSAT",	"NCLH",	"MSP",	"NTRA",	"MRCY",	"VNT",	"JBGS",	"HLF",
              "JWN",	"AYX",	"VIRT",	"LAZ",	"MSM",	"FHB",	"LESL",	"DV",	"SAM",	"BHF",	"SPB",	"SIX",	"KMPR",	
              "BOH",	"CNM",	"MSGS",	"NEU",	"LOPE",	"WTM",	"CERT",	"FL",	"TRIP",	"MCY",	"SABR",	"HAIN",	"CVAC",	
              "XRX",	"GO",	"SGFY",	"DCT",	"ADS",	"FOUR",	"KD",	"FIGS",	"WWE",	"OLLI",	"BYND",	"LZ",	"SNDR",	
              "STNE",	"CPA",	"DSEY",	"FTDR",	"IOVA",	"NKTR",	"TSP",	"SPCE",	"SHLS",	"AI",	"NABL",	"SAGE",	"QRTEA",
              "SWI",	"DH",	"VMEO",	"FSLY",	"ADPT",	"SLVM",	"RKT",	"COMM",	"EVBG",	"LMND",	"BRBR",	"ONL",
              "SKLZ",	"ZIMV",	"FLNC",	"LYLT",	"PSFE",	"UWMC",	"VRM",	"GOCO")
sp500 <- sort(sp500)
rusell_1 <- sort(rusell_1)

sp400 <- c("CPT",	"TRGP",	"AA",	"STLD",	"CLF",	"BLDR",	"FHN",	"FICO",	"CSL",	"MPW",	"RS",	"DAR",	
           "WTRG",	"AFG",	"GGG",	"CGNX",	"WOLF",	"CAR",	"JLL",	"REXR",	"WSO",	"LSI",	
           "ACM",	"EWBC",	"SNX",	"RRX",	"PCTY",	"WSM",	"CNXC",	"RPM",	"EQT",	"WBS",	"AGCO",	
           "HUBB",	"SCI",	"THC",	"JAZZ",	"BRKR",	"LAMR",	"LAD",	"LII",	"AZPN",	"RGEN",	"MIDD",	
           "RGLD",	"OC",	"AXON",	"CABO",	"CFR",	"X",	"Y",	"FIVE",	"CBSH",	"TTEK",	"KRC",	"KNX",	
           "NBIX",	"TTC",	"TREX",	"CIEN",	"NOV",	"BJ",	"AIRC",	"MANH",	"CHDN",	"ARW",	"LEA",	
           "XPO",	"STOR",	"SYNA",	"FSLR",	"JBL",	"MAT",	"ORI",	"MKSI",	"SYNH",	"UTHR",	"OGE",	
           "KBR",	"SEIC",	"EGP",	"WWD",	"WH",	"G",	"FR",	"OLED",	"OLN",	"ACC",	"NNN",	"MASI",	
           "NYT",	"GXO",	"CHH",	"KSS",	"LSCC",	"BRX",	"LECO",	"PFGC",	"ATR",	"JEF",	"WEX",	
           "NVST",	"FAF",	"CPRI",	"PEN",	"PNFP",	"RRC",	"OSK",	"BLD",	"GME",	"M",	"BYD",
           "CACI",	"CHE",	"DECK",	"IIVI",	"RH",	"GMED",	"UGI",	"SNV",	"SAIA",	"OHI",	"BC",	"RCM",
           "SF",	"RGA",	"AN",	"WU",	"DKS",	"TNDM",	"EHC",	"COTY",	"EXEL",	"GNTX",	"VOYA",	"LITE",	
           "FFIN",	"MTZ",	"ITT",	"PB",	"CASY",	"PDCE",	"COHR",	"SMG",	"PII",	"VAC",	"AYI",	"RNR",
           "DCI",	"RYN",	"EME",	"RUN",	"NFG",	"IBKR",	"TOL",	"SRC",	"CFX",	"HOG",	"GBCI",	"CUZ",
           "LFUS",	"CR",	"AZTA",	"ACHC",	"DEI",	"EEFT",	"CLH",	"NVT",	"SGMS",	"LPX",	"VLY",
           "MUR",	"LSTR",	"TPX",	"PPC",	"CW",	"CDK",	"IDA",	"INGR",	"COLM",	"NSA",	"UNM",	"JHG",	
           "DTM",	"ASGN",	"TXRH",	"HBI",	"SON",	"IART",	"ICUI",	"MIME",	"VVV",	"OZK",	"GPS",	"SLAB",	
           "WTFC",	"EXP",	"UNVR",	"AMG",	"NYCB",	"CCMP",	"POWI",	"FLO",	"PACW",	"CHX",	"MDU",	"SLG",
           "SRCL",	"AMKR",	"NCR",	"PRGO",	"SAIC",	"SKX",	"IRDM",	"NATI",	"MSA",	"YETI",	"ASH",	"SIGI",
           "SSD",	"FCN",	"HELE",	"QLYS",	"MEDP",	"PRI",	"THG",	"TGNA",	"CMC",	"KRG",	"AMED",	"UBSI",
           "VMI",	"LEG",	"UMBF",	"SLM",	"IAA",	"KNSL",	"HALO",	"SLGN",	"RLI",	"TDC",	"CRUS",	"MAN",
           "THO",	"HXL",	"HIW",	"OPCH",	"HWC",	"OGS",	"TNL",	"TKR",	"WEN",	"ZD",	"HE",	"MMS",	
           "UMPQ",	"BKH",	"AVNT",	"ESNT",	"FLS",	"ARWR",	"SWX",	"MTG",	"KEX",	"PK",	"MUSA",	"HQY",
           "PSB",	"LHCG",	"FOXF",	"R",	"EVR",	"GATX",	"NJR",	"LANC",	"CC",	"ELY",	"HPP",	"VSCO",	
           "QDEL",	"POST",	"SAIL",	"CROX",	"FNB",	"HR",	"AVT",	"FLR",	"JBLU",	"SMTC",	"SAFM",	"ENV",
           "HRB",	"CBT",	"PGNY",	"EPR",	"PNM",	"SITM",	"WTS",	"LIVN",	"CRI",	"PCH",	"HOMB",	"VSAT",
           "DOC",	"MRCY",	"CNX",	"VNT",	"JBGS",	"WING",	"GT",	"JWN",	"TMHC",	"NEOG",	"ACIW",	"MSM",	
           "SR",	"SPWR",	"SAM",	"BHF",	"ALE",	"SIX",	"ASB",	"SFM",	"PZZA",	"CATY",	"APPS",	"KMPR",	
           "BOH",	"KBH",	"NSP",	"NEU",	"ADNT",	"NWE",	"LOPE",	"ETRN",	"SBRA",	"OFC",	"SXT",	"TCBI",	
           "FCFS",	"BLKB",	"MAC",	"STAA",	"CADE",	"PEB",	"ENS",	"PDCO",	"BCO",	"FL",	"WOR",	"TRIP",	
           "MCY",	"DY",	"SABR",	"HAIN",	"AEO",	"XRX",	"FHI",	"ONB",	"VC",	"JW-A",	"GEF",	"GO",	"FULT",
           "CALX",	"WERN",	"ADS",	"CNO",	"HAE",	"CBRL",	"TRN",	"IBOC",	"CVLT",	"TEX",	"NUVA",	"KD",	
           "MLKN",	"NAVI",	"URBN",	"BDC",	"NGVT",	"WWE",	"OLLI",	"VSH",	"VICR",	"DAN",	"KMT",	"RAMP",	
           "TPH",	"NUS",	"GHC",	"WAFD",	"YELP",	"MTX",	"ENR",	"PRG",	"CRNC")
sp400 <- sort(sp400)

sp600 <- c("GTLS",	"MTDR",	"SWN",	"OMCL",	"IRT",	"UFPI",	"ROG",	"VG",	"EXPO",	"IIPR",	"SFBS",	
           "CIVI",	"ENSG",	"SM",	"ADC",	"AMN",	"MATX",	"HP",	"SPSC",	"WD",	"ABG",	"LXP",	"BCPC",	
           "MXL",	"EXLS",	"SJI",	"CNMD",	"UCBI",	"INDB",	"AIT",	"CBU",	"ONTO",	"FELE",	"ISBC",	
           "AGO",	"AEL",	"DIOD",	"LTHM",	"FIZZ",	"REZI",	"TTEC",	"NSIT",	"VIAV",	"CPE",
           "FHB",	"FN",	"MMSI",	"SMPL",	"BKU",	"LNTH",	"PRFT",	"MTH",	"COOP",	"PTEN",	"SIG",	"PPBI",
           "FUL",	"JBT",	"SITC",	"CELH",	"ATI",	"WSFS",	"ABCB",	"CVBF",	"KFY",	"IBTX",	"FIX",	"AVA",
           "HI",	"ALRM",	"COKE",	"SEM",	"SFNC",	"TRUP",	"GPI",	"PCRX",	"CYTK",	"KLIC",	"JOE",	"SSTK",	
           "MLI",	"AEIS",	"SAFE",	"AJRD",	"EPRT",	"UNIT",	"AWR",	"ABM",	"FORM",	"SHOO",	"REGI",	"CWT",	
           "PBF",	"MDC",	"RMBS",	"KWR",	"CCOI",	"BCC",	"DORM",	"OMI",	"IBP",	"JJSF",	"LCII",	"AX",	
           "LGIH",	"AAON",	"PBH",	"CORT",	"TWNK",	"EVTC",	"ACA",	"COLB",	"CRVL",	"BMI",	"FWRD",	"MOG-A",
           "HUBG",	"AIN",	"UNF",	"WDFC",	"BOOT",	"ITGR",	"HRMY",	"IPAR",	"MDRX",	"BANF",	"EPAY",	"ALGT",
           "SANM",	"WIRE",	"ARNC",	"FBP",	"MTOR",	"SHAK",	"RES",	"CPK",	"KTB",	"MANT",	"CVCO",	"HTH",	
           "TBK",	"GKOS",	"AAWW",	"NTCT",	"GCP",	"PSMT",	"PLXS",	"FBC",	"CVET",	"BDN",	"NXRT",	"ROIC",	
           "IOSP",	"THRM",	"PIPR",	"FFBC",	"AMEH",	"PRK",	"SPXC",	"AAT",	"GMS",	"CENTA",	"CENT",	"CENX",
           "FCPT",	"UE",	"TTGT",	"SCL",	"HCC",	"KAR",	"SBCF",	"XHR",	"WRE",	"FBK",	"NPO",	"ACLS",	
           "B",	"MYGN",	"CMP",	"MODV",	"ITRI",	"ARCB",	"LKFN",	"CSGS",	"ODP",	"UNFI",	"FSS",	"BANR",	
           "CCS",	"MD",	"TDS",	"DRH",	"BRC",	"VSTO",	"VBTX",	"MED",	"RNST",	"NKTR",	"HOPE",	"NEO",
           "WGO",	"EBS",	"TRMK",	"KN",	"PRGS",	"EPC",	"BBBY",	"NVEE",	"CALM",	"AKR",	"IDCC",	"PLAY",	
           "DEA",	"AVAV",	"ARI",	"GNW",	"SBH",	"EGBN",	"ESE",	"DDD",	"CNK",	"CUBI",	"OI",	"WWW",
           "THS",	"BLMN",	"PFS",	"CAKE",	"RLGY",	"FOE",	"BKE",	"CRSR",	"MMI",	"UCTT",	"TWO",	"NMIH",	
           "SKT",	"MTRN",	"NWBI",	"VRTV",	"STC",	"BGS",	"PRAA",	"RILY",	"MSEX",	"LGND",	"XPER",	"JACK",
           "TSE",	"ALG",	"INT",	"HMN",	"NWN",	"ALEX",	"CRS",	"CTRE",	"MGPI",	"GBX",	"STAR",	"NBTB",	
           "LPSN",	"WABC",	"GPRE",	"AMPH",	"OII",	"FLGT",	"SUPN",	"MRTN",	"LNN",	"AIR",	"XNCR",	"ANF",	
           "MEI",	"VCEL",	"MYRG",	"USNA",	"VRTS",	"PMT",	"VRE",	"XPEL",	"EAT",	"TBBK",	"VGR",	"HSKA",
           "FBNC",	"IRBT",	"GNL",	"GDEN",	"CYH",	"CFFN",	"RCII",	"CASH",	"ROCK",	"MCRI",	"ECPG",	"HNI",	
           "TVTY",	"MNRO",	"PUMP",	"PATK",	"PLMR",	"AVNS",	"CSR", "TNC",	"UIS",	"SSP",	"SLVM",	
           "ECOL",	"ANDE",	"TGI",	"FCF",	"CLB",	"STRA",	"GVA",	"BHLB",	"ILPT",	"SNEX",	"AROC",	"EXTR",	
           "OSIS",	"MHO",	"PLUS",	"LTC",	"OXM",	"VECO",	"NYMT",	"DRQ",	"PRLB",	"KALU",	"SCHL",	"COHU",	
           "SNBR",	"GDOT",	"NBR",	"SBSI",	"PRA",	"SVC",	"UVV",	"ASIX",	"DCOM",	"ENTA",	"SAH",	"CNXN",
           "OFG",	"TTMI",	"DLX",	"INVA",	"GTY",	"MLAB",	"TR",	"RWT",	"NXGN",	"TALO",	"RC",	"SKYW",	"SXI",
           "BRKL",	"HCSG",	"ITOS",	"LPI",	"PGTI",	"TREE",	"NBHC",	"EGHT",	"SAFT",	"ADUS",	"RGR",	"GFF",	
           "LZB",	"ELF",	"DIN",	"USPH",	"KREF",	"OPI",	"AZZ",	"EBIX",	"ATGE",	"RGNX",	"CHCO",	"BANC",	
           "SLCA",	"DNOW",	"AMCX",	"EPAC",	"APOG",	"KAMN",	"RDNT",	"FDP",	"GIII",	"TMP",	"CEIX",	"CDMO",	
           "STBA",	"GES",	"RPT",	"POLY",	"ENVA",	"CTS",	"CCSI",	"HTLD",	"EIG",	"VIVO",	"SPTN",	"BFS",
           "VTOL",	"CHEF",	"SPNT",	"HSC",	"WRLD",	"CXW",	"INN",	"MATW",	"PLAB",	"BSIG",	"SHEN",	"HMST",	
           "EFC",	"DFIN",	"CHCT",	"BIG",	"CARS",	"PDFS",	"AHH",	"GCO",	"PFBC",	"ASTE",	"ORGO",	"AGYS",	
           "HWKN",	"THRY",	"AMWD",	"VREX",	"MERC",	"ADTN",	"AXL",	"FORR",	"ICHR",	"CHRS",	"ONL",	"HZO",	
           "SMP",	"BLFS",	"FARO",	"LMAT",	"ZUMZ",	"HLIT",	"TBI",	"AMSF",	"SWM",	"BHE",	"ABTX",	"HFWA",	
           "BCOR",	"ANGO",	"TMST",	"TUP",	"CEVA",	"TWI",	"PBI",	"NTUS",	"HA",	"SCSC",	"SLP",	"ARLO",	
           "UTL",	"ARR",	"SCVL",	"UHT",	"DBI",	"ROCC",	"UBA",	"JRVR",	"KELYA",	"CPF",	"AORT",	"HLX",
           "PARR",	"NX",	"TILE",	"CUTR",	"WNC",	"WETF",	"NFBK",	"HAFC",	"IIIN",	"CSII",	"CAL",	"RUTH",	
           "PLCE",	"HNGR",	"PRDO",	"HSII",	"CCRN",	"SXC",	"IVR",	"DHC",	"JBSS",	"DGII",	"UFCS",	"QURE",	
           "NTGR",	"HCI",	"VVI",	"WW",	"CLDT",	"GEO",	"INGN",	"AAN",	"OPRX",	"ETD",	"MYE",	"TRST",	
           "CARA",	"EGRX",	"BOOM",	"CVGW",	"OFIX",	"WSR",	"CNSL",	"BJRI",	"VNDA",	"HIBB",	"QNST",	"SGH",	
           "ZIMV",	"GCI",	"ANIP",	"NP",	"FSP",	"HSTM",	"KOP",	"GPMT",	"DXPE",	"SRDX",	"LQDT",	"CRMT",	
           "AMBC",	"COLL",	"FBRT",	"REX",	"DBD",	"GLT",	"MOV",	"LPG",	"NPK",	"PETS",	"ATNI",	"CONN",	
           "RMAX",	"ENDP",	"DOUG",	"AVD",	"HAYN",	"RGP",	"CHUY",	"OSPN",	"HVT",	"CPSI",	"CHS",	"OSUR",	
           "CIR",	"CLW",	"LYLT",	"JYNT",	"OIS",	"FOSL",	"LL",	"CMTL",	"MCS",	"LOCO",	"SENEA",	"APEI",	
           "RYAM",	"PAHC",	"UEIC",	"PNTG",	"TG",	"UVE",	"ANIK",	"FF",	"SLQT",	"HT",	"CATO",	"TCMD",	"ZEUS",
           "UFI",	"MPAA",	"EZPW",	"GHL",	"PKE",	"EHTH",	"RRGB",	"POWL",	"VRA",	"FRGI",	"BNED",	"ZYXI",	
           "CPS",	"CAMP")
sp600 <- sort(sp600)

us_market <- sort(unique(c(dj30, nasdaq, sp500, rusell_1, sp400, sp600)))

hsi <- c("0005", "0011", "0388", "0939", "1299", "1398", "2318", "2388", "2628", "3968", 
         "3988", "0002", "0003", "0006", "1038", "0012", "0016", "0017", "0101", "0688", 
         "0823", "0960", "1109", "1113", "1997", "2007", "6098", "0001", "0027", "0066", 
         "0175", "0241", "0267", "0288", "0386", "0669", "0700", "0762", "0857", "0868", 
         "0883", "0941", "0968", "1044", "1093", "1177", "1211", "1810", "1876", "1928",
         "2018", "2020", "2269", "2313", "2319", "2331", "2382", "3690", "6862", "9988")
hsi <- lapply(1:60, function(i){
  hsi[i] <- paste(hsi[i], ".hk", sep="")
})
hsi <- unlist(hsi)

# shanghai 180
ss <- c("600000",	"600011",	"600025",	"600030",	"600038",	"600061",	"600104",	"600118",	
        "600150",	"600183",	"600298",	"600340",	"600362",	"600426",	"600489",	"600519",	
        "600536",	"600584",	"600598",	"600621",	"600699",	"600741",	"600763",	"600827",	
        "600862",	"600886",	"600895",	"600918",	"600958",	"601009",	"601066",	"601100",	
        "601138",	"601166",	"601198",	"601225",	"601238",	"601319",	"601360",	"601398",	
        "601601",	"601628",	"601668",	"601689",	"601766",	"601800",	"601857",	"601877",	
        "601888",	"601916",	"601939",	"601988",	"601995",	"603160",	"603288",	"603501",	
        "603658",	"603806",	"603986",	"688111",	"600009",	"600016",	"600028",	"600031",	
        "600048",	"600066",	"600109",	"600132",	"600161",	"600196",	"600305",	"600346",	
        "600383",	"600436",	"600511",	"600521",	"600547",	"600585",	"600600",	"600660",	
        "600703",	"600745",	"600779",	"600837",	"600867",	"600887",	"600900",	"600919",	
        "600989",	"601012",	"601088",	"601108",	"601155",	"601169",	"601211",	"601229",	
        "601288",	"601328",	"601377",	"601456",	"601607",	"601633",	"601669",	"601696",	
        "601778",	"601816",	"601865",	"601878",	"601899",	"601919",	"601966",	"601989",	
        "603019",	"603195",	"603369",	"603517",	"603659",	"603833",	"603993",	"688126",	
        "600010",	"600019",	"600029",	"600036",	"600050",	"600089",	"600111",	"600143",	
        "600176",	"600276",	"600309",	"600352",	"600406",	"600438",	"600516",	"600522",	
        "600570",	"600588",	"600606",	"600690",	"600739",	"600760",	"600809",	"600859",	
        "600872",	"600893",	"600909",	"600926",	"600999",	"601021",	"601099",	"601111",	
        "601162",	"601186",	"601216",	"601236",	"601318",	"601336",	"601390",	"601555",	
        "601618",	"601658",	"601688",	"601698",	"601788",	"601818",	"601872",	"601881",	
        "601901",	"601933",	"601985",	"601990",	"603087",	"603259",	"603392",	"603589",	
        "603799",	"603882",	"688012",	"688169")
ss <- lapply(1:180, function(i){
  ss[i] <- paste(ss[i], ".ss", sep="")
})
ss <- unlist(ss)

# shanghai 380
ss380 <- c("600007",	"600018",	"600027",	"600057",	"600073",	"600094",	"600120",	"600141",	
           "600167",	"600177",	"600197",	"600211",	"600223",	"600248",	"600258",	"600284",	
           "600299",	"600325",	"600329",	"600338",	"600363",	"600372",	"600377",	"600388",	
           "600409",	"600422",	"600459",	"600483",	"600498",	"600507",	"600531",	"600556",	
           "600563",	"600567",	"600582",	"600597",	"600641",	"600655",	"600673",	"600688",	
           "600711",	"600729",	"600742",	"600754",	"600765",	"600787",	"600802",	"600811",	
           "600835",	"600848",	"600885",	"600917",	"600966",	"600970",	"600985",	"600998",	
           "601006",	"601018",	"601069",	"601128",	"601158",	"601198",	"601231",	"601311",	
           "601567",	"601611",	"601665",	"601699",	"601808",	"601828",	"601866",	"601908",	
           "601965",	"601998",	"603008",	"603025",	"603039",	"603060",	"603108",	"603127",	
           "603180",	"603198",	"603225",	"603236",	"603279",	"603298",	"603313",	"603338",	
           "603378",	"603416",	"603456",	"603505",	"603520",	"603556",	"603583",	"603596",	
           "603600",	"603606",	"603613",	"603650",	"603681",	"603707",	"603712",	"603730",	
           "603786",	"603816",	"603868",	"603881",	"603887",	"603899",	"603919",	"603939",	
           "603982",	"603997",	"605111",	"605168",	"605266",	"605358",	"688005",	"688016",	
           "688036",	"688099",	"688166",	"688202",	"688298",	"688368",	"688568",	"600008",
           "600021",	"600039",	"600062",	"600075",	"600095",	"600125",	"600153",	"600170",
           "600185",	"600206",	"600216",	"600233",	"600252",	"600273",	"600285",	"600316",	
           "600326",	"600332",	"600348",	"600368",	"600373",	"600378",	"600392",	"600415",	
           "600446",	"600466",	"600486",	"600499",	"600510",	"600548",	"600559",	"600565",	
           "600577",	"600583",	"600612",	"600643",	"600663",	"600674",	"600704",	"600720",	
           "600738",	"600746",	"600755",	"600776",	"600795",	"600803",	"600820",	"600845",	
           "600850",	"600895",	"600933",	"600967",	"600975",	"600988",	"601000",	"601015",	
           "601019",	"601098",	"601139",	"601168",	"601200",	"601233",	"601330",	"601577",	
           "601615",	"601666",	"601717",	"601811",	"601838",	"601869",	"601949",	"601992",	
           "603000",	"603010",	"603026",	"603043",	"603068",	"603113",	"603128",	"603187",	
           "603208",	"603228",	"603258",	"603283",	"603301",	"603317",	"603355",	"603387",	
           "603429",	"603466",	"603508",	"603529",	"603565",	"603587",	"603598",	"603601",	
           "603609",	"603626",	"603666",	"603686",	"603708",	"603713",	"603733",	"603801",	
           "603858",	"603871",	"603883",	"603888",	"603915",	"603920",	"603956",	"603985",	
           "605009",	"605117",	"605199",	"605296",	"605376",	"688006",	"688019",	"688055",	
           "688122",	"688188",	"688208",	"688318",	"688390",	"688598",	"600015",	"600026",	
           "600056",	"600072",	"600079",	"600116",	"600131",	"600160",	"600171",	"600188",	
           "600210",	"600219",	"600236",	"600256",	"600282",	"600295",	"600323",	"600328",	
           "600337",	"600350",	"600369",	"600376",	"600380",	"600395",	"600420",	"600452",	
           "600477",	"600487",	"600502",	"600529",	"600549",	"600562",	"600566",	"600580",	
           "600596",	"600639",	"600648",	"600667",	"600685",	"600705",	"600728",	"600740",	
           "600750",	"600764",	"600782",	"600801",	"600808",	"600823",	"600846",	"600879",	
           "600903",	"600956",	"600968",	"600984",	"600993",	"601003",	"601016",	"601058",	
           "601117",	"601156",	"601187",	"601222",	"601298",	"601512",	"601598",	"601636",
           "601686",	"601799",	"601827",	"601858",	"601882",	"601952",	"601997",	"603005",
           "603018",	"603027",	"603056",	"603077",	"603118",	"603129",	"603197",	"603218",	
           "603233",	"603267",	"603290",	"603305",	"603327",	"603357",	"603393",	"603444",	
           "603489",	"603515",	"603533",	"603568",	"603588",	"603599",	"603605",	"603610",	
           "603638",	"603678",	"603690",	"603711",	"603728",	"603737",	"603808",	"603866",	
           "603877",	"603885",	"603893",	"603916",	"603927",	"603960",	"603989",	"605099",	
           "605136",	"605222",	"605337",	"688002",	"688008",	"688026",	"688088",	"688139",	
           "688200",	"688289",	"688356",	"688399")
ss380 <- lapply(1:380, function(i){
  ss380[i] <- paste(ss380[i], ".ss", sep="")
})
ss380 <- unlist(ss380)

## shen zhen 500
sz500 <- c(
  "000001",	"000002",	"000009",	"000012",	"000021",	"000027",	"000028",	"000031",	"000034",	
  "000035",	"000039",	"000046",	"000050",	"000060",	"000062",	"000063",	"000066",	"000069",	
  "000078",	"000089",	"000100",	"000156",	"000157",	"000158",	"000166",	"000301",	"000333",	
  "000338",	"000400",	"000401",	"000402",	"000403",	"000415",	"000423",	"000425",	"000488",	
  "000513",	"000516",	"000528",	"000537",	"000538",	"000539",	"000540",	"000547",	"000553",	
  "000555",	"000559",	"000560",	"000563",	"000568",	"000581",	"000582",	"000591",	"000596",	
  "000598",	"000600",	"000617",	"000623",	"000625",	"000627",	"000629",	"000630",	"000651",	
  "000656",	"000661",	"000671",	"000672",	"000681",	"000685",	"000686",	"000688",	"000690",	
  "000703",	"000708",	"000709",	"000710",	"000712",	"000717",	"000718",	"000723",	"000725",	
  "000728",	"000729",	"000735",	"000738",	"000739",	"000750",	"000758",	"000768",	"000776",	
  "000778",	"000783",	"000785",	"000786",	"000789",	"000799",	"000800",	"000807",	"000825",	
  "000826",	"000830",	"000831",	"000858",	"000860",	"000869",	"000876",	"000877",	"000878",	
  "000883",	"000887",	"000895",	"000898",	"000902",	"000921",	"000927",	"000930",	"000932",	
  "000933",	"000935",	"000937",	"000938",	"000951",	"000958",	"000959",	"000960",	"000961",	
  "000963",	"000967",	"000970",	"000975",	"000977",	"000983",	"000987",	"000988",	"000990",	
  "000997",	"000998",	"000999",	"001872",	"001914",	"001965",	"001979",	"002001",	"002002",	
  "002004",	"002007",	"002008",	"002010",	"002013",	"002019",	"002023",	"002024",	"002025",	
  "002027",	"002028",	"002030",	"002032",	"002038",	"002044",	"002048",	"002049",	"002050",	
  "002056",	"002064",	"002065",	"002074",	"002075",	"002078",	"002080",	"002081",	"002085",	
  "002091",	"002092",	"002099",	"002100",	"002110",	"002120",	"002123",	"002124",	"002127",	
  "002128",	"002129",	"002131",	"002138",	"002142",	"002146",	"002151",	"002152",	"002153",	
  "002155",	"002156",	"002157",	"002174",	"002179",	"002180",	"002183",	"002185",	"002191",	
  "002194",	"002195",	"002202",	"002203",	"002212",	"002216",	"002217",	"002221",	"002223",	
  "002230",	"002233",	"002236",	"002237",	"002241",	"002242",	"002243",	"002244",	"002249",	
  "002250",	"002252",	"002262",	"002266",	"002268",	"002271",	"002273",	"002281",	"002294",	
  "002299",	"002302",	"002304",	"002310",	"002311",	"002320",	"002332",	"002340",	"002351",	
  "002352",	"002353",	"002368",	"002371",	"002372",	"002373",	"002375",	"002382",	"002384",	
  "002385",	"002387",	"002389",	"002390",	"002396",	"002399",	"002402",	"002405",	"002408",	
  "002409",	"002410",	"002414",	"002415",	"002419",	"002422",	"002423",	"002424",	"002429",	
  "002430",	"002434",	"002436",	"002439",	"002440",	"002444",	"002456",	"002458",	"002459",	
  "002460",	"002461",	"002463",	"002465",	"002468",	"002475",	"002481",	"002493",	"002497",	
  "002498",	"002500",	"002505",	"002506",	"002507",	"002508",	"002511",	"002531",	"002532",	
  "002541",	"002555",	"002557",	"002558",	"002563",	"002568",	"002572",	"002583",	"002594",	
  "002595",	"002597",	"002600",	"002601",	"002602",	"002603",	"002607",	"002608",	"002624",	
  "002625",	"002626",	"002635",	"002643",	"002648",	"002653",	"002670",	"002673",	"002675",	
  "002683",	"002690",	"002701",	"002705",	"002706",	"002709",	"002714",	"002727",	"002736",	
  "002745",	"002747",	"002755",	"002756",	"002773",	"002791",	"002793",	"002797",	"002812",
  "002815",	"002818",	"002821",	"002831",	"002839",	"002841",	"002847",	"002851",	"002867",
  "002901",	"002911",	"002912",	"002916",	"002918",	"002920",	"002925",	"002926",	"002936",
  "002938",	"002939",	"002945",	"002946",	"002948",	"002950",	"002958",	"002959",	"002961",
  "002966",	"002967",	"002978",	"002984",	"002985",	"003012",	"003816",	"300001",	"300002",
  "300003",	"300009",	"300012",	"300014",	"300015",	"300017",	"300024",	"300026",	"300033",	
  "300037",	"300054",	"300058",	"300059",	"300068",	"300070",	"300072",	"300073",	"300085",	
  "300088",	"300113",	"300115",	"300118",	"300122",	"300124",	"300133",	"300136",	"300142",	
  "300144",	"300146",	"300166",	"300180",	"300182",	"300188",	"300207",	"300212",	"300223",	
  "300226",	"300236",	"300244",	"300251",	"300253",	"300257",	"300271",	"300274",	"300285",	
  "300294",	"300296",	"300298",	"300308",	"300315",	"300316",	"300326",	"300346",	"300347",	
  "300348",	"300357",	"300369",	"300373",	"300376",	"300379",	"300383",	"300408",	"300413",	
  "300418",	"300433",	"300450",	"300451",	"300454",	"300456",	"300457",	"300458",	"300459",	
  "300463",	"300474",	"300476",	"300482",	"300496",	"300498",	"300502",	"300529",	"300558",	
  "300567",	"300595",	"300601",	"300602",	"300616",	"300618",	"300623",	"300628",	"300630",	
  "300633",	"300638",	"300661",	"300666",	"300674",	"300676",	"300677",	"300682",	"300685",	
  "300699",	"300702",	"300724",	"300725",	"300726",	"300735",	"300741",	"300747",	"300748",	
  "300750",	"300751",	"300759",	"300760",	"300761",	"300763",	"300768",	"300770",	"300773",
  "300775",	"300777",	"300782",	"300783",	"300803",	"300815",	"300832",	"300841",	"300861",
  "300866",	"300869",	"300888",	"300896",	"300999")
sz500 <- lapply(1:500, function(i){
  sz500[i] <- paste(sz500[i], ".sz", sep="")
})
sz500 <- unlist(sz500)
china_market <- sort(unique(c(hsi, ss, ss380, sz500)))

# import stock pool
nasdaq_pool <- lapply(1:length(nasdaq), 
                      function(i) nasdaq[i] <- getSymbols(nasdaq[i], from = from
                                                          , auto.assign = FALSE, reload.Symbols = TRUE))
dj30_pool <- lapply(1:length(dj30), 
                    function(i) dj30[i] <- getSymbols(dj30[i], from = from 
                                                      , auto.assign = FALSE, reload.Symbols = TRUE))
sp500_pool <- lapply(1:length(sp500), 
                     function(i) sp500[i] <- getSymbols(sp500[i], from = from 
                                                        , auto.assign = FALSE, reload.Symbols = TRUE))
hsi_pool <- lapply(1:length(hsi), 
                   function(i) hsi[i] <- getSymbols(hsi[i], from = from
                                                    , auto.assign = FALSE, reload.Symbols = TRUE))
ss_pool <- lapply(1:length(ss), 
                  function(i) ss[i] <- getSymbols(ss[i], from = from
                                                  , auto.assign = FALSE, reload.Symbols = TRUE))
ss380_pool <- lapply(1:length(ss380), 
                     function(i) ss380[i] <- getSymbols(ss380[i], from = from
                                                        , auto.assign = FALSE, reload.Symbols = TRUE))
sz500_pool <- lapply(1:length(sz500), 
                     function(i) sz500[i] <- getSymbols(sz500[i], from = from
                                                        , auto.assign = FALSE, reload.Symbols = TRUE))


us_pool <- lapply(1:length(us_market),
                     function(i) us_market[i] <- getSymbols(us_market[i], from = from, auto.assign = FALSE))
china_pool <- lapply(1:length(china_market),
                  function(i) china_market[i] <- getSymbols(china_market[i], from = from, auto.assign = FALSE))
# renames
names(nasdaq_pool) <- nasdaq
names(dj30_pool) <- dj30
names(sp500_pool) <- sp500
names(hsi_pool) <- hsi
names(ss_pool) <- ss
names(ss380_pool) <- ss380
names(sz500_pool) <- sz500

names(us_pool) <- us_market
names(china_pool) <- china_market
# save to the directory /data in csv format
lapply(1:length(nasdaq), function(i){
  stock <- xts(data.frame(nasdaq_pool[i]), order.by = as.Date(rownames(data.frame(nasdaq_pool[i]))))
  write.csv(data.frame(date = index(stock), coredata(stock)), 
            file = paste(dir$source, "/nasdaq/", nasdaq[i], ".csv", sep=""), row.names = F)})

lapply(1:length(dj30), function(i){
  stock <- xts(data.frame(dj30_pool[i]), order.by = as.Date(rownames(data.frame(dj30_pool[i]))))
  write.csv(data.frame(date = index(stock), coredata(stock)), 
            file = paste(dir$source, "/dj/", dj30[i], ".csv", sep=""), row.names = F)})

lapply(1:length(sp500), function(i){
  stock <- xts(data.frame(sp500_pool[i]), order.by = as.Date(rownames(data.frame(sp500_pool[i]))))
  write.csv(data.frame(date = index(stock), coredata(stock)), 
            file = paste(dir$source, "/sp500/", sp500[i], ".csv", sep=""), row.names = F)})

lapply(1:length(hsi), function(i){
  stock <- xts(data.frame(hsi_pool[i]), order.by = as.Date(rownames(data.frame(hsi_pool[i]))))
  write.csv(data.frame(date = index(stock), coredata(stock)), 
            file = paste(dir$source, "/hk/", hsi[i], ".csv", sep=""), row.names = F)})

lapply(1:length(ss), function(i){
  stock <- xts(data.frame(ss_pool[i]), order.by = as.Date(rownames(data.frame(ss_pool[i]))))
  write.csv(data.frame(date = index(stock), coredata(stock)), 
            file = paste(dir$source, "/ss/", ss[i], ".csv", sep=""), row.names = F)})

lapply(1:length(ss380), function(i){
  stock <- xts(data.frame(ss380_pool[i]), order.by = as.Date(rownames(data.frame(ss380_pool[i]))))
  write.csv(data.frame(date = index(stock), coredata(stock)), 
            file = paste(dir$source, "/ss380/", ss380[i], ".csv", sep=""), row.names = F)})

lapply(1:length(sz500), function(i){
  stock <- xts(data.frame(sz500_pool[i]), order.by = as.Date(rownames(data.frame(sz500_pool[i]))))
  write.csv(data.frame(date = index(stock), coredata(stock)), 
            file = paste(dir$source, "/sz/", sz500[i], ".csv", sep=""), row.names = F)})
