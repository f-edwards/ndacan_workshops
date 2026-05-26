# load packages
library(tidyverse)
library(lme4)
library(marginaleffects)

# read AFCARS 2018-2023
a18 <- read_tsv("./afcars/FC18ABv2.tab")
a19 <- read_tsv("./afcars/FC19ABv2.tab")
a20 <- read_tsv("./afcars/FC20ABv2.tab")
a21 <- read_tsv("./afcars/FC21ABv2.tab")
a22 <- read_tsv("./afcars/FC22v2.tab")
a23 <- read_tsv("./afcars/FC23ABv2.tab")

# bind together
afcars <- bind_rows(
  a18, 
  a19,
  a20,
  a21,
  a22,
  a23) 

# subset to variables of interest
afcars <- afcars |> 
  select(FY, St, 
         LifeLOS, AgeAtStart, Sex)

# convert sex to factor
afcars <- afcars |> 
  mutate(Sex = factor(Sex))

# confirm age looks right
table(afcars$AgeAtStart)

# let's just remove the odd ones for now
afcars <- afcars |> 
  filter(AgeAtStart<=18)

# visualize bivariate LifeLOS AgeAtStart
ggplot(afcars,
       aes(x = LifeLOS)) + 
  geom_histogram() + 
  facet_wrap(~AgeAtStart)
  
# start with a simple model, lifeLOS as function of age, sex
m0 <- lm(LifeLOS ~ 
           Sex * 
           (AgeAtStart + I(AgeAtStart^2)),
         data = afcars)

plot_predictions(m0, condition = list("AgeAtStart", "Sex"))

# is there evidence of heterogeneity by state? 
# let's look at just 5 year-olds
ggplot(afcars |> 
         filter(AgeAtStart == 5),
       aes(x = LifeLOS, group = St)) + 
  geom_density()

# what about simple means
afcars |> 
  filter(AgeAtStart==5) |> 
  group_by(St) |> 
  summarize(LifeLOS_mn = mean(LifeLOS, na.rm=T)) |> 
  ggplot(aes(x = LifeLOS_mn,
             y = fct_reorder(St, LifeLOS_mn))) + 
  geom_point() + 
  labs(x = "Mean lifetime length of time in foster care", y = "State")

# ok, let's try a model with state intercepts
m1 <- lmer(LifeLOS ~ 
           Sex * 
           (AgeAtStart + I(AgeAtStart^2)) + 
           (1|St),
         data = afcars)

summary(m1)

plot_predictions(m1, condition = list("AgeAtStart", "St", "Sex"))

# and of course, by year

m2 <- lmer(LifeLOS ~ 
             Sex * 
             (AgeAtStart + I(AgeAtStart^2)) + 
             (1|St + FY),
           data = afcars)

summary(m2)

plot_predictions(m2, condition = list("AgeAtStart", "St", "FY", "Sex"))

# and now one with state slopes by age
m3 <- lmer(LifeLOS ~ 
             Sex * 
             (AgeAtStart + I(AgeAtStart^2)) + 
             (AgeAtStart|St) + (1|FY),
           data = afcars)

summary(m3)

plot_predictions(m3, condition = list("AgeAtStart", "St", "Sex"))


