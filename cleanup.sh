#!/bin/bash

# Step 1: Prompt user before deleting all files in the 'tmp' folder
read -p "Do you want to recursively delete all files in the 'tmp' folder? (y/n) " DELETE_TMP
if [[ $DELETE_TMP == "y" || $DELETE_TMP == "Y" ]]; then
    rm -rf tmp/*
    echo "Deleted all files in 'tmp' folder."
else
    echo "Skipping 'tmp' folder cleanup."
fi

# Step 2: Cleanup old IAM Users, access keys, and policies
if [[ ! -f config-log.txt ]]; then
    echo "config-log.txt not found. Exiting."
    exit 1
fi

# Assuming each set of IAM User, access keys, and policy are separated by "-----"
# Get the last entry (most recent set)
MOST_RECENT_ENTRY=$(awk '/-----/{x=NR} END{for(i=x; i<=NR; i++) print}' config-log.txt)

# Extract values from the most recent entry
MOST_RECENT_IAM_USER=$(echo "$MOST_RECENT_ENTRY" | grep "IAM User:" | cut -d' ' -f3)
MOST_RECENT_POLICY_ARN=$(echo "$MOST_RECENT_ENTRY" | grep "Policy ARN:" | cut -d' ' -f3)

# Go through the file and get a list of IAM users and policies, excluding the most recent ones
while IFS= read -r line; do
    if [[ $line == *"IAM User:"* && $line != *"$MOST_RECENT_IAM_USER"* ]]; then
        OLD_IAM_USER=$(echo $line | cut -d' ' -f3)
        read -p "Do you want to delete IAM User $OLD_IAM_USER? (y/n) " DELETE_IAM_USER
        if [[ $DELETE_IAM_USER == "y" || $DELETE_IAM_USER == "Y" ]]; then
            aws iam delete-user --user-name $OLD_IAM_USER
        fi
    fi

    if [[ $line == *"Policy ARN:"* && $line != *"$MOST_RECENT_POLICY_ARN"* ]]; then
        OLD_POLICY_ARN=$(echo $line | cut -d' ' -f3)
        read -p "Do you want to delete IAM Policy $OLD_POLICY_ARN? (y/n) " DELETE_POLICY
        if [[ $DELETE_POLICY == "y" || $DELETE_POLICY == "Y" ]]; then
            aws iam delete-policy --policy-arn $OLD_POLICY_ARN
        fi
    fi
done < config-log.txt

echo "Cleanup complete!"
