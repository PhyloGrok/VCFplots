#Ketsia Pierrelus
#set working directory to Aureus_mutations.csv
#packages
packages <- c("dplyr","tidyr","ggplot2", "ggthemes"
)

# Check for downloaded packages
for(p in packages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}

# Read CSV data
df_full <- read.csv("Aureus_mutations.csv")

# Calculate total of all mutations
mutation_count <- colSums(df_full[, c("HIGH", "MODERATE", "MODIFIER", "LOW")])

# Put into a separate dataframe
mutation_count_df <- data.frame(
  Type = c("HIGH", "MODERATE", "MODIFIER", "LOW"),
  Mutation_Count = mutation_count
)

# Sort mutation_count_df by Mutation_Count in descending order
mutation_count_df <- mutation_count_df %>% arrange(desc(Mutation_Count))

# Histogram plot of total amount

totmut <- ggplot
(data = mutation_count_df, mapping = aes(x = reorder(Type, -Mutation_Count), y = Mutation_Count, fill = Type)) +
  geom_bar(stat = "identity") +
  labs(
    title = "Total Mutations",
    subtitle = expression(italic("Staphylococcus Aureus") ~ "Frequency of Types of Mutations"),
    x = "Type of Mutation", y = "Frequency",
    fill = "Mutation Type"
  )

png(totmut)
dev.off()

