#Aimee Icaza
#packages
packages <- c("dplyr","tidyr"
)

#Check for downloaded packages
for(p in packages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}

#Read the full df into df_full
df_full <- read.csv("P_aeruginosa.csv")

# Remove rows with NA in Annotation_Impact
df_full <- df_full %>% filter(!is.na(Annotation_Impact))


df_gene <- df_full %>%
  group_by(SRA_Run, Gene_Name, Annotation_Impact) %>%
  summarise(count = n()) %>%
  spread(Annotation_Impact, count, fill = 0)



#Download as Gene_PA
write.csv(df_gene, file = "Pseudo_mutations.csv", row.names=FALSE)


