### Getting and cleaning data course project on Coursera
### This is final project script called called run_analysis.R
### Created by Artem on September 16, 2016

### It does the following:
### Creates directories for data, downloads zip archive, and unpacks it.
### Loads original data sets and merges the training and the test sets to create one data set.
### Extracts only the measurements on the mean and standard deviation for each measurement.
### Uses descriptive activity names to name the activities in the data set.
### Appropriately labels the data set with descriptive variable names.
### From this data set creates a second, independent tidy data set
### with the average of each variable for each activity and each subject.
### Finally it save tidy data set in txt-file.


## clean all objects from workspace
rm(list=ls())


## define all input parameters
# download data input parameters
datapath <- file.path(".", "original_data") # platform-independent way
zipurl <-  "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
datestamp <- as.character.Date(Sys.Date()) # use date to keep info when it was done
zipfilename <-  paste(datestamp, "_dataset", ".zip", sep = "") # keep original name dataset as well
zippath <- file.path(datapath, zipfilename) # full path to save original zip-file
upzipfilepath <-  file.path(datapath, datestamp) # use subfolder named by date for unpack data
overwriteflag <- FALSE # set flag to TRUE to download file and unpack it again
# read data files input parameters
datamaindir <- file.path(upzipfilepath, "UCI HAR Dataset")
traindir <- file.path(datamaindir, "train")
testdir <- file.path(datamaindir, "test")
trainsetpath <- file.path(traindir, "X_train.txt")
testsetpath <- file.path(testdir, "X_test.txt")
featurespath <- file.path(datamaindir, "features.txt")
trainactivitypath <- file.path(traindir, "y_train.txt")
testactivitypath <- file.path(testdir, "y_test.txt")
activitylabelspath <- file.path(datamaindir, "activity_labels.txt")
trainsubjectspath <- file.path(traindir, "subject_train.txt")
testsubjectspath <- file.path(testdir, "subject_test.txt")
# merging data input parameters
activityname <- "Activity"
subjectname <- "Subject"
# extracting data input parameters
excludemeanFreqflag = TRUE
if(excludemeanFreqflag) {
  # use mean() for extraction and ignore meanFrequency
  extractregexpr <- "mean\\(\\)|std\\(\\)" # double backslashs used to pass "(" and ")" as characters
} else {
  # use mean for extraction and includ meanFrequency
  extractregexpr <- "mean|std\\(\\)" # double backslashs used to pass "(" and ")" as characters
}
# activities name input parameters
activitylevelsind <- 1
activitylabelsind <- 2
# variable names input parameters
renamepatterns <-
  c("Acc", "Gyro", "^t", "^f", "Mag", "mean\\(\\)", "std\\(\\)", "meanFreq\\(\\)", "-")
renamereplacements <-
  c("Accelerometer", "Gyroscope","Time",
    "Frequency","Magnitude", "Mean", "StandardDeviation", "MEANFrequency", "")
renamedataframe <- data.frame(renamepatterns = renamepatterns,
                              renamereplacements = renamereplacements, stringsAsFactors = FALSE)
# tidy dataset input parameters
tidydatasetpath <- file.path(".", paste(datestamp, "-tidydataset.txt", sep = ""))


## get data
# create folder datapath (if not exist)
if(!file.exists(datapath)) { dir.create(datapath) }
# create folder for unpacked data (if not exist)
if(!file.exists(upzipfilepath)) { dir.create(upzipfilepath) }
# download zip-file (if not exist) and unpack it
if(!file.exists(zippath) || overwriteflag) {
  # remove previous files if overwrite flag TRUE
  if(overwriteflag) {
    file.remove(zippath) # remove zip file
    unlink(upzipfilepath, recursive = TRUE) # remove sub-folder with unpacked files
  }
  download.file(url = zipurl, destfile = zippath, method = "curl") # "curl" for macs
  unzip(zipfile = zippath, exdir = upzipfilepath, overwrite = overwriteflag)
}


## read data
trainset <- read.table(trainsetpath)
testset <- read.table(testsetpath)
features <- read.table(featurespath)
trainactivity <- read.table(trainactivitypath)
testactivity <- read.table(testactivitypath)
activitylabels <- read.table(activitylabelspath)
trainsubjects <- read.table(trainsubjectspath)
testsubjects <- read.table(testsubjectspath)


## merging data
dataset <- rbind(trainset, testset) # merge data sets
# features first column provides ID number and second colunm provides names
# in current dataset first column is simply coincides with row number
# in more general case, if ID numbers are not sorted, first column must be used to map names correctly
names(dataset) <- features[, 2] # use second column from features as names for data set
activity <- rbind(trainactivity, testactivity) # merge activity sets
names(activity)[1] <- activityname # set single column name to name defined in input section
dataset <- cbind(activity, dataset) # supplemented activity to dataset (add activity column to the left)
subjects <- rbind(trainsubjects, testsubjects) # similar to activity
names(subjects)[1] <- subjectname # similar to activity
dataset <- cbind(subjects, dataset) # subjects added to the left (first column)


## extractind data
extractregexprinds <- grep(extractregexpr, names(dataset)) # use extractregexpr defined in input section for selection
activitynameind <- head(grep(activityname, names(dataset)), 1) # get (first) index for activityname
subjectnameind <- head(grep(subjectname, names(dataset)), 1) # get (first) index for subjectname
subsetinds <- c(subjectnameind, activitynameind, extractregexprinds) # complete set of indices for extraction
datasubset <- dataset[, subsetinds] # exctract data using indices vector


## name activities in data subset
activitynamesubind <- head(grep(activityname, names(datasubset)), 1) # get (first) index for activityname
# factor function used
# levels taken from first column of activitylabels (converted to characters)
# and labels from second column of activitylabels
datasubset[, activitynamesubind] <-
  factor(datasubset[, activitynamesubind],
         levels = as.character(activitylabels[, activitylevelsind]),
         labels = activitylabels[, activitylabelsind])

# descriptive variable names
for(ind in 1:nrow(renamedataframe)) {
  renamepattern <- renamedataframe[ind, 1] # get pattern
  renamereplacement <- renamedataframe[ind, 2] # get full name
  # use gsub to rename variables
  names(datasubset) <- gsub(pattern = renamepattern,
                            replacement = renamereplacement,
                            x = names(datasubset))
}


## create independent tidy dataset
# fomula by subjectname and activityname from input section
formulastring = paste(". ~ ", subjectname, " + ", activityname)
# mean of each variable for each activity and each subject
tidydataset <- aggregate(formula = as.formula(formulastring), data = datasubset, FUN = mean)
# define indices for subjectname and activityname
subjectnamesubind <- head(grep(subjectname, names(datasubset)), 1) # get (first) index for subjecname
activitynamesubind <- head(grep(activityname, names(datasubset)), 1) # get (first) index for activityname
# order by subject and then by activity to chek the data
tidydataset <- tidydataset[order(tidydataset[, subjectnamesubind],
                                 tidydataset[, activitynamesubind]),]
# save tidy data set with the file name and path defined in input section
write.table(tidydataset, file = tidydatasetpath, row.name = FALSE)

