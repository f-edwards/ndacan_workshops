library(tidyverse)

pop<-read_fwf("./data/us.1990_2020.singleages.adjusted.txt",
              fwf_widths(c(4, 2, 2, 3, 2, 
                           1, 1, 1, 2, 8),
                         c("year", "state", "st_fips",
                           "cnty_fips", "reg", "race",
                           "hisp", "sex", "age", "pop")))

pop_demo<-pop %>% 
  filter(year==2019) %>% 
  select(year, state, sex, age, pop) %>% 
  mutate(age = as.numeric(age),
         pop = as.numeric(pop))

write_csv(pop_demo, "./data/pop_demo.csv")