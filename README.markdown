# Overview #

Scripts to extract and chart story data from a Rally project.  The output is a boxplot, showing the variation in cycle times across stories in each story size 'bucket'.  The ruby code uses Rally's REST API to read timestamps for 'In-Progress', 'Completed', and 'Accepted' transitions for every story that has been accepted on the project.  This output is in CSV format which is used as input to the R functions.

## Installation ##

Install R, and Ruby.  Not tested with Ruby 1.8, so I recommend you install Ruby 1.9

Install the bundler gem:

    > gem install bundler 

Install the ruby gem dependencies:

    > bundle install 

## Usage ##

Create a config.yaml file containing your Rally workspace and project settings:

    :workspace: 'Your workspace name here'
    :project: 'Your project name here'

Execute stats.rb to generate the contents of the CSV file that will be used by the R script.  Note that this script will prompt for your Rally username and password.

    ruby -I. stats.rb

Strip out any incomplete records from the CSV file.  Depending on how your project has used Rally, you may have some incomplete records returned, easily identifiable by consecutive commas where a timestamp should be.  There are many ways to automate this, but given that you have Ruby installed you can use:

    ruby -ne 'print unless /,,/' <your_csv_file>

Start R, and load up the plot.R file which contains two functions. Execute these two functions as follows:

    > source("plot.R")
    > df <- cycle.times(csv.file="...")
    > plot.cycle.times(df)

You'll see a line commented out in the plot.cycle.times() function, which can be uncommented to allow saving the graph to a PDF file instead of displaying it on the screen.
