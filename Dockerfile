# -------------------------- 
FROM hercules123/goodsy_r_shiny_plus2
MAINTAINER Paul Goodall "paul.thomas.goodall@gmail.com"

COPY nyc_taxi_data_challenge /home/rstudio/nyc_taxi_data_challenge
COPY setup_docs/getting_started.Rmd /home/rstudio/getting_started.Rmd
COPY setup_docs/first_time_setup /home/rstudio/first_time_setup
RUN chmod 777 /home/rstudio/first_time_setup 

COPY nyc_taxi_notebook /srv/shiny-server/nyc_taxi_notebook
COPY nyc_taxi_solution /srv/shiny-server/nyc_taxi_solution

RUN chmod -R 777 /srv/shiny-server/*
RUN ln -s /srv/shiny-server/examples /home/rstudio/shiny_examples

RUN export ADD=shiny && bash /etc/cont-init.d/add

# Expose the ports we need to get started:
EXPOSE 8787 3838

