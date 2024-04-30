#!/bin/bash

domain=$(cat /etc/xray/domain)
pub=$(cat /etc/slowdns/server.pub)
ns=$(cat /etc/xray/dns)
IP=$(cat /root/.myip)

NC='\033[0m'
r='\033[1;91m'
g='\033[1;92m'
y='\033[1;93m'
c='\033[1;96m'
pth='\033[1;97m'

function lane() {
echo -e "${y}========================${NC}"
}

function addssh() {
clear
lane
echo -e " Create SSH Account"
lane
read -p "Username : " user
read -p "Password : " pass
read -p "Expired (Days) : " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
hariini=`date -d "0 days" +"%Y-%m-%d"`
useradd -e $exp -s /bin/false -M $user
expi="$(chage -l $user | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$pass\n$pass\n"|passwd $user &> /dev/null
clear
lane
echo -e "     SSH ACCOUNT"
lane
echo -e " Username : $user "
echo -e " Password : $pass "
lane
echo -e " Host : $domain "
echo -e " Host IP : $IP "
echo -e " Dropbear : 143, 109"
echo -e " OpenSSH : 22"
echo -e " Port TLS  : 443"
echo -e " Port NTLS : 80"
echo -e " Port DNS  : 53"
echo -e " Port UDP  : 54-65535"
echo -e " BadVPN : 7100, 7200, 7300"
lane
echo -e " Host DNS : $ns "
echo -e " Pubkey : $pub "
lane
echo -e " Created On : $hariini "
echo -e " Expired On : $exp "
lane
exit 0
}
function dnstt() {
clear
read -rp "Input ur NS Domain : " -e NS_DOMAIN
echo $NS_DOMAIN >/etc/xray/dns
sed -i "s/$NS/$NS_DOMAIN/g" /etc/systemd/system/client.service
sed -i "s/$NS/$NS_DOMAIN/g" /etc/systemd/system/server.service
systemctl daemon-reload
systemctl restart server
systemctl restart client
echo "Change NS DOMAIN (SLOWDNS) Successfully"
exit 0
}
function domain() {
clear
read -rp "Input ur Domain/Host : " -e domain
systemctl stop haproxy
systemctl stop nginx
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
/root/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
rm -rf /etc/xray/domain
echo $domain >/etc/xray/domain
cat /etc/xray/xray.crt /etc/xray/xray.key | tee /etc/haproxy/hap.pem
systemctl daemon-reload
systemctl restart nginx
systemctl restart server
systemctl restart client
systemctl restart haproxy
menu
}
function memssh() {
clear
echo -e "${y}========================================${NC}"
echo -e "\E[1;41;97m           MEMBER SSH ACCOUNT           \E[0m"
echo -e "${y}========================================${NC}"
echo "USERNAME    EXP DATE       STATUS"
echo -e "${y}========================================${NC}"
while read expired
do
AKUN="$(echo $expired | cut -d: -f1)"
ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
status="$(passwd -S $AKUN | awk '{print $2}' )"
if [[ $ID -ge 1000 ]]; then
if [[ "$status" = "L" ]]; then
printf "%-11s %2s %-14s %2s \n" "$AKUN" "$exp  " "LOCKED"
else
printf "%-11s %2s %-14s %2s \n" "$AKUN" "$exp  " "UNLOCKED"
fi
fi
done < /etc/passwd
JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
echo -e "${y}========================================${NC}"
echo -e " Total Account SSH ${JUMLAH} User"
echo -e "${y}========================================${NC}"
echo -e ""
exit 0
}

function run() {
drbear=$(/etc/init.d/dropbear status | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
ws_epro=$(systemctl status ws | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
nginx=$(systemctl status nginx | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
hap=$(systemctl status haproxy | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
udp=$(systemctl status udp | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
dns_ser=$(systemctl status server | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
dns_clint=$(systemctl status client | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )

if [[ $drbear == "running" ]]; then
sts_dropbear="[${g}ON{NC}]"
else
sts_dropbear="[${r}OFF${NC}]"
fi

if [[ $ws_epro == "running" ]]; then
sts_ws="[${g}ON{NC}]"
else
sts_ws="[${r}OFF${NC}]"
fi

if [[ $nginx == "running" ]]; then
sts_nginx="[${g}ON{NC}]"
else
sts_nginx="[${r}OFF${NC}]"
fi

if [[ $hap == "running" ]]; then
sts_hap="[${g}ON{NC}]"
else
sts_hap="[${r}OFF${NC}]"
fi

if [[ $udp == "running" ]]; then
sts_udp="[${g}ON{NC}]"
else
sts_udp="[${r}OFF${NC}]"
fi

if [[ $dns_ser == "running" ]]; then
sts_ser="[${g}ON{NC}]"
else
sts_ser="[${r}OFF${NC}]"
fi

if [[ $dns_clint == "running" ]]; then
sts_clint="[${g}ON{NC}]"
else
sts_clint="[${r}OFF${NC}]"
fi

clear
neofetch
echo -e " Dropbear : ${sts_dropbear}"
echo -e " Ws ePRO : ${sts_ws}"
echo -e " Nginx : ${sts_nginx}"
echo -e " Haproxy : ${sts_hap}"
echo -e " Udp HC : ${sts_udp}"
echo -e " DNS Client : ${sts_clint}"
echo -e " DNS Server : ${sts_ser}"
exit 0
}
function checkssh() {
clear
if [ -e "/var/log/auth.log" ]; then
        LOG="/var/log/auth.log";
fi
if [ -e "/var/log/secure" ]; then
        LOG="/var/log/secure";
fi
logindrbr=( `ps aux | grep -i dropbear | awk '{print $2}'`);
echo -e "${y}====================================================${NC}"
echo "    User Login SSH Dropbear"
echo -e "${y}====================================================${NC}"
echo "   PID  |  Username  |  IP Address";
cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/login-db.txt;
for PID in "${logindrbr[@]}"
do
            cat /tmp/login-db.txt | grep "dropbear\[$PID\]" > /tmp/login-db-pid.txt;
            NUM=`cat /tmp/login-db-pid.txt | wc -l`;
            USER=`cat /tmp/login-db-pid.txt | awk '{print $10}'`;
            IP=`cat /tmp/login-db-pid.txt | awk '{print $12}'`;
            if [ $NUM -eq 1 ]; then
                    echo "  $PID - $USER - $IP";
                    fi
done
echo -e "${y}===============================================${NC}"
echo " "
echo -e "${y}====================================================${NC}"
echo "    User Login SSH OpenSSH"
echo -e "${y}====================================================${NC}"
echo "   PID  |  Username  |  IP Address";
cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/login-db.txt
loginopenssh=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);

for PID in "${loginopenssh[@]}"
do
            cat /tmp/login-db.txt | grep "sshd\[$PID\]" > /tmp/login-db-pid.txt;
            NUM=`cat /tmp/login-db-pid.txt | wc -l`;
            USER=`cat /tmp/login-db-pid.txt | awk '{print $9}'`;
            IP=`cat /tmp/login-db-pid.txt | awk '{print $11}'`;
            if [ $NUM -eq 1 ]; then
                    echo "  $PID - $USER - $IP";
        fi
done
echo -e "${y}===============================================${NC}"
echo " "
echo -e "${y}====================================================${NC}"
echo "    User Login SSH UDP"
echo -e "${y}====================================================${NC}"
echo "   Login  |  Username  |  IP Address";
rm -r /var/log/udp.log
journalctl -u udp -n 100 > /var/log/udp.log
cat /var/log/udp.log | grep -i "Client connected" > /tmp/login-udp.txt;
cat /var/log/udp.log | grep -i "Client disconnected" > /tmp/login-udp1.txt;
loginudp=(`cat /tmp/login-udp.txt | awk '{print $9}' | cut -d ":" -f 3 | cut -d "]" -f 1`)
for akun in "${loginudp[@]}"
do
cekcek=`cat /tmp/login-udp1.txt | grep -i "$akun"`;
if [[ $akun = $cekcek ]]; then
echo -ne
else
            cat /tmp/login-udp.txt | grep "$akun" > /tmp/login-udp-db.txt;
            IP=`cat /tmp/login-udp-db.txt | awk '{print $9}' | cut -d ":" -f 2`;
            USER=`cat /tmp/login-udp-db.txt | awk '{print $10}' | cut -d ":" -f 2-2 | cut -d "]" -f 1`;
            TIME=`cat /tmp/login-udp-db.txt | awk '{print $3}'`;
                    echo "  $TIME - $USER - $IP";
fi
done
echo -e "${y}===============================================${NC}"
exit 0
}
function restart() {
systemctl restart haproxy nginx ws dropbear client server cron udp
sleep 2
echo -e " Restart All Service Done"
sleep 1
exit 0
}

clear
neofetch
echo ""
echo -e "  ${r}1${NC} : Add SSH Account"
echo -e "  ${r}2${NC} : Delete SSH Account"
echo -e "  ${r}3${NC} : Member SSH Account"
echo -e "  ${r}4${NC} : Check User Login SSH"
echo -e "  ${r}5${NC} : Delete User SSH Expired"
echo -e "  ${r}6${NC} : Speedtest VPS"
echo -e "  ${r}7${NC} : Change Domain"
echo -e "  ${r}8${NC} : Change NS Domain"
echo -e "  ${r}9${NC} : Edit Banner SSH Message"
echo -e " ${r}10${NC} : Check Service Status"
echo -e " ${r}11${NC} : Check CPU/Ram Via Gotop"
echo -e " ${r}12${NC} : Restart All Service"
echo -e " ${r}x.${NC} : Exit"
echo ""
read -p "  Chose Options [ 1 - 12 or x ] : " opt
case $opt in
x) exit ;;
1) addssh ;;
2) delssh ;;
3) memssh ;;
4) checkssh ;;
5) xp ;;
6) speedtest-cli --share; exit 0 ;;
7) domain ;;
8) dnstt ;;
9) nano /etc/banner.com; systemctl restart dropbear; menu ;;
10) run ;;
11) gotop ; menu ;;
12) restart ;;
*) menu ;;
esac
