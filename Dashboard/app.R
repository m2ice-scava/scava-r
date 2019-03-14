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
library(reshape2)
library(shinyWidgets)
library(ggplot2)
library(scales)

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
  titlePanel("End-user Dashboard"),
  
  # Sidebar with a slider input for date 
  sidebarLayout(
    sidebarPanel(
      sliderTextInput(inputId = "date",
                  label = "Emotion date",
                  choices = dataFrameEmotionsRadarShape$date,
                  selected = dataFrameEmotionsRadarShape$date[[1]])
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      tags$h3("Emotions"),
      plotOutput("emotionsRadarPlot"),
      tags$h3("Stability"),
      plotOutput("stabilityPieChart"),
      tags$h3("Posts activity over time"),
      plotOutput("averageRepliesPerUserChart", width = "100%", height = "400px")
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
  
  # Retrieve all the needed fields
  requestRepliesBug <- JSONJestData$"bugs.requestsreplies-bugaverage"$datatable
  date <- requestRepliesBug$Date
  comments <- requestRepliesBug$Comments
  requests <- requestRepliesBug$Requests
  replies <- requestRepliesBug$Replies
  
  # Convert date string to a Date object
  requestRepliesBug$date <- as.Date(date, "%Y%m%d")
  dateSequence <- seq(requestRepliesBug$date[1], requestRepliesBug$date[length(requestRepliesBug$date)], "month")
  
  # Generate the plot chart
  output$averageRepliesPerUserChart <- renderPlot({
    ggplot(requestRepliesBug, aes(x=date)) +
      geom_line(aes(y = comments, colour = "Comments"), size=1) + 
      geom_line(aes(y = requests, colour = "Requests"), size=1) + 
      geom_line(aes(y = replies, colour = "Replies"), size=1) +
      labs(x = "date", y = "Number of post") +
      scale_x_date(labels = date_format("%m-%Y")) +
      theme(axis.text.x=element_text(angle=40, hjust=1))
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)

