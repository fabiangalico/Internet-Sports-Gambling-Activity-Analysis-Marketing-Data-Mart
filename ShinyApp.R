#https://ekapopev.shinyapps.io/Open-Source-Group-11/

# import packages

if (!require("haven")) install.packages("haven"); library(haven)
if (!require("dplyr")) install.packages("dplyr");library(dplyr)
if (!require("shiny")) install.packages("shiny"); library(shiny)
if (!require("ggplot2")) install.packages("ggplot2");library(ggplot2)
if (!require("DT")) install.packages("DT"); library(DT)
if (!require("tools")) install.packages("tools");library(tools)
if (!require("tidyr")) install.packages("tidyr");library(tidyr)
if (!require("shinydashboard")) install.packages("shinydashboard"); library(shinydashboard)
if (!require("shinyWidgets")) install.packages("shinyWidgets");library(shinyWidgets)
if (!require("scales")) install.packages("scales");library(scales)
# if (!require("plotly")) install.packages("plotly");library(plotly)

#import basetable
basetable <- load("Group11_Basetable.Rdata")
basetable <- Basetable_All
# Create Age_Range Column
basetable$Age_Range <- paste0((basetable$Age%/%10)*10,"-",((basetable$Age%/%10)+1)*10)
  
################################################ SHINY APP ###################################################
# Define UI for application 
ui <- fluidPage({
  
  sidebarLayout(
    # Inputs filters
    sidebarPanel(
        wellPanel(
          h4("Please select to filter data"),
          uiOutput("product_type"),
          uiOutput("Application_Description_selector"),
          uiOutput("Country_Name_selector"),
          uiOutput("Gender_selector"),
          uiOutput("Language_Description_selector"),
          uiOutput("Age_Range_selector")
        ),
        
        wellPanel(
          h4("Select X and Y axis for plotting"),
          uiOutput("x_col"),      
          uiOutput("x_col_axis"),
          uiOutput("y_col"),      
          uiOutput("y_col_axis")),

        # wellPanel(
        #   uiOutput("Groupby_Selector"),
        #   uiOutput("Sort_Selector")),

        wellPanel(
          h4("Download filtered data (*.csv format)"),
          downloadButton('download_filtered_data')
        )),
    
  mainPanel(
      # Application title
      titlePanel("Internet Sports Gambling Activity Analysis & Marketing Data Mart"),
        h5("Created by: Fabian Galico & Ekapope Viriyakovithya | Date: December 13, 2018"),
      tabsetPanel(type = "tabs",
                  # Tab : Histogram plot
                  tabPanel(title = "Histograms", br(),
                           h4(textOutput("description_hist0")),
                           plotOutput(outputId = "histogram_x"),verbatimTextOutput("summary_x_col"),
                           plotOutput(outputId = "histogram_y"),verbatimTextOutput("summary_y_col")
                  ),
                  # Tab : Scatterplot
                  tabPanel(title = "Scatter Plot", 
                           h4(textOutput("description_scatter0")),
                           plotOutput(outputId = "scatterplot"), br())
                  ,
                  # Tab : Bar chart
                  tabPanel(title = "Bar Charts", br(),
                           h4(textOutput("description_barplot0")),
                           h5(textOutput("description_barplot1")),
                           plotOutput(outputId = "barchart_x"),
                           h5(textOutput("description_barplot2")),
                           plotOutput(outputId = "barchart_y")),
                  # Tab : Data
                  tabPanel(title = "Filtered DataTable",br(),                           
                           shiny::dataTableOutput(outputId = "newtable"))
  )             
)
)
})
# Define server function 
server <- function(input, output) {


  #--------------- Input filters section ---------------
 
  #Select the product type , default selected = prod 1
  output$product_type<-renderUI({  
    selectInput(inputId = "product_type", label = "Select Product Type", 
                choices = c("All Products" = "All",
                            "Sports book fixed-odd (Prod1)" = "Prod1",
                            "Sports book live-action (Prod2)" = "Prod2",
                            "Poker BossMedia (Prod3)" = "Prod3",
                            "Casino BossMedia  (Prod4)" = "Prod4",
                            "Supertoto (Prod5)" = "Prod5",
                            "Games VS (Prod6)" = "Prod6",
                            "Games bwin (Prod7)" = "Prod7",
                            "Casino Chartwell (Prod8)" = "Prod8"),
                selected = "Prod1")
  })
  
  # initialise subset datatable to be use for this server, based on selected product type/ groupby or not
  rt<-reactive({
    
    if (input$product_type == "All"){
        basetable %>%
        select(c(1,13, 159:163))
    }
    else if (input$product_type != "All"){
        basetable %>%
        select(c(1,13, contains(input$product_type), 159:163))%>%
        drop_na()
    }
    # if (input$Groupby_Selector == "None" & input$product_type == "All"){
    #   basetable %>%
    #     select(c(1,13, 159:163))
    # }
    # else if (input$Groupby_Selector == "None" & input$product_type != "All"){
    #   basetable %>%
    #     select(c(1,13, contains(input$product_type), 159:163))%>%
    #     drop_na()
    # }
    # else if (input$Groupby_Selector != "None" & input$product_type == "All"){
    #     basetable %>%
    #       select(c(1,13, 159:163))%>%
    #       group_by_(input$Groupby_Selector)%>%
    #       summarize_all(funs(min, max))
    # }

    # else if (input$Groupby_Selector != "None" & input$product_type != "All"){
    #     basetable %>%
    #       select(c(1,13, contains(input$product_type), 159:163))%>%
    #       drop_na()%>% group_by_(input$Groupby_Selector)
    #       summarize_all(funs(min, max))
    # }
   
  })

  output$Application_Description_selector <- renderUI({
    pickerInput(inputId = "Application_Description_selector",
                label = "Select Applications", choices=unique(rt()$Application_Description), options = list(`actions-box` = TRUE),multiple = T,
                selected =unique(rt()$Application_Description))
  }) 

  output$Country_Name_selector <- renderUI({
    pickerInput(inputId = "Country_Name_selector",
                label = "Select Country(s)", choices=unique(rt()$Country_Name), options = list(`actions-box` = TRUE),multiple = T,
                selected =unique(rt()$Country_Name))
  })  
  
  output$Gender_selector <- renderUI({
    pickerInput(inputId = "Gender_selector",
                label = "Select Gender(s)", choices=unique(rt()$Gender_Label), options = list(`actions-box` = TRUE),multiple = T,
                selected =unique(rt()$Gender_Label))
  })  
  
  output$Language_Description_selector <- renderUI({
    pickerInput(inputId = "Language_Description_selector",
                label = "Select Language(s)", choices=unique(rt()$Language_Description), options = list(`actions-box` = TRUE),multiple = T,
                selected =unique(rt()$Language_Description))
  })

  output$Age_Range_selector <- renderUI({
    sliderInput(inputId = "Age_Range_selector",
                label = "Select Age Ranges", 
                min = min(as.numeric(rt()$Age),na.rm=T), 
                max = max(as.numeric(rt()$Age),na.rm=T),
                step = 1,
                value = c(min, max),round = T)
  })

  

  # create Group by selector ------------------
  output$Groupby_Selector<-renderUI({
    selectInput(inputId = "Groupby_Selector", label = h4("Choose column to groupby (based on X,Y selected)"), 
                choices = c("None","Country_Name","Language_Description","Application_Description","Age_Range","Gender_Label" ))
  })
  

  # create subset data flitered for plotting, table , named rtp ------------------
  rtp<-reactive({
      if (input$product_type == "All"){
        basetable %>%
          select(c(1,13, 159:163))%>%
          filter(Application_Description%in%input$Application_Description_selector,
                 Country_Name%in%input$Country_Name_selector,
                 Gender_Label%in%input$Gender_selector,
                 Language_Description%in%input$Language_Description_selector,
                 Age>input$Age_Range_selector[1], Age<input$Age_Range_selector[2]
          )
      }else {
        basetable %>%
          select(c(1,13, contains(input$product_type), 159:163))%>%
          filter(Application_Description%in%input$Application_Description_selector,
                 Country_Name%in%input$Country_Name_selector,
                 Gender_Label%in%input$Gender_selector,
                 Language_Description%in%input$Language_Description_selector,
                 Age>input$Age_Range_selector[1], Age<input$Age_Range_selector[2]
                 )%>%
          drop_na()  
      }
  })

  # Output table to show in the ta (filtered)
  output$newtable <- shiny::renderDataTable({rtp()
  })

  #--------------- Select Input for Ploting  ---------------

  output$x_col<-renderUI({
    selectInput(inputId = "x_col", label = h5("Choose X-Axis"), 
                choices = as.vector(as.character(names(rt()))),
                selected = "Age")
  })
  output$x_col_axis <- renderUI({
    sliderInput(inputId = "x_col_axis",
                label = "X-Axis range", 
                min = floor(min(as.numeric(rt()[[input$x_col]]),na.rm=T)), 
                max = ceiling(max(as.numeric(rt()[[input$x_col]]),na.rm=T)),
                value = c(min, max))
  })  
  output$y_col<-renderUI({
    selectInput(inputId = "y_col", label = h5("Choose Y-Axis"), 
                choices = as.vector(as.character(names(rt()))),
                selected = "Age")
  })
  output$y_col_axis <- renderUI({
    sliderInput(inputId = "y_col_axis",
                label = "Y-Axis range", 
                min = floor(min(as.numeric(rt()[[input$y_col]]),na.rm=T)), 
                max = ceiling(max(as.numeric(rt()[[input$y_col]]),na.rm=T)),
                value = c(min, max))
  })   
  output$Sort_Selector<-renderUI({
    selectInput(inputId = "Sort_Selector", label = h4("Choose column to be sorted (decending)"), 
                choices = as.vector(as.character(names(rt()))))
    
  })  
  
  #--------------- Ploting Section  ---------------
  # Convert plot_title toTitleCase
  plot_title <- reactive({ toTitleCase(paste(input$x_col,"VS", input$y_col)) })

  # Create scatterplot object the plotOutput function is expecting 2
  output$scatterplot <- renderPlot({
    ggplot(data = rtp(), aes_string(x = input$x_col, y = input$y_col))+geom_point(shape=1)+ggtitle(paste(input$product_type, "Scatter plot :", input$x_col,"VS", input$y_col))+ scale_x_continuous(labels = comma)+ scale_y_continuous(labels = comma)+xlim(input$x_col_axis)+ylim(input$y_col_axis) 
  })

  # summary_x_col
  output$summary_x_col <- renderPrint({
    summary(rtp()[[input$x_col]]) 
  })
  
  # summary_y_col
  output$summary_y_col <- renderPrint({
    summary(rtp()[[input$y_col]]) 
  })
  
  # Create histogram_x X
  output$histogram_x <- renderPlot({
    ggplot(data = rtp(), aes_string(x = input$x_col))+ ggtitle(paste("Selected X-Axis : ",input$x_col)) + geom_histogram(color="black", fill="white")+ scale_x_continuous(labels = comma)+xlim(input$x_col_axis)
    
  })
  # Create histogram y  
  output$histogram_y <- renderPlot({
    ggplot(data = rtp(), aes_string(x = input$y_col))+ ggtitle(paste("Selected Y-Axis : ",input$y_col)) + geom_histogram(color="black", fill="white")+ scale_x_continuous(labels = comma)+xlim(input$y_col_axis)
  })

  
  # Create descriptive text below scatter plot
  output$description_hist0 <- renderText({
    "Select the variables from the left panel [X for the upper plot, Y for the lower plot]"
  })
  
  # Create descriptive text below scatter plot
  output$description_scatter0 <- renderText({
    "Select the variables from the left panel [X and Y]"
  })
  
  # Create Title text for Bar plot
  output$description_barplot0 <- renderText({
    "Select the categorical variables [Country_Name, Language_Description, Application_Description, Age_Range, Gender_Label] "
  })
  # Create descriptive text below box plot x
  output$description_barplot1 <- renderText({
    paste0(input$product_type," Selected X : ", input$x_col,".")
  })
  
  # Create descriptive text below box plot y
  output$description_barplot2 <- renderText({
    paste0(input$product_type,"Selected Y : ", input$y_col,".")
  })  
  #Create a barchart x
  output$barchart_x <- renderPlot({
    ggplot(data = rtp(), aes_string(x = input$x_col))+ ggtitle(paste("Selected X-Axis : ",input$x_col)) + geom_bar()+theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1))

  })
  #Create a barchart y
  output$barchart_y <- renderPlot({
    ggplot(data = rtp(), aes_string(x = input$y_col))+ ggtitle(paste("Selected Y-Axis : ",input$y_col)) + geom_bar()+theme(axis.text.x = element_text(angle = 90, vjust = 1, hjust=1))
    
  })
  
  
  
  
  #--------------- Exporting filtered data section ---------------
  # Downloadable csv of selected dataset ----
  output$download_filtered_data <- downloadHandler(
    filename = function() {
      paste('Filtered_data', '.csv', sep = '')
    },
    content = function(file) {
      write.csv(rtp(), file, row.names = FALSE)
    }
  )
  
  
}
# Create a Shiny app object
shinyApp(ui = ui, server = server)
