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
library(glmmTMB)
library(DHARMa)

# Wild Collections 2019-2022 Data
z <- fread("C:/Users/mrake/Box/Logan-Research/Abundance Paper/Data/Zaprionus_wild_collections_master.csv")
z$date <- mdy(z$date)
z.sum<-z[fruit!="pile",.(prop.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)/sum(count, na.rm=T), n.total=sum(count, na.rm=T), n.zap=sum(count[species=="Zaprionus indianus"], na.rm=T), n.other = sum(count[species =="other"], na.rm = T)),.(date, location, season)]

# Virginia Seasonal Abundance
z_seasonal <- z.sum[location == "CM" | location == "HPO"]

z_seasonal[,year:=year(date)]
z_seasonal[,j:=yday(date)]
z_seasonal$location <- as.factor(z_seasonal$location)
z_seasonal$year <- as.factor(z_seasonal$year)
z_seasonal[,label:=ifelse(location == "CM", "Charlottesville", "Richmond")]
z_seasonal<- z_seasonal[year != 2019]
z_seasonal<- z_seasonal[-c(1,2)] #removing dummy counts

## Assigning sampling method
z_seasonal[, method := "net/asp"]
z_seasonal[location == "CM" & (year == "2021" | year == "2022"), method := "net/trap"]

## Getting Totals
seasonal.sum<-z_seasonal[, .(total.zap=sum(n.zap), total.number=sum(n.total), z.prop=(sum(n.zap)/(sum(n.total))))]
seasonal.sum

## Plotting Abundance Data
ggplot(z_seasonal, 
       aes(x = as.Date(j, origin = as.Date("2019-01-01")), 
           y = prop.zap, 
           group = interaction(year, location))) + 
  geom_line(aes(color = year, linetype = method), 
            linewidth = 0.8) + 
  facet_grid(cols = vars(label)) + 
  labs(x = NULL, 
       y=expression(paste("Proportion ", italic("Z. indianus"))), 
       color="Year") +
  scale_x_date(date_breaks = "2 months", 
               date_labels = "%b") +
  scale_color_brewer(palette = "Dark2") +
  theme_cowplot() + 
  guides(linetype = "none")

ggsave("../Analysis/fig_2_new.tiff", device = "tiff", height = 96.8, width = 170, units = "mm", dpi = 600)


## Seasonal Abundance Binomial GLM

### Binning by month
z_seasonal$month <- as.factor(month(z_seasonal$date))

seasonal.melt <- melt(z_seasonal, id.vars = c("location", "date", "year", "j", "n.total", "prop.zap", "label", "month", "method"), measure.vars = c("n.zap", "n.other"), variable.name = "species", value.name = "count")
setkey(seasonal.melt, location, date)

### Creating one row for each fly
seasonal.melt[, id := 1:nrow(seasonal.melt)]
seasonal.expand <- seasonal.melt[rep(1:.N, count)]
seasonal.expand[, index := 1:.N, by = id]

### Binary response variable
seasonal.expand[,response := 0]
seasonal.expand[species == "n.zap", response := 1]

seasonal.expand <- seasonal.expand[method != "net/trap"]

### Setting reference for month to July
seasonal.expand$month <- relevel(seasonal.expand$month, ref = "7")

seasonal.glm <- glm(response ~ location + year + month, data = seasonal.expand, family = binomial)

summary(seasonal.glm)

#### Testing significance of predictors
drop1(seasonal.glm, test = "Chisq")


#Latitudinal abundance
z_lat <- z[fruit!="pile",.(prop.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)/sum(count, na.rm=T), n.total=sum(count, na.rm=T), n.zap=sum(count[species=="Zaprionus indianus"], na.rm=T)),.(date, location, fruit, season)]
z_lat <- z_lat[fruit != "compost"]

## Selecting latitude sampling
z_lat <- z_lat[season == "lat"]

## Getting Totals
lat.sum<-z_lat[, .(total.zap=sum(n.zap), total.number=sum(n.total), z.prop=(sum(n.zap)/(sum(n.total))))]
lat.sum

## Selecting Apples and Florida Data
z_lat_apples <- z_lat[location == "FSP" | fruit == "apples", .(prop.zap=sum(n.zap)/sum(n.total), n.total=sum(n.total), n.zap=sum(n.zap), n.other=sum(n.total)-sum(n.zap)),.(date, location)]

## added latitude in excel

## latitude analysis
lat_reg <- fread("../Data/latitude_isofemale_regression.csv")
lat_reg <- lat_reg[orchard != "CM"]

lm.lat <- lm(prop.zap ~ latitude, lat_reg)
plot(lat_reg$latitude, lat_reg$prop.zap)
abline(lm.lat)
summary(lm.lat)
cor.test(lat_reg$latitude, lat_reg$prop.zap)


## load in abundance with lat/long
lat_map <- fread("lat_abund_map.csv")

## plotting relative abundance on map
usa <- map_data("state")

ggplot() + 
  geom_polygon(data = usa, 
               aes(x = long, y = lat, group = group), 
               fill = "gray90", 
               color = "gray30", 
               linewidth = 0.2) + 
  coord_fixed(xlim = c(-86, -67.5), 
              ylim = c(25.5, 47)) + 
  theme_bw() + 
  theme(axis.title.x = element_blank(), 
        axis.title.y = element_blank(), 
        panel.grid.major = element_blank(), 
        panel.grid.minor = element_blank(), 
        legend.position = c(0.75, .2), 
        legend.key.size = unit(0.45, "cm"), 
        legend.text.align = 0) +
  geom_scatterpie(data = lat_map, 
                  aes(x = long, y = lat, group = location, r = 0.6), 
                  cols = c("n.zap", "n.other"), 
                  color = NA, 
                  legend_name = "Species") + 
  scale_fill_manual(values = c("#E1BE6A", "#40B0A6"), 
                    labels = c(expression(italic("Z. indianus")), "Other"))

ggsave("../Analysis/fig_1.tiff", device = "tiff", height = 79, width = 82, units = "mm", dpi = 600, scale = 1.1)


# Apple vs peach analysis

ap<-fread("../Data/apple_peach_analysis.csv")
ap[,total:=zind+other]
ap[,prop:=zind/(zind+other)]


## binomial glm for apples vs peaches

ap[,date := mdy(date)]
ap[,julian.date := yday(date)]

ap.melt <- melt(ap, id.vars = c("location", "date", "julian.date", "fruit", "total", "prop"), measure.vars = c("zind", "other"), variable.name = "species", value.name = "count")
setkey(ap.melt, location, date, fruit)

### creating a row for each fly
ap.melt[, id := 1:nrow(ap.melt)]
ap.expand <- ap.melt[rep(1:.N, count)]
ap.expand[, index := 1:.N, by = id]

### binary response for species
ap.expand[,response := 0]
ap.expand[species == "zind", response := 1]

ap.expand$fruit <- as.factor(ap.expand$fruit)

### visualizing fruit x species
ggplot(data = ap.expand, 
       aes(x = fruit, y = count, fill = species)) + 
  geom_bar(position = "fill", 
           stat = "identity")

### including vs excluding cm
ap.expand.cm <- ap.expand[location == "CM"]
ap.expand.notcm <- ap.expand[location != "CM"]


cm.binom <- glm(response ~ fruit + julian.date, data = ap.expand.cm, family = "binomial")
summary(cm.binom)
notcm.binom <- glm(response ~ fruit + julian.date, data = ap.expand.notcm, family = "binomial")
summary(notcm.binom) # both positive and significant -> combine in one analysis


ap.binom <- glm(response ~ fruit + julian.date, data = ap.expand, family = "binomial")
summary(ap.binom)


# Net vs aspirator GLM

net_asp <- fread("C:/Users/mrake/Box/Logan-Research/Abundance Paper/Data/net_asp_analysis.csv")
net_asp[,date:=mdy(date)]
net_asp[, year:=year(date)]

netasp.sum<-net_asp[method!="",.(n.zap=sum(count[species=="Zaprionus indianus"], na.rm=T), n.other=sum(count[species=="other"], na.rm=T)), .(location, date, method, fruit)][order(date)]

netasp.melt <- melt(netasp.sum, id.vars = c("location", "date", "method", "fruit"), measure.vars = c("n.zap", "n.other"), variable.name = "species", value.name = "count")
setkey(netasp.melt, location, date, method, fruit)
netasp.melt <- netasp.melt[-c(11,12)] #removing peach sampling that did not have both methods (i.e. aspirated on peaches but didn't net)

netasp.melt[, id := 1:nrow(netasp.melt)]
netasp.expand <- netasp.melt[rep(1:.N, count)]
netasp.expand[, index := 1:.N, by = id]

netasp.expand[,response := 0]
netasp.expand[species == "n.zap", response := 1]

netasp.expand$location <- as.factor(netasp.expand$location)
netasp.expand$method <- as.factor(netasp.expand$method)
netasp.expand$date <- as.factor(netasp.expand$date)
netasp.expand$fruit <- as.factor(netasp.expand$fruit)

str(netasp.expand)

netasp.glmm <- glmmTMB(response ~ method + fruit + (1|date), family = binomial, data = netasp.expand)

summary(netasp.glmm)


#Fruit & Spice Park (FL) - Fruit analysis

z_fsp <- z[location == "FSP"]


z_fsp[, id := 1:nrow(z_fsp)]
fsp.expand <- z_fsp[rep(1:.N, count)]
fsp.expand[, index := 1:.N, by = id]

fsp.expand[,response := 0]
fsp.expand[species == "Zaprionus indianus", response := 1]

fsp.expand$fruit <- as.factor(fsp.expand$fruit)
str(fsp.expand)

fsp.glm <- glm(response ~ fruit, family = "binomial", data = fsp.expand)
summary(fsp.glm)
drop1(fsp.glm, test = "Chisq")