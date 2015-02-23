getwd()
setwd("/Users/michael/Desktop/working directory")
rm(list = ls(all = TRUE))
library(RJSONIO)
library(RCurl)
library(ggplot2)


# so Ive seen a version that loops by subject and by page and pulls all responses in that way. This monthly funciton may seem to put a greater burden on the API, but it does so a fixed number of times.

### set parameters ###
#API key
consumerKey <- "e1a7e4a5bb8f9c1155bf6e5853a8ece7:10:68135779"

# "Determining articles about budget deficits"
q <- "(\"budget deficit\" \"budget shortfall\" \"fiscal challenge\" \"fiscal cliff\" \"government debt\" \"national debt\" \"national deficit\" \"budget deficit\")" 
q <- "'body':['budget deficit', 'budget shortfall', 'fiscal challenge', 'fiscal cliff', 'government debt', 'national debt', 'national deficit', 'budget deficit']"
q <- "{'source':'The New York Times','body':['budget deficit', 'budget shortfall', 'fiscal challenge', 'fiscal cliff', 'government debt', 'national debt', 'national deficit', 'budget deficit']}"
q <- "source:(\"The New York Times\") AND body:(\"Obama\")"
q <- "(\"Obama\")"
check <- getURL(paste0("http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=",q,"&facet_field=source&fl=pub_date&begin_date=20121201&end_date=20131227&facet_filter=true&api-key=",consumerKey))
convert <- fromJSON(check, simplify = FALSE)
convert

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
matrix<- as.matrix(edate)
edate[==TRUE & Var2 == "0228",2] <- "0229"

edate$dts<-
# end leap year code
subset$

edate$leapyear <- NULL

eedate <- apply(edate,1,paste,collapse="")
sample <- eedate[1975:1979]

counts <- c()
dates <- c()

## if date invalid, returns all results 
#(filter-term)&
for (i in sample) {
  start <- paste0(substring(i,0,6),"01",sep = "")
  end <- i
  resp <- getURL(paste0("http://api.nytimes.com/svc/search/v2/articlesearch.json?fq=body:",q,"&facet_field=source&fl=pub_date&begin_date=",start,"&end_date=", end,"&facet_filter=true&api-key=",consumerKey))
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
#graphing
png(file="chart-all_time_monthly.png",
    width = 900, height = 300)
p<- ggplot(orderedinformation, aes(x = artmonthyear, y = counts,group=1))+labs(x="Date")+labs(y="Number of Articles") 
d <-p + geom_line()
d
dev.off()

