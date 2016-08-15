library(data.table)
library(dplyr)
#1 - Merges the training and the test sets to create one data set.
xtrain <- fread(input = "UCI HAR Dataset/train/X_train.txt")
xtest <- fread(input = "UCI HAR Dataset/test/X_test.txt")

ytrain <- fread(input = "UCI HAR Dataset/train/y_train.txt")
ytest <- fread(input = "UCI HAR Dataset/test/y_test.txt")

subjecttrain <- fread(input = "UCI HAR Dataset/train/subject_train.txt")
subjecttest <- fread(input = "UCI HAR Dataset/test/subject_test.txt")

features <- fread(input = "UCI HAR Dataset/features.txt")
names(features) <- c("featureid", "featuredescription")

names(ytest) <- c("activitylabelid")
names(ytrain) <- c("activitylabelid")

names(subjecttest) <- c("subject")
names(subjecttrain) <- c("subject")


#Extracts only the measurements on the mean and standard deviation for each measurement.
#and improving the collumn names
features$featuredescription <- tolower(features$featuredescription)
features$featuredescription <- gsub(x = features$featuredescription, "(body)+", "Body")
features$featuredescription <- gsub(x = features$featuredescription, "acc", "Acceleration")
features$featuredescription <- gsub(x = features$featuredescription, "gyro", "Gyroscope")
features$featuredescription <- gsub(x = features$featuredescription, "mag", "Magnitude")
features$featuredescription <- gsub(x = features$featuredescription, "mean", "Mean")
features$featuredescription <- gsub(x = features$featuredescription, "std", "STD")
features$featuredescription <- gsub(x = features$featuredescription, "gravity", "Gravity")
features$featuredescription <- gsub(x = features$featuredescription, "jerk", "Jerk")
features$featuredescription <- gsub(x = features$featuredescription, "freq", "Frequency")
features$featuredescription <- gsub(x = features$featuredescription, "^f", "Frequency")
features$featuredescription <- gsub(x = features$featuredescription, "^t", "Time")

selectids <- features$featureid[grep("(Mean\\(|STD\\())", features$featuredescription)]
selectdes <- features$featuredescription[grep("(Mean\\(|STD\\())", features$featuredescription)]

xtrain <- subset(xtrain, select = selectids)
xtest <- subset(xtest, select = selectids)

names(xtrain) <- selectdes
names(xtest) <- selectdes

train <- cbind(xtrain, ytrain, subjecttrain)
test <- cbind(xtest, ytest, subjecttest)

#Merges the training and the test sets to create one data set.
total <- rbind(train, test)


#Uses descriptive activity names to name the activities in the data set
activitylabels <- fread(input = "UCI HAR Dataset/activity_labels.txt")
names(activitylabels) <- c("activitylabelid", "activitylabel")

#Merge all datatables
total <- merge(total, activitylabels, by.x = "activitylabelid", by.y = "activitylabelid")
names(total) <- gsub("\\(\\)", "", names(total))

#From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidyresult <- aggregate(total, by = list(ActivityLabel = total$activitylabel, Subject = total$subject), FUN = mean)
#Cleaning useless collumns
tidyresult$activitylabel <- NULL
tidyresult$activitylabelid <- NULL
tidyresult$subject <- NULL

View(tidyresult)
write.table(tidyresult, file = "tidyresult.txt", row.names = F)
