export DEBIAN_FRONTEND=noninteractive
apt update
apt -y upgrade
apt -y install python3-pip python3-venv virtualenvwrapper
echo 'source "/usr/share/virtualenvwrapper/virtualenvwrapper.sh"' >> /home/vagrant/.bash_profile