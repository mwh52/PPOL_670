getwd()
setwd("/Users/michael/Desktop/working directory")
rm(list = ls(all = TRUE))
library(RJSONIO)
library(RCurl)
library(ggplot2)

# so Ive seen a version that loops by subject and by page and pulls all responses in that way. This monthly funciton may seem to put a greater burden on the API, but it does so a fixed number of times.

### set parameters ###
#API key
consumerKey <- ""

# "Determining articles about budget deficits"
q <- "source:(\"The+New+York+Times\")+AND+body:(\"budget+shortfall\"+\"fiscal+challenge\"+\"fiscal+cliff\"+\"government+debt\"+\"national+debt\"+\"national+deficit\"+\"budget+deficit\")"
#check <- getURL(paste0("http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=",q,"&facet_field=source&fl=pub_date&begin_date=20121201&end_date=20131227&facet_filter=true&api-key=",consumerKey))
#convert <- fromJSON(check, simplify = FALSE)

##generating start and end pull requests
# need a list of years
yearNum <- seq(1851,2015,1)
year <- as.character(yearNum)
#months and days
month <- c("01","02","03","04","05","06","07","08","09","10","11","12")
enddate <- c("31","28","31","30","31","30","31","31","30","31","30","31")
emonth <- paste(month,enddate,sep = "")
#create combination matrix of days and years
edate <- expand.grid(year, emonth)

## leap year code derived from "http://www.r-bloggers.com/leap-years/"
  is.leapyear=function(y){
   yr<- as.numeric(y)
   return(((yr %% 4 == 0) & (yr %% 100 != 0)) | (yr %% 400 == 0))
  }
yrstring<- paste(edate$Var1)
edate$leapyear <- is.leapyear(yrstring)
edate$Var2 <- ifelse((edate$leapyear == TRUE & edate$Var2 == "0228"),"0229", as.character(edate$Var2))
# end leap year code
# toss leap year variable
edate$leapyear <- NULL

#make flat for looping
eedate <- apply(edate,1,paste,collapse="")
sample <- eedate[]

counts <- c()
dates <- c()

## warning: if date invalid, api returns all results 
for (i in sample) {
  Sys.sleep(.2)
  start <- paste0(substring(i,0,6),"01",sep = "")
  end <- i
  resp <- getURL(paste0("http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=",q,"&facet_field=source&fl=pub_date&begin_date=",start,"&end_date=", end,"&facet_filter=true&api-key=",consumerKey))
  convert <- fromJSON(resp, simplify = FALSE)
  ## next line from http://web.stanford.edu/~cengel/cgi-bin/anthrospace/scraping-new-york-times-articles-with-r
  counts <- append(counts, unlist(convert$response$meta$hits))  # convert the dates to a vector and append
  dates <- append(dates, start)  
}

#convert dates to using format
artyear <- substring(dates,0,4)
artyearnum <- as.numeric(artyear)
artmont <- substring(dates,5,6)
artmontnum <- as.integer(artmont)
artmont <- month.abb[artmontnum]
artmonthyear <- paste(artmont," ",artyear)
information = data.frame(artmonthyear, counts, artmont, artyear, artyearnum, artmontnum)

#reorder for graphing purposes
orderedinformation <- information[order(artyearnum,artmontnum),]
# cut for current date
orderedinformation2 <- orderedinformation[1:1969,]


orderedinformation2$sortnum <- orderedinformation2$artyearnum + (orderedinformation2$artmontnum/100)
orderedinformation2$yearmonth <- as.character(orderedinformation2$sortnum)

#save file
write.table(orderedinformation2, file = "data", append = FALSE, quote = TRUE, sep = ",",
            eol = "\n", na = "NA", dec = ".", row.names = TRUE,
            col.names = TRUE, qmethod = c("escape", "double"),
            fileEncoding = "")
#graphing
png(file="chart.png",
    width = 900, height = 300)
p<- ggplot(orderedinformation2, aes(x = orderedinformation2$yearmonth, y = orderedinformation2$counts,group=1))+labs(x="Date")+labs(y="Number of Articles")
d <-p + geom_line()
d
dev.off()
