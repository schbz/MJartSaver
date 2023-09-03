#!/bin/bash

# Initialize log file
LOG_FILE="config-log.txt"
echo "Date: $(date)" >> $LOG_FILE

# Function to get user input for certificate settings
get_certificate_settings() {
  read -p "Enter the domain name (e.g., www.example.com): " DOMAIN_NAME
  echo "Domain Name: $DOMAIN_NAME" >> $LOG_FILE
  read -p "Enter validation method [EMAIL|DNS]: " VALIDATION_METHOD
  echo "Validation Method: $VALIDATION_METHOD" >> $LOG_FILE
}

# Function to get user input for CloudFront settings
get_cloudfront_settings() {
  read -p "Enter CloudFront price class [PriceClass_All|PriceClass_200|PriceClass_100]: " PRICE_CLASS
  echo "CloudFront Price Class: $PRICE_CLASS" >> $LOG_FILE
  read -p "Enable logging? [yes|no]: " ENABLE_LOGGING
  echo "Enable Logging: $ENABLE_LOGGING" >> $LOG_FILE
}

# Check if a bucket is specified
if [ -z "$1" ]; then
  echo "Fetching list of S3 buckets..."
  aws s3 ls
  read -p "Enter the name of the S3 bucket you want to use: " S3_BUCKET
else
  S3_BUCKET=$1
fi
echo "Bucket Name: $S3_BUCKET" >> $LOG_FILE

# List the paths in the bucket and ask the user to select one
S3_PATHS=$(aws s3 ls s3://$S3_BUCKET/ --recursive | awk '{print $4}')
echo "Paths available in bucket:"
echo $S3_PATHS
read -p "Select one of the above paths or leave empty to use the entire bucket: " S3_PATH_SELECTED
echo "Selected Path: $S3_PATH_SELECTED" >> $LOG_FILE

# Create a certificate for HTTPS
echo "Creating an ACM certificate for HTTPS..."
get_certificate_settings
CERTIFICATE_ARN=$(aws acm request-certificate \
  --domain-name $DOMAIN_NAME \
  --validation-method $VALIDATION_METHOD \
  --output json | jq -r '.CertificateArn')
echo "Certificate ARN: $CERTIFICATE_ARN" >> $LOG_FILE

# Get CloudFront settings
echo "Setting up CloudFront..."
get_cloudfront_settings

# Create JSON config file for CloudFront
cat > cloudfront_config.json <<- EOM
{
  "CallerReference": "CloudFront-${S3_BUCKET}",
  "Origins": {
    "Items": [
      {
        "Id": "${S3_BUCKET}",
        "DomainName": "${S3_BUCKET}.s3.amazonaws.com",
        "OriginPath": "${S3_PATH_SELECTED}",
        "S3OriginConfig": {}
      }
    ],
    "Quantity": 1
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "${S3_BUCKET}",
    "ViewerProtocolPolicy": "redirect-to-https",
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    },
    "TrustedSigners": {
      "Enabled": false,
      "Quantity": 0
    }
  },
  "PriceClass": "${PRICE_CLASS}",
  "ViewerCertificate": {
    "ACMCertificateArn": "${CERTIFICATE_ARN}",
    "SSLSupportMethod": "sni-only"
  },
  "Logging": {
    "Enabled": ${ENABLE_LOGGING},
    "IncludeCookies": false,
    "Bucket": "${S3_BUCKET}.s3.amazonaws.com",
    "Prefix": "logs"
  }
}
EOM

# Create CloudFront distribution
DISTRIBUTION=$(aws cloudfront create-distribution --distribution-config file://cloudfront_config.json)
DISTRIBUTION_ID=$(echo $DISTRIBUTION | jq -r '.Distribution.Id')
echo "CloudFront Distribution ID: $DISTRIBUTION_ID" >> $LOG_FILE

# Clean up
rm cloudfront_config.json

# Finalize log file
echo "------------------------" >> $LOG_FILE
