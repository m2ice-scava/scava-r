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


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Developper Dashboard"),
  
  # Sidebar with a slider input for number of bins 
  fluidRow(
    # Show a plot of the generated distribution
    mainPanel(
      textOutput("test_text"),
      textOutput("complexity_text"),
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
    output$complexity_text <- renderText({complexity_text})
    
    # Retrieve the complexity of the code
    LOCDatatable <- JSONJestData$LOCoverfilesovertime$datatable
    
    LOCColumns <- LOCDatatable[,length(LOCDatatable)]
    print("LOCDatatable")
    print(LOCDatatable)
    
    yrange <- LOCDatatable[, 1]
    xrange <- LOCDatatable[, 2]
    print("y")
    print(yrange)
    print("x")
    print(xrange)
    
    output$LOCChart <- renderPlot({
      plot(yrange, xrange, xlab="Days", ylab="Number of line of code", main = "Number of line of code over time", type = "o")
    })
  }
  
  # Run the application 
  shinyApp(ui = ui, server = server)
  
  