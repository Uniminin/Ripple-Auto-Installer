#!/bin/sh
# shellcheck disable=SC1090 # Non Acute trigger
# shellcheck disable=SC2128 # False trigger
# shellcheck disable=SC2178 # False trigger
# USING: APT, UNIX or GNU/Linux, Mysql Database.

: '
-------------------------------------------------------------------------------------
|  Created by Angel Uniminin <uniminin@zoho.com> in 2019 under the terms of AGPLv3  |
|                          Last Updated on 28th May, 2020                           |
-------------------------------------------------------------------------------------
'

# Simplified assertion by Jacob Hrbek. [kreyren@member.fsf.org]
# <kreyren@rixotstudio.cz> under the terms of GPL-3 (https://www.gnu.org/licenses/gpl-3.0.en.html)
efixme() {
	if [ "$FUNCNAME" != "efixme" ]; then
		FUNCNAME="efixme"
	elif [ "$FUNCNAME" = "efixme" ]; then
		true
	else
		if command -v die >/dev/null; then
			die 255 "checking for efixme FUNCNAME"
		elif ! command -v die >/dev/null; then
			printf 'FATAL: %s\n' "Unexpected happend while checking efixme FUNCNAME"
			exit 255
		else
			printf 'FATAL: %s\n' "Unexpected happend while processing unexpected in efixme"
			exit 255
		fi
	fi

	# NOTICE: Ugly, but this way it doesn't have to process following if statement on runtime
	[ -z "$IGNORE_FIXME" ] && if [ -z "$EFIXME_PREFIX" ]; then
		printf "$EFIXME_PREFIX: %s\\n" "$1"
		return 0
	elif [ -z "$EFIXME_PREFIX" ]; then
		printf 'FIXME: %s\n' "$1"
		return 0
	else
		if command -v die >/dev/null; then
			die 255 "Unexpected happend while exporting fixme message"
		elif ! command -v die >/dev/null; then
			printf 'FATAL: %s\n' "Unexpected happend while exporting fixme message"
			exit 255
		else
			printf 'FATAL: %s\n' "Unexpected happend while processing unexpected in $FUNCNAME"
			exit 255
		fi
	fi
}

lineno() {
	if command -v bash 1>/dev/null; then
		printf '%s\n' "$LINENO"
		return 0
	elif ! command -v bash 1>/dev/null; then
		return 1
	else
		efixme "ELSE"
	fi
}

set -e

die() {
	case "$2" in
		*) printf 'FATAL: %s\n' "$3 $1"
	esac
	
	exit "$2"
}

# NOTICE(Krey & uniminin): It ain't stupid if it works!
alias die="die \"[ line \$LINENO\"\ ]"


## WARNING ##
development="False"
if [ "$development" = "True" ]; then
	die 1 "Script is on Development! Execution of any arguments are disabled in development mode."
fi

# Checking If Running [Script] as Root
checkRoot() {
	if ! [ "$(id -u)" = 0 ]; then
		die 1 "The Script needs to be executed as Root."
	else
		printf "%s\n" "Superuser Permission: Granted!"
	fi
}

notice() {
	case "$1" in
		*) printf 'Installation of %s has been completed! Follow Github Repository for more information.\n'  "$2"
	esac
	
	exit "$1"
}

# Check number of cpu threads for faster compilation/builds
nproc_detector() {
	case "$(nproc)" in
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9]) procNum="$(nproc)" export procNum exit ;;
		*)
			case "$LANG" in
				en-*|*) eerror "Command 'nproc' does not return an expected value on this system, setting the processor count on '1' which will negatively affect performance on systems with more then one thread"
			esac

			export procNum="1"
	esac
}

# FIXME: Add more support for other distros and package managers.
DetectPackageManager() {
	if command -v apt >/dev/null; then
		pm="apt"
		printf "%s\n" "Found Package Manager: $pm"
		export package_manager="$pm"

	elif ! command -v apt >/dev/null; then
		die 1 "apt is not executable on this system! Currently this script is programmed to install packages with apt only."
	else
		die 1 "Unexpected Error!"
	fi
}


# Python 3.5 for pep.py
python3_5() {

	task="python3.5"

	printf "%s\n" "Setting up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 python.org || die 1 "Domain 'python.org' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	printf "%s\n" "Using Package Manager: $package_manager"
	"$package_manager" update ; "$package_manager" upgrade -y
	"$package_manager" install build-essential libssl-dev zlib1g-dev openssl libbz2-dev libsqlite3-dev \
	wget git python-dev default-libmysqlclient-dev make cython -y

	if command -v gcc >/dev/null; then
		printf "%s\n" "Done Installing necessary Dependencies required for peppy!" 
	else
		die 1 "Failed to Install necessary Dependencies required for peppy."
	fi

	(	
		if [ -d "/usr/src" ]; then
			cd /usr/src || die 1 "Failed to cd into '/usr/src'"
			wget -O "Python-3.5.9.tar.xz" https://www.python.org/ftp/python/3.5.9/Python-3.5.9.tar.xz || die 1 "Could not download file 'Python-3.5.9.tar.xz'."
		fi

		if [ -f "Python-3.5.9.tar.xz" ]; then
			tar -xvf Python-3.5.9.tar.xz
			if [ -d "Python-3.5.9" ]; then
				cd Python-3.6.8 || die 1 "Could not cd into 'Python-3.5.9'."
			else
				die 1 "Failed to extract 'Python-3.5.9.tar.xz'."
			fi
			./configure --enable-optimizations --with-ensurepip=install ; make --jobs "$procNum" ; make install
			if command -v python3.5 -m pip >/dev/null; then
				python3.5 -m pip install --upgrade pip
			else
				die 1 "python3.5 pip not found."
			fi
		
		if command -v python3.5 >/dev/null; then
			printf "%s\n" "Python3.5 has been installed on this system."
		else
			die 1 "Failed to install python3.5!"
		fi

		else
			die 1 "Python3.5.9 couldn't be installed because file 'Python-3.5.9.tar.xz' was not found!"
		fi
	)
}

# Python 3.6 for lets
python3_6() {

	task="python3.6"

	printf "%s\n" "Setting up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 python.org || die 1 "Domain 'python.org' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	printf "%s\n" "Using Package Manager: $package_manager"
	"$package_manager" update ; "$package_manager" upgrade -y
	"$package_manager" install build-essential libssl-dev zlib1g-dev openssl libbz2-dev libsqlite3-dev \
	wget git python-dev default-libmysqlclient-dev make cython -y

	if command -v gcc >/dev/null; then
		printf "%s\n" "Done Installing necessary Dependencies required for lets." 
	else
		die 1 "Failed to Install necessary Dependencies required for lets."
	fi

	(
		if [ -d "/usr/src" ]; then
			cd /usr/src || die 1 "Failed to cd into '/usr/src'"
			wget -O "Python-3.6.8.tar.xz" https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tar.xz || die 1 "Could not download file 'Python-3.6.8.tar.xz'."
		fi

		if [ -f "Python-3.6.8.tar.xz" ]; then
			tar -xvf Python-3.6.8.tar.xz
			if [ -d "Python-3.6.8" ]; then
				cd Python-3.6.8 || die 1 "Failed to cd into 'Python-3.6.8'."
			else
				die 1 "Failed to extract 'Python-3.6.8.tar.xz'."
			fi
			./configure --enable-optimizations --with-ensurepip=install ; make --jobs "$procNum" ; make install
			if command -v python3.6 -m pip >/dev/null; then
				python3.6 -m pip install --upgrade pip
			else
				die 1 "python3.6 pip not found."
			fi

		if command -v python3.6 >/dev/null; then
			printf "%s\n" "Python3.6 has been installed on this system."
		else
			die 1 "Failed to install python3.6!"
		fi

		else
			die 1 "Python3.6.8 couldn't be installed because file 'Python-3.6.8.tar.xz' was not found."
		fi
	)
}


# Golang1.13+ for Hanayo & rippleapi
golang() {

	task="golang"

	printf "%s\n" "Setting up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 dl.google.com || die 1 "Domain 'dl.google.com' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	(	
		if [ -d "/usr/src" ]; then
			cd /usr/src || die 1 "Failed to cd into '/usr/src'."
			wget https://dl.google.com/go/go1.13.11.linux-amd64.tar.gz
			if [ -d "/usr/local" ]; then
				tar -C /usr/local -xzf go1.13.11.linux-amd64.tar.gz
				export PATH=$PATH:/usr/local/go/bin
				. "$HOME"/.profile
				export GOPATH=/root/go
			else
				die 1 "Directory: '/usr/local' doesn't exist."
			fi
		fi
	)

	if command -v go 1>/dev/null; then
		printf "%s\n" "Done Setting up '$task'."
	else
		die 1 "Failed to Setup '$task'."
	fi
}

# For Interacting with Database online.
phpmyadmin(){

	task="phpmyadmin"

	printf "%s\n" "Setting up '$task'!"

	# Dependencies
	"$package_manager" install phpmyadmin php-mbstring php-gettext -y

	if [ -d "/var/www/osu.ppy.sh" ]; then
		(
			cd /var/www/osu.ppy.sh || die 1 "Failed to cd into '/var/www/osu.ppy.sh'."
			ln -s /usr/share/phpmyadmin phpmyadmin
		)
		printf "%s\n" "Done setting up '$task'." 
	else
		die 1 "Directory '/var/www/osu.ppy.sh' does not exist."
	fi
}

# Extra Dependencies required to run stack softwares and get the server online.
extra_dependencies() {

	task="Extra Dependencies"

	printf "%s\n" "Installing '$task'!" 

	# Dependencies
	"$package_manager" update ; "$package_manager" upgrade -y
	"$package_manager" install tmux nginx redis-server socat -y

	if command -v nginx >/dev/null; then
		printf "%s\n" "Done Installing '$task'."
	else
		die 1 "Failed to Install '$task'."
	fi

}

inputs() {

	task="Inputs"

	# Creating Master Directory (where all The Repositories will be cloned)
	while [ -z "$targetDir" ]; do
		printf "%s" "Enter Master Directory: " 
		read -r targetDir
	done

	if [ -n "$targetDir" ]; then
		master_dir="$(pwd)/$targetDir"
		printf "%s" "Create Master Directory: '$master_dir' ? y/n " 
		read -r confirmation
		if [ "$confirmation" = "y" ]; then
			mkdir "$master_dir"
			if [ -d "$master_dir" ]; then
				chmod -R a+rwx "$master_dir" || die 1 "Unable to change permission of the file '$master_dir'"
				export directory="$master_dir"
				printf "'%s' has been created!\n" "$master_dir"
			else
				die 1 "Failed to create Directory: $master_dir"
			fi
		else
			die 1 "Directory: $master_dir wasn't created!\n"
		fi
	fi

	# Domain
	while [ -z "$domain" ]; do
		printf "%s" "Domain (example: ripple.moe): " 
		read -r domain
	done
	printf "%s" "Are you sure you want to use '$domain' ? y/n " 
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export domain
	else
		die 1 "Domain Not specified!"
	fi

	# Cikey
	while [ -z "$cikey" ]; do
		printf "%s" "cikey: "
		read -r cikey
	done
	printf "%s" "Are you sure you want to use '$cikey' ? y/n " 
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export cikey
	else
		die 1 "cikey Not specified!"
	fi

	# OSU!API
	printf "%s" "Get OSU!API Key Here: https://old.ppy.sh/p/api"
	while [ -z "$api" ]; do
		printf "%s" "OSU!API key: " 
		read -r api
	done
	printf "%s" "Are you sure you want to use '$api' ? y/n " 
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export api
	else
		die 1 "OSU!API Key Not specified!"
	fi

	# API-Secret
	while [ -z "$api_secret" ]; do
		printf "%s" "API Secret: " 
		read -r api_secret
	done
	printf "%s" "Are you sure you want to use '$api_secret' ? y/n " 
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export api_secret
	else
		die 1 "API Secret Not specified!"
	fi

	# MySQL USERNAME
	while [ -z "$mysql_user" ]; do
		printf "%s" "Enter MySQL Username: " 
		read -r mysql_user
	done
	printf "%s" "Are you sure you want to use '$mysql_user' ? y/n " 
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export mysql_user
	else
		die 1 "MYSQL Username Not specified!"
	fi

	# MySQL PASSWOD
	while [ -z "$mysql_password" ]; do
		printf "%s" "Enter MySQL Password: " 
		read -r mysql_password
	done
	printf "%s" "Are you sure you want to use '$mysql_password' ? y/n " 
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export mysql_password
	else
		die 1 "MYSQL Password Not specified!"
	fi

	# MySQL DATABASE NAME
	while [ -z "$database_name" ]; do
		printf "%s" "Enter MySQL Database Name For Ripple: " 
		read -r database_name
	done
	printf "%s" "Are you sure you want to use '$database_name' ? y/n " 
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export database_name
	else
		die 1 "MYSQL Database Name Not specified!"
	fi

	printf "%s\n" "Done obtaining all the necessary '$task'."
}

# Database is required to access, read, write & manage all the user's data. (Required for all Ripple's Softwares i.e lets, peppy..)
mysql_database() {

	task="MySQL Database"

	printf "%s\n" "Setting up '$task'." 

	# Mysql Dependencies
	"$package_manager" install mysql-server mysql-client -y ; service mysql start

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 raw.githubusercontent.com || die 1 "Domain 'raw.githubusercontent.com' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	(
		if [ -d "$directory" ]; then
			cd "$directory" || die 1 "Failed to cd into '$directory'"
			mysql_dir="mysql_db"
			mkdir $mysql_dir ; cd $mysql_dir || die 1 "Failed to cd into '$mysql_dir'."
			wget -O "ripple.sql" https://raw.githubusercontent.com/Uniminin/Ripple-Auto-Installer/master/Database%20files/ripple.sql || die 1 "Could not download file 'ripple.sql'."
			if [ -f "ripple.sql" ]; then
				mysql -u "$mysql_user" -p"$mysql_password" -e "CREATE DATABASE '$database_name';"
				mysql -p -u "$mysql_user" "$database_name" < ripple.sql
				printf "%s\n" "Done Setting Up '$task'."
			else
				die 1 "Failed to Setup '$task'."
			fi
		else
			die 1 "Directory '$directory' doesn't exist."
		fi
	)

}

# Nginx to balance loads & for proxies
nginx() {

	task="nginx"

	printf "%s\n" "Setting up '$task'."
	
	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 raw.githubusercontent.com || die 1 "Domain 'raw.githubusercontent.com' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	if [ -d "/etc/nginx" ]; then
		pkill -f nginx || die 1 "Failed to kill process '$task'."
		(
			cd /etc/nginx || die 1 "Failed to cd into '/etc/nginx'."
			if [ -f "nginx.conf" ]; then
				rm -rf nginx.conf
			fi
			wget -O "nginx.conf" https://raw.githubusercontent.com/Uniminin/Ripple-Auto-Installer/master/Nginx/N1.conf || die 1 "Could not download file 'nginx.conf'."
			sed -i 's#include /root/ripple/nginx/*.conf\*#include '"$directory"'/nginx/*.conf#' /etc/nginx/nginx.conf || die 1 "Failed to Setup Config file."
		)
	else
		die 1 "Directory '/etc/nginx' does not exist!"
	fi
	
	if [ -d "$directory" ]; then
		(
			cd "$directory" || die 1 "Failed to cd into '$directory'"
			mkdir nginx ; cd nginx || die 1 "Failed to cd into 'nginx'"

			wget -O "nginx.conf" https://raw.githubusercontent.com/Uniminin/Ripple-Auto-Installer/master/Nginx/N2.conf || die 1 "Could not download file 'nginx.conf'."
			if [ -f "nginx.conf" ]; then
				sed -Ei 's#DOMAIN#'"$domain"'#g; s#DIRECTORY#'"$directory"'#g' nginx.conf || die 1 "Failed to Setup Config file."
			fi

			wget -O "old-frontend.conf" https://raw.githubusercontent.com/Uniminin/Ripple-Auto-Installer/master/Nginx/old-frontend.conf || die 1 "Could not download file 'old-frontend.conf'."
			if [ -f "old-frontend.conf" ]; then
				sed -Ei 's#DOMAIN#'"$domain"'#g; s#DIRECTORY#'"$directory"'#g' old-frontend.conf || die 1 "Failed to Setup Config file."
			fi

			# Using osuthailand certificate. (since plebs)
			printf "%s\n" "Downloading Certificates. (ainu-certificate)"
			wget -O "cert.pem" https://raw.githubusercontent.com/osuthailand/ainu-certificate/master/cert.pem || die 1 "Could not download file 'cert.pem'."
			wget -O "key.pem" https://raw.githubusercontent.com/osuthailand/ainu-certificate/master/key.key || die 1 "Could not download file 'key.pem'."
			if [ -f "cert.pem" ] && [ -f "key.pem" ]; then
				printf "%s\n" "Done downloading Certificates."
			else
				die 1 "Failed to download certificates."
			fi
		)

		nginx || die 1 "Nginx: BAD CONFIG!"
		printf "%s\n" "Done setting up '$task'." 
	fi
}

SSL() {

	task="acme.sh"

	printf "%s\n" "Cloning and Setting up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 github.com || die 1 "Domain 'github.com' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			cd "$directory" || die 1 "Failed to cd into '$directory'."
			git clone https://github.com/Neilpang/acme.sh
			if [ -d "acme.sh" ]; then
				cd acme.sh || die 1 "Failed to cd into acme.sh"
				if [ -f "acme.sh" ]; then
					./acme.sh --install
					./acme.sh --issue --standalone -d "$domain" -d c."$domain" -d i."$domain" -d a."$domain" -d s."$domain" -d old."$domain"

					printf "%s\n" "Done setting up '$task'" 
				else
					die 1 "'$task' not found."
				fi
			else
				die 1 "Failed to clone '$task'"
			fi
		)
	else
			die 1 "Directory '$directory' doesn't exist."
	fi
}

# peppy is the backend of osu/bancho, starting from client login, it handles most of the stuff.
peppy () {

	task="pep.py"

	printf "%s\n" "Cloning and Setting up '$task'!" 

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 zxq.co || die 1 "Domain: zxq.co is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			cd "$directory" || die 1 "Failed to cd into '$directory'."
			git clone https://zxq.co/ripple/pep.py ; cd pep.py || die 1 "Failed to cd into '$task'"
			git submodule init ; git submodule 
			
			if command -v python3.5 >/dev/null; then
				python3.5 -m pip install -r requirements.txt
				python3.5 setup.py build_ext --inplace
				if [ -f "pep.py" ]; then
					python3.5 pep.py
					if [ -f "config.ini" ]; then
						sed -Ei "s:^username =.*$:username = $mysql_user:g" config.ini || die 1 "Failed to Setup Config file. [$task/config.ini -> mysql_user]"
						sed -Ei "s:^password =.*$:password = $mysql_password:g" config.ini || die 1 "Failed to Setup Config file. [$task/config.ini -> mysql_password]"
						sed -Ei "s:^database =.*$:database = $database_name:g" config.ini || die 1 "Failed to Setup Config file. [$task/config.ini -> database_name]"
						sed -Ei "s:^cikey =.*$:cikey = $cikey:g" config.ini || die 1 "Failed to Setup Config file. [$task/config.ini -> cikey]"
						sed -Ei "s:^apikey =.*$:apikey = $api:g" config.ini || die 1 "Failed to Setup Config file. [$task/config.ini -> api]"
					fi
				fi
				printf "%s\n" "Done Setting Up '$task'." 
			else
				die 1 "Could not setup '$task' because python3.5 wasn't found on this system."
			fi
		)
	else
		die 1 "Directory '$directory' doesn't exist."
	fi
}

secret() {

	task="secret"

	printf "%s\n" "Cloning and Setting up '$task'!" 

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 github.com || die 1 "Domain 'github.com' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	if [ -d "secret" ]; then
		rm -rf secret
		git clone https://github.com/osufx/secret
		(
			cd secret || die 1 "Failed to cd into 'secret'"
			git submodule init ; git submodule update
		)
	fi
	printf "%s\n" "Done Setting Up '$task'." 
}

# LETS is the Ripple's score server. It manages scores, osu!direct etc.
lets() {

	task="lets"

	printf "%s\n" "Cloning & Setting Up '$task'!" 

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 github.com || die 1 "Domain 'github.com' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			cd "$directory" || die 1 "Failed to cd into '$directory'."
			git clone https://github.com/osufx/lets ; cd lets || die 1 "Failed to cd into '$task'."

			if command -v python3.6 >/dev/null; then
				python3.6 -m pip install -r requirements.txt
				python3.6 setup.py build_ext --inplace
				secret
				if [ -f "lets.py" ]; then
					python3.6 lets.py
					if [ -f "config.ini" ]; then
						sed -Ei "s:^username =.*$:username = $mysql_user:g" config.ini || die 1 "Failed to Setup Config file. [$task/config.ini -> mysql_user]"
						sed -Ei "s:^password =.*$:password = $mysql_password:g" config.ini || die 1 "Failed to Setup Config file. [$task/config.ini -> mysql_password]"
						sed -Ei "s:^database =.*$:database = $database_name:g" config.ini || die 1 "Failed to Setup Config file. [$task/config.ini -> database_name]"
						sed -Ei "s/changeme/$cikey/g" config.ini || die 1 "Failed to Setup Config file. [$task/config.ini -> cikey]"
						sed -Ei "s:^apikey =.*$:apikey = $api:g" config.ini || die 1 "Failed to Setup Config file. [$task/config.ini -> apikey]"
					fi
				fi
				printf "%s\n" "Done Setting Up '$task'." 
			else
				die 1 "Could not install '$task' because python3.6 wasn't found on this system."
			fi
			# compile oppai-ng to make pp calculation working
			if [ -d "pp/oppai-ng" ]; then
				(
					cd pp/oppai-ng || die 1 "Failed to cd into 'pp/oppai-ng'."
					if [ -f "build" ]; then
						chmod +x build ; ./build
					fi
				)
			fi
			printf "%s\n" "Done Setting Up '$task'."
		)
	else
		die 1 "Directory '$directory' doesn't exist."
	fi
}

# Hanayo: The Ripple's Frontend.
hanayo() {

	task="hanayo"

	printf "%s\n" "Cloning & Setting up '$task'!" 

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 zxq.co || die 1 "Domain 'zxq.co' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			go get zxq.co/ripple/hanayo
			if [ -d "/root/go/src/zxq.co/ripple/hanayo" ]; then
				cd /root/go/src/zxq.co/ripple/hanayo || die 1 "Failed to cd into '$task'."
				go build ; ./hanayo ; ./hanayo
				if [ -f "hanayo.conf" ]; then
					sed -Ei "s/ListenTo=:45221/ListenTo=127.0.0.1:45221/g" hanayo.conf || die 1 "Failed to Setup Config file. [$task/hanayo.conf -> ListenTo]"
					sed -E -i -e 'H;1h;$!d;x' hanayo.conf -e 's#DSN=#DSN='"$mysql_user"':'"$mysql_password"'@/'"$database_name"'#' || die 1 "Failed to Setup Config file. [$task/hanayo.conf -> mysql-user, pass, db]"
					sed -Ei "s:^RedisEnable=.*$:RedisEnable=true:g" hanayo.conf || die 1 "Failed to Setup Config file. [$task/hanayo.conf -> Redis]"
					sed -Ei "s/ripple.moe/$domain/g" hanayo.conf || die 1 "Failed to Setup Config file. [$task/hanayo.conf -> domain]"
					sed -Ei "s:^APISecret=.*$:APISecret=$api_secret:g" hanayo.conf || die 1 "Failed to Setup Config file. [$task/hanayo.conf -> api_secret]"
					sed -Ei "s:^MainRippleFolder=.*$:MainRippleFolder=$directory:g" hanayo.conf || die 1 "Failed to Setup Config file. [$task/hanayo.conf -> directory]"
					sed -Ei "s:^AvatarsFolder=.*$:AvatarsFolder=$directory/nginx/avatar-server/Avatars:g" hanayo.conf || die 1 "Failed to Setup Config file. [$task/hanayo.conf -> avatar-folder]"
					sed -Ei "s#https://storage.$domain/api#'https://storage.ripple.moe/api'#g" hanayo.conf || die 1 "Failed to Setup Config file. [$task/hanayo.conf -> cheesegull]"
				else
					die 1 "Failed To Configure '$task'."
				fi

				if [ -f "templates/navbar.html" ]; then
					sed -Ei 's#ripple.moe#'"$domain"'#' templates/navbar.html
				fi

				if [ ! -d "$directory/hanayo" ]; then
					mv go/src/zxq.co/ripple/hanayo "$directory"
					printf "%s\n" "Done Setting Up '$task'." 
				else
					die 1 "Unexpected Error!"
				fi
			else
				die 1 "Failed to Setup '$task'."
			fi
		)
	else
		die 1 "$directory doesn't exist."
	fi
}

# Ripple API is required to talk with the frontend (hanayo), and all other Ripple's Software (lets, peppy..)
rippleapi() {

	task="rippleapi"

	printf "%s\n" "Cloning & Setting up '$task'." 

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 zxq.co || die 1 "Domain 'zxq.co' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			go get zxq.co/ripple/rippleapi
			cd go/src/zxq.co/ripple/rippleapi || die 1 "Failed to cd into '$task'."
			go build ; ./rippleapi
			if [ ! -f "api.conf" ]; then
				sed -E -i -e 'H;1h;$!d;x' api.conf -e 's#DSN=#DSN='"$mysql_user"':'"$mysql_password"'@/'"$database_name"'#' || die 1 "Failed to Setup Config file. [$task/api.conf -> mysql-user, pass, db]"
				sed -Ei "s:^HanayoKey=.*$:HanayoKey=$api_secret:g" api.conf || die 1 "Failed to Setup Config file. [$task/api.conf -> api_secret]"
				sed -Ei "s:^OsuAPIKey=.*$:OsuAPIKey=$cikey:g" api.conf || die 1 "Failed to Setup Config file. [$task/api.conf -> cikey]"
			fi

			if [ ! -d "$directory/rippleapi" ]; then
				mv go/src/zxq.co/ripple/rippleapi "$directory"
				printf '%s/n' "Done setting up '$task'." 
			else
				die 1 "Unexpected Error!"
			fi
		)
	else
		die 1 "Directory '$directory' doesn't exist."
	fi
}

# Avatar-Server handles/manages ingame & frontend's avatars of all users.
avatar_server() {

	task="avatar-server"

	printf "%s\n" "Cloning & Setting up '$task'!" 

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 github.com || die 1 "Domain 'github.com' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			cd "$directory" || die 1 "Failed to cd into '$directory'"
			git clone https://github.com/Uniminin/avatar-server
			if [ -d "avatar-server" ]; then
				cd avatar-server || die 1 "Failed to cd into '$task'."
				python3.6 -m pip install -r requirements.txt
				printf "%s\n" "Done setting up '$task'." 
			else
				die 1 "Failed to Setup '$task'."
			fi
		)
	else
		die 1 "Directory '$directory' doesn't exist."
	fi
}

# OLD-FRONTEND is the Ripple's Admin Panel. Which can be accessed at old.domain
old_frontend() {

	task="old-frontend"

	printf "%s\n" "Cloning & Setting up '$task'!" 

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 zxq.co || die 1 "Domain 'zxq.co' is not reachable from this environment."
		ping -i 0.5 -c 5 getcomposer.org || die 1 "Domain 'getcomposer.org' is not reachable from this environment."
	else
		die 1 "Unknown Error!"
	fi

	"$package_manager" update ; "$package_manager" upgrade -y
	"$package_manager" install build-essential \
	git php-fpm php7.0-mbstring php7.0-curl php-mysql composer -y

	if command -v composer >/dev/null; then
		printf "%s\n" "Done Installing necessary Dependencies required for '$task'." 
	else
		die 1 "Failed to Install necessary Dependencies required for '$task'."
	fi

	(
		if [ ! -d "/var/www/" ]; then
			mkdir /var/www/ ; cd /var/www/ || die 1 "Could not cd into '/var/www/'"
			git clone https://zxq.co/ripple/old-frontend osu.ppy.sh
			if [ -d "osu.ppy.sh" ]; then
				cd osu.ppy.sh || die 1 "Failed to cd into 'osu.ppy.sh'"
				curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
				(
					cd inc || die 1 "Failed to cd into 'inc'"
					cp config.sample.php config.php

					if [ -f "config.php" ]; then
						sed -Ei "s/root/$mysql_user/g" config.php || die 1 "Failed to Setup Config file. [$task/config.php -> mysql_user]"
						sed -Ei "s/meme/$mysql_password/g" config.php || die 1 "Failed to Setup Config file. [$task/config.php -> mysql_password]"
						sed -Ei "s/allora/$database_name/g" config.php || die 1 "Failed to Setup Config file. [$task/config.php -> database_name]"
						sed -Ei "s/ripple.moe/$domain/g" config.php || die 1 "Failed to Setup Config file. [$task/config.php -> domain]"
					fi
				)

				if command -v composer 1>/dev/null; then
					composer install
				else
					die 1 "composer not found."
				fi
				
				secret

				printf "%s\n" "Done setting up '$task'." 
			fi
		else
			die 1 "Unknown Error!"
		fi
	)

}


while [ "$#" -ge 0 ]; do case "$1" in
	--all)
		checkRoot
		DetectPackageManager
		inputs
		mysql_database
		nproc_detector
		python3_5
		peppy
		python3_6
		lets
		avatar_server
		golang
		hanayo
		rippleapi
		extra_dependencies
		old_frontend
		phpmyadmin
		nginx
		notice 1 "Ripple Stack"
		exit ;;

	--help)
		printf "%s\n" \
		"Note:sudo ripple --[argument]" \
		"" \
		"Usage:" \
		"    --help           Shows the list of all arguments including information." \
		"    --all            To Setup Entire Ripple Stack!" \
		"    --dependencies   To Install all the necessary dependencies required for Ripple Stack." \
		"    --mysql          To Manually Setup MySQL DB with dependencies." \
		"    --peppy          To Clone and Setup peppy with dependencies." \
		"    --lets           To Clone and Setup lets with dependencies." \
		"    --hanayo         To Clone and Setup hanayo with dependencies." \
		"    --rippleapi      To Clone and Setup rippleapi with dependencies." \
		"    --avatarserver   To Clone and Setup avatar-server with dependencies." \
		"    --oldfrontend    To Clone and Setup oldfrontend with dependencies." \
		"" \
		"Report bugs to: uniminin@zoho.com or Discord: uniminin#7522" \
		"RAI Repository URL: <https://github.com/Uniminin/Ripple-Auto-Installer/> " \
		"GNU AGPLv3 Licence: <https://www.gnu.org/licenses/agpl-3.0.en.html/>" \
		"General help using GNU software: <https://www.gnu.org/gethelp/>"
		exit ;;

	--dependencies)
		checkRoot
		DetectPackageManager
		nproc_detector
		python3_5
		python3_6
		golang
		phpmyadmin
		extra_dependencies
		notice 1 "All The Dependencies"
		exit ;;

	--mysql)
		checkRoot
		DetectPackageManager
		inputs
		mysql_database
		exit ;;

	--peppy)
		checkRoot
		DetectPackageManager
		inputs
		nproc_detector
		python3_5
		peppy
		exit ;;

	--lets)
		checkRoot
		DetectPackageManager
		inputs
		nproc_detector
		python3_6
		lets
		exit ;;

	--avatarserver)
		checkRoot
		DetectPackageManager
		inputs
		nproc_detector
		python3_6
		avatar_server
		exit ;;

	--hanayo)
		checkRoot
		DetectPackageManager
		inputs
		golang
		hanayo
		exit ;;

	--rippleapi)
		checkRoot
		DetectPackageManager
		inputs
		golang
		rippleapi
		exit ;;

	--oldfrontend)
		checkRoot
		DetectPackageManager
		inputs
		php
		old_frontend
		exit ;;

	"")
		printf "%s\n" "Fatal: No argument were provided | Try: ripple --help"
		exit ;;

	*)
		printf "%s\n" "Fatal: Unknown argument | Try: ripple --help"
		exit ;;
esac; shift; done
