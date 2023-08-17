# Deploy-Flask-App-LinuxUbuntu-SSL-Pipeline 🚀

This repo is under development and has not been fully tested yet!

I personally was tired of all the process that it takes to deploy a Flask App to an EC2 or VM, so I created this streamlined process to deploy your Flask App to, for example, an AWS EC2 Ubuntu machine. 

## Why Use This? 🤔
* Simplifies the deployment process into a single script
* Sets up a robust production environment with Gunicorn, Nginx, and SSL via Certbot
* Gets your Flask app running in no time!

## Prerequisites 🛠
1) A VM, like an AWS EC2 instance, running Ubuntu.
2) A domain name. The DNS for this domain should be pointing at the VM.

## Step-by-Step Guide 🚶

### Step 1: Prepare Your VM 🖥
- Set up your security groups on AWS (or equivalent on other providers).
  - SSH access to port 22
  - HTTP access to port 80
  - HTTPS access to port 443

📺 _I will make a video about it. There are some tutorials online too for this._

### Step 2: Prepare Your Flask Project 📁
Your Flask project should have this structure:
```
/YourApp
│
├── /static
├── /templates
├── app.py (or your main python file)
└── requirements.txt
```

### Step 3: Zip Your Project 🗃
- Zip the entire Flask project directory:
  ```bash
  zip -r YourApp.zip YourApp/
  ```

### Step 4: Upload to the Server 🚀
- Use `scp` or any method you are comfortable with to upload `YourApp.zip` to your server. I personally use MobaXTerm and use the UI to upload the .zip.

### Step 5: Deploy The Script 🛠
- Put this bash script to your server next to the zip file. 
- Make the script executable and run it:
  ```bash
  chmod +x deploy_flask_app.sh
  ./deploy_flask_app.sh
  ```

### Step 6: Follow The Script 🧙
- The script will prompt you for several pieces of information, including your domain name and email. Follow the prompts, and the script will handle the rest!

### Step 7: Celebrate 🎉
- Your Flask app is now deployed with Gunicorn, served by Nginx, and secured with SSL via Certbot!

## Troubleshooting 🚧
If you encounter any issues, check the logs for Gunicorn and Nginx, and ensure that your DNS settings are correct.

## Contributing 🤝
Feel free to fork this repository and submit pull requests. We appreciate your contributions!

## License 📝
This project is licensed under the MIT License. See `LICENSE` for more details.

```