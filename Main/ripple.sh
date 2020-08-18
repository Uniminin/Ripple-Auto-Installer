#!/bin/sh
# shellcheck shell=sh # Written to be posix compatible
# shellcheck disable=SC2128,SC2178 # False Trigger
# shellcheck disable=SC2039,SC1090,SC1091 # Non-Acute Trigger
# USING: APT, Pacman, Portage, Paludis, UNIX or GNU/Linux, Mysql/Mariadb Database.
# SUPPORTS INIT SYSTEMS: systemd and openrc.

: '
-------------------------------------------------------------------------------------
|  Created by Angel Uniminin <uniminin@zoho.com> in 2019 under the terms of AGPLv3  |
|            Last Updated on Tuesday, August 18, 2020 at 05:15 PM (GMT+6)           |
-------------------------------------------------------------------------------------
'

###! Script to clone, install & configure Ripple (https://ripple.moe)
###! Main Ripple Git: https://zxq.co/ripple | Mirror: https://github.com/osuripple
###! We need:
###! - FIXME-DOCS
###! - TEST-SCRIPT
###! Requires:
###! - FIXME
###! Exit codes:
###! - FIXME-DOCS: Defined in die()
###! - Error Log [*]
###! Platforms:
###!  - [*] Linux
###!    - [*] Archlinux
###!    - [ ] Alpine
###!    - [ ] Arya
###!    - [*] Bedrock (strat -r x-stratum)
###!    - [*] Debian
###!    - [*] Exherbo
###!    - [ ] Fedora
###!    - [*] Gentoo
###!    - [*] Ubuntu
###!    - [ ] NixOS
###!    - [ ] Slackware
###!    - [ ] Venom
###!    - [ ] Void
###!  - [ ] BSD
###!    - [ ] FreeBSD
###!    - [ ] GhostBSD
###!    - [ ] DragonFly BSD
###!  - [ ] Redox
###!    - [ ] Redox
###!  - [*] Windows (https://github.com/Uniminin/Light-Ripple-Windows)
###!    - [*] Windows 7
###!    - [*] Windows 8
###!    - [*] Windows 8.1
###!    - [*] Windows 10
###! Package Managers:
###!  - [ ] Apk
###!  - [*] Apt
###!  - [ ] ALPS
###!  - [ ] Brew
###!  - [*] Pacman
###!  - [*] Portage
###!  - [*] cave
###!  - [ ] xbps
###!  - [ ] zypper
###!  - [ ] dnf
###!  - [ ] rpm
###!  - [ ] Zernit (https://github.com/RXT0112/Zernit)
###! Init System:
###!  - [*] Openrc
###!  - [*] Systemd
###!  - [ ] SysV-init
###!  - [ ] runit
###!  - [ ] s6
###! System Detection:
###!  - [*] Ubuntu
###!    - [*] Ubuntu 20.04
###!    - [*] Ubuntu 18.04
###!    - [ ] Ubuntu 16.10
###!    - [*] Ubuntu 16.04
###!    - [*] Ubuntu 14.04
###!    - [ ] Ubuntu 12.04


# TODO: Detect Operating System/Kernel/Distro and pull proper packages.

# Maintainer info
# UPSTREAM="https://github.com/Uniminin/Ripple-Auto-Installer"
# MAINTAINER_EMAIL="uniminin@zoho.com"
# MAINTAINER_NICKNAME="Uniminin"
# MAINTAINER_NAME="uniminin"


# Version #
UPSTREAM_VERSION=0.5.2


# Colors For Prints
alias RPRINT="printf '\\033[0;31m%s\\n'"     # Red
alias GPRINT="printf '\\033[0;32m%s\\n'"     # Green
alias YPRINT="printf '\\033[0;33m%s\\n'"     # Yellow
alias BPRINT="printf '\\033[0;34m%s'"        # Blue


# Modified version of efixme originally designed by Jacob Hrbek <kreyren@rixotstudio.cz> under the terms of GPL-3
efixme() {
	if [ "$FUNCNAME" != "efixme" ]; then
		FUNCNAME="efixme"
	elif [ "$FUNCNAME" = "efixme" ]; then
		true
	else
		if command -v die >/dev/null; then
			die 255 "checking for efixme FUNCNAME"
		elif ! command -v die >/dev/null; then
			RPRINT "FATAL: Unexpected happend while checking efixme FUNCNAME"
			exit 255
		else
			RPRINT "FATAL: Unexpected happend while processing unexpected in efixme"
			exit 255
		fi
	fi

	# NOTICE: Ugly, but this way it doesn't have to process following if statement on runtime #
	[ -z "$IGNORE_FIXME" ] && if [ -z "$EFIXME_PREFIX" ]; then
		RPRINT "$EFIXME_PREFIX: $1"
		return 0
	elif [ -z "$EFIXME_PREFIX" ]; then
		RPRINT "FIXME: $1"
		return 0
	else
		if command -v die >/dev/null; then
			die 255 "Unexpected happend while exporting fixme message"
		elif ! command -v die >/dev/null; then
			RPRINT "FATAL: Unexpected happend while exporting fixme message"
			exit 255
		else
			RPRINT "FATAL: Unexpected happend while processing unexpected in $FUNCNAME"
			exit 255
		fi
	fi
}


# Get's directory name from filepath
# Usage: getdir "path"
getdir() {
	local tmp=${1:-.}

	[[ $tmp != *[!/]* ]] && {
		printf "/\\n"
		return
	}

	tmp=${tmp%%"${tmp##*[!/]}"}

	[[ $tmp != */* ]] && {
		printf ".\\n"
		return
	}

	tmp=${tmp%/*}
	tmp=${tmp%%"${tmp##*[!/]}"}

	GPRINT "${tmp:-/}"
}


# prints line number
lineno() {
	if command -v bash 1>/dev/null; then
		RPRINT "$LINENO"
		return 0
	elif ! command -v bash 1>/dev/null; then
		return 1
	else
		efixme "ELSE"
	fi
}

set -e


# Simplified Assersion by uniminin <uniminin@zoho.com> under the terms of AGPLv3
# Usage: die "exitcode" "msg..."
die() {

	# Current Date
	Date=$(date)


	case "$2" in
		*) RPRINT "FATAL ""$2"": $3 $1"
	esac
	
	if [ ! -f "ErrorLog.txt" ]; then
		touch Error.log
	fi
	
	if [ -f "Error.log" ]; then
		printf "[$Date]\\nFATAL: %s\\n\\n" "$3 $1" >> Error.log || die 1 "Couldn't write into 'Error.log'."
		GPRINT "Successfully Written into 'Error.log'"
	fi

	BPRINT "Continue ? y/n "
	read -r confirmation
	
	if [ ! "$confirmation" = "y" ]; then
		RPRINT "Exiting..."
		exit 4
	fi
}


# Die
alias die="die \"[ line \$LINENO\"\\ ]"


# Simplified Network Checker (IPv4 & DNS connectivity) 
checkNetwork() {
	if command -v ping 1>/dev/null; then
		if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
			GPRINT "IPv4 is up."
		else
			die 64 "IPv4 is down!"
		fi

		if ping -q -c 1 -W 1 google.com >/dev/null; then
			GPRINT "The network is up."
		else
			die 64 "The network is down!"
		fi
	else
		die 127 "ping is not executable on this system. Failed to check network connectivity."
	fi
}


# Detect Operating System
. /etc/os-release


# Check for root
checkRoot() {
	if [ $EUID -ne 0 ]; then
		RPRINT "The Script needs to be executed as Root/Superuser!"
		exit 1
	fi
}


# Detect number of cpu threads for faster compilation/builds
nproc_detector() {
	case "$(nproc)" in
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9]) procNum="$(nproc)" export procNum exit ;;
		*)
			case "$LANG" in
				en-*|*) die 5 "Command 'nproc' does not return an expected value on this system, setting the processor count on '1' which will negatively affect performance on systems with more then one thread"
			esac

			export procNum="1"
	esac
}


# FIXME: Add more support for other distros and package managers.
# Supports: apt, pacman, portage and paludis.
DetectPackageManager() {
	if command -v apt >/dev/null; then
		pm="apt"
		GPRINT "Found Package Manager: '$pm'"
		export package_manager="$pm"
		YPRINT "Using Package Manager: '$package_manager'"

	elif command -v pacman >/dev/null; then
		pm="pacman"
		GPRINT "Found Package Manager: '$pm'"
		export package_manager="$pm"
		YPRINT "Using Package Manager: '$package_manager'"

	elif command -v emerge >/dev/null; then
		pm="portage"
		GPRINT "Found Package Manager: '$pm'"
		export package_manager="emerge"
		YPRINT "Using Package Manager: 'portage [$package_manager]'"

	elif command -v cave >/dev/null; then
		pm="paludis"
		GPRINT "Found Package Manager: '$pm'"
		export package_manager="cave"
		YPRINT "Using Package Manager: 'paludis [$package_manager]'"

	elif ! command -v apt >/dev/null || ! command -v pacman >/dev/null \
	|| ! command -v emerge >/dev/null || ! command -v cave >/dev/null; then
		die 8 "Any of apt, pacman, portage or paludis is not executable on this system! The script is programmed to work on APT, Pacman and Portage only."
	else
		die 14 "Unexpected Error!"
	fi
}


packageManagerUpgrade() {

	task="packages"

	GPRINT "Upgrading/Updating system '$task'!"

	if command -v apt >/dev/null; then
		apt update ; apt upgrade -y ; apt update

	elif command -v pacman >/dev/null; then
		pacman --noconfirm -Syyu
	
	elif command -v emerge >/dev/null; then
		emerge --sync ; emerge -quDN @world

	elif command -v cave >/dev/null; then
		cave sync ; cave resolve world -x
	fi
}


# Dependencies Requires for Python3.5 & Python3.6
python_dependencies() {

	task="python"

	GPRINT "Installing Necessary Dependencies required for '$task'!"

	# Dependencies
	if [ "$package_manager" = "apt" ]; then
		"$package_manager" install build-essential libssl-dev zlib1g-dev openssl libbz2-dev libsqlite3-dev \
		git wget python-dev default-libmysqlclient-dev tar make cython -y

	elif [ "$package_manager" = "pacman" ]; then
		"$package_manager" --noconfirm -S gcc git wget tar make cython

	elif [ "$package_manager" = "emerge" ]; then
		"$package_manager" -q sys-devel/gcc dev-vcs/git net-misc/wget \
		sys-devel/make app-arch/tar dev-python/cython

	elif [ "$package_manager" = "cave" ]; then
		"$package_manager" resolve -x sys-devel/gcc dev-scm/git \
		sys-devel/make app-arch/tar dev-python/shiboken2

	fi

	for packages in gcc make git wget cython; do
		if command -v $packages >/dev/null; then
			GPRINT "Done Installing necessary Dependencies required for '$task'"
		else
			die 123 "Failed to Install necessary Dependencies required for '$task'"
		fi
	done
}


# Python 3.5 for pep.py
python3_5() {

	task="python3.5"

	if command -v python3.5 >/dev/null; then
		GPRINT "Python3.5 has been found on this system. Skipping.."
	else
		YPRINT "Setting up '$task'!"

		if command -v ping 1>/dev/null; then
			ping -i 0.5 -c 5 python.org || die 121 "Domain 'python.org' is not reachable from this environment."
		else
			die 61 "Unknown Error!"
		fi

		(
			if [ -d "/usr/src" ]; then
				cd /usr/src || die 1 "Failed to cd into '/usr/src'"
				wget -O "Python-3.5.9.tar.xz" https://www.python.org/ftp/python/3.5.9/Python-3.5.9.tar.xz || die 1 "Could not download file 'Python-3.5.9.tar.xz'."
			fi

			if [ -f "Python-3.5.9.tar.xz" ]; then
				tar -xvf Python-3.5.9.tar.xz
				if [ -d "Python-3.5.9" ]; then
					cd Python-3.5.9 || die 1 "Could not cd into 'Python-3.5.9'."
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
				GPRINT "Python3.5 has been installed on this system."
			else
				die 1 "Failed to install python3.5!"
			fi

			else
				die 1 "Python3.5.9 couldn't be installed because file 'Python-3.5.9.tar.xz' was not found!"
			fi
		)
	fi

}


# Python 3.6 for lets
python3_6() {

	task="python3.6"

	if command -v python3.6 >/dev/null; then
		GPRINT "Python3.6 has been found on this system. Skipping.."
		
	else
		YPRINT "Setting up '$task'!"
		
		# FIXME: detect distro version, add and pull proper repository and package respectively
		if [ "$ID" = "Ubuntu" ]; then
			add-apt-repository ppa:deadsnakes/ppa -y
			"$package_manager" update
			"$package_manager" install python3.6 python3-pip -y
			
		else
			if command -v ping 1>/dev/null; then
				ping -i 0.5 -c 5 python.org || die 121 "Domain 'python.org' is not reachable from this environment."
			else
				die 61 "Unknown Error!"
			fi

			(
				if [ -d "/usr/src" ]; then
					cd /usr/src || die 1 "Failed to cd into '/usr/src'"
					wget -O "Python-3.6.8.tar.xz" https://www.python.org/ftp/python/3.6.8/Python-3.6.8.tar.xz || die 11 "Could not download file 'Python-3.6.8.tar.xz'."
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
					GPRINT "Python3.6 has been installed on this system."
				else
					die 1 "Failed to install python3.6!"
				fi

				else
					die 1 "Python3.6.8 couldn't be installed because file 'Python-3.6.8.tar.xz' was not found."
				fi
			)
		fi
	fi

	
}


# Golang1.13+ for Hanayo & rippleapi
golang() {

	task="golang"

	if command -v go 1>/dev/null; then
		GPRINT "Golang has be found on this system. Skipping.."
	else
		YPRINT "Setting up '$task'!"
		
		if [ "$ID" = "Ubuntu" ]; then
			add-apt-repository ppa:longsleep/golang-backports -y
			"$package_manager" update
			"$package_manager" install golang-go -y
		
		elif [ "$package_manager" = "apt" ]; then
			# FIXME: provide proper package name
			"$package_manager" install wget go golang-go -y
			
			if ! command -v go 1>/dev/null; then
				if command -v ping 1>/dev/null; then
					ping -i 0.5 -c 5 dl.google.com || die 121 "Domain 'dl.google.com' is not reachable from this environment."
				else
					die 61 "Unknown Error!"
				fi

				(
					if [ -d "/usr/src" ]; then
						cd /usr/src || die 1 "Failed to cd into '/usr/src'."
						wget https://dl.google.com/go/go1.13.11.linux-amd64.tar.gz
						if [ -d "/usr/local" ]; then
							tar -xvf go1.13.11.linux-amd64.tar.gz
							chown -R root:root ./go
							mv go /usr/local
							
							# FIXME: Absolute Path
							getdir ~/.profile

							if [ ! -f "$HOME/.profile" ]; then
								touch ~/.profile
							fi

							echo export GOPATH=/root/go > ~/.profile
							echo export PATH="$PATH":/usr/local/go/bin:"$GOPATH"/bin > ~/.profile
							. ~/.profile

						else
							die 1 "Directory: '/usr/local' doesn't exist."
						fi
					fi
				)
			fi

		elif [ "$package_manager" = "pacman" ]; then
			"$package_manager" --noconfirm -S go

		elif [ "$package_manager" = "emerge" ]; then
			"$package_manager" -q dev-lang/go

		elif [ "$package_manager" = "cave" ]; then
			"$package_manager" resolve -x dev-lang/go
		fi

		if command -v go 1>/dev/null; then
			GPRINT "Done Setting up '$task'."
		else
			die 1 "Failed to Setup '$task'."
		fi
	fi
}


# Extra Dependencies required to run stack softwares and get the server online.
extra_dependencies() {

	task="Extra Dependencies"

	YPRINT "Installing '$task'!"

	# Dependencies
	if [ "$package_manager" = "apt" ]; then
		"$package_manager" install tmux nginx redis-server socat -y

	elif [ "$package_manager" = "pacman" ]; then
		"$package_manager" --noconfirm -S tmux nginx redis socat

	elif [ "$package_manager" = "emerge" ]; then
		"$package_manager" -q app-misc/tmux www-servers/nginx dev-db/redis net-misc/socat

	elif [ "$package_manager" = "cave" ]; then
		"$package_manager" resolve -x app-terminal/tmux www-servers/nginx \
		dev-db/redis net-misc/socat
	fi

	for packages in tmux nginx redis-cli; do
		if command -v $packages >/dev/null; then
			GPRINT "Done Installing necessary Dependencies required for '$task'"
		else
			die 1 "Failed to Install necessary Dependencies required for '$task'"
		fi
	done
}


# Nginx to balance loads & for proxies
nginx() {

	task="nginx"

	YPRINT "Setting up '$task'."

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 raw.githubusercontent.com || die 121 "Domain 'raw.githubusercontent.com' is not reachable from this environment."
	else
		die 61 "Unknown Error!"
	fi

	if [ -d "/etc/nginx" ]; then
		pkill -f nginx || die 1 "Failed to kill process '$task'."
		(
			cd /etc/nginx || die 1 "Failed to cd into '/etc/nginx'."
			if [ -f "nginx.conf" ]; then
				rm -rfv nginx.conf
			fi
			wget -O "nginx.conf" https://raw.githubusercontent.com/Uniminin/Ripple-Auto-Installer/master/Nginx/N1.conf || die 11 "Could not download file 'nginx.conf'."
			sed -i 's#include /root/ripple/nginx/*.conf\*#include '"$directory"'/nginx/*.conf#' /etc/nginx/nginx.conf || die 1 "Failed to Setup Config file."
		)
	else
		die 1 "Directory '/etc/nginx' does not exist!"
	fi

	if [ -d "$directory" ]; then
		(
			cd "$directory" || die 1 "Failed to cd into '$directory'"
			mkdir -v nginx ; cd nginx || die 1 "Failed to cd into 'nginx'"

			wget -O "nginx.conf" https://raw.githubusercontent.com/Uniminin/Ripple-Auto-Installer/master/Nginx/N2.conf || die 11 "Could not download file 'nginx.conf'."
			if [ -f "nginx.conf" ]; then
				sed -Ei 's#DOMAIN#'"$domain"'#g; s#DIRECTORY#'"$directory"'#g' nginx.conf || die 1 "Failed to Setup Config file."
			fi

			wget -O "old-frontend.conf" https://raw.githubusercontent.com/Uniminin/Ripple-Auto-Installer/master/Nginx/old-frontend.conf || die 11 "Could not download file 'old-frontend.conf'."
			if [ -f "old-frontend.conf" ]; then
				sed -Ei 's#DOMAIN#'"$domain"'#g; s#DIRECTORY#'"$directory"'#g' old-frontend.conf || die 1 "Failed to Setup Config file."
			fi

			# Using osuthailand certificate. (since plebs)
			YPRINT "Downloading Certificates. (ainu-certificate)"
			wget -O "cert.pem" https://raw.githubusercontent.com/osuthailand/ainu-certificate/master/cert.pem || die 11 "Could not download file 'cert.pem'."
			wget -O "key.pem" https://raw.githubusercontent.com/osuthailand/ainu-certificate/master/key.key || die 11 "Could not download file 'key.pem'."
			if [ -f "cert.pem" ] && [ -f "key.pem" ]; then
				GPRINT "Done downloading Certificates."
			else
				die 1 "Failed to download certificates."
			fi
		)

		nginx || die 1 "Nginx: BAD CONFIG!"
		GPRINT "Done setting up '$task'."
	fi
}


SSL() {

	task="acme.sh"

	YPRINT "Cloning and Setting up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 github.com || die 121 "Domain 'github.com' is not reachable from this environment."
	else
		die 61 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			cd "$directory" || die 1 "Failed to cd into '$directory'."
			if command -v git 1>/dev/null; then
				git clone https://github.com/Neilpang/acme.sh
			else
				die 1 "git not found on this system!"
			fi

			if [ -d "acme.sh" ]; then
				cd acme.sh || die 1 "Failed to cd into acme.sh"
				if [ -f "acme.sh" ]; then
					./acme.sh --install
					./acme.sh --issue --standalone -d "$domain" -d c."$domain" -d i."$domain" -d a."$domain" -d s."$domain" -d old."$domain"

					GPRINT "Done setting up '$task'"
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


# For Interacting with Database online.
phpmyadmin(){

	task="phpmyadmin"

	YPRINT "Setting up '$task'!"

	# Dependencies
	if [ "$package_manager" = "apt" ]; then
		"$package_manager" install phpmyadmin php-mbstring php-gettext -y

	elif [ "$package_manager" = "pacman" ]; then
		"$package_manager" --noconfirm -S phpmyadmin

	elif [ "$package_manager" = "emerge" ]; then
		"$package_manager" -q dev-db/phpmyadmin

	elif [ "$package_manager" = "cave" ]; then
		"$package_manager" resolve -x dev-lang/php
	fi

	if [ -d "/var/www/osu.ppy.sh" ]; then
		(
			cd /var/www/osu.ppy.sh || die 1 "Failed to cd into '/var/www/osu.ppy.sh'."
			ln -s /usr/share/phpmyadmin phpmyadmin
		)
		GPRINT "Done setting up '$task'."
	else
		die 1 "Directory '/var/www/osu.ppy.sh' does not exist."
	fi
}


inputs() {

	task="Inputs"

	# Creating Master Directory (where all The Repositories will be cloned)
	while [ -z "$targetDir" ]; do
		BPRINT "Enter Master Directory: "
		read -r targetDir
	done

	if [ -n "$targetDir" ]; then
		master_dir="$(pwd)/$targetDir"
		if [ -d "$master_dir" ]; then
			BPRINT "Master Directory: '$master_dir' exists. Continue ? y/n "
			read -r confirmation
			if [ "$confirmation" = "y" ]; then
				GPRINT "Using Directory '$master_dir'"
			else
				die 1 "Input Declined by the user!"
			fi
		else
			BPRINT "Create Master Directory: '$master_dir' ? y/n "
			read -r confirmation
			if [ "$confirmation" = "y" ]; then
				mkdir -v "$master_dir"
				if [ -d "$master_dir" ]; then
					GPRINT "'$master_dir' has been created!"
				else
					die 1 "Failed to create '$master_dir'"
				fi
			fi
		fi

		if [ -d "$master_dir" ]; then
			chmod -R a+rwx "$master_dir" || die 1 "Unable to change permission of the file '$master_dir'"
			export directory="$master_dir"
		else
			die 1 "Failed to create Directory '$master_dir'"
		fi
	fi

	# Domain
	while [ -z "$domain" ]; do
		BPRINT "Domain (example: ripple.moe): "
		read -r domain
	done
	BPRINT "Are you sure you want to use '$domain' ? y/n "
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export domain
	else
		die 1 "Domain Not specified!"
	fi

	# Cikey
	while [ -z "$cikey" ]; do
		BPRINT "cikey: "
		read -r cikey
	done
	BPRINT "Are you sure you want to use '$cikey' ? y/n "
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export cikey
	else
		die 1 "cikey Not specified!"
	fi

	# OSU!API
	BPRINT "Get OSU!API Key Here: https://old.ppy.sh/p/api"
	while [ -z "$api" ]; do
		BPRINT "OSU!API key: "
		read -r api
	done
	BPRINT "Are you sure you want to use '$api' ? y/n "
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export api
	else
		die 1 "OSU!API Key Not specified!"
	fi

	# API-Secret
	while [ -z "$api_secret" ]; do
		BPRINT "API Secret: "
		read -r api_secret
	done
	BPRINT "Are you sure you want to use '$api_secret' ? y/n "
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export api_secret
	else
		die 1 "API Secret Not specified!"
	fi

	# MySQL USERNAME
	while [ -z "$mysql_user" ]; do
		BPRINT "Enter MySQL Username: "
		read -r mysql_user
	done
	BPRINT "Are you sure you want to use '$mysql_user' ? y/n "
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export mysql_user
	else
		die 1 "MYSQL Username Not specified!"
	fi

	# MySQL PASSWORD
	while [ -z "$mysql_password" ]; do
		BPRINT "Enter MySQL Password: "
		read -r mysql_password
	done
	BPRINT "Are you sure you want to use '$mysql_password' ? y/n "
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export mysql_password
	else
		die 1 "MYSQL Password Not specified!"
	fi

	# MySQL DATABASE NAME
	while [ -z "$database_name" ]; do
		BPRINT "Enter MySQL Database Name For Ripple: "
		read -r database_name
	done
	BPRINT "Are you sure you want to use '$database_name' ? y/n "
	read -r confirmation
	if [ "$confirmation" = "y" ]; then
		export database_name
	else
		die 1 "MYSQL Database Name Not specified!"
	fi

	GPRINT "Done obtaining all the necessary '$task'."
}


# Database is required to access, read, write & manage all the user's data. (Required for all Ripple's Softwares i.e lets, peppy..)
mysql_database() {

	task="MySQL Database"

	YPRINT "Setting up '$task'."

	if command -v mysql 1>/dev/null; then
		GPRINT "Done Installing Mysql Dependencies."
	else
		die 1 "Could not find mysql package on this system."
	fi

	# Dependencies
	if [ "$package_manager" = "apt" ]; then
		"$package_manager" install mysql-server mysql-client -y
		service mysql start

	elif [ "$package_manager" = "pacman" ]; then
		"$package_manager" --noconfirm -S mariadb
		mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
		systemctl start mariadb.service

	elif [ "$package_manager" = "emerge" ]; then
		"$package_manager" -q dev-db/mysql
		if command -v rc >/dev/null; then
			rc-update add mysql default ; rc-service mysql start
		elif command -v service >/dev/null; then
			service mysql start
		else
			die 1 "Unable to Detect init system and start Mysql service!"
		fi

	elif [ "$package_manager" = "cave" ]; then
		"$package_manager" resolve -x virtual/mysql
		if command -v rc >/dev/null; then
			rc-update add mysql default ; rc-service mysql start
		elif command -v service >/dev/null; then
			service mysql start
		else
			die 1 "Unable to Detect init system and start Mysql service!"
		fi
	fi


	if command -v mysql >/dev/null; then
		GPRINT "Done Installing necessary Dependencies required for '$task'"
	else
		die 1 "Failed to Install necessary Dependencies required for '$task'"
	fi

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 raw.githubusercontent.com || die 121 "Domain 'raw.githubusercontent.com' is not reachable from this environment."
	else
		die 61 "Unknown Error!"
	fi

	(
		if [ -d "$directory" ]; then
			cd "$directory" || die 1 "Failed to cd into '$directory'"
			mysql_dir="mysql_db"
			mkdir -v $mysql_dir ; cd $mysql_dir || die 1 "Failed to cd into '$mysql_dir'."
			wget -O "ripple.sql" https://raw.githubusercontent.com/Uniminin/Ripple-Auto-Installer/master/Database%20files/ripple.sql || die 11 "Could not download file 'ripple.sql'."
			if [ -f "ripple.sql" ]; then
				YPRINT "Note: Enter MySql Password. Same for each prompt"
				mysql -u "$mysql_user" -p -e 'CREATE DATABASE '"$database_name"'';
				mysql -p -u "$mysql_user" "$database_name" < ripple.sql
				GPRINT "Done Setting Up '$task'."
			else
				die 1 "Failed to Setup '$task'."
			fi
		else
			die 1 "Directory '$directory' doesn't exist."
		fi
	)
}


# peppy is the backend of osu/bancho, starting from client login, it handles most of the stuff.
peppy () {

	task="pep.py"

	YPRINT "Cloning and Setting up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 zxq.co || die 121 "Domain: zxq.co is not reachable from this environment."
	else
		die 61 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			cd "$directory" || die 1 "Failed to cd into '$directory'."

			if command -v git 1>/dev/null; then
				git clone https://zxq.co/ripple/pep.py ; cd pep.py || die 1 "Failed to cd into '$task'"
				git submodule init ; git submodule update
			else
				die 1 "git not found on this system!"
			fi

			if command -v python3.5 >/dev/null; then
				python3.5 -m pip install -r requirements.txt
				python3.5 setup.py build_ext --inplace
				if [ -f "pep.py" ]; then
					python3.5 pep.py
					if [ -f "config.ini" ]; then
						sed -Ei "s:^username =.*$:username = $mysql_user:g" config.ini || die 74 "Failed to Setup Config file. [$task/config.ini -> mysql_user]"
						sed -Ei "s:^password =.*$:password = $mysql_password:g" config.ini || die 74 "Failed to Setup Config file. [$task/config.ini -> mysql_password]"
						sed -Ei "s:^database =.*$:database = $database_name:g" config.ini || die 74 "Failed to Setup Config file. [$task/config.ini -> database_name]"
						sed -Ei "s:^cikey =.*$:cikey = $cikey:g" config.ini || die 74 "Failed to Setup Config file. [$task/config.ini -> cikey]"
						sed -Ei "s:^apikey =.*$:apikey = $api:g" config.ini || die 74 "Failed to Setup Config file. [$task/config.ini -> api]"
					fi
				fi
				GPRINT "Done Setting Up '$task'."
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

	YPRINT "Cloning and Setting up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 github.com || die 121 "Domain 'github.com' is not reachable from this environment."
	else
		die 61 "Unknown Error!"
	fi

	if [ -d "secret" ]; then
		rm -rfv secret

		if command -v git 1>/dev/null; then
			git clone https://github.com/osufx/secret
		(
			cd secret || die 1 "Failed to cd into 'secret'"
			git submodule init ; git submodule update
		)
		else
			die 1 "git not found on this system!"
		fi
	fi
	GPRINT "Done Setting Up '$task'."
}


# LETS is the Ripple's score server. It manages scores, osu!direct etc.
lets() {

	task="lets"

	YPRINT "Cloning & Setting Up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 github.com || die 121 "Domain 'github.com' is not reachable from this environment."
	else
		die 61 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			cd "$directory" || die 1 "Failed to cd into '$directory'."

			if command -v git 1>/dev/null; then
				git clone https://github.com/osufx/lets ; cd lets || die 1 "Failed to cd into '$task'."
			else
				 1 "git not found on this system!"
			fi

			if command -v python3.6 >/dev/null; then
				secret
				git submodule init ; git submodule update
				python3.6 -m pip install -r requirements.txt
				python3.6 setup.py build_ext --inplace
				if [ -f "lets.py" ]; then
					python3.6 lets.py
					if [ -f "config.ini" ]; then
						sed -Ei "s:^username =.*$:username = $mysql_user:g" config.ini || die 74 "Failed to Setup Config file. [$task/config.ini -> mysql_user]"
						sed -Ei "s:^password =.*$:password = $mysql_password:g" config.ini || die 74 "Failed to Setup Config file. [$task/config.ini -> mysql_password]"
						sed -Ei "s:^database =.*$:database = $database_name:g" config.ini || die 74 "Failed to Setup Config file. [$task/config.ini -> database_name]"
						sed -Ei "s/changeme/$cikey/g" config.ini || die 74 "Failed to Setup Config file. [$task/config.ini -> cikey]"
						sed -Ei "s:^apikey =.*$:apikey = $api:g" config.ini || die 74 "Failed to Setup Config file. [$task/config.ini -> apikey]"
					fi
				fi
				GPRINT "Done Setting Up 'lets'."
			else
				die 1 "Could not install 'lets' because python3.6 wasn't found on this system."
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
			GPRINT "Done Setting Up 'lets'."
		)
	else
		die 1 "Directory '$directory' doesn't exist."
	fi
}


# Hanayo: The Ripple's Frontend.
hanayo() {

	task="hanayo"

	YPRINT "Cloning & Setting up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 zxq.co || die 121 "Domain 'zxq.co' is not reachable from this environment."
	else
		die 61 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			if command -v go 1>/dev/null; then
				go get zxq.co/ripple/hanayo
				if [ -d "/root/go/src/zxq.co/ripple/hanayo" ]; then
					cd /root/go/src/zxq.co/ripple/hanayo || die 1 "Failed to cd into '$task'."
					# twice. Not a mistake!!!
					go build ; ./hanayo ; ./hanayo
			else
				die 1 "Could not install '$task' because golang wasn't found on this system."
			fi
				if [ -f "hanayo.conf" ]; then
					sed -Ei "s/ListenTo=:45221/ListenTo=127.0.0.1:45221/g" hanayo.conf || die 74 "Failed to Setup Config file. [$task/hanayo.conf -> ListenTo]"
					sed -E -i -e 'H;1h;$!d;x' hanayo.conf -e 's#DSN=#DSN='"$mysql_user"':'"$mysql_password"'@/'"$database_name"'#' || die 1 "Failed to Setup Config file. [$task/hanayo.conf -> mysql-user, pass, db]"
					sed -Ei "s:^RedisEnable=.*$:RedisEnable=true:g" hanayo.conf || die 74 "Failed to Setup Config file. [$task/hanayo.conf -> Redis]"
					sed -Ei "s/ripple.moe/$domain/g" hanayo.conf || die 74 "Failed to Setup Config file. [$task/hanayo.conf -> domain]"
					sed -Ei "s:^APISecret=.*$:APISecret=$api_secret:g" hanayo.conf || die 74 "Failed to Setup Config file. [$task/hanayo.conf -> api_secret]"
					sed -Ei "s:^MainRippleFolder=.*$:MainRippleFolder=$directory:g" hanayo.conf || die 74 "Failed to Setup Config file. [$task/hanayo.conf -> directory]"
					sed -Ei "s:^AvatarsFolder=.*$:AvatarsFolder=$directory/nginx/avatar-server/Avatars:g" hanayo.conf || die 74 "Failed to Setup Config file. [$task/hanayo.conf -> avatar-folder]"
					sed -Ei "s#https://storage.$domain/api#'https://storage.ripple.moe/api'#g" hanayo.conf || die 74 "Failed to Setup Config file. [$task/hanayo.conf -> cheesegull]"
				else
					die 1 "Failed To Configure '$task'."
				fi

				if [ -f "templates/navbar.html" ]; then
					sed -Ei 's#ripple.moe#'"$domain"'#' templates/navbar.html
				fi

				if [ ! -d "$directory/hanayo" ]; then
					mv -v go/src/zxq.co/ripple/hanayo "$directory"
					GPRINT "Done Setting Up '$task'."
				else
					die 12 "Unexpected Error!"
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

	YPRINT "Cloning & Setting up '$task'."

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 zxq.co || die 121 "Domain 'zxq.co' is not reachable from this environment."
	else
		die 61 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			if command -v go 1>/dev/null; then
				go get zxq.co/ripple/rippleapi
				cd go/src/zxq.co/ripple/rippleapi || die 1 "Failed to cd into '$task'."
				go build ; ./rippleapi
			else
				die 1 "Could not install '$task' because golang wasn't found on this system."
			fi

			if [ ! -f "api.conf" ]; then
				sed -E -i -e 'H;1h;$!d;x' api.conf -e 's#DSN=#DSN='"$mysql_user"':'"$mysql_password"'@/'"$database_name"'#' || die 1 "Failed to Setup Config file. [$task/api.conf -> mysql-user, pass, db]"
				sed -Ei "s:^HanayoKey=.*$:HanayoKey=$api_secret:g" api.conf || die 74 "Failed to Setup Config file. [$task/api.conf -> api_secret]"
				sed -Ei "s:^OsuAPIKey=.*$:OsuAPIKey=$cikey:g" api.conf || die 74 "Failed to Setup Config file. [$task/api.conf -> cikey]"
			fi

			if [ ! -d "$directory/rippleapi" ]; then
				mv -v go/src/zxq.co/ripple/rippleapi "$directory"
				GPRINT "Done setting up '$task'."
			else
				die 12 "Unexpected Error!"
			fi
		)
	else
		die 1 "Directory '$directory' doesn't exist."
	fi
}


# Avatar-Server handles/manages ingame & frontend's avatars of all users.
avatar_server() {

	task="avatar-server"

	YPRINT "Cloning & Setting up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 github.com || die 121 "Domain 'github.com' is not reachable from this environment."
	else
		die 61 "Unknown Error!"
	fi

	if [ -d "$directory" ]; then
		(
			cd "$directory" || die 1 "Failed to cd into '$directory'"

			if command -v git 1>/dev/null; then
				git clone https://github.com/Uniminin/avatar-server
			else
				die 1 "git not found on this system!"
			fi

			if [ -d "avatar-server" ]; then
				cd avatar-server || die 1 "Failed to cd into '$task'."
				python3.6 -m pip install -r requirements.txt
				GPRINT "Done setting up '$task'."
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

	YPRINT "Cloning & Setting up '$task'!"

	if command -v ping 1>/dev/null; then
		ping -i 0.5 -c 5 zxq.co || die 121 "Domain 'zxq.co' is not reachable from this environment."
		ping -i 0.5 -c 5 getcomposer.org || die 121 "Domain 'getcomposer.org' is not reachable from this environment."
	else
		die 61 "Unknown Error!"
	fi

	# Dependencies
	if [ "$package_manager" = "apt" ]; then
		"$package_manager" install build-essential \
		apt install apt-transport-https lsb-release ca-certificates -y
		wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
		echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list
		"$package_manager" update
		"$package_manager" install php7.2 php7.2-cli php7.2-common php7.2-json \
		php7.2-opcache php7.2-mysql php7.2-zip php7.2-fpm php7.2-mbstring -y
		curl -sS https://getcomposer.org/installer -o composer-setup.php
		php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') \
		{ echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
		php composer-setup.php --install-dir=/usr/local/bin --filename=composer

	elif [ "$package_manager" = "pacman" ]; then
		"$package_manager" --noconfirm -S php composer

	elif [ "$package_manager" = "emerge" ]; then
		"$package_manager" -q dev-lang/php dev-lang/composer

	elif [ "$package_manager" = "cave" ]; then
		"$package_manager" resolve -x dev-lang/php dev-php/composer
	fi

	for packages in php composer; do
		if command -v $packages >/dev/null; then
			GPRINT "Done Installing necessary Dependencies required for '$task'"
		else
			die 1 "Failed to Install necessary Dependencies required for '$task'"
		fi
	done

	(
		if [ ! -d "/var/www/" ]; then
			mkdir -v /var/www/ ; cd /var/www/ || die 1 "Could not cd into '/var/www/'"

			if command -v git 1>/dev/null; then
				git clone https://zxq.co/ripple/old-frontend osu.ppy.sh
			else
				 1 "git not found on this system!"
			fi

			if [ -d "osu.ppy.sh" ]; then
				cd osu.ppy.sh || die 1 "Failed to cd into 'osu.ppy.sh'"
				curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
				(
					cd inc || die 1 "Failed to cd into 'inc'"
					cp -v config.sample.php config.php

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

				GPRINT "Done setting up 'old-frontend'."
			fi
		else
			die 61 "Unknown Error!"
		fi
	)
}



while [ "$#" -ge 0 ]; do case "$1" in
	"--all" | "-A")
		case "$2" in
			"--nodependencies" | "--nodep")
				checkRoot
				DetectPackageManager
				inputs
				checkNetwork
				mysql_database
				peppy
				lets
				avatar_server
				hanayo
				rippleapi
				frontend
				phpmyadmin
				nginx
				SSL
				exit 0 ;;
		esac
		
		checkRoot
		DetectPackageManager
		inputs
		checkNetwork
		packageManagerUpgrade
		mysql_database
		python_dependencies
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
		SSL
		exit 0 ;;

	"--help" | "-h")
		GPRINT \
		"Note: 'sudo $0 --<arguments>'" \
		"Upstream Version: $UPSTREAM_VERSION" \
		"" \
		"Usage:" \
		"   --help, -h             Shows the list of all arguments including relevant informations." \
		"   --all, -A              To Setup Entire Ripple Stack with Dependencies!" \
		"   --dependencies, -dep   To Install all the necessary dependencies required for Ripple Stack." \
		"   --mysql, -M            To Install & Setup MySQL DB with Dependencies." \
		"   --peppy, -P            To Clone & Setup peppy with Dependencies." \
		"   --lets, -L             To Clone & Setup lets with Dependencies." \
		"   --hanayo, -H           To Clone & Setup hanayo with Dependencies." \
		"   --rippleapi, -api      To Clone & Setup rippleapi with Dependencies." \
		"   --avatarserver, -AS    To Clone & Setup avatar-server with Dependencies." \
		"   --oldfrontend, -OF     To Clone & Setup oldfrontend with Dependencies." \
		"   --nginx, -N            To Install & Configure Nginx with nginx Dependencies." \
		"   --version, -V          Prints the upstream version of the script." \
		"" \
		"Without Dependencies:" \
		"   --nodependencies, --nodep" \
		"" \
		"Examples:" \
		"sudo $0 --all            To Setup Entire Ripple Stack with Dependencies!" \
		"sudo $0 -peppy --nodep   To Clone & Setup peppy without Dependencies." \
		"" \
		"Report bugs to: 'uniminin@zoho.com' or Discord: 'uniminin#7522'" \
		"RAI Repository URL: <https://github.com/Uniminin/Ripple-Auto-Installer/>" \
		"GNU AGPLv3 Licence: <https://www.gnu.org/licenses/agpl-3.0.en.html/>" \
		"General help using GNU software: <https://www.gnu.org/gethelp/>"
		exit 0 ;;

	"--dependencies" | "-dep")
		checkRoot
		DetectPackageManager
		checkNetwork
		packageManagerUpgrade
		python_dependencies
		nproc_detector
		python3_5
		python3_6
		golang
		phpmyadmin
		extra_dependencies
		exit 0 ;;

	"--mysql" | "-M")
		checkRoot
		DetectPackageManager
		inputs
		checkNetwork
		packageManagerUpgrade
		mysql_database
		exit 0 ;;

	"--peppy" | "-P")
		case "$2" in
			"--nodependencies" | "--nodep")
				inputs
				checkNetwork
				peppy
				exit 0 ;;
		esac
		
		checkRoot
		DetectPackageManager
		inputs
		checkNetwork
		packageManagerUpgrade
		python_dependencies
		nproc_detector
		python3_5
		peppy
		exit 0 ;;

	"--lets" | "-L")
		case "$2" in
			"--nodependencies" | "--nodep")
				inputs
				checkNetwork
				lets
				exit 0 ;;
		esac
		
		checkRoot
		DetectPackageManager
		inputs
		checkNetwork
		packageManagerUpgrade
		python_dependencies
		nproc_detector
		python3_6
		lets
		exit 0 ;;

	"--avatarserver" | "-AS")
		case "$2" in
			"--nodependencies" | "--nodep")
				inputs
				checkNetwork
				avatar_server
				exit 0 ;;
		esac
		
		checkRoot
		DetectPackageManager
		inputs
		checkNetwork
		packageManagerUpgrade
		python_dependencies
		nproc_detector
		python3_6
		avatar_server
		exit 0 ;;

	"--hanayo" | "-H")
		case "$2" in
			"--nodependencies" | "--nodep")
				inputs
				checkNetwork
				hanayo
				exit 0 ;;
		esac
		
		checkRoot
		DetectPackageManager
		inputs
		checkNetwork
		packageManagerUpgrade
		golang
		hanayo
		exit 0 ;;

	"--rippleapi" | "-api")
		case "$2" in
			"--nodependencies" | "--nodep")
				inputs
				checkNetwork
				rippleapi
				exit 0 ;;
		esac
		
		checkRoot
		DetectPackageManager
		inputs
		checkNetwork
		packageManagerUpgrade
		golang
		rippleapi
		exit 0 ;;

	"--oldfrontend" | "-OF")
		case "$2" in
			"--nodependencies" | "--nodep")
				inputs
				checkNetwork
				old_frontend
				exit 0 ;;
		esac
		
		checkRoot
		DetectPackageManager
		inputs
		checkNetwork
		packageManagerUpgrade
		php
		old_frontend
		exit 0 ;;

	"--nginx" | "-N")
		case "$2" in
			"--nodependencies" | "--nodep")
				checkNetwork
				nginx
				exit 0 ;;
		esac
		
		checkRoot
		DetectPackageManager
		checkNetwork
		packageManagerUpgrade
		extra_dependencies
		nginx
		exit 0 ;;

	"--version" | "-V")
		YPRINT "Version: $UPSTREAM_VERSION"
		exit 0 ;;

	"")
		RPRINT "Fatal: No argument were provided | Try: $0 --help"
		exit 74 ;;

	*)
		RPRINT "Fatal: Unknown argument | Try: $0 --help"
		exit 74 ;;

esac; shift; done
