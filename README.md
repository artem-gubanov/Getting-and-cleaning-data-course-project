# Getting and cleaning data Coursera final course project
***

**Final project on Courser course "Getting and cleaning data"**  
_Created by Artem on September 16, 2016_

***

Scripts is written in sections to provide more readable structure.  
First section presents all input parameters (such as link, filenames, folders, directories, paths, etc.) in one place.  
Next sections analyze the data step by step, corresponding to the sections described below.  
Note: do not forget to change working directory to correct one before running this script.


## 1. Download data

### 1.1. Data original sourse
Here are the link to the data for the project:  
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

A full description is available at the site where the data was obtained:  
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The data represent data collected from the accelerometers from the Samsung Galaxy S smartphone.

### 1.2. Download and unpack original data
Script creates (if not exists):

* Folder named __"original_data"__ in current working directory 
* Sub-folder named by current system time (under "original_data" directory)
* Using date-like name serves two purposes: keeps info about date when file was downloaded and prevents existing data overwriting (running script at different date results in different data sets).

Script checks:

* If zip-archive file exists
* If overwrite parameter is set to TRUE (default value is FALSE, change to TRUE to overwrite existing files)
* Note: if overwrite parameter is set to TRUE, then script remove existing zip file and remove the sub-folder with all files. Use caution!

Script downloads and unpacks zip archive file:

* If there is no zip file OR overwrite is set to TRUE, then the zip file is downloaded using above web link. File name starts with the above sub-folder name (current date), following by __"\_dataset.zip"__
* Zip-archive is unpacked to the sub-folder (date format)
* Note: if script runs more than one time the same day (and rewriting set to FALSE), then it skips zip archive downloading and unpacking; it uses previously unpacked data

Successful downloading should result in data folder named "UCI HAR Dataset" with number of data files in it, including README.txt file explaining data folder content.


## 2. Read data

### 2.1. Data files for analysis (structure brief description)
First step of the analysis is to merge the training and the test sets to create one data set.

According to README.txt file:

* 'train/X_train.txt': Training set
* 'test/X_test.txt': Test set

These sets are to be merged.

* 'features.txt': List of all features.

These "features" are "column names" (like "tBodyAcc-mean()-X") for the above data sets. Detailed description is in "features_info.txt" file.

* 'train/y_train.txt': Training labels and  
* 'test/y_test.txt': Test labels.
* 'activity_labels.txt': Links the class labels with their activity name.

These are "activity" labels in numerical format (from 1 to 6) corresponding to data sets (i.e. each row contains activity label). Details on activity labels are in "activity_labels.txt" (like label "1"" means "WALKING"). There are 6 activity in total.

* 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.
* 'test/subject_test.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30.

These are "person" labels in numerical format (from 1 to 30) corresponding to data sets (i.e. each row contains activity label).

Note: only mentioned above files are used to construct tidy data set, all other files are not used in current analysis.

### 2.2. Read files
Features and activity labels are in the main data directory.
All other data files are located under sub-directory named "train" and "test" (as shown above).

Scripts defines all necessary names for data tables with corresponding file paths:

* trainset: trainsetpath
* testset: testsetpath
* features: featurespath
* trainactivity: trainactivitypath
* testactivity: testactivitypath
* activitylabels: activitylabelspath
* trainsubjects: trainsubjectspath
* testsubjects: testsubjectspath

Data files are tables in text files, so read.table() function is used to read data. Function default parameters are used.

Short description of loaded data:

* trainset has 7352 observations of 561 variables (numerical, V1 t0 V561)
* trainactivity corresponds to trainset (7352 obs. with one variable coding activity by numbers from 1 to 6)
* trainsubjects corresponds to trainset (7352 obs. with one variable coding person id number from 1 to 30)
* testset, testacivity, and testsubjects have same structure as train data set with 2947 obs.
* activitylabels has 6 obs. with two columns: first provides numerical number from 1 to 6, and second one maps them to string description of activity (like "WALKING")
* features has 561 obs. with 2 columns: first one shows number ID (1, 2, 3, and so on) and second one provides names which corresponds to data set variables (columns)


## 3. Merge data sets
There are many ways to create merged data set.  
Current analysis does this in following way:

* dataset is created by binding trainset and testset by rows (10299 obs. in total)
* features second column are used to set name for dataset
* activity is created by binding trainactivity and testactivity (similar to data set, 10299 obs.)
* activity single column name is set to activityname defined in input section ("activity" by default)
* activity is added to dataset (to the left), so dataset has 562 columns
* subjects is created and added to dataset similar to activity and added to dataset the same way as it was done with activities (i.e. it is first colunm)

Resulting dataset contains:

* all observation (train and test, 10299 in total)
* all original features (with corresponding features names for columns, 561)
* activity and subjects columns (named "activity" and "subjects")
* first column is "subjects", second column is "activity", following with the rest of variables

Total number of column-variables is 563.  
Note: **activitylabels** is not used for so far (will be used in project requirement #3).

Bottom-line: **dataset** is complete data set for the project requirement #1.


## 4. Extract required measurements
Only the measurements on the mean and standard deviation for each measurement are to be extracted.

According to description is in "features_info.txt" file, mean and standard deviation are performed on all signals (taking into account XYZ direction, it is 33 signals in total) and denoted by presence in feature name of:

* "mean()"" for mean value
* "std()"" for standard deviation

However, there is one more place the "mean" is used

* meanFreq(): Weighted average of the frequency components to obtain a mean frequency

I believe, some people would say I should include in to the extraction. I also strongly believe, that other people would say absolutely opposite thing.  
To break this issue, make all people happy and do not loose points, I introduced additional condition:

* excludemeanFreqflag = TRUE

It is defined in input section of the script. By default it is set to TRUE, which means "meanFreq()" won't be extracted.  
Please, change this flag to FALSE if you are strong about to include that "meanFreq()" into excracted data set.  
If so, please be advised that number of variables will be, obviously, greater than without "meanFreq()" but for the sake of my time, I'll provide explanation below following default conditions.

Note: "angle() variable" uses 'Mean' values, like "gravityMean" signal, but "angle() variable" is not a mean value itself, so all capital case "Mean" should be ignored (for example, "angle(tBodyGyroJerkMean,gravityMean)" feature should not be extracted).

As an example, first feature name "tBodyAcc-mean()-X" has "mean()" in its name which indicates that mean value of the signal "tBodyAcc" in "X" detection was calculated.

So, above patterns are used to extract data.
Function grep() is used to match above patterns in dataset names using regular expressions.  
Note: regular expression is defined in script input section.

From help topic in **"Regular Expressions as used in R"**:

* "backslashes need to be doubled when entering R character strings"
* "Two regular expressions may be joined by the infix operator |; the resulting regular expression matches any string matching either subexpression"

This means that to be able to pass "(" and ")" as characters, double backslashs must be used.

Complete regular expression used for in current analysis:

* "mean\\\\(\\\\)|std\\\\(\\\\)"

Note: no spaces are used in regular expression.

NOTE: in case the above mentioned excludemeanFreqflag is set to FALSE, the above complete regular expression is changed to:

* "mean|std\\\\(\\\\)"  
and results in exctracting "meanFreq()" feature.

As expected (by default settings, wihout "meanFreq()"), 66 features are meet the above requirement (33 signals for each of mean and std). The function grep() returns indices of the features with requirement met.

Last thing is to keep two more columns for activity and subjects (named "activity" and "subjects") for data extraction. This can be done in various ways. In present analysis, indices for names "activity" and "subjects" are looked in dataset names, and last index is chosen for each of the names (in the unlikely case that column names are not unique, those columns were added to the right end of dataset).

So, extracting data subset is done by using combination of the above indices.  
Result is stored in **datasubset** (10299 obs. by 68 columns).

Note: extraction can be made in different ways, for example, using names and/or subset() function.

Bottom-line: **datasubset** is extracted data set for the project requirement #2.


## 4. Name the activities in the data set
Column "activity" in datasubset represents activities by numerical values (from 1 to 6).  
As mentioned above, **activitylabels** maps numerical values (from 1 to 6) to string description (like "SITTING").  
This can be done by using factor() function.  
Factor levels should be taken from first column of activitylabels (and converted to characters), and labels - from activitylabels second column.

As a result, activity column in datasubset presented as factor with 6 descriptive activity name levels, which is the project requirement #3.


## 5. Label the data set with descriptive variable names
According to description is in "features_info.txt" file, following abbreviations are used:

* Acc: Accelerometer
* Gyro: Gyroscope
* t: Time
* f: Frequency
* Mag: Magnitude

The other abbreviations I personally suggest to replace:

* mean(): Mean
* std(): StandardDeviation
* meanFreq(): MEANFrequency (if set for extraction)
* -: ""

Note: most likely "()" in original data states for functions (i.e. helps to see difference between variables, names, nad functions). Also, each function has also dash symbol "-" in front of it (and components too: "-X", "-Y", "-Z"). So, the dash symbol "-" and parentheses "()" are toj be removed. To show that "meanFreq()" feature is a single function rather than combination of "Mean" and "Frequency" function/name, it is renamed into "MEANFrequency" feature (if applicable).

These abbreviations are to be replaced by their full names.  
Function gsub() can be used to find and substitute those abbreviations.
As usual, the abbreviations rename parameters are define in script input section (renamedataframe with renamepattern containing abbreviations and renamereplacement with corresponding full names).
This allows to rename abbreviations in a loop.  
Note: time "t" and frequency "f" have only one letter but they always appear in the beginning of the string. So, metacharacter caret "^" is used in front of them to point that.

Other names are:

* Body
* Gravity
* XYZ
* Jerk

These can be left untouched.

Here is the example on the replacement:

* "tBodyAcc-mean()-X" renamed into "TimeBodyAccelerometerMeanX"
* "tBodyAcc-std()-Y" renamed into "TimeBodyAccelerometerStandardDeviationY"

This section covers the project requirement #4.


## 6. Create independent tidy data set with the average of each variable for each activity and each subject
From the data set the project requirement #4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

There is a function aggregate() which computes summary statistics of Data Subsets (for class 'formula'):

* aggregate(formula, data, FUN, ..., subset, na.action = na.omit)

The following parameters should be used:

* formula: formula = . ~ subject + activity  
From help: "a formula, such as y ~ x" or "breaks ~ wool + tension" and "There are two special interpretations of . in a formula. The usual one is in the context of a data argument of model fitting functions and means 'all columns not otherwise in the formula'"  
So, dot notation "." means all colunms from data set, except "subject" and "activity"
* data: data = datasubset (data set for analysis)
* FUN: FUN = mean (as mean values are required, so mean FUNction should be applied)
* subset: optional, no need to specify as all data should be used
* na.action: by default is set to ignore NA values (no need to specify)

After that it makes sense to order new data set by subject and activity, so it can be easily readable (for example, first 6 rows corresponds to the first subject "1" and activities are listed the same order as in original file - not alphabetical as "WALKING" coded by "1", "WALKING_UPSTAIRS" by "2" and so on).

Finally, tidy data set is saved to "tidydataset.txt" file (with leading date in the name) in current directory (defined in input section in tidydatasetpath), for example:

* "2016-09-15-tidydataset.txt"

So, it is easy to see later to what initial data this file corresponds.  
Note: running script at different date (a day(s) apart) will dowload original data again, do analysis for that "new" data, and saves file with corresponding name. Sweet.


