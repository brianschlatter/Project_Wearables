if (!file.exists("wearable_data")) {
  dir.create("wearable_data")
}

if (!file.exists("./wearable_data/Dataset.zip")) {
  fileURL = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip?accessType=DOWNLOAD"
  download.file(fileURL, dest="./wearable_data/Dataset.zip", method="curl")
  unzip("./wearable_data/Dataset.zip", overwrite=FALSE, exdir="./wearable_data")
}


# Let's build a data frame with all of the data from the test set first.
# Read in the subject data
subj_test <- read.table("./wearable_data/UCI HAR Dataset/test/subject_test.txt", sep=" ", header=FALSE)
colnames(subj_test) <- "SubjectID"

# Now load the feature vector
features_test <- read.table("./wearable_data/UCI HAR Dataset/test/X_test.txt")
# Let's load the column labels as well for the feature vectors
feature_names <- read.table("./wearable_data/UCI HAR Dataset/features.txt", stringsAsFactors=FALSE)
colnames(features_test) <- feature_names[,"V2"]

# Now load the class label for the test set.
class_label_test <- read.table("./wearable_data/UCI HAR Dataset/test/y_test.txt", sep=" ", header=FALSE)
colnames(class_label_test) <- "ClassLabel"

test_set <- data.frame(subj_test, features_test, class_label_test)

# Let's build up the training data frame now.
# Read in the subject data
subj_train <- read.table("./wearable_data/UCI HAR Dataset/train/subject_train.txt", sep=" ", header=FALSE)
colnames(subj_train) <- "SubjectID"

# Now load the feature vector
features_train <- read.table("./wearable_data/UCI HAR Dataset/train/X_train.txt")
colnames(features_train) <- feature_names[,"V2"]

# Now load the class label for the train set.
class_label_train <- read.table("./wearable_data/UCI HAR Dataset/train/y_train.txt", sep=" ", header=FALSE)
colnames(class_label_train) <- "ClassLabel"

train_set <- data.frame(subj_train, features_train, class_label_train)

# Let's now combine the two data frames
all_data <- rbind(test_set, train_set)

# Let's only keep those features that are specific to mean()/Std()
all_col_names <- names(all_data)
col_matches <- grepl("mean|std", all_col_names)
# We want to keep the first column (subject ID) and the last column (class label) so let's explicitly set those to TRUE
col_matches[1] <- TRUE
col_matches[length(col_matches)] <- TRUE

# Now only keep those columns that are TRUE
subset_data <- all_data[,col_matches]


# Let's add a new column to show the friendly names for the class labels.
activity_labels <- read.table("./wearable_data/UCI HAR Dataset/activity_labels.txt", stringsAsFactors=FALSE)
subset_data$ClassLabelFriendly <- activity_labels[match(subset_data$ClassLabel, activity_labels[,1]), 2]


# Rename the column labels since they are a little strange. 
curColNames <- names(subset_data)
curColNames <- gsub("-mean()", "Mean", curColNames)
curColNames <- gsub("-std()", "Std", curColNames)
curColNames <- gsub("-X", "X", curColNames)
curColNames <- gsub("-Y", "Y", curColNames)
curColNames <- gsub("-Z", "Z", curColNames)
colnames(subset_data) <- curColNames


# Finally, create another data set that is the average value of each feature per subject, per activity
melted_data <- melt(subset_data, id.vars=c("SubjectID", "ClassLabelFriendly"))
averaged_tidy_data <- dcast(melted_data, SubjectID + ClassLabelFriendly ~ variable, fun.aggregate = mean, na.rm = TRUE)

# Write it to disk
write.table(averaged_tidy_date, file="./wearable_data/averaged_tidy_data.txt")
