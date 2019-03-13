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
library(reshape)


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Emotions radar"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("emotionsRadarPlot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
  JSONJestData <- fromJSON("metricsRaw.json", simplifyVector = TRUE)
  
  emotionsCommentPourcentagesData <- JSONJestData$bugs.emotions.commentPercentages$datatable
  
  dataFrameEmotionsRadar <- data.frame(
    date = emotionsCommentPourcentagesData[,1],
    emotion = emotionsCommentPourcentagesData[,2],
    percentage = emotionsCommentPourcentagesData[,3]
  )
  
  # pivot the data frame to have emotion per date
  print(cast(dataFrameEmotionsRadar, date ~ emotion))
  
  output$emotionsRadarPlot <- renderPlot(
    radarchart(
      dataFrameEmotionsRadar,
      maxmin=F,
      emotionsCommentPourcentagesData
    )
    
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

