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


# ** Emotions Data
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


# ** Stability Data
nonResolvedClosedBugs <- JSONJestData$bugs.nonResolvedClosedBugs$datatable
resolvedClosedBugs <- JSONJestData$bugs.resolvedClosedBugs$datatable
unansweredBugs <- JSONJestData$bugs.unansweredBugs$datatable
invalidBugs <- JSONJestData$bugs.invalidBugs$datatable
wontFixBugs <- JSONJestData$bugs.wontFixBugs$datatable
worksForMeBugs <- JSONJestData$bugs.worksForMeBugs$datatable
# newBugs <- JSONJestData$bugs.newbugs$datatable

lastDateBugs <- paste(substr(tail(nonResolvedClosedBugs$Date, 1), 7, 8 ), substr(tail(nonResolvedClosedBugs$Date, 1), 5, 6), substr(tail(nonResolvedClosedBugs$Date, 1), 1, 4), sep="/")
bugsValues <- c(tail(nonResolvedClosedBugs$Bugs, 1), tail(resolvedClosedBugs$Bugs, 1),tail(unansweredBugs$Bugs, 1), tail(invalidBugs$Bugs, 1),tail(wontFixBugs$Bugs, 1), tail(worksForMeBugs$Bugs, 1))
bugsLabels <- c(JSONJestData$bugs.nonResolvedClosedBugs$name, JSONJestData$bugs.resolvedClosedBugs$name, JSONJestData$bugs.unansweredBugs$name, JSONJestData$bugs.invalidBugs$name, JSONJestData$bugs.wontFixBugs$name, JSONJestData$bugs.worksForMeBugs$name)
bugsLabels <- paste(bugsLabels, bugsValues,sep=" - ")
# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("End User Dashboard"),
  
  # Sidebar with a slider input for date 
  sidebarLayout(
    sidebarPanel(
      h2("Emotions radar"),
      sliderTextInput(inputId = "date",
                  label = "Date",
                  choices = dataFrameEmotionsRadarShape$date,
                  selected = dataFrameEmotionsRadarShape$date[[1]])
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("emotionsRadarPlot"),
      br(),
      plotOutput("stabilityPieChart")
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
      title = "Emotions Radar"
    ))
    
  output$stabilityPieChart <- renderPlot(

    pie(bugsValues, labels = bugsLabels, main=paste("Bugs treatments up to",lastDateBugs))
  )
    
  
}

# Run the application 
shinyApp(ui = ui, server = server)

