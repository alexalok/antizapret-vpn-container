AntiZapret VPN Container
========================

#### Создайте свой личный VPN АнтиЗапрета за 10 минут!

**Что это?** Это полный аналог сервиса для получения доступа к заблокированным сайтам в Российской Федерации [АнтиЗапрет VPN](https://antizapret.prostovpn.org/), пригодный для установки на личный сервер в интернете.

**Какие преимущества перед обычным VPN?** Обычные VPN направляют трафик ко всем сайтам и сервисам через свои серверы, что понижает общую скорость работы интернета. АнтиЗапрет направляет трафик на свои серверы только к сайтам и сервисам, заблокированным на территории Российской Федерации, и не снижает скорость открытия других сайтов.

**Зачем нужен этот контейнер?** Он нужен в случаях, если вы не доверяете администратору сервиса АнтиЗапрет, недовольны скоростью работы или просто хотите запустить аналог сервиса для себя на собственном оборудовании.

**Вам потребуется:**

* Личный сервер или VPS с виртуализацией XEN или KVM (OpenVZ не подойдёт), с выделенным IPv4-адресом, минимум 384 МБ оперативной памяти и 700 МБ свободного места;
* Любой современный дистрибутив Linux, где доступен LXD или systemd-machined (рекомендуется Ubuntu 18.04 LTS, Ubuntu 20.04 LTS);

**Рекомендуемые протестированные хостинг-провайдеры**: [ITLDC](https://itldc.com/?from=51099) (сервер SSD VDS 1G за €3.49), [Vultr](https://www.vultr.com/?ref=8592407-6G) (серверы за $3.5 и $5, при регистрации по ссылке даётся бонус на первый месяц), [Scaleway](https://www.scaleway.com/en/) (сервер DEV1-S за €2.99).  
*Часть ссылок — реферальные. При покупке сервера по реферальным ссылкам выше, часть оплаченной суммы пойдёт на содержание серверов АнтиЗапрета.*


## Установка на собственный сервер

### С помощью LXD

Сперва установите и настройте LXD (произведите `lxd init`), затем выполните следующие команды от root (с sudo):

```
lxc image import https://antizapret.prostovpn.org/container-images/az-vpn --alias antizapret-vpn-img
lxc init antizapret-vpn-img antizapret-vpn
lxc config device add antizapret-vpn proxy_1194 proxy listen=tcp:[::]:1194 connect=tcp:127.0.0.1:1194
lxc start antizapret-vpn
sleep 10
lxc file pull antizapret-vpn/root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-tcp.ovpn antizapret-client-tcp.ovpn
```

Протестировано на Ubuntu 20.04.

### С помощью systemd-machined

Выполните следующие команды от root (с sudo):

```
gpg --no-default-keyring --keyring /etc/systemd/import-pubring.gpg --keyserver hkps://keyserver.ubuntu.com --receive-keys 0xEF2E2223D08B38D4B51FFB9E7135A006B28E1285

machinectl pull-tar https://antizapret.prostovpn.org/container-images/az-vpn/rootfs.tar.xz antizapret-vpn
mkdir -p /etc/systemd/nspawn/
echo -e "[Network]\nVirtualEthernet=yes\nPort=tcp:1194:1194\nPort=udp:1194:1194" > /etc/systemd/nspawn/antizapret-vpn.nspawn

systemctl enable --now systemd-networkd.service
machinectl enable antizapret-vpn
machinectl start antizapret-vpn
sleep 10
machinectl copy-from antizapret-vpn /root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-tcp.ovpn antizapret-client-tcp.ovpn
```

Протестировано на Ubuntu 20.04.

### Установка на Vultr и Scaleway (с помощью cloud-init)

**Scaleway**: при создании нового сервера (instance) выберите ОС Ubuntu 20.04, после пункта #5 (Enter a Name and Optional Tags) нажмите на кнопку "Advanced Options", активируйте "Cloud-init", скопируйте и вставьте скрипт ниже.

**Vultr**: при создании нового сервера выберите ОС Ubuntu 20.04, в пункте Startup Script создайте новый скрипт кнопкой Add New убедитесь, что тип скрипта — Boot, скопируйте и вставьте скрипт ниже.

```
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
apt update
apt -y install systemd-container dirmngr
mkdir -p /root/.gnupg/
gpg --no-default-keyring --keyring /etc/systemd/import-pubring.gpg --keyserver hkps://keyserver.ubuntu.com --receive-keys 0xEF2E2223D08B38D4B51FFB9E7135A006B28E1285

machinectl pull-tar https://antizapret.prostovpn.org/container-images/az-vpn/rootfs.tar.xz antizapret-vpn
mkdir -p /etc/systemd/nspawn/
echo -e "[Network]\nVirtualEthernet=yes\nPort=tcp:1194:1194\nPort=udp:1194:1194" > /etc/systemd/nspawn/antizapret-vpn.nspawn

systemctl enable --now systemd-networkd.service
machinectl enable antizapret-vpn
machinectl start antizapret-vpn
sleep 20
machinectl copy-from antizapret-vpn /root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-tcp.ovpn /root/antizapret-client-tcp.ovpn
```

По завершении создания сервера у вас уже будет установлен АнтиЗапрет.


## После установки

После выполнения команд, скопируйте файл `antizapret-client-tcp.ovpn` с сервера на ваш компьютер, с помощью программы FileZilla (Windows, macOS, Linux) или WinSCP (только для Windows), по протоколу **SFTP**.  
Это ваш конфигурационный файл OpenVPN, который нужно импортировать в программу OpenVPN на компьютере и OpenVPN Connect на Android и iOS.


## Особенности VPN

### Нестандартный способ маршрутизации

В отличие от обычных VPN, осуществляющих перенаправление отдельных IP-адресов или диапазонов средствами маршрутизации ОС, VPN АнтиЗапрета использует маршрутизацию на основе доменных имен, с помощью специального DNS-сервера, созданного для этой цели.

На VPN-сервере запущен специальный DNS-резолвер, устанавливающий отображение (соответствие, маппинг) настоящего IP-адреса домена в свободный IP-адрес большой внутренней подсети, и отдающий запрашиваемому клиенту адрес из внутренней подсети.

У такого подхода есть множество преимуществ:

* Клиенту устанавливается только один или несколько маршрутов, вместо десятков тысяч маршрутов;
* Маршрутизируются только заблокированные **домены**, а не все сайты на заблокированном IP-адресе;
* Возможность обновления списка заблокированных сайтов без переподключения клиента;
* Корректная работа с доменами, постоянно меняющими IP-адреса, и с CDN-сервисами;
* Корректная работа с провайдерами, блокирующими все поддомены заблокированного домена (блокировка всей DNS-зоны). Пример такого провайдера — Yota.

Но есть и минусы:

* Необходимо использовать только DNS-сервер внутри VPN. С другими DNS-серверами работать не будет.
* Работает только для заблокированных доменов и программ, использующих доменные имена. Для заблокированных IP-адресов необходимо использовать обычную маршрутизацию.

Схематичное представление:

```
📱 — Клиент
🖥 — VPN и DNS-сервер
🖧 — Интернет

📱 → rutracker.org? → 🖥
  🖥 → rutracker.org? → 🖧
  🖥 ← 195.82.146.214 ← 🖧
  10.224.0.1 → 195.82.146.214
📱 ← 10.224.0.1 ← 🖥
```

Обычная способ маршрутизации также применяется, но только для больших диапазонов заблокированных адресов (всего несколько маршрутов).

### Намеренное удаление IPv6-адресов

Текущая версия специального DNS-сервера не работает с IPv6 и намеренно удаляет IPv6-адреса (AAAA-записи) из DNS-ответов, чтобы у пользователей, провайдеры которых предоставляют IPv6-связность, работал обход блокировок.

Это не является серьёзным недостатком, так как сайтов, доступных только по IPv6, но не по IPv4, практически не существует.

Корректная поддержка IPv6 запланирована в следующих версиях специального DNS-сервера.

### Работа со сторонними DNS-зонами

Контейнер настроен на работу с дополнительными доменными зонами, которые используются некоторыми заблокированными сайтами:

* OpenNIC (`.bbs, .chan, .cyb, .geek, .pirate` и другие);
* EmerDNS (`.lib, .emc, .coin, .bazar`);
* Namecoin (`.bit`).

## Техническая поддержка

Техническая поддержка осуществляется на форуме NTC Community: https://ntc.party/c/antizapret-prostovpn-org
