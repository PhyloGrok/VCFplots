#Aimee Icaza 
#This code is for PA
# QC calculation scatter plot with logarithmic regression 

# Load necessary packages
packages <- c("tidyverse", "ggplot2", "ggthemes")

# Check for and install any missing packages
for(p in packages) {
  if(!require(p, character.only = TRUE)) install.packages(p)
  library(p, character.only = TRUE)
}

# Open CSV file
df <- read.csv("QC_PA.csv")

# Plot: Double check the x and y axes as well as the SRA_Run types with different colors
QCplot <- ggplot(
  data = df, mapping = aes(x = Coverage, y = Count.of.SRA_Run)) +
  #If the count is less than 300 the is is a square (15) is not a crircle (16)
  geom_point(aes(color = SRA_Run), shape = ifelse(df$Count.of.SRA_Run < 300, 15, 16)) +
  geom_smooth(method = "lm", formula = y ~ log(x), color = "blue") +
  labs(
    title = "QC Metrics and Coverage",
    subtitle = expression(italic("Pseudomonas aeruginosa") ~ "Coverage by Number of Mutations"),
    x = "Coverage",
    y = "Number of Mutations",
    color = "SRA_Run"
  )
png(QCplot)
dev.off()

