#Aimee Icaza and Ketsia
#Must have all the CSV files saved in the session for the working directory

#packages
packages <- c("dplyr","readr","ggplot2"
)

#Check for downloaded packages
for(p in packages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}

#File from session directory
file_path = getwd()

#import and merge all three CSV files into one data frame
df <- list.files(path=file_path) %>% 
  lapply(read_csv) %>% 
  bind_rows 

#view resulting data frame
df

#Download as P.a...
write.csv(df, file = "P_aeruginosa.csv", row.names=FALSE)

