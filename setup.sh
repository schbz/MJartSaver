#!/bin/bash

# Default Variables
DATE=$(date +%Y-%m-%d)
RANDOM_SUFFIX=$(head /dev/urandom | tr -dc a-z0-9 | head -c 5)
USERNAME="mjArtSaver-$DATE"
DEFAULT_BUCKET_NAME="mj-art-saves-$RANDOM_SUFFIX"
POLICY_NAME="mj-art-saver-S3Policy-$DATE"
REGION="us-east-1"
POLICY_FILE="s3_custom_policy.json"

# Create or check for .env file
[ -f .env ] || touch .env

# Create or check for config-log.txt file
[ -f config-log.txt ] || touch config-log.txt

# Create IAM User
echo "Creating IAM user..."
if ! aws iam create-user --user-name $USERNAME; then
    echo "Error creating IAM user. Exiting."
    exit 1
fi

# Create Access Keys for the User
echo "Generating access keys..."
ACCESS_KEY_INFO=$(aws iam create-access-key --user-name $USERNAME --query 'AccessKey.[AccessKeyId,SecretAccessKey]' --output text)
if [ -z "$ACCESS_KEY_INFO" ]; then
    echo "Error generating access keys for IAM user. Exiting."
    exit 1
fi
ACCESS_KEY_ID=$(echo $ACCESS_KEY_INFO | awk '{print $1}')
SECRET_ACCESS_KEY=$(echo $ACCESS_KEY_INFO | awk '{print $2}')
echo "IAM_USERNAME=$USERNAME" >> .env
echo "ACCESS_KEY_ID=$ACCESS_KEY_ID" >> .env
echo "SECRET_ACCESS_KEY=$SECRET_ACCESS_KEY" >> .env

# Prompt for Bot Token and Client ID
read -p "Please enter the bot token: " BOT_TOKEN
echo "BOT_TOKEN=$BOT_TOKEN" >> .env
read -p "Please enter the client ID: " CLIENT_ID
echo "CLIENT_ID=$CLIENT_ID" >> .env

# Prompt for S3 Bucket Name with Reminder and Default
read -p "Enter a name for the S3 bucket (remember AWS S3 bucket names must be globally unique, contain only lowercase letters, numbers, hyphens, and not formatted as IP addresses. Default is '$DEFAULT_BUCKET_NAME'): " BUCKET_NAME
BUCKET_NAME=${BUCKET_NAME:-$DEFAULT_BUCKET_NAME}

# Create S3 Bucket
echo "Creating S3 bucket in $REGION..."
if ! aws s3api create-bucket --bucket $BUCKET_NAME --region $REGION; then
    echo "Error creating S3 bucket. Exiting."
    exit 1

# Store the bucket name in the .env file
echo "S3_BUCKET_NAME=$BUCKET_NAME" >> .env


# Define S3 Custom Policy 
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
echo "$POLICY_JSON" > $POLICY_FILE

# Create IAM Policy
echo "Creating IAM policy..."
if ! POLICY_ARN=$(aws iam create-policy --policy-name $POLICY_NAME --policy-document file://$POLICY_FILE --query "Policy.Arn" --output text); then
    echo "Error creating IAM policy. Exiting."
    rm $POLICY_FILE
    exit 1
fi

# Attach Policy to User
echo "Attaching policy to user..."
if ! aws iam attach-user-policy --policy-arn "$POLICY_ARN" --user-name $USERNAME; then
    echo "Error attaching policy to user. Exiting."
    rm $POLICY_FILE
    exit 1
fi

# Append to config-log.txt
echo "Date: $DATE" >> config-log.txt
echo "IAM User: $USERNAME" >> config-log.txt
echo "Access Key ID: $ACCESS_KEY_ID" >> config-log.txt
echo "Bot Token: $BOT_TOKEN" >> config-log.txt
echo "Client ID: $CLIENT_ID" >> config-log.txt
echo "Bucket Name: $BUCKET_NAME" >> config-log.txt
echo "Policy ARN: $POLICY_ARN" >> config-log.txt
echo "Region: $REGION" >> config-log.txt
echo "------------------------" >> config-log.txt

# Cleanup - Remove the temporary policy file
rm $POLICY_FILE

echo "Setup complete!"
