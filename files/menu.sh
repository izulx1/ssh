#!/bin/bash
hariini=$(date +%d-%m-%Y)
MYIP=$(wget -qO- ipinfo.io/ip)
PUB=$(cat /etc/slowdns/server.pub)
NS=$(cat /etc/xray/dns)
host=$(cat /etc/xray/domain)
#source '/usr/bin/menu'

function add() {
    useradd -e $(date -d "$masaaktif days" +"%Y-%m-%d") -s /bin/false -M $Login
    exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
    echo -e "$Pass\n$Pass\n" | passwd $Login &>/dev/null
}
function addssh() {
    clear
    read -p "Username : " Login
    read -p "Password : " Pass
    read -p "Expired (hari): " masaaktif
    add
    clear
    echo -e "==== 𝐀𝐜𝐜𝐨𝐮𝐧𝐭 𝐈𝐧𝐟𝐨𝐫𝐦𝐚𝐭𝐢𝐨𝐧 ===="
    echo -e ""
    echo -e "Username: $Login"
    echo -e "Password: $Pass"
    echo -e "Expired: $masaaktif Day"
    echo -e ""
    echo -e "==== 𝐒𝐞𝐫𝐯𝐞𝐫 𝐈𝐧𝐟𝐨𝐫𝐦𝐚𝐭𝐢𝐨𝐧 ==="
    echo -e ""
    echo -e "Host IP: $MYIP"
    echo -e "Port OpenSSH : 22"
    echo -e "Port DNS : 53"
    echo -e "Port UDP : 1-65535"
    echo -e "Port Dropbear : 143, 109"
    echo -e "Port BadVPN : 7100, 7200, 7300"
    echo -e ""
    echo -e "==== 𝐖𝐞𝐛𝐬𝐨𝐜𝐤𝐞𝐭 𝐒𝐒𝐇 ===="
    echo -e ""
    echo -e "Websocket HOST : $host"
    echo -e "Websocket SSH Port: 80, 8080"
    echo -e "Websocket SSL Port: 443"
    echo -e ""
    echo -e "==== 𝐃𝐍𝐒𝐓𝐓 𝐒𝐒𝐇 ===="
    echo -e "Pub Key : $PUB"
    echo -e "Host Dns : $NS"
    echo -e "====================="
    echo -e ""
}
function trialssh() {
    clear
    Login=trial-`</dev/urandom tr -dc 0-9 | head -c4`
    Pass=1
    read -p "Expired ( menit ) : " masaaktif
    add
    echo "userdel -f ${Login}" | at now +$masaaktif minutes &>/dev/null
    clear
    echo -e "==== 𝐀𝐜𝐜𝐨𝐮𝐧𝐭 𝐈𝐧𝐟𝐨𝐫𝐦𝐚𝐭𝐢𝐨𝐧 ===="
    echo -e ""
    echo -e "Username: $Login"
    echo -e "Password: $Pass"
    echo -e "Expired: $masaaktif Menit"
    echo -e ""
    echo -e "==== 𝐒𝐞𝐫𝐯𝐞𝐫 𝐈𝐧𝐟𝐨𝐫𝐦𝐚𝐭𝐢𝐨𝐧 ==="
    echo -e ""
    echo -e "Host IP: $MYIP"
    echo -e "Port OpenSSH : 22"
    echo -e "Port DNS : 53"
    echo -e "Port UDP : 1-65535"
    echo -e "Port Dropbear : 143, 109"
    echo -e "Port BadVPN : 7100, 7200, 7300"
    echo -e ""
    echo -e "==== 𝐖𝐞𝐛𝐬𝐨𝐜𝐤𝐞𝐭 𝐒𝐒𝐇 ===="
    echo -e ""
    echo -e "Websocket HOST : $host"
    echo -e "Websocket SSH Port: 80, 8080"
    echo -e "Websocket SSL Port: 443"
    echo -e ""
    echo -e "==== 𝐃𝐍𝐒𝐓𝐓 𝐒𝐒𝐇 ===="
    echo -e "Pub Key : $PUB"
    echo -e "Host Dns : $NS"
    echo -e "====================="
    echo -e ""
}
function member() {
    clear
    echo "---------------------------------------------------"
    echo "USERNAME          EXP DATE          STATUS"
    echo "---------------------------------------------------"
    while read expired; do
        AKUN="$(echo $expired | cut -d: -f1)"
        ID="$(echo $expired | grep -v nobody | cut -d: -f3)"
        exp="$(chage -l $AKUN | grep "Account expires" | awk -F": " '{print $2}')"
        status="$(passwd -S $AKUN | awk '{print $2}')"
        if [[ $ID -ge 1000 ]]; then
            if [[ "$status" = "L" ]]; then
                printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "LOCKED${NORMAL}$"
            else
                printf "%-17s %2s %-17s %2s \n" "$AKUN" "$exp     " "UNLOCKED${NORMAL}"
            fi
        fi
    done </etc/passwd
    JUMLAH="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"
    echo "---------------------------------------------------"
    echo "Account number: $JUMLAH user"
    echo "---------------------------------------------------"
}
function delssh() {
    member
    echo -e ""
    read -p "Username SSH to Delete : " Pengguna

    if getent passwd $Pengguna >/dev/null 2>&1; then
        userdel -f $Pengguna
        echo -e "Username $Pengguna Telah Di Hapus"
    else
        echo -e "Failure: Username $Pengguna Tidak Ada"
    fi
}
function check() {
    clear
    if [ -e "/var/log/auth.log" ]; then
        LOG="/var/log/auth.log"
    fi
    if [ -e "/var/log/secure" ]; then
        LOG="/var/log/secure"
    fi

    data=($(ps aux | grep -i dropbear | awk '{print $2}'))
    echo "----------=[ OpenSSH User Login ]=------------"
    echo "ID  |  Username  |  IP Address"
    echo "----------------------------------------------"
    cat $LOG | grep -i sshd | grep -i "Accepted password for" >/tmp/login-db.txt
    data=($(ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'))

    for PID in "${data[@]}"; do
        cat /tmp/login-db.txt | grep "sshd\[$PID\]" >/tmp/login-db-pid.txt
        NUM=$(cat /tmp/login-db-pid.txt | wc -l)
        USER=$(cat /tmp/login-db-pid.txt | awk '{print $9}')
        IP=$(cat /tmp/login-db-pid.txt | awk '{print $11}')
        if [ $NUM -eq 1 ]; then
            echo "$PID - $USER - $IP"
        fi
    done
    echo "----------=[ Dropbear User Login ]=-----------"
    echo "ID  |  Username  |  IP Address"
    echo "----------------------------------------------"
    cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" >/tmp/login-db.txt
    for PID in "${data[@]}"; do
        cat /tmp/login-db.txt | grep "dropbear\[$PID\]" >/tmp/login-db-pid.txt
        NUM=$(cat /tmp/login-db-pid.txt | wc -l)
        USER=$(cat /tmp/login-db-pid.txt | awk '{print $10}')
        IP=$(cat /tmp/login-db-pid.txt | awk '{print $12}')
        if [ $NUM -eq 1 ]; then
            echo "$PID - $USER - $IP"
        fi
    done
}
function delxp() {
    clear
    echo "Thank you for removing the EXPIRED USERS"
    echo "--------------------------------------"
    cat /etc/shadow | cut -d: -f1,8 | sed /:$/d >/tmp/expirelist.txt
    totalaccounts=$(cat /tmp/expirelist.txt | wc -l)
    for ((i = 1; i <= $totalaccounts; i++)); do
        tuserval=$(head -n $i /tmp/expirelist.txt | tail -n 1)
        username=$(echo $tuserval | cut -f1 -d:)
        userexp=$(echo $tuserval | cut -f2 -d:)
        userexpireinseconds=$(($userexp * 86400))
        tglexp=$(date -d @$userexpireinseconds)
        tgl=$(echo $tglexp | awk -F" " '{print $3}')
        while [ ${#tgl} -lt 2 ]; do
            tgl="0"$tgl
        done
        while [ ${#username} -lt 15 ]; do
            username=$username" "
        done
        bulantahun=$(echo $tglexp | awk -F" " '{print $2,$6}')
        echo "echo "Expired- User : $username Expire at : $tgl $bulantahun"" >>/usr/local/bin/alluser
        todaystime=$(date +%s)
        if [ $userexpireinseconds -ge $todaystime ]; then
            :
        else
            echo "echo "Expired- Username : $username are expired at: $tgl $bulantahun and removed : $hariini "" >>/usr/local/bin/deleteduser
            echo "Username $username that are expired at $tgl $bulantahun removed from the VPS $hariini"
            userdel -f $username
        fi
    done
    echo " "
    echo "--------------------------------------"
    echo "Script are successfully run"
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
}
function speedtest() {
    speedtest-cli --share
}

clear
neofetch
echo ""
echo -e "\033[31m1\033[0m : Membuat Akun SSH Trial"
echo -e "\033[31m2\033[0m : Membuat Akun SSH"
echo -e "\033[31m3\033[0m : Menghapus Akun SSH"
echo -e "\033[31m4\033[0m : Menampikan Akun Login SSH"
echo -e "\033[31m5\033[0m : Menampilkan Semua Akun SSH"
echo -e "\033[31m6\033[0m : Menghapus Semua Akun Expired SSH"
echo -e "\033[31m7\033[0m : Cek Kecepatan Server"
echo -e "\033[31m8\033[0m : Mengganti Domain"
echo -e "\033[31m9\033[0m : Mengganti NS SlowDNS"
echo -e "\033[31m10\033[0m : Edit Banner SSH Message"
echo ""
read -p " Chose Options [ 1 - 10 or x ] : " opt
case $opt in
x) exit ;;
1) trialssh ;;
2) addssh ;;
3) delssh ;;
4) member ;;
5) check ;;
6) delexp ;;
7) speedtest ;;
8) domain ;;
9) dnstt ;;
10) 
nano /etc/banner.com
systemctl restart dropbear 
menu ;;
*) menu ;;
esac

