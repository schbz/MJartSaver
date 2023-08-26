# Midjourney Art Saver Bot

This bot is designed to interact with users on Discord, allowing them to upload images to an S3 bucket on AWS. It also includes various commands for configuration and can respond to messages from another bot, known as "midjourney bot."

## Features

- Upload images to an S3 bucket.
- Configure S3 bucket and path.
- Set image metadata.
- Prompt users to upload the last image after interacting with the midjourney bot.

## Prerequisites

- Python 3.6 or higher
- Discord Developer Account
- AWS Account with S3 access

## Installation

### Clone the Repository

```
    git clone https://github.com/your-username/your-repo-name.git
    cd your-repo-name
```

Install Dependencies

```
pip install discord.py boto3
```

## Configuration

Discord Bot Token

Create a bot user in the Discord Developer Portal and obtain the bot token.
Add your bot token value to the 'config.py' file


### AWS Credentials

Set up AWS credentials for S3 access, either by configuring them locally or using the !config_aws command within the bot.

### Intents and Permissions

Enable the necessary intents in the Discord Developer Portal, and set the appropriate permissions when inviting the bot to your server.

### Running the Bot Locally

```
python bot.py
```

### Inviting the Bot to Your Server

Create an invite URL using your bot's client ID:

```
https://discord.com/oauth2/authorize?client_id=YOUR_CLIENT_ID_HERE&scope=bot&permissions=YOUR_PERMISSIONS_INTEGER
https://discord.com/api/oauth2/authorize?client_id=1144616319908585654&permissions=2147585024&scope=bot%20applications.commands
```

Replace YOUR_CLIENT_ID_HERE and YOUR_PERMISSIONS_INTEGER with appropriate values.

## Usage

    !set_bucket <bucket_name> <path>: Set the S3 bucket and path.
    !set_metadata <key> <value>: Set metadata for an image.
    Interaction with Midjourney bot: Prompts to upload the last image.

## Contributing

If you'd like to contribute to this project, please fork the repository and submit a pull request.
License

This project is licensed under the MIT License - see the LICENSE.md file for details.
Support

If you encounter any issues or have questions, please open an issue on GitHub.
