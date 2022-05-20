####### make sample data for 2021 SRI workshop
###### read in and deidentify admin data for geo / time join

library(data.table)
library(tidyverse)

ncands<-fread("~/Projects/ndacan_data/ncands/CF2019v1.tab")

afcars<-fread("~/Projects/ndacan_data/afcars/FC2019v1.tab")

##### select variables for join

ncands_demo<-ncands %>% 
  select(subyr, StaTerr, ChAge)

afcars_demo<-afcars %>% 
  select(FY, STATE, St, AgeAtStart)

write_csv(ncands_demo, 
          "./data/ncands_demo.csv")

write_csv(afcars_demo,
          "./data/afcars_demo.csv")

