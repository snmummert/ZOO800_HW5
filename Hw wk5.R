#####################################
############ HW WEEK 5 ##############
## Maddie Thall and Sophia Mummert ##
#####################################

install.packages("readxl")
install.packages("writexl")
library(dplyr)

##Problem 1##

#using function head() to read first 5 rows of each dataset
fish.csv = read.csv("fish.csv")
head(fish.csv, 5)
fish.xlsx = readxl::read_excel("fish.xlsx")
head(fish.xlsx, 5)


##Problem 2## 

write.csv(fish.csv, "Output/fish.csv", row.names = FALSE)
writexl::write_xlsx(fish.csv, "Output/fish.xlsx")
saveRDS(fish.csv, "Output/fish.rds")

file.info(c("Output/fish.csv", "Output/fish.xlsx", "Output/fish.rds"))$size

#Out of all of these options, excel is the best for shaing because it is
#"friendly," or easiest to work with. The downside of this is that it is the 
#largest file size, making it not the best for exporting. CSV is another 
#universal format, but its only marginally smaller than excel. The most compact
#file type is RDS, which preserves object structure and classes. It would be the
#best for compact storage. 

##Problem 3##

fish.filtered = fish.cvs %>%
  filter(Species %in% c("Walleye", "Yellow Perch", "Smallmouth Bass"),
         Lake %in% c("Erie", "Michigan")) %>%
  select(Species, Lake, Year, Length_cm, Weight_g)
  