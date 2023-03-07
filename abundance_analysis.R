setwd("C:/Users/mrake/Box/Logan-Research/Abundance Paper/Data")

library(data.table)
library(ggplot2)
library(lubridate)
library(ggmap)
library(scatterpie)
library(RColorBrewer)
library(maps)
library(sf)
library(cowplot)
library(viridis)


#wild collections 2019-2022
z<- fread("C:/Users/mrake/Box/Logan-Research/Abundance Paper/Data/Zaprionus_wild_collections_master.csv")
z$date <- mdy(z$date)
z.sum<-z[fruit!="pile",.(prop.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)/sum(count, na.rm=T), n.total=sum(count, na.rm=T), n.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)),.(date, location, season)]

#seasonal abundance of CM and HPO
z_seasonal <- z.sum[location == "CM" | location == "HPO",]

z_seasonal[,year:=year(date)]
z_seasonal[,j:=yday(date)]
z_seasonal$location <- as.factor(z_seasonal$location)
z_seasonal$year <- as.factor(z_seasonal$year)
z_seasonal[,label:=ifelse(location=="CM", "Charlottesville", "Richmond")]

ggplot(z_seasonal, aes(x = as.Date(j, origin = as.Date("2019-01-01")), y = prop.zap, group = interaction(year, location))) + 
  geom_line(aes(color = year)) + 
  geom_point(aes(color = year)) +
  facet_grid(cols = vars(label)) +
  labs(x = NULL, y=expression(paste("Proportion ", italic("Z. indianus"))), color="Year") +
  scale_x_date(date_breaks = "2 months", date_labels = "%b") +
  theme_cowplot()


#Latitudinal abundance
z_lat<-z[fruit!="pile",.(prop.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)/sum(count, na.rm=T), n.total=sum(count, na.rm=T), n.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)),.(date, location, fruit, season)]
z_lat <- z_lat[season == "lat"]
z_lat_apples <- z_lat[location == "FSP" | fruit == "apples", .(prop.zap=sum(n.zap)/sum(n.total), n.total=sum(n.total), n.zap=sum(n.zap), n.other=sum(n.total)-sum(n.zap)),.(date, location)]

#load in abundance with lat/long

lat_map <- fread("lat_abund_map.csv")

states <- map(database = "state", plot = F, fill = T)
states_sf <- st_as_sf(states)

ggplot(data = states_sf) +
  geom_sf(size = 0.1) +
  coord_sf(xlim = c(-88, -67), ylim = c(25.5, 47)) +
  geom_scatterpie(data = lat_map, aes(x = long, y = lat, group = location, r = 0.6), cols = c("n.zap", "n.other"), color = NA, legend_name = "Species") +
  scale_fill_manual(values = c("#E1BE6A", "#40B0A6"), labels = c(expression(italic("Z. indianus")), "Other")) + theme_bw() + theme(axis.title.x = element_blank(), axis.title.y = element_blank(), panel.grid.major = element_blank(), legend.position = c(0.75, .2), legend.key.size = unit(0.45, "cm"), legend.text.align = 0)

#regression
lat_reg <- fread("../Data/latitude_isofemale_regression.csv")

lm.lat <- lm(prop.zap ~ latitude, lat_reg)
plot(lat_reg$latitude, lat_reg$prop.zap)
abline(lm.lat)
summary(lm.lat)

lm.iso <- lm(isofemale_success ~ latitude, lat_reg)
plot(lat_reg$latitude, lat_reg$isofemale_success, ylim = c(0,1))
abline(lm.iso)
summary(lm.iso)
