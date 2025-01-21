#Alazar

#Packages
library(tidyverse)
library(janitor)
library(dplyr)
library(ggplot2)
library(data.table)
library(readr)

Archaea <- read.csv("/Users/alazarmanakelew/Downloads/archaea.csv")

#OxyReq
oxygen_plot <- Archaea %>%
  count(OxygenReq) %>%
  ggplot(aes(x = reorder(OxygenReq, -n), y = n, fill = OxygenReq)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Counts of Oxygen Requirements",
    x = "Oxygen Requirement",
    y = "Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(oxygen_plot)

#TempRange
temperature_plot <- Archaea %>%
  count(TemperatureRange) %>%
  ggplot(aes(x = reorder(TemperatureRange, -n), y = n, fill = TemperatureRange)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Counts of Temperature Ranges",
    x = "Temperature Range",
    y = "Count"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

print(temperature_plot)
