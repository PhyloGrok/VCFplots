#Aimee and Ketsia 
#This code worked for Ketsia S.A QC plot

#QC calc scatter plot with polynomial regression to the power of 3.5
#Set up session with the .csv file u are gpoing to use 
#packages
packages <- c("tidyverse","ggplot2","ggthemes"
)
#Check for dowloaded packages
for(p in packages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}
#opening based on session
df <- read.csv("../data/P_aeruginosa/QC_PA.csv")
class(df)
#Plot
#Double check the x and y axis as well as the SRA_Run types with diffrent colors
png(file="../plots/impacts.png")
ggplot(
  data = df,
  mapping = aes(x = Coverage, y = Count.of.SRA_Run )
) +
  geom_point(aes(color = SRA_Run)) +
  geom_smooth(method = "lm", formula = y ~ poly(x,3.5)) +
  labs(
    title = "QC Metrics and Coverage",
    subtitle = expression(italic("Pseudomonas aeruginosa") ~ "Coverage by Number of Mutations",
    x = "Coverage", y = "Number of Mutations",
    color = "SRA_Run"
  ) 
dev.off()

impactDF <- ggplot(
  data = df,
  mapping = aes(x = Coverage, y = Count.of.SRA_Run )
) +
  geom_point(aes(color = SRA_Run)) +
  geom_smooth(method = "lm", formula = y ~ poly(x,3.5)) +
  labs(
    title = "QC Metrics and Coverage",
    subtitle = expression(italic("Pseudomonas aeruginosa") ~ "Coverage by Number of Mutations",
    x = "Coverage", y = "Number of Mutations",
    color = "SRA_Run"
  ) 

png(impactDF)
dev.off()

plot(impactDF)
#Unique checks the diffrent values in df column SRA_Run
unique(df$SRA_Run)
