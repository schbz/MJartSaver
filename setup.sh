#!/bin/bash

# Variables
DATE=$(date +%Y-%m-%d)
USERNAME="mjArtSaver1"
BUCKET_NAME="mj-art-saves-$DATE"
POLICY_NAME="mj-art-saver-S3Policy-$Date"
REGION="us-east-1"
POLICY_FILE="s3_custom_policy.json"

# Create IAM User
echo "Creating IAM user..."
aws iam create-user --user-name $USERNAME

# Create Access Keys for the User
echo "Generating access keys..."
aws iam create-access-key --user-name $USERNAME

# Create S3 Bucket
echo "Creating S3 bucket in $REGION..."
aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION

# Define S3 Custom Policy (Assuming you've already defined this in s3_custom_policy.json)
POLICY_JSON=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::$BUCKET_NAME",
                "arn:aws:s3:::$BUCKET_NAME/*"
            ]
        }
    ]
}
EOF
)
echo $POLICY_JSON > $POLICY_FILE

# Create IAM Policy
echo "Creating IAM policy..."
POLICY_ARN=$(aws iam create-policy --policy-name $POLICY_NAME --policy-document file://$POLICY_FILE --query "Policy.Arn" --output text)

# Attach Policy to User
echo "Attaching policy to user..."
aws iam attach-user-policy --policy-arn $POLICY_ARN --user-name $USERNAME

# Cleanup - Remove the temporary policy file
rm $POLICY_FILE

echo "Setup complete!"
