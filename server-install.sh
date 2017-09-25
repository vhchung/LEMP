#!/bin/bash
echo "Ubuntu Server 16.04 installation script for..."
echo "- Nginx"
echo "- Php7.1"
echo "- MariaDB"
echo "- Git, Curl & Composer"
echo "- Node.JS, Gulp, Bower & Socket.io"
read -p "Continue with installation? (y/n)" CONTINUE
if [ $CONTINUE = "y" ]; then
	echo "Note: Script assumes you have a file named nginx-site in script directory to be copied to /etc/nginx/sites-available"
	read -p "Install Nginx? (y/n)" NGINX
	if [ $NGINX = "y" ]; then
		sudo apt-get install -y nginx
		sudo mv /etc/nginx/sites-available/default /etc/nginx/sites-available/default.backup
		echo "Moving default site file to /etc/nginx/sites-available/default.backup"
		sudo cp nginx-site /etc/nginx/sites-available/myapp
		read -p "Would you like to modify the Nginx site file? (y/n)" MOD
		if [ $MOD = "y" ]; then
			sudo nano /etc/nginx/sites-available/myapp
		fi
		sudo ln -s /etc/nginx/sites-available/myapp /etc/nginx/sites-enabled/myapp
		sudo nginx -t
		sudo systemctl reload nginx
		sudo systemctl restart nginx
		read -p "Install OpenSSL & Generate SSL Cert for Nginx? (y/n)" SSL
		if [ $SSL = "y" ]; then
			sudo apt-get install -y openssl
			sudo mkdir /etc/nginx/ssl
			sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
			sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048
			sudo systemctl restart nginx.service
		fi
	fi
	read -p "Install PHP7.1? (y/n)" PHP
	if [ $PHP = "y" ]; then
		sudo apt install -y php7.1 php7.1-common php7.1-curl php7.1-zip php7.1-fpm php7.1-cli php7.1-mcrypt php7.1-mbstring php7.1-mysql php7.1-xml php7.1-dev php7.1-pgsql php7.1-gd
		sudo echo 'cgi.fix_pathinfo=0' >> /etc/php/7.1/fpm/php.ini
		echo 'Adding cgi.fix_pathinfo=0 to /etc/php/7.1/fpm/php.ini'
		read -p "Would you like to modify the FPM php.ini file? (y/n)" INI
		if [ $INI = "y" ]; then
			sudo nano /etc/php/7.1/fpm/php.ini
		fi
		sudo systemctl restart php7.1-fpm
	fi
	read -p "Install MariaDB? (y/n)" MARIADB
	if [ $MARIADB = "y" ]; then
		sudo apt install -y mariadb-server mariadb-client
		sudo mysql_secure_installation
		sudo mysql << EOF
		use mysql;
		update user set plugin=’‘ where User=’root’;
		flush privileges;
		exit
EOF
	fi
	read -p "Install Curl, Nano, Composer? (y/n)" CGC
	if [ $CGC = "y" ]; then
		sudo apt-get install -y curl git nano
		curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
	fi
	read -p "Install Node.js? (y/n)" NODE
	if [ $NODE = "y" ]; then
		echo "Please select a version of Node.js:"
		echo "1. Node.js v 6.x LTS"
		echo "2. Node.js v 8.x"
		read -p "Which version would you like? (1/2)" NODEV
		if [ $NODEV = "1" ]; then
			curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
		else
			curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
		fi
		sudo apt-get install -y nodejs
		read -p "Install Socket.io, bower & gulp? (y/n)" SIO
		if [ $SIO = "y" ];then
			sudo npm install -g socket.io
			sudo npm install -g bower
			sudo npm install -g gulp-cli
		fi

	fi
else
	exit
fi
