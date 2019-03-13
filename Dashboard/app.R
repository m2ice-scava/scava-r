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
library(shinyWidgets)

JSONJestData <- fromJSON("metricsRaw.json", simplifyVector = TRUE)

emotionsCommentPourcentagesData <- JSONJestData$bugs.emotions.commentPercentages$datatable

dataFrameEmotionsRadar <- data.frame(
  date = emotionsCommentPourcentagesData[,1],
  emotion = emotionsCommentPourcentagesData[,2],
  percentage = emotionsCommentPourcentagesData[,3]
)

# pivot the data frame to have emotion per date
dataFrameEmotionsRadarShape = cast(dataFrameEmotionsRadar, date ~ emotion)

# Transform NA into 0
dataFrameEmotionsRadarShape[is.na(dataFrameEmotionsRadarShape)] <- 0

# Transform date
dataFrameEmotionsRadarShape$date <- paste(substr(dataFrameEmotionsRadarShape$date, 7, 8 ), substr(dataFrameEmotionsRadarShape$date, 5, 6), substr(dataFrameEmotionsRadarShape$date, 1, 4), sep="/")


# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Emotions radar"),
  
  # Sidebar with a slider input for date 
  sidebarLayout(
    sidebarPanel(
      sliderTextInput(inputId = "date",
                  label = "Date",
                  choices = dataFrameEmotionsRadarShape$date,
                  selected = dataFrameEmotionsRadarShape$date[[1]])
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("emotionsRadarPlot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  
  
  
  # Make the radar plot with the data
  output$emotionsRadarPlot <- renderPlot(
    radarchart(
      rbind(rep(100,7), rep(0,7), dataFrameEmotionsRadarShape[dataFrameEmotionsRadarShape$date==input$date,-1]),
      pcol = rgb(0.2, 0.5, 0.5, 0.9),
      cglty = 1, # full lines
      pfcol = rgb(0.2, 0.5, 0.5, 0.4),
      plty = 1,
      caxislabels = seq(0, 100, 20),
      axislabcol = "grey",
      emotionsCommentPourcentagesData
    )
    
  )
}

# Run the application 
shinyApp(ui = ui, server = server)

