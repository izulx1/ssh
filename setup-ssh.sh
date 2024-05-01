#!/bin/bash

os=$(cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g')
os2=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')

echo "$(wget -qO- ipinfo.io/ip)" > /root/.myip
MYIP=$(cat /root/.myip)

clear
mkdir -p /etc/xray
GITHUB_CMD="https://github.com/izulx1/ssh/raw/master/files/"
function add_domain() {
read -p "Input Domain :  " domain
if [[ ${domain} ]]; then
echo $domain >/etc/xray/domain
else
echo -e " Please input your Domain"
add_domain
fi
}

add_domain
apt update -y
apt install sudo -y
sudo apt-get clean all
sudo apt-get autoremove -y
apt install -y debconf-utils
sudo apt-get remove --purge exim4 -y
sudo apt-get remove --purge ufw firewalld -y
apt install -y --no-install-recommends software-properties-common
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
apt install -y speedtest-cli jq iptables iptables-persistent netfilter-persistent net-tools socat cron dropbear squid neofetch

if [[ $os == "ubuntu" ]]; then
echo "Setup Dependencies $os2"
sudo apt update -y
apt-get install --no-install-recommends software-properties-common
add-apt-repository ppa:vbernat/haproxy-2.0 -y
apt-get -y install haproxy=2.0.\*
elif [[ $os == "debian" ]]; then
echo "Setup Dependencies For OS Is $os2"
curl https://haproxy.debian.net/bernat.debian.org.gpg |
gpg --dearmor >/usr/share/keyrings/haproxy.debian.net.gpg
echo deb "[signed-by=/usr/share/keyrings/haproxy.debian.net.gpg]" \
http://haproxy.debian.net buster-backports-1.8 main \
>/etc/apt/sources.list.d/haproxy.list
sudo apt-get update
apt-get -y install haproxy=1.8.\*
else
rcho -e " Your OS Is Not Supported ($os2 )"
exit 1
fi

source <(curl -sL ${GITHUB_CMD}bbr)

if [[ $os == "ubuntu" ]]; then
echo "Setup nginx For OS Is $os2"
rm -f /etc/apt/sources.list.d/nginx.list
apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor |
tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" |
tee /etc/apt/sources.list.d/nginx.list
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" |
tee /etc/apt/preferences.d/99nginx
apt update -y
apt install -y nginx
elif [[ $os == "debian" ]]; then
echo "Setup nginx For OS Is $os2 "
INS="apt install -y"
rm -f /etc/apt/sources.list.d/nginx.list
apt install -y curl gnupg2 ca-certificates lsb-release debian-archive-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor |
tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/debian $(lsb_release -cs) nginx" |
tee /etc/apt/sources.list.d/nginx.list
echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" |
tee /etc/apt/preferences.d/99nginx
apt update -y
apt install -y nginx
else
echo -e "Your OS Is Not Supported ($os2 )"
exit 1
fi

cat >/root/.profile <<END
# ~/.profile: executed by Bourne-compatible login shells.
if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then

    . ~/.bashrc
  fi
fi
mesg n || true
source '/usr/bin/menu'
clear
neofetch
echo "Silahkan Ketik menu Untuk Melihat daftar Perintah"
END
cd

wget -q -O /usr/bin/menu "${GITHUB_CMD}menu.sh"
wget -q -O /usr/bin/clearlog "${GITHUB_CMD}clearlog"
wget -q -O /usr/bin/xp "${GITHUB_CMD}xp.sh"
wget -q -O /etc/squid/squid.conf "${GITHUB_CMD}squid.conf"
wget -q -O /etc/default/dropbear "${GITHUB_CMD}dropbear"
wget -q -O /etc/ssh/sshd_config "${GITHUB_CMD}sshd"
wget -q -O /etc/banner.com "${GITHUB_CMD}banner.com"
wget -q -O /etc/nginx/nginx.conf "${GITHUB_CMD}nginx.conf"
wget -q -O /etc/haproxy/haproxy.cfg "${GITHUB_CMD}haproxy.cfg"
wget -q -O /etc/nameserver "https://github.com/FighterTunnel/tunnel/raw/main/X-SlowDNS/nameserver"
bash /etc/nameserver >/dev/null 2>&1
wget -q -O /usr/sbin/xdvpn "${GITHUB_CMD}xdvpn"
wget -q -O /etc/systemd/system/ws.service "${GITHUB_CMD}ws.service"
wget -q -O /usr/bin/ws "${GITHUB_CMD}ws"
wget -q -O /usr/bin/ws.conf "${GITHUB_CMD}ws.conf"
source <(curl -sL ${GITHUB_CMD}ins-badvpn)
mkdir -p /etc/udp
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
wget -q -O /etc/udp/udp-custom "https://github.com/izulx1/ssh/raw/master/udp/udp-custom-linux-amd64"
wget -q -O /etc/udp/config.json "https://github.com/izulx1/ssh/raw/master/udp/config.json"
wget -q -O /etc/systemd/system/udp.service "https://github.com/izulx1/ssh/raw/master/udp/udp.service"
sed -i "s/xxx/${MYIP}/g" /etc/squid/squid.conf
chmod 777 /usr/sbin/xdvpn
chmod 777 /usr/bin/ws
chmod 777 /etc/udp/config.json
chmod 777 /etc/udp/udp-custom
chmod 777 /usr/bin/clearlog
chmod 777 /usr/bin/xp
rm -rf /lib/systemd/system/haproxy.service
cat >/etc/systemd/system/haproxy.service <<-END
[Unit]
Description=XDTunnel Server Balancer
Documentation=https://t.me/xdxl_store
After=network-online.target rsyslog.service
Wants=network-online.target

[Service]
EnvironmentFile=-/etc/default/haproxy
EnvironmentFile=-/etc/sysconfig/haproxy
Environment="CONFIG=/etc/haproxy/haproxy.cfg" "PIDFILE=/run/haproxy.pid"
ExecStartPre=/usr/sbin/xdvpn -Ws -f \$CONFIG -c -q \$EXTRAOPTS
ExecStart=/usr/sbin/xdvpn -Ws -f \$CONFIG -p \$PIDFILE \$EXTRAOPTS
ExecReload=/usr/sbin/xdvpn -Ws -f \$CONFIG -c -q \$EXTRAOPTS
ExecReload=/bin/kill -USR2 \$MAINPID
KillMode=mixed
Restart=always
SuccessExitStatus=143
Type=notify

[Install]
WantedBy=multi-user.target
END
chmod 777 /usr/bin/menu
mkdir /root/.acme.sh
systemctl daemon-reload
systemctl stop haproxy
systemctl stop nginx
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
cat /etc/xray/xray.crt /etc/xray/xray.key | tee /etc/haproxy/hap.pem

# Monitoring Gotop
gotop_latest="$(curl -s https://api.github.com/repos/xxxserxxx/gotop/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
gotop_link="https://github.com/xxxserxxx/gotop/releases/download/v$gotop_latest/gotop_v"$gotop_latest"_linux_amd64.deb"
curl -sL "$gotop_link" -o /tmp/gotop.deb
dpkg -i /tmp/gotop.deb >/dev/null 2>&1

# Auto Clear Log Setiap 120 Menit
cat >/etc/cron.d/clearlog <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/120 * * * * root clearlog
END

# Auto Delete User SSH Expired
cat >/etc/cron.d/del_exp <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root xp
END

# Auto Reboot VPS Jam 3 Pagi
cat >/etc/cron.d/del_exp <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
* 3 * * * root reboot
END

# Swap 1GB
dd if=/dev/zero of=/swapfile bs=1024 count=1048576
mkswap /swapfile
chown root:root /swapfile
chmod 0600 /swapfile >/dev/null 2>&1
swapon /swapfile >/dev/null 2>&1
sed -i '$ i\/swapfile  swap swap   defaults 0 0' /etc/fstab

systemctl daemon-reload
systemctl enable client server
systemctl enable netfilter-persistent
systemctl enable ws haproxy udp cron
systemctl start client server haproxy
systemctl start netfilter-persistent
systemctl restart client server
systemctl restart ws cron dropbear haproxy rc-local sshd nginx cron
systemctl restart netfilter-persistent
clear
neofetch
echo "Script berhasil Di install"
echo -ne "Please Reboot Your Vps (y/n)? "
read REDDIR
if [ "$REDDIR" == "${REDDIR#[Yy]}" ]; then
exit 0
reboot
else
reboot
fi
