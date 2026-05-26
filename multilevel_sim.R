### simulate multilevel test data
### function is
### wave, student, teacher, school, income
### y = 50 + income * b1 + wave * b2 + student + teacher + school
set.seed(1)

income<-rnorm(180, 7.5, 2.5)
i<-rnorm(180, 10, 10)
s<-rnorm(3, 10, 10)


data<-data.frame(i = i,
                 income = income,
                 s = s,
                 school = c("a", "b", "c"))

data<-data %>% 
  mutate(w = 1) %>% 
  bind_rows(data %>% 
              mutate(w = 2)) %>% 
  bind_rows(data %>% 
              mutate(w = 3))

data<-data %>% 
  mutate(y = 50 + 5 * income + s + 1.3 * w + i)

ggplot(data, 
       aes(x = income, y = y)) + 
  geom_point() + 
  geom_smooth(method = "lm") + 
  labs(y = "test score")

ggplot(data, 
       aes(x = income, y = y,
           color = school)) + 
  geom_point() + 
  geom_smooth(method = "lm") +
  labs(y = "test score")


