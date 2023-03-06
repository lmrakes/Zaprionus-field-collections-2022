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

abundance <- fread("collection_abundance.csv")

#abundance all vials by date, orchard, fruit
abund <- abundance[, .(n.zap = sum(Z.indianus), n.other = sum(other), n.total = sum(total), n.vials = .N), by = .(date, location, fruit, season)]
abund[, prop.zap := n.zap/n.total]

abund$location <- as.factor(abund$location)
abund$date <- mdy(abund$date)

#HPO seasonal abundance 2022
abund_HPO <- abundance[, .(n.zap = sum(Z.indianus), n.total = sum(total)), by = .(date, location)]
abund_HPO[, prop.zap := n.zap/n.total]

abund_HPO$location <- as.factor(abund_HPO$location)
abund_HPO$date <- mdy(abund_HPO$date)

abund_HPO <- abund_HPO[location == "HPO"]

ggplot(abund_HPO, aes(x = date, y = prop.zap, group = location)) +
  geom_line(aes(color = location), size = 0.75) + 
  geom_point(aes(color = location)) + 
  theme_cowplot()





#CM&HPO 2019-2022
z<- fread("C:/Users/mrake/Box/Logan-Research/Abundance Paper/Data/Zaprionus wild collections 2019-2021.csv")
z$date <- mdy(z$date)
z.sum<-z[fruit!="pile",.(prop.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)/sum(count, na.rm=T), n.total=sum(count, na.rm=T), n.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)),.(date, location)]

#merge with 2022 data
z.sum <- merge(x = z.sum, y = abund_HPO, all = T)


z.sum[,year:=year(date)]
z.sum[,j:=yday(date)]
z.sum$location <- as.factor(z.sum$location)
z.sum$year <- as.factor(z.sum$year)
z.sum[,label:=ifelse(location=="CM", "Charlottesville", "Richmond")]

ggplot(z.sum, aes(x = as.Date(j, origin = as.Date("2019-01-01")), y = prop.zap, group = interaction(year, location))) + 
  geom_line(aes(color = year)) + 
  geom_point(aes(color = year)) +
  facet_grid(cols = vars(label)) +
  labs(x = NULL, y=expression(paste("Proportion ", italic("Z. indianus"))), color="Year") +
  scale_x_date(date_breaks = "2 months", date_labels = "%b") +
  theme_cowplot()



#Latitudinal abundance map

abund_lat <- abund[season == "lat"]
abund_lat_apples <- abund_lat[location == "FSP" | fruit == "apples"]


abund_map <- fread("abund_map.csv")
abund_map[, prop.zap := .(n.zap/n.total)]

states <- map(database = "state", plot = F, fill = T)
states_sf <- st_as_sf(states)

ggplot(data = states_sf) +
  geom_sf(size = 0.1) +
  coord_sf(xlim = c(-88, -67), ylim = c(25.5, 47)) +
  geom_scatterpie(data = abund_map, aes(x = long, y = lat, group = location, r = 0.6), cols = c("n.zap", "n.other"), color = NA, legend_name = "Species") +
  scale_fill_manual(values = c("#E1BE6A", "#40B0A6"), labels = c(expression(italic("Z. indianus")), "Other")) + theme_bw() + theme(axis.title.x = element_blank(), axis.title.y = element_blank(), panel.grid.major = element_blank(), legend.position = c(0.75, .2), legend.key.size = unit(0.45, "cm"), legend.text.align = 0)

#regression
lat_reg <- fread("../Data/latitude_isofemale_regression.csv")
lm.lat <- lm(prop.zap ~ latitude, lat_reg)

plot(lat_reg$latitude, lat_reg$prop.zap)
abline(lm.lat)
summary(lm.lat)

lm.iso <- lm(isofemale_success ~ latitude, lat_reg)
plot(lat_reg$latitude, lat_reg$isofemale_success)
abline(lm.iso)
summary(lm.iso)
