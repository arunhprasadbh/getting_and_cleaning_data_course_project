# create one R script called run_analysis.R that does the following. 
# 1.Merges the training and the test sets to create one data set.
# 2.Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3.Uses descriptive activity names to name the activities in the data set
# 4.Appropriately labels the data set with descriptive variable names. 
# 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# Install packages data.table and reshape2 if needed
if (!require("data.table")) {
  install.packages("data.table")
}

if (!require("reshape2")) {
  install.packages("reshape2")
}

require("data.table")
require("reshape2")


# Read Test Data

X_test <- read.table("test/X_test.txt")
y_test <- read.table("test/y_test.txt")
subject_test <- read.table("test/subject_test.txt")


# Read Train Data

X_train <- read.table("train/X_train.txt")
y_train <- read.table("train/y_train.txt")
subject_train <- read.table("train/subject_train.txt")

# read activity labels
activity_labels <- read.table("activity_labels.txt")[,2]

# read data column names
features <- read.table("features.txt")[,2]

# Get only the measurements on the mean and standard deviation for each measurement.
reqd_features <- grepl("mean|std", features)

#  Add labels to X_test data
names(X_test) = features
names(X_train) = features

# Extract only the measurements on the mean and standard deviation for each measurement.
X_test = X_test[,reqd_features]
X_train = X_train[,reqd_features]

# Add label name to label ids i.e. y_test and y_train
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Name")
y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Name")

# Add column name to subjects
names(subject_test) = "subject"
names(subject_train) = "subject"

# Bind test and train data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

# Now merge test data and train data
data = rbind(test_data, train_data)

#  Reshape  Data to using melt

id_labels   = c("subject", "Activity_ID", "Activity_Name")
data_labels = setdiff(colnames(data), id_labels)
melt_data      = melt(data, id = id_labels, measure.vars = data_labels)

# Create tidy data by applyig mean on melt data
tidy_data   = dcast(melt_data, subject + Activity_Name ~ variable, mean)

# Write Tidy data to file
write.table(tidy_data, file = "./tidy_data.txt", row.name=FALSE)


