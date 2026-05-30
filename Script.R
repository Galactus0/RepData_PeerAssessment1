library(tidyverse)
library(dplyr)
library(xtable)
library(ggplot2)
#Reading the data
data <- read.csv(unz("activity.zip","activity.csv"))

#Transforming the data
data <- mutate(data, date = ymd(date))
data <- group_by(data, by = day(date))


#Making histogram
graph <- ggplot(data,aes(x = date, weight = steps))
graph + geom_histogram(binwidth = 1) + labs(title = "Steps taken per day",
                                            y = "Steps", x = "") + 
                                theme(plot.title = element_text(hjust = 0.5))

#Calculating the mean and median
mean <- summarise(data, mean = mean(steps, na.rm = TRUE))
mean <- mutate(mean, median = summarise(data, median = median(steps, na.rm = TRUE))$median)

#Converting the interval into a period object
data <- mutate(data, interval = minutes(interval))

#Creating a new data frame by interval distribution
new_data <- group_by(data, interval)

#calculating the mean of 5 minute interval across all the days
interval_mean <- summarise(new_data, steps = mean(steps, na.rm = TRUE))

#Creating a time series line plot
line_plot <- ggplot(interval_mean, aes(x = minute(interval), y = steps))
line_plot + geom_line()  + labs(x = "5 Minutes Intervel")

#Finding the average max steps taken in a 5 minute interval
max <- max(interval_mean$steps)
interval_mean[which(interval_mean$steps == max),]

#Finding the percentage of missing values
mean(is.na(data$steps)) *100


#Replacing the missing values by calculating the mean of steps taken daily
#in 5 minute interval
no_nas <- new_data %>% mutate(steps = replace_na(steps,
            as.integer(round(mean(steps, na.rm = TRUE)))))

# Calculating median and mean after inputing missing values

average <- no_nas %>% group_by(day(date))%>% summarise(mean = mean(steps))
average <- no_nas %>% group_by(day(date)) %>% summarise(median = median(steps)) %>% 
                mutate(average,median = median)
#Creating Histpgram of total number of steps taken each day
graph <- ggplot(no_nas,aes(x = date, weight = steps))
graph + geom_histogram(binwidth = 1) + labs(title = "Steps taken per day", y = "Steps",
                                            x = "") + theme(plot.title = element_text(hjust = 0.5))


#Adding the factor weekday and weekend

by_week <- mutate(no_nas, day_type = if_else(weekdays(date) %in% 
                c("Saturday", "Sunday"), "Weekend", "Weekday"), day_type = factor(day_type,
                levels = c("Weekday", "Weekend")))

#Grouping the data frame by weekday and interval and calculating the mean
by_week <- group_by(by_week, day_type, interval) %>% 
    summarise(steps = mean(steps), .groups = "drop_last")

#Creating the line grapph
line_grap <- ggplot(by_week, aes(x = as.numeric(interval, "minutes"),
                                 y = steps, group = 1))

line_grap + geom_line() + facet_grid(by_week$day_type~.)


