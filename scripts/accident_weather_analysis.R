library(tidyverse)
library(broom)

plot_acc <- labeled %>%
  filter(CASEDATE < today() - period(1, "month")) %>%
  group_by(day = floor_date(CASEDATE, "day"),
           yday = yday(CASEDATE),
           year) %>%
  summarise(total = n())

plot_acc %>%
  ggplot(aes(yday, total)) +

  # set alpha below 1 to show overplotting

  geom_point(alpha = 0.5) +
  geom_smooth(se = FALSE, color = "red", size = 0.5) +

  # geom_smooth will extend below zero if we don't set limits

  scale_y_continuous(limits = c(0, 130)) +
  facet_wrap(~ year) +
  theme_minimal() +
  labs(x ="", y = "Daily Count of Accidents", title = "Milwaukee Traffic Accident Reports",
       subtitle = "Each point represents a daily total")

weather <- read_csv("data/mke_hourly_weather.csv")

hourly <- weather  %>%
  filter(REPORT_TYPE == "FM-15") %>%
  mutate(hour = round_date(DATE, "hour")) %>%
  select(hour, HourlyDryBulbTemperature, HourlyPrecipitation)

weather %>%
  ggplot(aes(x = DATE)) +
  geom_point(aes(y = TMAX), color = "red") +
  geom_point(aes(y = TMIN), color = "blue") +
  theme_minimal() +
  scale_x_continuous(breaks = seq(from = 2008, to = 2020, by = 1))

w <- weather %>%
  select(DATE, TMAX, TMIN, SNOW, PRCP) %>%
  mutate(day = as_datetime(DATE))

all <- left_join(w, plot_acc, by = c("day")) %>%
  mutate(lag1 = lag(TMIN, 1),
         lag2 = lag(TMIN, 2)) %>%
  group_by(day, SNOW, PRCP, total, TMAX, TMIN) %>%
  summarise(three_day = mean(c(TMIN, lag1, lag2), na.rm = TRUE))

all %>%
  arrange(desc(total)) %>%
  head()

acc_lm <- lm(total ~ SNOW + PRCP + as_factor(wday(day)), data = all)
summary(acc_lm)


hourly_acc <- labeled %>%
  group_by(hour = floor_date(CASEDATE, "hour")) %>%
  summarise(total = n())

hourly_acc %>%
  ggplot(aes(total)) +
  geom_histogram()

weather_acc_hourly <- left_join(hourly, hourly_acc, by = "hour") %>%
  modify_at("HourlyPrecipitation", as.numeric) %>%
  mutate(total = ifelse(is.na(total), 0, total)) %>%
  mutate(HourlyPrecipitation = ifelse(is.na(HourlyPrecipitation), 0, HourlyPrecipitation),
         rush_hour = ifelse(hour(hour) > 7 & hour(hour) < 9, "Morning",
                            ifelse(hour(hour) > 16 & hour(hour) < 18, "Evening",
                                   "Not Rush Hour")),
         rain = ifelse(HourlyPrecipitation > 0 , "Yes", "No"),
         freezing = ifelse(HourlyDryBulbTemperature < 32, "Yes", "No"),
         dhour = factor(hour(hour)),
         wday = factor(wday(hour)))

model <- lm(total ~ rain:freezing + dhour:wday,
            data = weather_acc_hourly)

summary(model)
aug_mod <- augment(model) %>%
  mutate(round_fit = round(.fitted))

aug_mod %>%
  ggplot(aes(total, round_fit)) +
  geom_point() +
  theme_minimal() +
  scale_y_continuous(limits = c(0, 30))

cor_df <- weather_acc_hourly[, c(2:4)]

cor(cor_df, use = "complete.obs")
