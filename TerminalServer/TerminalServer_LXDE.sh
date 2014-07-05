#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

sudo apt-get -y install --no-install-recommends lubuntu-desktop

# Делаем автоматический вход в Ubuntu Lxde:
# nano /etc/lxdm/lxdm.conf
# надо раскомментировать (убрать #) перед autologin в самом начале файла,
# поставить имя желаемого пользователя для автовхода:
# autologin=ИмяПользователяДляАвтовхода
# Если работаем под VirtualBox ставим дополнения virtualbox-guest-x11
# apt-get install virtualbox-guest-x11
# перезагрузка, теперь при старте сразу попадаем на рабочий стол lxde


echo;
echo "################################################################################################"
echo;
echo "Please refer to https://github.com/StackGeek/openstackgeek/blob/master/readme.md for setup help."
echo;
echo "################################################################################################"
echo;
