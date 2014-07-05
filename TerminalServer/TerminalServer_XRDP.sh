#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

# С сайта http://scarygliders.net/ берем адрес скрипта для автоматической компиляции XRDP из исходников самой последней доступной версии.
# На момент написания статьи это можно было сделать так:
apt-get -y install git
mkdir -p /opt/install/
cd /opt/install
git clone https://github.com/scarygliders/X11RDP-o-Matic.git
cd X11RDP-o-Matic
sudo ./X11rdp-o-matic.sh --justdoit
# стартует долгий процесс скачивания, проверки и компиляции модулей для xrdp, обязательно нужно дождатся завершения процедуры...
# В папке /X11RDP-o-Matic/packages/ лежат уже готовые собранные пакеты x11rdp_0.7.0-1_amd64.deb, xrdp_0.7.0-1_amd64.deb,
# пригодятся при переинсталированнии сервера без необходимости еще раз компилировать и собирать xrdp из исходников.
# Проверяем установку xrdp:
# sudo service xrdp restart
/etc/init.d/xrdp restart
netstat -lntp |grep 3389
# Ставим xrdp в автозагрузку:
update-rc.d xrdp defaults
update-rc.d xrdp enable
# Там же в папке /X11RDP-o-Matic/ находится скрипт создания файла *.xsession с командой startlxde для запуска LXDE при подключении пользователей:
./RDPsesconfig.sh

echo lxsession -s Lubuntu -e LXDE> ~/.xsession
