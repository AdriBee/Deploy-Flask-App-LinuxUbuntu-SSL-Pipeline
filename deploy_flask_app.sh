#!/bin/bash

# Display the server's public IPv4 address at the start
IPV4_ADDRESS=$(curl -4 -s ifconfig.co)
echo "Your server's public IPv4 address is: $IPV4_ADDRESS"

# Ask the user to confirm if DNS records point to this IP address
read -p "Have you pointed your domain's DNS records to this IP address? (yes/no): " DNS_CONFIRM
if [ "$DNS_CONFIRM" != "yes" ]; then
    echo "Please point your domain's DNS records to this IP address and then re-run the script."
    exit 1
fi

# Proceed with the rest of the questions
read -p "Enter the name (or path) of the zip file containing your Flask application: " APP_ZIP
read -p "Enter the name of your Flask application (this will be used as the deployment directory name): " APP_NAME
read -p "Enter the Python file and object that contains your Flask application (format: filename:object), e.g. app_name.py:app: " ENTRY_POINT
read -p "Enter your domain (e.g., example.com): " DOMAIN
read -p "Enter any additional domains, separated by spaces (or press Enter to continue): " ADDITIONAL_DOMAINS
read -p "Enter your email address (for SSL certificate notifications): " EMAIL

# Prepare additional domains for Certbot
for ADD_DOMAIN in $ADDITIONAL_DOMAINS
do
  CERTBOT_DOMAINS="$CERTBOT_DOMAINS -d $ADD_DOMAIN"
done

# Directory where the app will be deployed
APP_DIR="/var/www/$APP_NAME"

# Directory where the app source code will be unzipped
UNZIP_DIR="$APP_DIR/app_source"

# Step 2: Extract the ZIP file
mkdir -p $UNZIP_DIR
unzip $APP_ZIP -d $UNZIP_DIR

# Step 3: Install dependencies
sudo apt update
sudo apt install -y python3 python3-pip python3-venv nginx certbot python3-certbot-nginx

# Step 4: Configure the Application
python3 -m venv $APP_DIR/venv
source $APP_DIR/venv/bin/activate
pip install gunicorn flask
pip install -r $UNZIP_DIR/requirements.txt
gunicorn -w 4 -b unix:$APP_DIR/$APP_NAME.sock -m 007 $ENTRY_POINT &

# Step 5: Configure Nginx
NGINX_CONF=$(cat <<- EOM
    server {
        listen 80;
        server_name $DOMAIN $ADDITIONAL_DOMAINS;
    
        location / {
            proxy_pass http://unix:$APP_DIR/$APP_NAME.sock;
            include proxy_params;
        }
    }
EOM
)
echo "$NGINX_CONF" | sudo tee /etc/nginx/sites-available/$APP_NAME
sudo ln -s /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled
sudo nginx -t
sudo systemctl restart nginx


# Step 6: Configure SSL with Certbot
sudo certbot --nginx -d $DOMAIN $CERTBOT_DOMAINS --non-interactive --agree-tos --email $EMAIL --redirect

# Script ends
echo "Deployment Complete"
