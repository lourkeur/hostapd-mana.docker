#!/bin/sh

pemdir=/data/pems
server_cert=$pemdir/server_cert.pem
private_key=$pemdir/private_key.pem
credout_file=/data/hostapd.credout
interface=wlp2s0

if ! [ -e $server_cert ]; then
  echo "No certificates found in $pemdir!"
  echo "Generating a self-signed certificate"
  mkdir -p $pemdir
  openssl req -x509 -newkey rsa -subj /CN=radius.example.org/ -keyout $private_key -out $server_cert --nodes
fi

confdir=/data/conf
mkdir -p $confdir
eap_user_file=$confdir/hostapd.eap_user
test -e $eap_user_file ||
cat > $eap_user_file <<END
*		PEAP,TTLS,TLS,MD5,GTC
"t"     	TTLS-MSCHAPV2,MSCHAPV2,MD5,GTC,TTLS-PAP,TTLS-CHAP,TTLS-MSCHAP  "1234test"  [2]
END

config_file=$confdir/hostapd.conf
test -e $config_file ||
cat > $config_file <<END
interface=$interface
ssid=example
hw_mode=g
channel=7

wpa=2
wpa_key_mgmt=WPA-EAP
wpa_pairwise=TKIP CCMP
auth_algs=3
ieee8021x=1
eap_server=1
macaddr_acl=0
mana_wpe=1
eap_user_file=$eap_user_file
mana_credout=$credout_file
server_cert=$server_cert
private_key=$private_key
END

cat <<END

Welcome! Use
hostapd $config_file
to start the AP.
You can edit the configuration files first.
END
exec sh -i
