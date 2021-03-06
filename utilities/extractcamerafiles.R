library(tidyverse)

# clear the enviroment
rm(list=ls(all=TRUE))

# set working directory
wd <- setwd("J:/cameratraps")

# scan the external hard drive and read in the sub-folder and files as a character vector
all_files<- list.files(path = wd, full.names = TRUE, recursive = TRUE, include.dirs = TRUE)

# view the resulting character vector
# View(all_files)

# convert the character vector into a tibble (similar to a data frame)
# this will make it easier to work with and view the files
all_files_tibble <- as_tibble(all_files)

# view the tibble
head(all_files_tibble)

# rename the first column of our tibble to better represent its meaning
# this first column represents the path to the file (i.e. its location) on the hard drive
names(all_files_tibble)[names(all_files_tibble) == "value"] <- "path"

# check to see if the first column of the tibble was renamed
head(all_files_tibble)

# all_files_tibble_path_fixed <- str_replace(all_files_tibble, "//", "/")

# all_files_tibble_separated_into_columns <- separate(all_files_tibble, path, into = c("rootfolder", "mainfolder"), sep = "/", remove = FALSE)

# View(all_files_tibble_separated_into_columns)

# separate the first column of the tibble into new columns to make them easier to read
# preserve the first column, as we may use it to navigate to those files later
# Note: any empty spaces in the resulting tibble will be filled with NAs
all_files_tibble_separated_into_columns <- separate(all_files_tibble, path, into = c("rootfolder","mainfolder", "locationfolder", "sitefolder", "collectionfolder", "subfolder", "file"), sep = "/", remove = FALSE)

# view the resulting tibble, now split into multiple columns
head(all_files_tibble_separated_into_columns)

# create a new tibble that is a subset of the all files tibble
# this tibble will store the number of files in each subfolder
# separate from the all files tibble
subfolders.tibble <- (filter(all_files_tibble_separated_into_columns, is.na(all_files_tibble_separated_into_columns$file) == TRUE & nchar(all_files_tibble_separated_into_columns$subfolder) <9))

# view this new tibble
head(subfolders.tibble)

collections.tibble <- (filter(all_files_tibble_separated_into_columns, is.na(all_files_tibble_separated_into_columns$subfolder) == TRUE))

# view this new tibble
head(collections.tibble)

# Custom function: count.files.in.subfolders
# What it does: This function reads in the all files tibble and then counts the number of files in each subfolder. It removes NA values before counting files.
# What it needs: The inputs of this function are the tibble of files, the name of the collection folder (e.g., ACB_03272019_05102019), and the name of the subfolder (e.g., 100EK113)
# What it outputs: This function outputs a single integer value of the number of files from the specified subfolder
count.files.in.subfolders<- function(files.tibble, collection, folder){
  first.collection.subfolder <- filter(files.tibble, collectionfolder == collection & subfolder == folder)
  files <- na.omit(first.collection.subfolder)
  filecount <- as.integer(count(files))
return(filecount)
}

# Custom function: count.files.in.collections
# What it does: This function reads in the all files tibble and then counts the number of files in each collection folder. It removes NA values before counting files.
# What it needs: The inputs of this function are the tibble of files and the name of the collection folder (e.g., ACB_03272019_05102019).
# What it outputs: This function outputs a single integer value of the number of files from the collection folder.
count.files.in.collections <- function(files.tibble, folder){
  files.in.collection.folder <- filter(files.tibble, collectionfolder == folder)
  removed.na.files.in.collection.folder <- na.omit(files.in.collection.folder)
  filecount <- as.integer(count(removed.na.files.in.collection.folder))
  return(filecount)
}

# example use of this function
# this function requires that there be a 'metadata' folder inside of the collection folder
count.files.in.collections(all_files_tibble_separated_into_columns, "ACB_03272019_05102019")


# Apply the 'count.files.in.subfolders' function over the entire the subfolders.tibble
# This will count the number of files in each subfolder
# Each time the for loop will append the file count result to the corresponding file column in the subfolders.tibble
for (i in 1:length(subfolders.tibble$subfolder)) {
subfolders.tibble$file[i]  <- count.files.in.subfolders(all_files_tibble_separated_into_columns, subfolders.tibble$collectionfolder[i], subfolders.tibble$subfolder[i])
}

head(subfolders.tibble)
tail(subfolders.tibble)

# Apply the 'count.files.in.collections' function over the entire the subfolders.tibble
# This will count the number of files in each subfolder
# Each time the for loop will append the file count result to the corresponding file column in the subfolders.tibble
for (i in 1:length(collections.tibble$file)) {
  collections.tibble$file[i]  <- count.files.in.collections(all_files_tibble_separated_into_columns, collections.tibble$collectionfolder[i])
}

head(collections.tibble)

write.csv(subfolders.tibble, file = "file-count-by-subfolder-2020-04-30.csv", row.names = F)

write.csv(all_files_tibble_separated_into_columns, file = "all-camera-files-2020-04-30.csv", row.names = F)

write.csv(collections.tibble, file = "file-count-by-collection-folder-2020-04-30.csv", row.names = F)

# View(allcamerafiles)

# length(allcamerafiles)
