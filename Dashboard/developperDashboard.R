#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(jsonlite)
library(fmsb)
library(ggplot2)
library(scales)


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Developper Dashboard"),
  
  # Sidebar with a slider input for number of bins 
  fluidRow(
    # Show a plot of the generated distribution
    mainPanel(
      tags$h3("Metrics"),
      tableOutput("dataArray"),
      tags$h3("Lines of code over time"),
      plotOutput("LOCChart", width = "100%", height = "400px")
    )
  )
)
  
  # Define server logic required to draw a histogram
  server <- function(input, output) {
    
    JSONJestData <- fromJSON("metricsRaw.json", simplifyVector = TRUE)
    
    # Retrieve the test coverage last data
    testCoverageDatatable <- JSONJestData$testCoveragePublicHistoric$datatable
    
    testCoverageRows <- testCoverageDatatable[,length(testCoverageDatatable)]
    testCoverageLastValue <- testCoverageRows[length(testCoverageRows)]
    test_text <- paste("Test coverage : ", testCoverageLastValue, "%")
    output$test_text <- renderText({test_text})
    
    # Retrieve the complexity of the code
    complexityDatatable <- JSONJestData$CCHistogramJavaTimeLine$datatable
    
    complexityRows <- complexityDatatable[,length(complexityDatatable)]
    complexityLastValue <- complexityRows[length(complexityRows)]
    complexity_text <- paste("Number of Java methods for Cyclometic Complexity risk factor : ", complexityLastValue)
    dataArray = list(c("Test coverage percentage", "Number of Java methods for Cyclometic Complexity risk factor"), c(testCoverageLastValue, complexityLastValue))
    output$dataArray <- renderTable(dataArray, colnames = FALSE)
    
    # Retrieve the complexity of the code
    LOCDatatable <- JSONJestData$LOCoverfilesovertime$datatable
    
    date <- LOCDatatable$Date
    gini <- LOCDatatable$Gini
    
    LOCDatatable$Date <- as.Date(LOCDatatable$Date, "%Y%m%d")
    dateSequence <- seq(LOCDatatable$Date[1], LOCDatatable$Date[length(LOCDatatable$Date)], "month")
    
    output$LOCChart <- renderPlot({
      ggplot(LOCDatatable, aes(x=Date)) +
        geom_line(aes(y = gini, colour = "Lines of code"), size=1) +
        labs(x = "date", y = "Lines of code") +
        scale_x_date(labels = date_format("%m-%Y")) +
        theme(axis.text.x=element_text(angle=40, hjust=1))
    })
  }
  
  # Run the application 
  shinyApp(ui = ui, server = server)
  
  