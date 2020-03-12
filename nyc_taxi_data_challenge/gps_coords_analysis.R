## ========================
## NYC TAXI DATA CHALLENGE
## ========================
setwd("/home/rstudio/nyc_taxi_data_challenge")

# ============================
# Load the libraries that we need:
source("code/my_setup.R")
library(chron)
library(leaflet)
library(htmlwidgets)
library(mapview)
# ============================

# Load the data:
my_data <- readRDS("data/nyc_taxi_data_clean_medium.rds")

data_sample <- my_data %>%
  filter(randID == 1) %>%
  select(pickup_latitude,pickup_longitude)

# Plot something:
plot(x = data_sample$pickup_longitude, y = data_sample$pickup_latitude)

# ============================
# Now what???  :)


