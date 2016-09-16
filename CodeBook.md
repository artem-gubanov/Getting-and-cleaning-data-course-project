# Codebook

***

**Final project on Courser course "Getting and cleaning data"**  
_Created by Artem on September 16, 2016_

***

## 1. Data original sourse
Here are the link to the data for the project:  
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

A full description is available at the site where the data was obtained:  
http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

The data represent data collected from the accelerometers from the Samsung Galaxy S smartphone.


## 2. Original data set description (variables, features, etc.)

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz.

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag).

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals).

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

tBodyAcc-XYZ  
tGravityAcc-XYZ  
tBodyAccJerk-XYZ  
tBodyGyro-XYZ  
tBodyGyroJerk-XYZ  
tBodyAccMag  
tGravityAccMag  
tBodyAccJerkMag  
tBodyGyroMag  
tBodyGyroJerkMag  
fBodyAcc-XYZ  
fBodyAccJerk-XYZ  
fBodyGyro-XYZ  
fBodyAccMag  
fBodyAccJerkMag  
fBodyGyroMag  
fBodyGyroJerkMag  

The set of variables that were estimated from these signals are: 

mean(): Mean value  
std(): Standard deviation  
mad(): Median absolute deviation  
max(): Largest value in array  
min(): Smallest value in array  
sma(): Signal magnitude area  
energy(): Energy measure. Sum of the squares divided by the number of values.  
iqr(): Interquartile range  
entropy(): Signal entropy  
arCoeff(): Autorregresion coefficients with Burg order equal to 4  
correlation(): correlation coefficient between two signals  
maxInds(): index of the frequency component with largest magnitude  
meanFreq(): Weighted average of the frequency components to obtain a mean frequency  
skewness(): skewness of the frequency domain signal  
kurtosis(): kurtosis of the frequency domain signal  
bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.  
angle(): Angle between to vectors.  

Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:

gravityMean  
tBodyAccMean  
tBodyAccJerkMean  
tBodyGyroMean  
tBodyGyroJerkMean  


## 3. Transformation of original data sets into new tidy data set

### 3.1. List of data files for analysis and merged data set structure
The only following original files are used to construct a new tidy data set (all other files are not used in current analysis):

* 'train/X_train.txt': Training set
* 'test/X_test.txt': Test set
* 'features.txt': List of all features
* 'train/y_train.txt': Training labels
* 'test/y_test.txt': Test label
* 'activity_labels.txt': Links the class labels with their activity name (like "1" is means "WAKING")
* 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample (range is from 1 to 30)
* 'test/subject_test.txt': Each row identifies the subject who performed the activity for each window sample (range is from 1 to 30)

First step was to combine above data sets into new common data set (except activity_labels.txt) in the following way:

| "Subject"         | "Activity"  | features.txt |
|-------------------|-------------|--------------|
| subject_train.txt | y_train.txt | X_train.txt  |
| subject_test.txt  | y_test.txt  | X_test.txt   |

The first two columns were assigned new names "Subject" and "Activity", respectively.


### 3.2. Extracts measurements on the mean and standard deviation only
The second step was to extracts only the measurements on the mean and standard deviation for each measurement. Measurements are presented in 'features', for example:

* feature name 'tBodyAcc-mean()-X' means "mean value" of "tBodyAcc" signal in "X" direction

So, the features (measurements) containing the following:

* "mean()"" for mean value
* "std()"" for standard deviation

are extracted into data set.

However, there is one more place the "mean" word can be found in original data:

* meanFreq(): Weighted average of the frequency components to obtain a mean frequency

I believe, some people would say I should include in to the extraction. I also strongly believe, that other people would say absolutely opposite thing.  
To break this issue, make all people happy and do not loose points, I introduced additional condition in my script:

* excludemeanFreqflag = TRUE

It is defined in input section of the script. By default it is set to TRUE, which means "meanFreq()" won't be extracted.  
One can change it to FALSE and, consequently, change CodeBook.
For the sake of my time, I'll provide explanation below following this default condition (not including "meanFreq()" into extracted data set).


### 3.3. Name activities in data subset
The third step is to map "Activity" numeric codes (1 to 6, from y_train.txt and y_test.txt in second "Activity" column) to their string equivalent which is provided in "activity_labels.txt" file.  
So, the second "Activity" column is converted into factor with following levels:

* WALKING
* WALKING_UPSTAIRS
* WALKING_DOWNSTAIRS
* SITTING
* STANDING
* LAYING

### 3.3. Descriptive variable names
The next step is to rename all feature (measurement) names into clear descriptive ones.

The following abbreviations are replaced by their full names:

* Acc: Accelerometer
* Gyro: Gyroscope
* t: Time
* f: Frequency
* Mag: Magnitude

Also, additional abbreviations was replaced:

* mean(): Mean
* std(): StandardDeviation
* meanFreq(): MEANFrequency (if it was set for extraction)
* -: ""

Please note that all "()" and "-" occurances are removed (these special symbols should not be used in tidy data set names).  
Please also note that to show the "meanFreq()" feature is a single function rather than combination of "Mean" and "Frequency" function/name, it is renamed into "MEANFrequency" feature (if applicable).

Other names:

* Body
* Gravity
* XYZ
* Jerk

are kept untouched.

Here is the example on the described above replacement:

* "tBodyAcc-mean()-X" renamed into "TimeBodyAccelerometerMeanX"
* "tBodyAcc-std()-Y" renamed into "TimeBodyAccelerometerStandardDeviationY"

The full list of names are in the header of the new tidy data set.


### 3.4. Create independent tidy data set with the average of each variable for each activity and each subject

Mean of each variable for each activity and each subject is calculated using aggregate() function with formula notation: mean function was applied to all colums, except subject and activity, keeping them grouped by subject and activity.  
Then the new data set is ordered by subject and by activity.

Here is a few first rows and columns of the tidy data set:

    Subject           Activity TimeBodyAccelerometerMeanX TimeBodyAccelerometerMeanY
          1            WALKING                  0.2773308               -0.017383819
          1   WALKING_UPSTAIRS                  0.2554617               -0.023953149
          1 WALKING_DOWNSTAIRS                  0.2891883               -0.009918505
          1            SITTING                  0.2612376               -0.001308288
          1           STANDING                  0.2789176               -0.016137590
          1             LAYING                  0.2215982               -0.040513953
          2            WALKING                  0.2764266               -0.018594920
          2   WALKING_UPSTAIRS                  0.2471648               -0.021412113

One can see, for example, that first 6 rows corresponds to the first subject "1" (there are 30 subjects-people in the data set from 1 to 30) and activities are listed the same order as in original file - not in alphabetical order but as it was coded by numbers (i.e. "WALKING" is coded by "1", "WALKING_UPSTAIRS" by "2" and so on). Then the second subject "2" data block is provided and so on. Third and the rest columns represent measurements with proper names.  


Finally, tidy data set is saved to "tidydataset.txt" file (with leading date in the name) in current directory (defined in input section in script), for example:

* "2016-09-16-tidydataset.txt"


