# Midjourney Art Saver Bot

<p align="center">
  <img src="https://raw.githubusercontent.com/schbz/MJartSaver/main/assets/mjartsaverLogo.png" alt="Logo" width="100" height="100">
</p>

This bot is designed to interact with Midjourney generative AI bot users on Discord, allowing them to upload images to their secure S3 buckets on AWS. It also includes various commands for configuration and can respond to messages from the standard "Midjourney Bot."
Link your specified S3 bucket/path to other AWS services like S3 static web hosting or Cloudfront to allow for streamlined collaborative updating of website media and more with the latest in generative art.

## Features

- Upload your Midjourney art to a secure S3 bucket.
- Customize S3 bucket and path.
- Set image metadata.
- Automatically prompts users to upload each image posted with the push of a button.
- Retrieve Previously saved art from S3.

## Prerequisites

- Python 3.6 or higher
- Discord Developer Account
- AWS Account with S3 access

## Installation

### Clone the Repository

```
    git clone https://github.com/schbz/mjartsaver.git
    cd mjartsaver
```

Install Dependencies

```
pip install discord.py boto3 aiohttp python-dotenv
```

## Configuration

### Discord Bot Token

Register a bot Application in the Discord Developer Portal and obtain the bot token.
Add your bot token value to the 'config.py' file

### AWS Credentials

Set up AWS credentials for S3 access, either by configuring them locally or using the !config_aws command within the bot.

### Setup Script

##### AWS Script for User and S3 Bucket Creation with Custom IAM Policy

This script automates several tasks related to Amazon Web Services (AWS) specifically for creating an IAM user, generating access keys for the user, creating an S3 bucket, and applying a custom policy for S3 access.

##### Features

1. **Variable Definition**: The script begins by defining several key variables that will be used throughout:

   - `DATE`: Gets the current date in the format `YYYY-MM-DD`.
   - `USERNAME`: Defines a specific IAM username, `mjArtSaver1`.
   - `BUCKET_NAME`: Creates a dynamic S3 bucket name based on the date.
   - `POLICY_NAME`: Names the IAM policy.
   - `REGION`: Sets the AWS region to `us-east-1`.
   - `POLICY_FILE`: Sets the filename for the custom policy, `s3_custom_policy.json`.

2. **IAM User Creation**: The script creates an IAM user with the defined `USERNAME`.

3. **Access Key Generation**: Immediately after creating the user, it generates access keys for them.

4. **S3 Bucket Creation**: The script creates an S3 bucket in the defined region with the dynamically generated name.

5. **IAM Policy Definition**:

   - A custom policy is created which allows the user to put objects (`s3:PutObject`), get objects (`s3:GetObject`), and list objects in the bucket (`s3:ListBucket`).
   - The policy specifically targets the newly created bucket and all of its contents.
   - This policy is then saved to a temporary `.json` file.

6. **IAM Policy Creation and Attachment**:

   - The custom policy is then officially created within AWS using the IAM service.
   - After creation, it is attached to the previously defined user, granting them the defined permissions on the S3 bucket.

7. **Cleanup**: To keep things tidy, the script deletes the temporary policy file after it's no longer needed.

8. **Completion Message**: Finally, a message "Setup complete!" is printed to the console indicating successful execution of the script.

##### Usage

Ensure you have the [AWS Command Line Interface (CLI)](https://aws.amazon.com/cli/) installed and correctly configured with the necessary access rights.

Simply run the script in your shell:

```bash
chmod +x setup.sh
./setup.sh
```

**Note**: Modify the script variables as needed to fit your specific use case or naming convention. Always ensure you're following AWS best practices for security and resource management.

### Intents and Permissions

Enable the necessary intents in the Discord Developer Portal, and set the appropriate permissions when inviting the bot to your server.

### Running the Bot Locally

```
python bot.py
```

### Inviting the Bot to Your Server

Create an invite URL using your bot's client ID:

```
https://discord.com/api/oauth2/authorize?client_id=YOUR_CLIENT_ID_HERE4&permissions=2147585024&scope=bot%20applications.commands
```

Replace YOUR_CLIENT_ID_HERE and YOUR_PERMISSIONS_INTEGER with appropriate values.

## Usage

Simply use the above invite to add your locally hosted bot to your personal server along with the Midjourney Bot

### Command List

Below is a list of available commands and their descriptions:

- **`bucket`**

  - Display the current S3 bucket and path (if available).
  - Usage: `!bucket`

- **`list_images`**

  - List all images in the S3 bucket (or specific path if set).
  - Usage: `!list_images`

- **`set_path`**

  - Set the S3 path.
  - Usage: `!set_path <path>`

- **`help`**

  - Displays a list of commands for mjartsaver bot.
  - Usage: `!help`

- **`upload`**

  - Upload an image to the S3 bucket. Drag and drop the image and optionally provide a name.
  - Usage: `!upload <optional_name>`

- **`path`**

  - Display the current S3 path (if available).
  - Usage: `!path`

- **`set_metadata`**

  - Set default metadata values for uploaded files.
  - Usage: `!set_metadata <key> <value>`

- **`set_bucket`**

  - Set the S3 bucket and optionally the path.
  - Usage: `!set_bucket <bucket_name> [path]`

- **`config`**

  - Display current config settings for the mjartsaver bot.
  - Usage: `!config`

- **`set_aws`**

  - Set AWS credentials.
  - Usage: `!set_aws <access_key_id> <secret_access_key>`

- **`get_image`**
  - Choose an image from the current location to download.
  - Usage: `!get_image <filename>`

Each command typically begins with a `!` prefix, followed by the command name and any applicable arguments. Please refer to the provided usages for details on how to use each command.

## Contributing

If you'd like to contribute to this project, please fork the repository and submit a pull request.
License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues or have questions, please open an issue on GitHub.
