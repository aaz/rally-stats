### rally-stats ###

Scripts to extract and chart story data from a Rally project.

## Installation ##

Install R, and Ruby.  Not tested with Ruby 1.8, so I recommend you install Ruby 1.9
Install the bundler gem:
    > gem install bundler 
Install the ruby gem dependencies:
    > bundle install 

## Usage ##

1. Create a config.yaml file containing your Rally workspace and project settings.
2. Execute stats.rb to generate the contents of a CSV file that will be fed to R.
3. Strip out any incomplete records from the CSV file.
4. Start R, and load up the plot.R file which contains two functions.
5. Execute cycle.times() passing in the CSV filename as csv.file="..."
6. Execute plot.cycle.times() passing in the data frame returned by cycle.times()
