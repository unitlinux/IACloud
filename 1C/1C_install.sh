#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

#------------------------------------------------
# Установка 1C server и 1C client
#------------------------------------------------
# Установка дополнительных пакетов совместимости
# Для ttf-mscorefonts-installer нужно принять условия лицензии
apt-get -y install imagemagick unixodbc libgsf-bin t1utils ttf-mscorefonts-installer texlive-base

# Увеличиваем максимальный размер сегмента памяти до 1Гб. Для менее мощных машин устанавливают от 64Мб до половины объема ОЗУ (для теста выделим 1Gb):
echo "kernel.shmmax=1073741824" >>/etc/sysctl.conf
sysctl -p
# Генерируем русскую локаль и задаем переменную среды LANG, именно с ней будет работать скрипт инициализации базы данных.
locale-gen en_US ru_RU ru_RU.UTF-8
export LANG="ru_RU.UTF-8"

# Установка 1С
# Ссылку для скачивания ищем на сайте http://users.v8.1c.ru/
# wget http://*.v8.1c.ru/.*./.*./.*./.*./deb64.tar.gz
# Перед загрузкой нужно авторизироваться на сайте 1С
wget http://downloads.v8.1c.ru/get/Info/Platform/8_3_4_496/deb64.tar.gz
wget http://downloads.v8.1c.ru/get/Info/Platform/8_3_4_496/client.deb64.tar.gz
# Распаковываем файлы deb64.tar.gz и client.deb64.tar.gz из дистрибутива 1С 8.3 в одну папку.
#------------------------------------------------

tar xvfz deb64.tar.gz
tar xvfz client.deb64.tar.gz
# Примечание:
# NLS-ы точно не нужно (это для дистрибов где русской кодировки нет, а такие сейчас поискать нужно :))
# WS-ка нужна только если собираешся веб-сервис публиковать
# Перечисленные пакеты можно удалить
sudo dpkg -i 1c*.deb
# При установке пакетов 1С:Предприятия 8.3 могут быть ошибки «сломанных» связей... исправляем связи:
apt-get -f install
# УРААААААААААА!!! Все получилось!
# Для проверки того, все ли пакеты установились корректно выполняем комадну:
dpkg -l | grep 1c-enterprise83

# Запускаем скрипт конфигурации платформы 1С: (на новые версии 8.3 не работает)
sudo /opt/1C/v8.3/i386/utils/config_system /usr/share/fonts/truetype/msttcorefonts
