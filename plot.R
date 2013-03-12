# Strip out lines with missing fields from the CSV:
# E.g. ruby -ne 'print unless /,,/' stats.csv > complete.csv

cycle.times <- function(csv.file = "complete.csv") {
  df <- read.csv("complete.csv")

  df$In.Progress <- strptime(df$In.Progress, format="%Y-%m-%dT%H:%M:%S")
  df$Completed <- strptime(df$Completed, format="%Y-%m-%dT%H:%M:%S")
  df$Accepted <- strptime(df$Accepted, format="%Y-%m-%dT%H:%M:%S")
  df$Story <- as.character(df$Story)
  df$Estimate <- as.numeric(df$Estimate)
  df$Size <- cut(df$Estimate, breaks=c(0.0, 1.5, 2.5, 3.5, 5.5, 10.5, 13.0), labels=c('1', '2', '3', '5', '8-10', '13'))
  df$Cycle.Time.Days <- round(df$Cycle.Time / 24.0, digits=1)

# cycle.time <- difftime(df[,4], df[,3], units="days")
# df$Cycle.Time <- cycle.time # - df$Blocked.Time
# df$Cycle.Time <- round(df$Cycle.Time, digits=1)

  return(df[!is.na(df$Size),])
}

plot.cycle.times <- function(df, ...) {

  pdf(file="cycle_times.pdf")

  boxplot(as.numeric(Cycle.Time.Days) ~ Size, data=df, ylab="Cycle Time (days)", xlab="Story Point Size", main="Cycle Time Variation for Story Sizes", varwidth=T, ...)

  dev.off()
}
