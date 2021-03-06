## load packages ---------------------------------------------------------------
library(caret)
library(dplyr)
library(DT)
library(ggplot2)
library(leaflet)
library(leaflet.extras)
library(shinythemes)
library(tidyr)
library(wordcloud)
library(shiny)
library(tidyverse)
library(tidytext)
library(plotly)
library(ggmap)
library(mapproj)
library(lubridate)
library(data.table)
library(ggrepel)
require(dplyr)



#read the csv's to merge
df1 <- read.csv('data/listing.csv')
df2 <- read.csv('data/Airbnb5122.csv', fileEncoding = "UTF-8-BOM")
df1
df2

#merge
AirbnbDF <- left_join(df2, 
                      df1 %>% select(id, latitude, longitude),
                      by = "id")


#for map
room <- sort(unique(AirbnbDF$`room_type`))
property <- sort(unique(AirbnbDF$`property_type`))
bed <- sort(unique(AirbnbDF$`bed_type`))
numbeds <- sort(unique(AirbnbDF$`beds`))
numbedrooms <- sort(unique(AirbnbDF$`bedrooms`))
numbathrooms <- sort(unique(AirbnbDF$`bathrooms`))
accommodates <- sort(unique(AirbnbDF$`accommodates1`))
min_price <- min(AirbnbDF$`price`)
max_price <- max(AirbnbDF$`price`)
zipcode <- sort(unique(AirbnbDF$`zipcode`))
#for bar chart
max_guests <- list("2" = 2,
                   "4" = 4,
                   "6" = 6,
                   "8" = 8,
                   "10 or more" = 10)


ui <- fluidPage(
  titlePanel("Seattle Airbnb Listings"), # Application title
  
  # task1: add in the sidebarLayout with sidebarPanel and mainPanel
  tabsetPanel(
    tabPanel("Property Type Search",
             sidebarLayout(
               
               sidebarPanel(
                 h4("Bar Chart of Property Types"),
                 p("Use the filters below to select what type of listing satisfies your specifications."),
                 p("NOTE: Click on a property's bar to see the details of those listings in the table below."),
                 hr(),
                 checkboxGroupInput("num_bedrooms", "Number of Bedrooms:",
                                    c("One" = 1,
                                      "Two" = 2,
                                      "Three" = 3,
                                      "Four" = 4,
                                      "Five" = 5),
                                    selected = 1,
                                    inline = TRUE
                 ),
                 checkboxGroupInput("num_bathrooms", "Number of Bathrooms:",
                                    c("One" = 1,
                                      "Two" = 2,
                                      "Three" = 3,
                                      "Four" = 4,
                                      "Five" = 5),
                                    selected = 1,
                                    inline = TRUE),
                 
                 selectInput(inputId = "max_guests", label = "Accomodates at least this many guests:",
                             choices = max_guests, selected = "4"),
                 
                 sliderInput(inputId = "min_num_reviews", label = "Minimum number of reviews:",
                             min = 10, max = 200, value = 40),
                 sliderInput(inputId = "min_review_score_ratings", label = "Minimum review score ratings:",
                             min = 20, max = 100, value = 80),
                 
                 actionButton(inputId = "run_app",
                              label = "Run"),
               ),
               
               mainPanel(
                 tabsetPanel(type = "tabs",
                             tabPanel("View by Price", plotOutput(outputId = "price_barchart", click="price_barchart_click"),
                                      dataTableOutput("price_table")),
                             tabPanel("View by Count", plotOutput(outputId = "count_barchart", click="count_barchart_click"),
                                      dataTableOutput("count_table"))
                 )
               )
             )
    ),
    tabPanel("Map",
             sidebarLayout(
               sidebarPanel(
                 h4("Map of Seattle Listings"),
                 p("Use the filters below to select what type of listing you'd like to find on the map of Seattle."),
                 p("NOTE: If no listings match your specifications, no points will appear on the map."),
                 hr(),
                 sliderInput(
                   inputId = "price_budget",
                   label = "Select Your Price Budget ($):",
                   min = min(AirbnbDF$price),
                   max = max(AirbnbDF$price),
                   value = c(50,100),
                   step = 1,
                   sep = ""
                 ),
                 
                 selectInput(
                   inputId = "propertytype",
                   label = "Choose Property Type:",
                   choices = c("Select" = "", property),
                   selected = "Apartment"
                 ),
                 
                 selectInput(
                   inputId = "roomtype",
                   label = "Choose Room Type:",
                   choices = c("Select" = "", room),
                   selected = "Entire home/apt"
                 ),
                 
                 selectInput(
                   inputId = "accom",
                   label = "Select Number of People to Accommodate:",
                   choices = c("Select" = "", accommodates),
                   selected = "1"
                 ),
                 
                 selectInput(
                   inputId = "bedroomnumber",
                   label = "Choose Minimum Number of Bedrooms:",
                   choices = c("Select" = "", numbedrooms),
                   selected = "1"
                 ),
                 
                 selectInput(
                   inputId = "bednumber",
                   label = "Choose Minimum Number of Beds:",
                   choices = c("Select" = "", numbeds),
                   selected = "1"
                 ),
                 
                 selectInput(
                   inputId = "bathroomnumber",
                   label = "Choose Minimum Number of Bathrooms:",
                   choices = c("Select" = "", numbathrooms),
                   selected = "1"
                 )),
               
               mainPanel(plotlyOutput("mapPlot", height = "650px", width = "590px")))),
    
    tabPanel("Box Plot Prices",     
             
             # App title ----
             #titlePanel("Price Per Neighborhood"),
             
             # Sidebar layout with input and output definitions ----
             sidebarLayout(
               
               # Sidebar panel for inputs ----
               sidebarPanel(
                 h4("Property Type Pricing in a Zipcode: Box Plot"),
                 p("Use the filters below to see the pricing of different properties"),
                 
                 radioButtons(
                   "num_beds",
                   "Number of Bedrooms:",
                   choices = numbedrooms[numbedrooms != "0"],
                   selected = 1,
                   inline = TRUE
                 ),
                 
                 selectInput(
                   inputId = "accomodation",
                   label = "Minimum number of accommodation:",
                   choices = c("Select" = "", accommodates),
                   selected = "2"
                 ),
                 selectInput(
                   inputId = "zipcode",
                   label = "Zip Code:",
                   choices = c("Select" = "", zipcode),
                   selected = "98101"
                 ),
                 
               ),
               
               # Main panel for displaying outputs ----
               mainPanel("",
                         
                         
                         
                         # Output: Formatted text for caption ----
                         #h3(textOutput("caption")),
                         
                         # Output: Plot of the requested variable against mpg ----
                         plotlyOutput("mpgPlot")
               )
             )
    ),
    
    tabPanel('About',
             br(),
             column(1),
             column(8, 
                    h5('This app was created by Allie Baker, Jaime Cassell, and Nikunja Shrestha.'),
                    p("It was the result of Chase Romano's Visual Analytics course at the University of North Carolina at Charlotte through the Data Science and Business Analytics MS program."),
                    br(),
                    HTML("<p> View the application on <a href = 'https://github.com/AllieBaker21/Seattle-Airbnbs'> 
                          Allie's Github </a>"),
                    br(),
                    HTML("<p> View the application on <a href = 'https://github.com/jcassell6/Seattle-Airbnb-Shiny-App'> 
                         Jaime's Github </a>"),
                    br(),
                    HTML("<p> View the application on <a href = 'https://github.com/Nikunja1/Seattle.airbnb'> 
                         Nikunja's Github </a>"),
                    hr(),
                    HTML('<a href = "https://www.linkedin.com/in/allison-baker-416171236/" 
                         style = "color: #FFC300"> Allie Baker Linkedin</a>'),
                    br(),
                    HTML('<a href = "https://www.linkedin.com/in/jaime-cassell-b141a5168/"
                         style = "color: #FFC300"> Jaime Cassell Linkedin</a>'),
                    br(),
                    HTML('<a href = "https://www.linkedin.com/in/nikunja-shrestha-b51270218/"
                         style = "color: #FFC300"> Nikunja Shrestha Linkedin</a>')
             ),
             column(3)
             
    )))



server <- function(input, output) {
  
  
  # ------------------------------ Bar Chart ------------------------------
  count_plot_data <- reactive({
    AirbnbDF %>%
      filter(bedrooms %in% c(as.numeric(input$num_bedrooms)), bathrooms %in% c(as.numeric(input$num_bathrooms)), 
             accommodates1 >= as.numeric(input$max_guests), number_of_reviews >= input$min_num_reviews, 
             review_scores_rating >= input$min_review_score_ratings) %>% count(property_type)
  })
  
  clicked_count_bar <- reactive({
    round(as.numeric(input$count_barchart_click$x))
  })
  
  count_table_data <- reactive({
    ordered_count_plot_data <- count_plot_data()[order(-count_plot_data()$n),]
    filtered_table_data <- AirbnbDF %>%
      filter(bedrooms %in% c(as.numeric(input$num_bedrooms)), bathrooms %in% c(as.numeric(input$num_bathrooms)), 
             accommodates1 >= as.numeric(input$max_guests), number_of_reviews >= input$min_num_reviews, 
             review_scores_rating >= input$min_review_score_ratings)
    clicked_table_data <- filtered_table_data[filtered_table_data$property_type==ordered_count_plot_data$property_type[clicked_count_bar()],]
    clicked_table_data[, c('name', 'street', 'neighbourhood', 'zipcode', 'property_type', 'price')]
    
  })
  
  price_plot_data <- reactive({
    AirbnbDF %>%
      filter(bedrooms %in% c(as.numeric(input$num_bedrooms)), bathrooms %in% c(as.numeric(input$num_bathrooms)), 
             accommodates1 >= as.numeric(input$max_guests), number_of_reviews >= input$min_num_reviews, 
             review_scores_rating >= input$min_review_score_ratings) %>%
      group_by(property_type) %>%
      summarise_at(vars(price), list(avg_price = mean))
  })
  
  clicked_price_bar <- reactive({
    round(as.numeric(input$price_barchart_click$x))
  })
  
  price_table_data <- reactive({
    ordered_price_plot_data <- price_plot_data()[order(-price_plot_data()$avg_price),]
    filtered_table_data <- AirbnbDF %>%
      filter(bedrooms %in% c(as.numeric(input$num_bedrooms)), bathrooms %in% c(as.numeric(input$num_bathrooms)), 
             accommodates1 >= as.numeric(input$max_guests), number_of_reviews >= input$min_num_reviews, 
             review_scores_rating >= input$min_review_score_ratings)
    clicked_table_data <- filtered_table_data[filtered_table_data$property_type==ordered_price_plot_data$property_type[clicked_price_bar()],]
    clicked_table_data[, c('name', 'street', 'neighbourhood', 'zipcode', 'property_type', 'price')]
    
  })
  
  
  output$count_barchart <-renderPlot({
    final_plot_data <- count_plot_data()
    final_plot_data$property_type <- factor(final_plot_data$property_type, 
                                            levels=final_plot_data$property_type[order(final_plot_data$n, decreasing = TRUE)])
    ggplot(data=final_plot_data, aes(x = property_type, y = n, fill= property_type)) +
      geom_bar(stat = "identity") +
      labs(title = "Number of Properties by Property Type in Seattle",
           y = "Property Count", x = "Property Type", fill = "Property Type") +
      theme_classic() +
      theme(axis.title = element_text(size = 18)) +
      theme(plot.title = element_text(size = 22)) +
      theme(axis.text = element_text(size = 12))
    
  })
  
  output$count_table <- renderDataTable(count_table_data(),
                                        options = list(
                                          pageLength = 5
                                        )
  )
  
  output$price_barchart <-renderPlot({
    final_plot_data <- price_plot_data()
    final_plot_data$property_type <- factor(final_plot_data$property_type, 
                                            levels=final_plot_data$property_type[order(final_plot_data$avg_price, decreasing = TRUE)])
    ggplot(data=final_plot_data, aes(x = property_type, y = avg_price, fill=property_type)) +
      geom_bar(stat = "identity") +
      labs(title = "Average Price of Properties by Property Type in Seattle",
           y = "Average Price", x = "Property Type", fill = "Property Type") +
      theme_classic() +
      theme(axis.title = element_text(size = 18)) +
      theme(plot.title = element_text(size = 22)) +
      theme(axis.text = element_text(size = 12))
    
  })
  
  output$price_table <- renderDataTable(price_table_data(),
                                        options = list(
                                          pageLength = 5
                                        )
  )
  
  # ------------------------------ Map ------------------------------
  output$mapPlot <- renderPlotly({
    listings_grouping <- AirbnbDF %>% 
      filter(`price`>= input$price_budget[1] & `price` <= input$price_budget[2]) %>%
      filter(`property_type`==input$propertytype) %>%
      filter(`room_type`==input$roomtype) %>%
      filter(`beds` >= input$bednumber) %>%
      filter(`bedrooms` >= input$bedroomnumber) %>%
      filter(`bathrooms` >= input$bathroomnumber) %>%
      filter(`accommodates1` >= input$accom)
    listings_grouping
    
    #Just the map that shows all of the listings and colored by prices
    height <- max(AirbnbDF$latitude) - min(AirbnbDF$latitude)
    width <- max(AirbnbDF$longitude) - min(AirbnbDF$longitude)
    Seattle_borders <- c(bottom  = min(AirbnbDF$latitude)  - 0.1 * height, 
                         top     = max(AirbnbDF$latitude)  + 0.1 * height,
                         left    = min(AirbnbDF$longitude) - 0.1 * width,
                         right   = max(AirbnbDF$longitude) + 0.1 * width)
    
    map <- get_stamenmap(Seattle_borders, zoom = 10, maptype = "toner-lite")
    
    map_output <- ggmap(map) +
      geom_point(data = listings_grouping, mapping = aes(x = longitude, y = latitude, text = str_glue("Price: ${price}
                                                                                                      Neighborhood: {neighbourhood}
                                                                                                      Accommodates: {accommodates1}
                                                                                                      Number of Bedrooms: {bedrooms}
                                                                                                      Number of Beds: {beds}
                                                                                                      Number of Bathrooms: {bathrooms}"), col = price)) +
      scale_color_distiller("Price", palette = "YlOrRd", direction = 1) +
      theme(axis.title.x = element_blank(), axis.title.y = element_blank()) 
    
    ggplotly(map_output, tooltip = "text")
  })
  
  # ------------------------------ Boxplot ------------------------------
  
  
  neighborhood_df <- reactive ({
    AirbnbDF %>% filter(zipcode == as.numeric(input$zipcode),
                        bedrooms == as.numeric(input$num_beds), 
                        #bathrooms == as.numeric(input$num_baths), 
                        accommodates1 >= as.numeric(input$accomodation))
  })
  
  # Generate a plot of the requested neighborhood against price ----
  output$mpgPlot <- renderPlotly({
    df <- neighborhood_df()
    validate(
      need(nrow(df) > 0, 'No property exists, please select another neighborhood')
    )
    ggplot(data = df, aes(x=as.factor(property_type), y=price)) +
      labs(title = "Property Price Per Property Type in a Selected Zipcode",
           y = "Price", x = "Property Type") +
      theme(axis.title = element_text(size = 18)) +
      theme(plot.title = element_text(size = 22)) +
      theme(axis.text = element_text(size = 12)) +
      geom_boxplot(fill="sienna1", alpha=0.2, outlier.colour="red", outlier.shape=8,
                   outlier.size=4) +
      theme_classic()
  })
  
}

shinyApp(ui = ui, server = server)
    