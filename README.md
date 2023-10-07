# A small survey of introduced African fig fly (Zaprionus indianus) (Diptera: Drosophilidae) in orchards of the eastern United States
---

This dataset contains counts of wild Drosophilids collected from locations in the eastern United States from 2020 to 2022. All flies were identified as Z. indianus or other species. 


Principal Investigator Contact Information
  	 Name: Priscilla Erickson	
  	 Institution: University of Richmond
  	 Address: Richmond, VA, USA
  	 Email: perickso@richmond.edu

##List of files
1. Zaprionus_wild_collections_master.csv This file contains all collection data from all locations. This data file is used for the majority of the analyses in the paper. 
2. lad_abund_map.csv This file contains the tabulated data for each latitudinal collection data as well as latitude and longitude information for each location and is used to generate Figure 1
3. net_asp_analysis.csv This file contains only the sampling dates where both netting and aspirating were used to enable a comparison of the two methods
4. apple_peach_analysis.csv This file contains only the sampling dates where both apples and peaches were sampled for the analysis of the two fruits. 
5. latitude_isofemale_regression.csv This file contains the data used to regress Z. indianus abundance against latitude


Relationship between files, if important: the smaller files are all subsets derived from Zaprionus_wild_collections_master.csv to simplify analysis

## Description of the data and file structure

1. Zaprionus_wild_collections_master.csv

Description of Columns:
- location: where flies were collected.
  - CM = Carter Mountain Orchard, Charlottesville, VA
  - HPO = Hanover Peach Orchard, Richmond, VA
  - Linvilla = Linvilla Orchard, Media, PA
  - RAB = Red Apple Barn, Ellijay, GA
  - FSP = Fruit and Spice Park, Homestead, FL
  - HC = Hillcrest Orchard, Ellijay, GA
  - Carver Hill = Carver Hill Orchard, Stowe, MA
  - Westward = Westward Orchard, Stowe, MA
  - HPH = Honey Pot Orchard, Stowe, MA
  - Lyman = Lyman Orchard, Middlefield, CT
  - Hansel= Hansel Orchard, North Yarmouth, ME
  - RR = Rocky Ridge Orchard, Bowdoinham, ME
- date: the date the flies were collected
- species: whether flies were Z. indianus or not (other)
- vial: if flies were collected in multiple vials, which vial did the data come from?
- count: the number of flies of that species present in the vial. Note that "999" is a placeholder for a small number of collections where total number of flies was not recorded, but flies were scanned and 0 Z. indianus were detected. 999 should not be included in any total counts
- method: how flies were collected: netting (net), aspirating (asp), or both (net/asp)
- fruit: the type of fruit the flies were collected on, if recorded
- season: "lat" indicates that the flies were part of the latitudinal analysis; "season"" indicates part of the seasonal analysis

2. lat_abund_map.csv
Description of columns
 - date: the collection date in M/D/Y format
 - location: where the flies were collected. See "location" for file number 1 above
 - prop.zap: The proportion of all drosophilids collected that were Z. indianus
 - n.total: The total number of Drosophilids collected
 - n.zap: The number of Z. indianus collected
 - n.other: The nubmer of non-Z.indianus collected
 - lat: The latitude of the colleciton location
 - long: The longitude of the collection location

3. net_asp_analysis.csv 
- location: where flies were collected-see file 1 above
- date: the date the flies were collected
- species: whether flies were Z. indianus or not (other)
- vial: if flies were collected in multiple vials, which vial did the data come from?
- count: the number of flies of that species present in the vial. Note that "999" is a placeholder for a small number of collections where total number of flies was not recorded, but flies were scanned and 0 Z. indianus were detected. 999 should not be included in any total counts
- method: how flies were collected: netting (net), aspirating (asp), or both (net/asp)
- fruit: the type of fruit the flies were collected on, if recorded

4. apple_peach_analysis
 - location: where the flies were collected. See "location" for file number 1 above
 - date: the collection date in M/D/Y format
 - fruit: whether flies were collected near apples or peaches
 - zind: the number of Z. indianus sampled
 - other: the number of non-Z.indianus drosophilids sampled

5. latitude_isofemale_regression.csv
 - orchard: where the flies were collected. See "location" for file number 1 above
 - prop.zap: The proportion of all drosophilids collected that were Z. indianus
 - latitude: the latitude of the collection location
 - date: the collection date in M/D/Y format
  


## Sharing/Access information

Links to other publicly accessible locations of the data:
  * https://github.com/lmrakes/Zaprionus-field-collections-2022

Data was derived from the following sources:
  * all data produced from collections performed by the Erickson lab at University of Richmond


## Code/Software

All data were analyzed in R with the scripts attached.
