#####################################
############ HW WEEK 5 ##############
## Maddie Thall and Sophia Mummert ##
#####################################

library(dplyr)
library(parallel)

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

#Filter & Select
fish.filtered = fish.csv %>%
  filter(Species %in% c("Walleye", "Yellow Perch", "Smallmouth Bass"),
         Lake %in% c("Erie", "Michigan")) %>%
  select(Species, Lake, Year, Length_cm, Weight_g)

#Create Variables
fish.mutated = fish.filtered %>%
  mutate(
    Length_mm = Length_cm * 10,
    Length_group = cut(
      Length_mm,
      breaks = c(-Inf, 200, 400, 600, Inf),
      right = TRUE
    )
  ) %>%
  group_by(Species, Length_group) %>%
  mutate(Count = n()) %>%
  ungroup()

#Summarise
fish.summarized = fish.mutated %>%
  group_by(Species, Year) %>%
  summarise(
    mean_weight = mean(Weight_g, na.rm = TRUE),
    median_weight = median(Weight_g, na.rm = TRUE),
    n = n()
  )

#Plot
library(ggplot2)
ggplot(fish.summarized, aes(Year, mean_weight, color = Species)) +
  geom_line() +
  geom_point() +
  labs(
    title = "Temporal Change of Mean Weight by Species",
    x = "Year",
    y = "Mean Weight (g)"
  )

#Export Results
write.csv(fish.mutated, "Output/fish.mutated.csv", row.names = FALSE)
write.csv(fish.mutated, "Output/fish.summarised.csv", row.names = FALSE)

##Problem 4## 
all.files = list.files("Multiple_files", full.names = TRUE)
all.list = lapply(all.files, read.csv)
all.data = dplyr::bind_rows(all.list) #combined into 1 data frame

##Problem 5##

lake.erie = filter(fish.csv, Lake %in% "Erie") #pull from dataset to just have Lake Erie
species.erie = unique(lake.erie$Species)

boot_mean = function(species_name, n_boot = 10000, sample_size = 200) {
  x = lake.erie$Weight_g[lake.erie$Species == species_name]
  means = replicate(n_boot, mean(sample(x, size = sample_size, replace = TRUE)))
  mean(means)
}

#output for results using sapply to merge the species names with their boot mean
boot_results = sapply(species.erie, boot_mean)

print(boot_results)

t_serial <- system.time({
  res_serial <- lapply(
    species,
    boot_mean,               
    n_boot = 10000,
    sample_size = 200
  )
})
head(res_serial)

n_cores <- max(1, detectCores() - 1)
cl <- makeCluster(n_cores)

clusterSetRNGStream(cl, iseed = 123)

clusterExport(cl, varlist = c("lake.erie", "boot_mean", "species"), envir = environment())

t_parallel <- system.time({ 
  res_parallel <- parLapply(
    cl,
    species, 
    boot_mean,
    n_boot = 10000,
    sample_size = 200
  )
})

stopCluster(cl)

head(res_parallel)

elapsed_serial   <- unname(t_serial["elapsed"])
elapsed_parallel <- unname(t_parallel["elapsed"])
speedup <- elapsed_serial / elapsed_parallel

cat("Serial elapsed (s):   ", round(elapsed_serial, 3), "\n")
cat("Parallel elapsed (s): ", round(elapsed_parallel, 3), " using ", n_cores, " cores\n", sep = "")
cat("Speedup:               ", round(speedup, 2), "x\n", sep = "")
