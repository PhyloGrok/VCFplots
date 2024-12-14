library(tidyverse)
library(janitor)
library(dplyr)
library(ggplot2)
library(readr)

Genomics_Ref2 <- read.csv("~/Downloads/Reference_Genomes.csv")

Genomics_Ref2 %>%
  count(`CheckM.marker.set`) %>%
  top_n(15, n) %>%
  ggplot(aes(x = reorder(`CheckM.marker.set`, -n), y = n)) +
  geom_bar(stat = "identity", fill = "orange", alpha = 0.7, color = "black") +
  geom_text(aes(label = n), vjust = -0.3, size = 5, family = "serif") +  
  ggtitle("Top 15 CheckM Marker Sets") +
  xlab("CheckM Marker Set") +
  ylab("Frequency") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 16, face = "bold", family = "serif"),  
    axis.title.x = element_text(size = 12, family = "serif"),  
    axis.title.y = element_text(size = 12, family = "serif"),  
    axis.text.x = element_text(angle = 45, hjust = 1, size = 10, family = "serif"),  
    axis.text.y = element_text(size = 10, family = "serif")  
  )


