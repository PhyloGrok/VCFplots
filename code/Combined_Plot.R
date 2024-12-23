# AlazarM

# List of required packages
packages <- c("tidyverse", "janitor", "dplyr", "ggplot2", "readr", "ggpubr")

for(p in packages){
  if(!require(p, character.only = TRUE)) install.packages(p)
  library(p, character.only = TRUE)
}


Genomics_Ref1 <- read.csv("~/Downloads/Reference_Genomes.xlsx - Sheet1.csv")
Genomics_Ref2 <- read.csv("~/Downloads/Reference_Genomes.csv")


top_4_checkm <- Genomics_Ref2 %>%
  count(`CheckM.marker.set`, sort = TRUE) %>%  
  top_n(4, n) %>%                             
  pull(`CheckM.marker.set`)                   

filtered_data <- Genomics_Ref2 %>%
  filter(`CheckM.marker.set` %in% top_4_checkm)  

short_names <- c(
  "Halobacteriales" = "Halo",
  "Methanosarcinaceae" = "M-Sarc",
  "Sulfolobaceae" = "Sulfo",
  "Thermococcus" = "Thermo"
)


bar_data <- filtered_data %>%
  group_by(`CheckM.marker.set`) %>%
  summarise(Average_Protein_Coding = mean(Annotation.Count.Gene.Protein.coding)) %>%
  mutate(Short_Name = recode(`CheckM.marker.set`, !!!short_names))


scatter_plot <- ggplot(filtered_data, aes(x = Annotation.Count.Gene.Protein.coding, 
                                          y = Annotation.Count.Gene.Pseudogene, 
                                          color = `CheckM.marker.set`)) +
  geom_point(alpha = 0.7, size = 2) +
  labs(title = "A. Scatter Plot", x = "Protein-Coding Genes", y = "Pseudogenes") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    legend.position = "none"
  )


density_plot <- ggplot(filtered_data, aes(x = Annotation.Count.Gene.Protein.coding, 
                                          fill = `CheckM.marker.set`)) +
  geom_density(alpha = 0.6) +
  labs(title = "B. Density Plot", x = "Protein-Coding Gene Count", y = "Density") +
  theme_minimal() +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    legend.position = "none"
  )


bar_plot <- ggplot(bar_data, aes(x = reorder(Short_Name, -Average_Protein_Coding), 
                                 y = Average_Protein_Coding, fill = `CheckM.marker.set`)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  labs(title = "C. Bar Plot", x = "Marker Set", y = "Avg. gene count/genome") +  
  theme_minimal() +
  theme(
    plot.title = element_text(size = 12, face = "bold"),
    legend.position = "bottom",
    axis.text.x = element_text(angle = 30, hjust = 1)  
  )

summary_data <- filtered_data %>%
  group_by(`CheckM.marker.set`) %>%
  summarise(
    Count = n(),
    Mean = round(mean(Annotation.Count.Gene.Protein.coding), 1),  
    SD = round(sd(Annotation.Count.Gene.Protein.coding), 1)       
  )

table_plot <- ggtexttable(summary_data, rows = NULL, theme = ttheme("classic"))
table_with_title <- annotate_figure(
  table_plot,
  top = text_grob("D. Table", face = "bold", size = 12, hjust = 3)  
)

final_plot <- ggarrange(
  scatter_plot, density_plot, 
  bar_plot, table_with_title,
  ncol = 2, nrow = 2,
  common.legend = TRUE,
  legend = "bottom"
)

final_plot
