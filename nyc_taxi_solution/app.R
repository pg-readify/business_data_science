#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Solution: Taxi Case Study"),
   
   fluidRow(
     column(3, 
            wellPanel(
              
HTML("<h4>Problem Question</h4>
Imagine that you are a New York City taxi driver. 
You have just dropped off a passenger at JFK Airport, which is 20 miles (via the highway) from downtown Manhattan. 
You are now faced with a choice of returning to Manhattan with an empty cab, or join the airport taxi queue (2 hours and 15 mins) to collect a passenger at the airport.
<br/><br/>
Q1) Do you stay at the airport or drive back to the city? Why?<br/>
Q2) What factors might affect your decision?<br/>
Q3) What changes could you make to the process, to improve the experience for:<br/>
&emsp; - the driver?<br/>
&emsp; - the passenger?<br/>
&emsp; - the taxi company?<br/>
Q4) What opportunites might there be to sync-up with other datasets?<br/>
Q5) Any opportunities for IoT to enhance the process?<br/>
<br/>
<h5>Initial Parameters</h5>
- Fare structure: <br/>
$4 for the first mile, and $2 for every subsequent mile<br/>

- Tips = 15% of meter reading per trip, rounded up to nearest dollar<br/>

- Trip from Airport to City: 20-miles trip lasting 75-minutes<br/>

- Average speed on highway: 16-mph<br/>

- Average speed in city: 12-mph<br/>

- Average wait time for city job: 5-mins<br/>

- Average city job: 2-miles trip lasting 10-mins<br/>

- Fuel price is $5/gallon<br/>

- Fuel consumption: highway = 25-mpg<br/>
- Fuel consumption: city = 20-mpg<br/>
- Fuel consumption: queing = 0<br/>

- 40% of meter reading per trip goes to taxi company as rental fee<br/>

- Highway toll is $4 per single trip, which is passed on to the passenger.  If travelling without passengers, the driver takes the hit.<br/>
<br/>
")
              )
     ),
     column(3, 
         sliderInput("q_wait", "Queue wait time (mins)", min = 60, max = 240, value = 135, step = 5),
         sliderInput("meter_initial", "Meter initial value ($)", min = 0, max = 10, value = 0, step = 0.5),
         sliderInput("meter_dollars_per_minute", "Meter Charge per minute ($/min)", min = 0.0, max = 5.0, value = 0.0, step = 0.25),
         sliderInput("fare_structure", "Fare structure ($/mile)", min = 0, max = 10, value = c(2,4), step = 0.5),
         sliderInput("airport_city_dist", "Airport-City distance (miles)", min = 1, max = 100, value = 20),
         sliderInput("highway_toll", "Highway toll ($)", min = 0, max = 10, value = 4, step = 0.5),
         sliderInput("tip_percentage", "Tip % of fare", min = 0, max = 100, value = 15)
     ),
     column(3, 
         sliderInput("taxi_co_cut", "Taxi commision cut %", min = 0, max = 100, value = 40),
         sliderInput("fuel_cost", "Fuel price ($/gal)", min = 1, max = 10, value = 5, step = 0.5),
         sliderInput("mpg", "Fuel mpg (1=city, 2=hwy)", min = 15, max = 50, value = c(20,25)),
         sliderInput("speeds", "Average speeds (1=city, 2=hwy)", min = 5, max = 30, value = c(12,16), step = 0.5),
         sliderInput("avg_city_wait", "Avg city wait for job (mins)", min = 0, max = 15, value = 5, step = 0.5),
         sliderInput("avg_city_trip_dist", "Avg city trip dist. (miles)", min = 1, max = 10, value = 2, step = 0.25)
     ),
     column(3, 
         tableOutput("results")
     )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
   output$results <- renderTable({
      my_calcs <- list()
      my_calcs$items <-  c("> Timings (mins) ~~","Time at Airport","Time on Highway", "Time in City","Total Time",""
                          ,"> Revenues ($) ~~","Fares","Tolls","Tips","Total Revenue",""
                          ,"> Costs ($) ~~","Taxi Tax","Tolls","Fuel","Total Costs",""
                          ,"> Profits ($) ~~","Total Profit","Hourly Wage","40-hour Week","Annual Salary","","")
      my_df <- as.data.frame(my_calcs)
      my_df$stay  <- 0
      my_df$leave <- 0
      
      my_df$stay[2] <- input$q_wait
      my_df$stay[3] <- 60 * input$airport_city_dist/input$speeds[2]
      my_df$stay[4] <- 0
      my_df$stay[5] <- my_df$stay[2] + my_df$stay[3] + my_df$stay[4]
      
      my_df$leave[2] <- 0
      my_df$leave[3] <- 60 * input$airport_city_dist/input$speeds[2]
      my_df$leave[4] <- input$q_wait
      my_df$leave[5] <- my_df$leave[2] + my_df$leave[3] + my_df$leave[4]
      
      my_df$stay[8]  <-  input$meter_initial + input$meter_dollars_per_minute*my_df$stay[3] + input$fare_structure[2] + (input$airport_city_dist-1)*input$fare_structure[1]
      my_df$stay[9]  <-  input$highway_toll
      my_df$stay[10] <-  ceiling(my_df$stay[8] * input$tip_percentage/100)
      my_df$stay[11] <-  my_df$stay[8] + my_df$stay[9] + my_df$stay[10]
      
      my_time_per_trip <-  input$avg_city_wait + 60*input$avg_city_trip_dist/input$speeds[1]
      my_n_trips       <-  floor(my_df$leave[4]/my_time_per_trip)
      my_df$leave[8]   <-  my_n_trips * (input$meter_initial + input$meter_dollars_per_minute*60*input$avg_city_trip_dist/input$speeds[1] + input$fare_structure[2] + max(0,input$avg_city_trip_dist - 1) * input$fare_structure[1])
      my_df$leave[9]   <-  0
      my_df$leave[10]  <-  ceiling(my_df$leave[8] * input$tip_percentage/100)
      my_df$leave[11]  <-  my_df$leave[8] + my_df$leave[9] + my_df$leave[10]
        
      my_df$stay[14]  <-  my_df$stay[8] * input$taxi_co_cut/100
      my_df$stay[15]  <-  input$highway_toll
      my_df$stay[16]  <-  input$fuel_cost * (input$airport_city_dist / input$mpg[2])
      my_df$stay[17]  <-  my_df$stay[14] + my_df$stay[15] + my_df$stay[16]
      
      my_total_city_mileage <- input$speeds[1] * (my_df$leave[4]/60)
      my_df$leave[14]  <-  my_df$leave[8] * input$taxi_co_cut/100
      my_df$leave[15]  <-  input$highway_toll
      my_df$leave[16]  <-  input$fuel_cost * ((my_total_city_mileage / input$mpg[1]) + (input$airport_city_dist / input$mpg[2]))
      my_df$leave[17]  <-  my_df$leave[14] + my_df$leave[15] + my_df$leave[16]
      
      my_df$stay[20] <- my_df$stay[11] - my_df$stay[17]
      my_df$stay[21] <- my_df$stay[20] / (my_df$stay[5]/60)
      my_df$stay[22] <- my_df$stay[21] * 40
      my_df$stay[23] <- my_df$stay[22] * 50
      
      my_df$leave[20] <- my_df$leave[11] - my_df$leave[17]
      my_df$leave[21] <- my_df$leave[20] / (my_df$leave[5]/60)
      my_df$leave[22] <- my_df$leave[21] * 40
      my_df$leave[23] <- my_df$leave[22] * 50
      
      my_df$stay <- as.character(round(my_df$stay,2))
      my_df$leave <- as.character(round(my_df$leave,2))
      
      my_df[c(1,6,7,12,13,18,19,24,25),2:3] <- ""
      names(my_df)[2] <- "stay @ airport"
      names(my_df)[3] <- "go to city"
      
      my_df
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

