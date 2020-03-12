# Set the working directory for this work:
#setwd("~/NYC_Taxis")

# ============================
# To prevent libraries displaying messy messages when loading, I'm going to re-define the function as an alias:
library <- function(...){
  suppressPackageStartupMessages(base::library(...))
}

# ============================
# Load the libraries that we need:
library(knitr)
library(tidyverse)
library(kableExtra)
library(dplyr)
library(data.table)
library(R.utils)

# Create function for viewing tables simply in the notebook:
show_table <- function(my_table){
  kable(my_table) %>%
    column_spec(1, width = "10em") %>%
    kable_styling(bootstrap_options = c("striped", "hover"))
}
# ============================
# Update Dictionary
update_dictionary <- function(my_vars){
  data_dictionary$Clean[which(data_dictionary$Variable_Name %in% my_vars)] <- 1  
  return (data_dictionary)
}

# ============================
# Show Mini-Dictionary
show_mini_dictionary <- function(data_dictionary){
  show_table(cbind(data_dictionary[1:7,1:2],data_dictionary[8:14,1:2],data_dictionary[15:21,1:2]))
}

# ============================
# Show Dictionary Definition:
show_dict_defn <- function(my_varname){
  ii <- which(data_dictionary$Variable_Name == my_varname)
  cat(data_dictionary[ii,2], ":\n", data_dictionary[ii,3])
}

# ============================
# Show double histogram:
double_hist <- function(my_x, my_name = "varname", my_breaks = 20){
  
  x_norm_lin <- round(my_breaks*(my_x - min(my_x))/(max(my_x) - min(my_x)))
  
  nyc_taxi_data %>% ggplot(aes(x = trip_time_in_secs)) + geom_histogram() + scale_x_log10()
}

# ============================
# Nice Summary:
nice_summary <- function(df_var){
  aa <- summary(df_var)
  data.frame('quantity'=names(aa), 'values'=as.character(aa))
}