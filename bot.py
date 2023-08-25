from config import BOT_TOKEN, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
import os
import boto3
import discord
from discord.ext import commands
from discord.ui import Button, View
from discord import Embed
from datetime import datetime
import aiohttp
from io import BytesIO

# Constants
MIDJOURNEY_BOT_ID = "None"  # Replace with the actual bot's user ID

# AWS S3 Configuration
s3_client = boto3.client('s3', aws_access_key_id=AWS_ACCESS_KEY_ID, aws_secret_access_key=AWS_SECRET_ACCESS_KEY)
s3_bucket = 'mj-art-saves-2023-08-25'
s3_path = ''
image_metadata = {}

intents = discord.Intents.default()
intents.message_content = True
intents.messages = True
intents.members = True

async def stream_to_s3(url, s3_full_path):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as response:
            # Check if the request was successful
            if response.status != 200:
                raise ValueError(f"Failed to fetch image from {url}. Status: {response.status}")

            # Convert bytes to a file-like object using BytesIO
            fileobj = BytesIO(await response.read())

            # Stream data directly to S3
            s3_client.upload_fileobj(fileobj, s3_bucket, s3_full_path, ExtraArgs={'Metadata': image_metadata})

# Custom Help Command
class CustomHelpCommand(commands.HelpCommand):
    async def send_bot_help(self, mapping):
        embed = Embed(title="Help", description="List of commands:")
        for command in self.context.bot.commands:
            embed.add_field(name=f'{command.name}', value=command.help or "No description provided.", inline=False)
        await self.get_destination().send(embed=embed)


# Bot Class
class MyBot(commands.Bot):
    async def on_ready(self):
        global MIDJOURNEY_BOT_ID
        # Iterate through all guilds the bot is a member of
        for guild in self.guilds:
            # Iterate through all members in the guild
            for member in guild.members:
                # Check if the member is a bot and has "midjourney" in their name
                if member.bot and "midjourney" in member.name.lower():
                    MIDJOURNEY_BOT_ID = member.id
                    break

            # Break the outer loop if the bot ID is found
            if MIDJOURNEY_BOT_ID != "None":
                break
        
        print(f'{self.user} has connected to Discord! Midjourney Bot ID: {MIDJOURNEY_BOT_ID}')


    async def on_message(self, message):
        if message.author.id == MIDJOURNEY_BOT_ID and any(att.content_type.startswith('image/') for att in message.attachments):
            await self.handle_midjourney_bot_message(message)
        await super().on_message(message)

    async def handle_midjourney_bot_message(self, message):
        view = UploadView()
        await message.channel.send('Would you like to upload the last image?', view=view)



bot = MyBot(command_prefix='!', help_command=CustomHelpCommand(), intents=intents)




# Upload View
class UploadView(View):
    @discord.ui.button(label='Upload Last Image', style=discord.ButtonStyle.primary)
    async def upload_button(self, button: discord.ui.Button, interaction: discord.Interaction):
        channel = interaction.channel
        last_image = None
        async for message in channel.history(limit=10):  # Search the last 10 messages
            if message.attachments:
                last_image = message.attachments[0]
                break

        if last_image:
            file_path = f'/tmp/{last_image.filename}'
            await last_image.save(file_path)
            s3_client.upload_file(file_path, s3_bucket, f'{s3_path}/{last_image.filename}', ExtraArgs={'Metadata': image_metadata})
            await interaction.followup.send('Image uploaded!')
        else:
            await interaction.followup.send('No recent image found.')


@bot.command(name='upload', help='Upload an image to the S3 bucket. Drag and drop the image and optionally provide a name. Usage: !upload <optional_name>')
async def upload(ctx, image_name_or_link: str = None):
    # Check if bucket is set
    if not s3_bucket:
        await ctx.send('Please set the S3 bucket first using !set_bucket')
        return
    
    # If a link is provided
    if image_name_or_link and image_name_or_link.startswith(('http://', 'https://')):
        try:
            # Generate a filename based on current time
            current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
            # Assuming .jpg extension for simplicity; can be enhanced
            image_name = f'{current_time}.jpg'
            s3_full_path = os.path.join(s3_path, image_name)
            await stream_to_s3(image_name_or_link, s3_full_path)
            await ctx.send(f'Image uploaded as {s3_full_path} in the bucket {s3_bucket}!')
        except Exception as e:
            await ctx.send(f'Error uploading the image: {str(e)}')
            return

    # If an attachment is present in the message
    elif ctx.message.attachments:
        attachment = ctx.message.attachments[0]
        # Generate a filename if none is provided
        if image_name_or_link is None:
            current_time = datetime.now().strftime('%Y%m%d_%H%M%S')
            file_extension = os.path.splitext(attachment.filename)[1]  # Extract extension from the original filename
            image_name_or_link = f"{current_time}{file_extension}"
        file_path = f'{image_name_or_link}'
        await attachment.save(file_path)
        
        # Upload to S3
        try:
            s3_full_path = os.path.join(s3_path, image_name_or_link)
            s3_client.upload_file(file_path, s3_bucket, s3_full_path, ExtraArgs={'Metadata': image_metadata})
            await ctx.send(f'Image uploaded as {s3_full_path} in the bucket {s3_bucket}!')
        except Exception as e:
            await ctx.send(f'Error uploading the image: {str(e)}')
        finally:
            # Delete the image from the project folder (temporary location)
            try:
                os.remove(file_path)
            except Exception as e:
                print(f"Error deleting the file {file_path}: {str(e)}")
    else:
        await ctx.send('Please provide a valid image or image link.')

@bot.command(name='set_bucket', help='Set the S3 bucket and path: !set_bucket <bucket_name> <path>')
async def set_bucket(ctx, bucket: str, path: str):
    global s3_bucket, s3_path
    s3_bucket = bucket
    s3_path = path
    await ctx.send(f'S3 bucket and path set to {s3_bucket}/{s3_path}')

@bot.command(name='set_metadata', help='Set metadata for an image: !set_metadata <key> <value>')
async def set_metadata(ctx, key: str, value: str):
    global image_metadata
    image_metadata[key] = value
    await ctx.send(f'Metadata set: {key} = {value}')

@bot.command(name='upload_prompt', help='Prompt to upload an image.')
async def upload_prompt(ctx):
    embed = Embed(title="Upload an Image", description="Please attach an image and use the `!upload` command to upload it.")
    await ctx.send(embed=embed)

@bot.command(name='koala', help='Responds with "platypus"')
async def koala(ctx):
    print('somebody typed koala')
    await ctx.send('eucalyptus')


@bot.command(name='config_aws')
@commands.is_owner()  # Restrict this command to the bot owner
async def config_aws(ctx, access_key_id: str, secret_access_key: str):
    os.environ['AWS_ACCESS_KEY_ID'] = access_key_id
    os.environ['AWS_SECRET_ACCESS_KEY'] = secret_access_key
    await ctx.send('AWS credentials configured.')

@bot.command(name='list_photos', help='List all photos in the S3 bucket')
async def list_photos(ctx):
    # Check if bucket is set
    if not s3_bucket:
        await ctx.send('Please set the S3 bucket first using !set_bucket')
        return

    # Fetch the list of objects in the bucket
    objects = s3_client.list_objects_v2(Bucket=s3_bucket)
    
    # Filter for photos (assuming JPEG and PNG for simplicity)
    photo_files = [obj['Key'] for obj in objects.get('Contents', []) if obj['Key'].endswith(('.jpg', '.jpeg', '.png'))]
    
    if not photo_files:
        await ctx.send('No photos found in the bucket.')
        return

    # Send the list of photos to the channel
    photos_list = '\n'.join(photo_files)
    await ctx.send(f"Photos in the bucket:\n{photos_list}")

@bot.command(name='get_photo', help='Get a specific photo from the S3 bucket or the most recent one if no filename provided. Usage: !get_photo <filename>')
async def get_photo(ctx, filename: str = None):
    # Check if bucket is set
    if not s3_bucket:
        await ctx.send('Please set the S3 bucket first using !set_bucket')
        return
    
    if filename is None:  # If no filename is provided
        # Fetch all objects from the bucket
        objects = s3_client.list_objects_v2(Bucket=s3_bucket)
        
        # Filter for photos (assuming JPEG and PNG for simplicity)
        photo_files = [obj for obj in objects.get('Contents', []) if obj['Key'].endswith(('.jpg', '.jpeg', '.png'))]
        
        # Sort the files by their last modified timestamp in descending order
        sorted_files = sorted(photo_files, key=lambda x: x['LastModified'], reverse=True)
        
        # If there are no photos, inform the user and return
        if not sorted_files:
            await ctx.send('No photos found in the bucket.')
            return
        
        # Set the filename to the most recently modified photo's filename
        filename = sorted_files[0]['Key']

        if filename.count('.') > 1:
            parts = filename.split('.')
            sanitized_filename = '.'.join(parts[:-1]) + '.' + parts[-1]
        else:
            sanitized_filename = filename
 
    # Fetch the image from S3
    file_path = f'{sanitized_filename}'
    print(sanitized_filename)
    print(filename)
    print(file_path)
    print(s3_bucket)
    try:
        s3_client.download_file(s3_bucket, filename, file_path)
    except Exception as e:
        await ctx.send(f'Error fetching the photo: {str(e)}')
        return
    
    # Send the image to the Discord channel
    with open(file_path, 'rb') as img:
        await ctx.send(f"File Name: **{filename}**",file=discord.File(img, sanitized_filename))


@bot.command(name='config', help='Get a specific photo from the S3 bucket. Usage: !get_photo')
@commands.is_owner()  # Restrict this command to the bot owner
async def config(ctx):
    # Display bot token partially masked for security
    masked_bot_token = BOT_TOKEN[:5] + "..." + BOT_TOKEN[-5:]
    # Display AWS keys partially masked for security
    masked_aws_access_key_id = AWS_ACCESS_KEY_ID[:4] + "..." + AWS_ACCESS_KEY_ID[-4:]
    masked_aws_secret_access_key = AWS_SECRET_ACCESS_KEY[:4] + "..." + AWS_SECRET_ACCESS_KEY[-4:]
    
    # Construct the message
    config_info = f"""
    Current settings for MJ Art Saver Bot:
    BOT_TOKEN: {masked_bot_token}
    AWS_ACCESS_KEY_ID: {masked_aws_access_key_id}
    AWS_SECRET_ACCESS_KEY: {masked_aws_secret_access_key}
    S3 Bucket: {s3_bucket}
    S3 Path: {s3_path}
    Image Metadata: {image_metadata}
    """
    
    await ctx.send(f"```{config_info}```")


# Run Bot

bot.run(BOT_TOKEN)
