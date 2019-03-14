# Getting Started
## Requirements
First, make sure you have the **R** installed on your computer.

Then, you need to install **RStudio**.

Download the [project repository](https://github.com/m2ice-scava/scava-r/tree/dev)

Some libraries are required to launch the app.  
Run the script **Dashboard/install.R** to install those libraries.

If a *upper R version* is asked, you can update R on your computer with this
command line on your R console :

    install.packages("installr"); library(installr)
    updateR()

## End-User Dashboard Launch

Open the __Dashboard/App.R__ file with Rstudio.  
Click the Run app button.

### Dashboard for Developpers
Execute the __Dashboard/developperDashboard.R__ script (With Rstudio, open it
then click run).

# End-user Dashboard
The end-user dashboard contains four parts :
+ Emotions Radar chart
+ Emotions Radar slider bar
+ Bugs treatments pie chart
+ Posts activity line chart

## Emotions Radar chart
The emotions radar shows the different emotions shown on the comments at a given
date.

## Emotions Radar slider bar
The emotions radar slider bar permit to change the date to the Radar chart

## Bugs treatments pie chart
The Bugs treatments pie chart show the last bugs treatments state of the project

## Posts activity chart
The sum up the activity of the user posts on the project

# Developper Dashboard
This dashboard is aimed toward developpers

## Summary of metrics
The first section is a summary of metrics

## Line of code chart
This display the amount of line of codes over time
