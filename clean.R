# read in the data
library(readxl)
rawdata<-read_xlsx("data/EdinParkQuality_rawdata.xlsx", sheet="2015", col_names = F)

# format the columns
head(rawdata$...1)

# get rid of the numbers 
rawdata$Name<-gsub("[[:digit:]]+", "" ,rawdata$...1)
rawdata$Name<-gsub("[[:punct:]]+", "" ,rawdata$Name)

rawdata$Name<-gsub("\\Natural Park\\b", "" ,rawdata$Name)
rawdata$Name<-gsub("\\South West\\b", "" ,rawdata$Name)
rawdata$Name<-gsub("\\Community Park\\b", "" ,rawdata$Name)
rawdata$Name<-gsub("\\ South\\b", "" ,rawdata$Name)
rawdata$Name<-gsub("\\ East\\b", "" ,rawdata$Name)
rawdata$Name<-gsub("\\CC\\b", "" ,rawdata$Name)
rawdata$Name<-gsub("\\Leith\\b", "" ,rawdata$Name)
rawdata$Name<-gsub("\\Premier Park\\b", "" ,rawdata$Name)
rawdata$Name<-gsub("\\  North\\b|\\ North\\b", "" ,rawdata$Name)
rawdata$Name<-gsub("\\  West\\b", "" ,rawdata$Name)
rawdata$Name<-gsub("\\Gardens Garden\\b|\\Garden Garden\\b", "Garden" ,rawdata$Name)
rawdata$Name<-gsub("\\ Links\\b", "Leith Links" ,rawdata$Name)

# getting the data
library(readr)
rawdata$score2014<-parse_number(rawdata$...1)

rawdata$score2014[rawdata$Name=="HoBinc Blackford Hill     "]<-78
rawdata$score2014[rawdata$Name=="Portobello Comm Garden     "]<-72
rawdata$score2014[rawdata$Name=="Gracemount Comm Park     "]<-54
rawdata$score2014[rawdata$Name=="GorgieDalry Comm Park      "]<-45

rawdata$...1<-NULL
#write.csv(rawdata, "data/EdinParkQuality_rawdata2014.csv")

# manual edits
# add in the data for 2008 from here: https://www.edinburgh.gov.uk/downloads/file/22559/parks-quality-report-2018 

procdata<-read.csv("data/EdinParkQuality_rawdata2014 - EdinParkQuality_rawdata_master.csv")

procdata$Scorechange<-procdata$Score2021-procdata$Score2014

# geocode the data and then see which park they fall in using the os map

library(ggmap)


addr.geo$lat[addr.geo$Name=="Whinhill Park       , Edinburgh, Scotland"]<-55.927589
addr.geo$lon[addr.geo$Name=="Whinhill Park       , Edinburgh, Scotland"]<--3.271985

addr.geo$lat[addr.geo$Name=="Marchbank Park       , Edinburgh, Scotland"]<-55.877015
addr.geo$lon[addr.geo$Name=="Marchbank Park       , Edinburgh, Scotland"]<--3.343840



#write.csv(addr.geo, "data/EdinParkQuality_rawdata2014_2.csv")


# mre detailed data for 2021 at end of report here: https://www.edinburgh.gov.uk/downloads/file/30233/parks-quality-report-2021

library(sf)

parkpoints<-st_read("geo/parkpoints.shp")
simd<-st_read("geo/sc_dz_11.shp")
simddata<-read.csv("data/simd2020_withinds.csv")
simd<-merge(simd, simddata, by.x="DataZone", by.y="Data_Zone")

# correction
parkpoints$SIMD2020[parkpoints$Name=="The Meadows and BLeith Links      , Edinburgh, Scotland"]<-5
parkpoints$lat[parkpoints$Name=="The Meadows and BLeith Links      , Edinburgh, Scotland"]<-55.940278
parkpoints$lon[parkpoints$Name=="The Meadows and BLeith Links      , Edinburgh, Scotland"]<--3.193139

# change to new points!!!
#parkpoints$geometry<-NULL
#parkpoints<-parkpoints%>%
  #st_as_sf(.,coords=c("lat","lon"),crs=4326)

library(dplyr)
int <- sf::st_intersects(parkpoints, simd)
parkpoints$SIMD2020 <- as.factor(simd$SIMD2020v2_Quintile[unlist(int)])
parkpoints$Scorechang<-as.numeric(as.character(parkpoints$Scorechang))
parkpoints$Score2014<-as.numeric(as.character(parkpoints$Score2014))
parkpoints$Score2021<-as.numeric(as.character(parkpoints$Score2021))


ggplot(parkpoints, aes(x=SIMD2020, y=as.numeric(Score2014))) + 
  geom_boxplot(notch=F)


ggplot(parkpoints, aes(x=SIMD2020, y=as.numeric(Score2021))) + 
  geom_boxplot(notch=F)


library(ggplot2)
ggplot(parkpoints, aes(x=SIMD2020, y=as.numeric(Scorechang))) + 
  geom_boxplot(notch=F)
  

mapview(parkpoints, xcol = "lon", ycol = "lat", zcol="SIMD2020", crs = 4269, grid = FALSE)

parkpoints$Scorechang<-as.numeric(as.character(parkpoints$Scorechang))
parkpoints$ScorechangQ4<-gtools::quantcut(parkpoints$Scorechang, 4)
parkpoints$ScorechangQ2<-gtools::quantcut(parkpoints$Scorechang, 2)
parkpoints$ScorechangQ2Q1<-ifelse(parkpoints$ScorechangQ2=="[-6,9]",1,0)
parkpoints$ScorechangQ2Q2<-ifelse(parkpoints$ScorechangQ2=="(9,26]",1,0)


mapview(parkpoints, xcol = "lon", ycol = "lat", zcol="ScorechangQ4", crs = 4269, grid = FALSE)

a<-mapview(parkpoints, xcol = "lon", ycol = "lat", zcol="ScorechangQ2Q1", crs = 4269, grid = FALSE)
b<-mapview(parkpoints, xcol = "lon", ycol = "lat", zcol="ScorechangQ2Q2", crs = 4269, grid = FALSE)


