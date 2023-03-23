setwd("C:/Users/mrake/Box/Logan-Research/Abundance Paper/Data")

library(data.table)
library(ggplot2)
library(lubridate)
library(scatterpie)
library(RColorBrewer)
library(maps)
library(sf)
library(cowplot)
library(viridis)
library(mapdata)


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

## getting totals
seasonal.sum<-z_seasonal[year != 2019, .(total.zap=sum(n.zap), total.number=sum(n.total), z.prop=(sum(n.zap)/(sum(n.total))))]
seasonal.sum

ggplot(z_seasonal[year != 2019], aes(x = as.Date(j, origin = as.Date("2019-01-01")), y = prop.zap, group = interaction(year, location))) + 
  geom_line(aes(color = year), size = 0.8) + 
  facet_grid(cols = vars(label)) +
  labs(x = NULL, y=expression(paste("Proportion ", italic("Z. indianus"))), color="Year") +
  scale_x_date(date_breaks = "2 months", date_labels = "%b") +
  scale_color_brewer(palette = "Dark2") +
  theme_cowplot()

ggsave("../Analysis/fig_2.tiff", device = "tiff", height = 97.37, width = 171, units = "mm", dpi = 600)


#Latitudinal abundance
z_lat<-z[fruit!="pile",.(prop.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)/sum(count, na.rm=T), n.total=sum(count, na.rm=T), n.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)),.(date, location, fruit, season)]
z_lat <- z_lat[season == "lat"]
z_lat_apples <- z_lat[location == "FSP" | fruit == "apples", .(prop.zap=sum(n.zap)/sum(n.total), n.total=sum(n.total), n.zap=sum(n.zap), n.other=sum(n.total)-sum(n.zap)),.(date, location)]

## getting totals
lat.sum<-z_lat[, .(total.zap=sum(n.zap), total.number=sum(n.total), z.prop=(sum(n.zap)/(sum(n.total))))]
lat.sum

##load in abundance with lat/long

lat_map <- fread("lat_abund_map.csv")

##fixed pie charts
usa <- map_data("state")
ggplot() + geom_polygon(data = usa, aes(x = long, y = lat, group = group), fill = "gray90", color = "gray30", size = 0.2) + 
  coord_fixed(xlim = c(-86, -67.5), ylim = c(25.5, 47)) + theme_bw() + theme(axis.title.x = element_blank(), axis.title.y = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.position = c(0.75, .2), legend.key.size = unit(0.45, "cm"), legend.text.align = 0) +
  geom_scatterpie(data = lat_map, aes(x = long, y = lat, group = location, r = 0.6), cols = c("n.zap", "n.other"), color = NA, legend_name = "Species") +
  scale_fill_manual(values = c("#E1BE6A", "#40B0A6"), labels = c(expression(italic("Z. indianus")), "Other"))

ggsave("../Analysis/fig_1.tiff", device = "tiff", height = 79, width = 82, units = "mm", dpi = 600, scale = 1.1)


#latitude and isofemale regression
lat_reg <- fread("../Data/latitude_isofemale_regression.csv")

lm.lat <- lm(prop.zap ~ latitude, lat_reg)
plot(lat_reg$latitude, lat_reg$prop.zap)
abline(lm.lat)
summary(lm.lat)
cor.test(lat_reg$latitude, lat_reg$prop.zap)

lm.iso <- lm(isofemale_success ~ latitude, lat_reg)
plot(lat_reg$latitude, lat_reg$isofemale_success, ylim = c(0,1))
abline(lm.iso)
summary(lm.iso)
cor.test(lat_reg$latitude, lat_reg$isofemale_success)

#start apple vs peach analysis

ap<-fread("../Data/apple_peach_analysis.csv")
ap[,total:=zind+other]
ap[,prop:=zind/(zind+other)]
ap.wide<-dcast(ap, location+date~fruit, value.var=c("prop", "total"))

ap.wide[, apples:=paste(round(prop_apples, 2), " ", "(", total_apples, ")", sep="")]
ap.wide[, peaches:=paste(round(prop_peaches, 2), " ", "(", total_peaches, ")", sep="")]

ap.wide[location=="CM"|location=="HPO", location:="VA"]
ap.wide[location=="Carver Hill", location:="MA"]
ap.wide[location=="Linvilla", location:="PA"]

ap.table<-ap.wide[,.(location, date, apples, peaches)]

write.csv(ap.table[order(-location),.(location, date, apples, peaches)], "~/Desktop/apple_peach_table.csv", row.names=F)

##stats on total
ap.sum<-ap[, .(total.zind=sum(zind), total.other=sum(other)), .(fruit)]
ap.sum[,prop:=total.zind/(total.zind+total.other)]
ap.sum[,total.number:=total.zind+total.other]
ap.sum

chisq.test(ap.sum[1:2,2:3]) #very sig

#Virginia orchards isofemale chi-squared test

##making matrix

cm.matrix <- matrix(c(103,14, 29,71), nrow = 2, ncol = 2, 
                    dimnames = list(c("success", "fail"),
                                    c("early", "late")))
chisq.test(cm.matrix)

hpo.matrix <- matrix(c(107,21, 63,37), nrow = 2, ncol = 2, 
                      dimnames = list(c("success", "fail"),
                                      c("early", "late")))
chisq.test(hpo.matrix)
