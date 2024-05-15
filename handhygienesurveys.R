## Hand hygiene graph percieved vs actual compliance rates
hh <- read.csv("./HHPerception_Reality.csv")
hhnew <- hh[,c(2:5)] 
numeric_cols <- Filter(is.numeric, hhnew)
averages <- colMeans(numeric_cols, na.rm = TRUE)
colors <- c("#F4A582", "#4393C3", "#F4A582", "#4393C3")
barplot(averages,
        main = "Average Hand Hygiene Perceived And Actual Compliance Rates Across Nurses",
        xlab = "Time of Survey and Sample",
        ylab = "Average Percentage of Hand Hygiene Compliance",
        col = colors,
        border = "black",
        ylim = c(0, max(averages)*1.2), 
        las = 1)

bar_centers <- barplot(averages, plot = FALSE)
rounded_values <- round(averages, digits = 2)
text(x = bar_centers, y = averages, labels = paste0(rounded_values, "%"), pos = 3, cex = 0.8, col = "black")

prop.test(c(187,239),c(637,739), alternative="less", conf.level = .95)
