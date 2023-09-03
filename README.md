# Midjourney Art Saver Bot

---

<p align="center">
  <a target="_blank" rel="noopener noreferrer nofollow" href="https://raw.githubusercontent.com/schbz/MJartSaver/main/assets/mjartsaverLogo.webp"><img src="https://raw.githubusercontent.com/schbz/MJartSaver/main/assets/mjartsaverLogo.png" alt="Logo" width="140" height="140" style="border-radius: 50%;"></a>
</p>
A customizable Discord bot that streamlines the uploading of Midjourney generative AI images to secure AWS S3 buckets 
<br>
<br>
<p align="center">
    <a href="https://www.python.org/downloads/release/python-311/">
        <img src="https://img.shields.io/badge/python-3.1-blue.svg" alt="Python Version">
    </a>
    <a href="https://opensource.org/licenses/MIT">
        <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT">
    </a>
    <a href="https://github.com/schbz/mjartsaver/issues">
        <img src="https://img.shields.io/github/issues/schbz/mjartsaver.svg" alt="Issues">
    </a>
    <a href="https://makeapullrequest.com">
        <img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" alt="PRs Welcome">
    </a>
</p>

---

This bot is designed to interact with Midjourney generative AI users on Discord, allowing them to upload image files to their secure S3 buckets on AWS. It also includes various commands for configuration and can respond to messages from the standard "Midjourney Bot."

## Table of Contents

- [Midjourney Art Saver Bot](#midjourney-art-saver-bot)
  - [Table of Contents](#table-of-contents)
  - [Usage Examples](#usage-examples)
  - [Features](#features)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
    - [Clone the Repository](#clone-the-repository)
  - [Configuration](#configuration)
    - [Discord Bot Token](#discord-bot-token)
    - [Setup Script](#setup-script)
      - [Setup Script Prerequisites and Usage](#setup-script-prerequisites-and-usage)
      - [Setup Script Features](#setup-script-features)
    - [Intents and Permissions](#intents-and-permissions)
    - [Running the Bot Locally](#running-the-bot-locally)
    - [Inviting the Bot to Your Server](#inviting-the-bot-to-your-server)
  - [Usage](#usage)
    - [Command List](#command-list)
    - [Cleanup Script](#cleanup-script)
      - [Cleanup Script Prerequisites and Usage](#cleanup-script-prerequisites-and-usage)
      - [Cleanup Script Features](#cleanup-script-features)
  - [Contributing](#contributing)
  - [License](#license)
  - [Support](#support)

## Usage Examples

- Link your specified S3 bucket/path to other AWS services like S3 static web hosting or Cloudfront distributions to allow for streamlined collaborative updating of website media and more with the latest in generative art.

## Features

- Upload your Midjourney art to a secure S3 bucket with one click.
- customize S3 bucket and path.
- customize image metadata.
- Automatically prompt users to upload each image posted with the push of a button.
- Retrieve Previously saved images from S3.

## Prerequisites

- Python 3.1 or higher
- Discord Developer Account
- AWS Account with S3 access

## Installation

### Clone the Repository

```
    git clone https://github.com/schbz/mjartsaver.git
    cd schbz/mjartsaver
```

Install Dependencies

```
pip install discord.py boto3 aiohttp python-dotenv
```

## Configuration

### Discord Bot Token

Register a bot Application in the Discord Developer Portal and obtain the bot token.

### Setup Script

`setup.sh`

This script automates several tasks required for interacting with your S3 file hosting accounts, specifically creating an IAM user, generating access keys for the user, creating an S3 bucket, and applying a custom policy for S3 access.

##### Setup Script Prerequisites and Usage

Make sure you have [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed on your computer and logged in with an administrator account that has sufficient permissions.

Simply run the script in your shell:

1. Give the script execution permissions and run:

```bash
chmod +x setup.sh
./setup.sh
```

##### Setup Script Features

1. **Default Variable Setup**

   - Gets the current date and a random suffix to generate unique naming conventions.
   - Specifies default names for an IAM user, an S3 bucket, and an IAM policy.
   - Prepares a custom S3 policy filename.

2. **Environment Files Creation**

   - Checks for and, if needed, creates `.env` and `config-log.txt` files.

3. **IAM User Creation**

   - Creates an IAM user with the generated name.

4. **Access Key Generation**

   - Generates access keys for the created IAM user.
   - Saves access key details in the `.env` file.

5. **Bot Credentials Prompt**

   - Prompts the user to input the bot token and client ID, which are also saved in the `.env` file.

6. **S3 Bucket Creation**

   - Allows the user to name the S3 bucket (with a default naming option provided).
   - Creates an S3 bucket with the given or default name.

7. **S3 Custom Policy Definition and Creation**

   - Defines a custom policy for S3 actions (`PutObject`, `GetObject`, `ListBucket`).
   - Creates the IAM policy using the defined JSON.
   - Attaches the created policy to the IAM user.

8. **Configuration Log Update**

   - Appends all key configuration details to the `config-log.txt` file.

9. **Cleanup**

   - Removes the temporary policy file.

10. **Completion Message**
    Prints a "Setup complete!" message to indicate the successful execution of the script.

### Intents and Permissions

Enable the necessary intents in the Discord Developer Portal, and set the appropriate permissions when inviting the bot to your server.

### Running the Bot Locally

```bash
python bot.py
```

### Inviting the Bot to Your Server

Create an invite URL using your bot's client ID:

```bash
https://discord.com/api/oauth2/authorize?client_id=[YOUR_CLIENT_ID_HERE]&permissions=101376&scope=bot
```

Replace YOUR_CLIENT_ID_HERE with the appropriate value obtained from Discord Developer Portal.

## Usage

Simply enter the above invite into your browser to add the running bot to your personal server where a Midjourney bot has already been added.

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

### Cleanup Script

`cleanup.sh`

This shell script facilitates the cleanup process for an AWS-based environment, ensuring the safe deletion of temporary files and old IAM users and policies.

#### Cleanup Script Prerequisites and Usage

- AWS Command Line Interface (CLI) properly installed and configured.
- User must have appropriate permissions to delete IAM users and policies.
- Presence of `config-log.txt`, which keeps track of created IAM users and policies.

1. Give the script execution permissions and run:

```bash
chmod +x cleanup.sh
./cleanup.sh
```

#### Cleanup Script Features

1. **Temporary Files Cleanup**

   - Prompts the user for confirmation before deleting all files within the `tmp` directory.
   - Deletes the contents of the `tmp` directory upon confirmation.

2. **Old AWS IAM Users and Policies Cleanup**

   - Verifies the existence of `config-log.txt` before continuing.
   - Extracts the most recent IAM user and policy ARN details from `config-log.txt`.
   - Iteratively checks for older IAM user and policy entries in `config-log.txt`.
   - Prompts the user for confirmation before deleting each old IAM user and policy.

3. **Completion Message**
   - Informs the user that the cleanup process is complete.

## Contributing

If you'd like to contribute to this project, please fork the repository and submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions, please open an [issue on Github](https://github.com/schbz/mjartsaver/issues).
