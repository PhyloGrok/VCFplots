#Aimee Icaza and Ketsia Pierrelus
#Nhi Luu provided reference code

# Load necessary packages
packages <- c("dplyr", "readr", "ggplot2")
for(p in packages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}

# Read the data
df_full <- read.csv("P_aeruginosa.csv")

# Remove rows with NA in Annotation_Impact
df_full <- df_full %>% filter(!is.na(Annotation_Impact))

# Count the SRA_Run bins and Annotation_Impact
df_counts <- df_full %>% 
  count(SRA_Run, Annotation_Impact)

# Set the desired order for Annotation_Impact
df_counts$Annotation_Impact <- factor(df_counts$Annotation_Impact, levels = c("HIGH", "MODERATE", "MODIFIER", "LOW"))

# Summarize the counts for "LOW" Annotation_Impact and reorder SRA_Run
df_low_counts <- df_counts %>%n 
  filter(Annotation_Impact == "LOW") %>%
  arrange(desc(n))

# Reorder the SRA_Run factor based on the "LOW" counts
df_counts$SRA_Run <- factor(df_counts$SRA_Run, levels = df_low_counts$SRA_Run)

# Stacked bar plot with percentages
g <- ggplot(df_counts, aes(x = SRA_Run, y = n, fill = Annotation_Impact)) + 
  geom_bar(position = "fill", stat = "identity") +
  scale_y_continuous(labels = scales::percent) +  # Convert y-axis to percentages
  labs(
    x = "SRA Run ID",
    y = "Percent of Mutations (%)",
    fill = "Annotation Impact",
    title = "Annotation Impacts by SRA Run in Pseudomonas Aeruginosa, Determined by SNPeff"
  ) +
  theme_minimal()  

# Display the plot
g

