# Strip out lines with NA fields from the CSV:
#   ruby -ne 'print unless /,,/' stories.csv > complete.csv

# as.numeric(df$Cycle.Time)
# levels(df$Size)
# table(df$Size)


plot.cycle.times <- function(csv.file = "complete.csv") {
  df <- read.csv("complete.csv")

  df$In.Progress <- strptime(df$In.Progress, format="%Y-%m-%dT%H:%M:%S")
  df$Completed <- strptime(df$Completed, format="%Y-%m-%dT%H:%M:%S")
  df$Accepted <- strptime(df$Accepted, format="%Y-%m-%dT%H:%M:%S")
  df$Story <- as.character(df$Story)
  df$Size <- as.factor(df$Size)

  cycle.time <- difftime(df[,4], df[,3], units="days")
  df$Cycle.Time <- cycle.time
  df$Cycle.Time <- round(df$Cycle.Time, digits=1)

  pdf(file="cycle_times.pdf")

  boxplot(as.numeric(Cycle.Time) ~ Size, data=df, ylab="Cycle Time (days)", xlab="Story Point Size", main="Cycle Time Variation for Story Sizes", varwidth=T)
}

plot.cycle.times()
