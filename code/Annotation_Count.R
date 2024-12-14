library(tidyverse)
library(janitor)
library(dplyr)
library(ggplot2)
library(readr)

Genomics_Ref2 <- read.csv("~/Downloads/Reference_Genomes.csv")

top_checkm <- Genomics_Ref2 %>%
  count(CheckM.marker.set, sort = TRUE) %>%
  top_n(10, n) %>%
  pull(CheckM.marker.set)

filtered_data <- Genomics_Ref2 %>%
  filter(CheckM.marker.set %in% top_checkm)

ggplot(filtered_data, aes(
  x = Annotation.Count.Gene.Protein.coding,
  y = Annotation.Count.Gene.Pseudogene,
  color = CheckM.marker.set
)) +
  geom_point(size = 3, alpha = 0.7) +
  labs(
    title = "Annotation Count Relationship by Top 10 CheckM Marker Sets",
    x = "Annotation Count Gene Protein-coding",
    y = "Annotation Count Gene Pseudogene",
    color = "CheckM Marker Set"
  ) +
  theme_minimal() +
  theme(
    legend.position = "right",
    plot.title = element_text(size = 16, face = "bold", family = "serif"),  
    axis.title = element_text(size = 12, family = "serif"),  
    legend.title = element_text(size = 12, family = "serif"),  
    legend.text = element_text(size = 10, family = "serif")  
  )