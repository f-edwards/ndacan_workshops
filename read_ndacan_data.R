### this script joins ndacan tables to SEER pop data

### load libraries

library(tidyverse)


### read in the demo files
ncands<-read_csv("./data/ncands_demo.csv")
afcars<-read_csv("./data/afcars_demo.csv")
pop<-read_csv("./data/pop_demo.csv")

### harmonize the names in ncands and pop

ncands<-ncands %>% 
  rename(year = subyr,
         state = StaTerr,
         age = ChAge)

unique(ncands$age)
### note that 77 and 99 have special meaning
### recode 77 -> 0; 99 -> NA

ncands<-ncands %>% 
  mutate(age = ifelse(age==77, 0, 
                      ifelse(age==99, NA,
                             age)))

### collapse NCANDS to state - year, collapse pop to state - year

ncands_st<-ncands %>% 
  group_by(year, state, age) %>% 
  summarize(child_investigation = n())

pop_st<-pop %>% 
  filter(age<18) %>% 
  group_by(year, state, age) %>% 
  summarize(pop = sum(pop))

#### join them together

ncands_pop<-ncands_st %>% 
  left_join(pop_st)
  
### super cool!

### now let's do afcars

afcars<-afcars %>% 
  rename(year = FY,
         state = St,
         age = AgeAtStart) %>% 
  mutate(age = ifelse(age<0, 0, age),
         age = ifelse(age==99, NA, age)) %>% 
  select(-STATE)

### collapse to state level

afcars_st<-afcars %>% 
  group_by(year, state, age) %>% 
  summarize(fc = n())

### now join to ncands_pop

ncands_afcars_pop<-ncands_pop %>% 
  left_join(afcars_st)

### compute per capita rates

ncands_afcars_pop<-ncands_afcars_pop %>% 
  mutate(investigation_rate = child_investigation / pop * 1000,
         fc_rate = fc / pop * 1000)

### quick visuals

ggplot(ncands_afcars_pop,
       aes(x = age, y = investigation_rate)) + 
  geom_line() + 
  facet_wrap(~state)

ggplot(ncands_afcars_pop,
       aes(x = age, y = fc_rate)) + 
  geom_line() + 
  facet_wrap(~state)

library(geofacet)

ggplot(ncands_afcars_pop,
       aes(x = age, y = fc_rate)) + 
  geom_line() + 
  facet_geo(~state)
