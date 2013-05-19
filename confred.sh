#!/bin/sh

reload='y'
var=`ls /usr/lib |grep NetworkManager`
if [ $? -eq 0 ]; then
	/etc/init.d/network-manager stop && aptitude remove network-manager network-manager-gnome
	var=`ls /usr/lib |grep NetworkManager`
	if [ $? -eq 0 ]; then
		echo "No se desintalo correctamente, vuelva a intentarlo y recuerde que debe tener privilegios de administrador"
		exit 1
	fi
fi
echo "¿Desea crear un archivo de configuración nuevo? y/n"
read conf
if [ $conf = 'y' ];then
	echo auto lo"\n"iface lo inet loopback"\n"address 127.0.0.1"\n"netmask 255.0.0.0 > /etc/network/interfaces
fi
while [ $reload = 'y' ]
	do
	echo "¿Que tipo de interface queres configurar? eth/wlan/otros"
	read tipe
	if [ $tipe = 'eth' ]; then
	echo "Elige la interface que quieres configurar, Ejm: eth0\n" `ifconfig -a |grep ^eth`
	read var
		echo "¿Quieres que la configuracion sea por dhcp? y/n"
		read dhcp
		if [ $dhcp = 'y' ]; then
			echo "\n"auto $var"\n"iface $var inet dhcp >> /etc/network/interfaces
			dhclient $var
		elif [ $dhcp = 'n' ]; then
			echo "Introducza la direccion IP"
			read ip
			echo "Introduzca la direccion de red"
			read dr
			echo "Introduzca la máscara de red"
			read mask
			echo "Introduzca la puerta de acceso"
			read pa
			echo "Introduzca el DNS principal"
			read dns1
			echo domain Home"\n"search Home"\n"nameserver $dns1"\n" > /etc/resolv.conf
			echo "¿Quiere introducir un DNS adicional? y/n"
			read petdns
			while [ $petdns = 'y' ]
			do
				echo "Introduzca el DNS"
				read dnssec
				echo nameserver $dnssec"\n" >> /etc/resolv.conf
				echo "¿Quiere introducir otro DNS? y/n"
				read petdns
			done
			echo "\n"auto $var"\n"iface $var inet static"\n"address $ip"\n"network $dr"\n"netmask $mask"\n"gateway $pa >> /etc/network/interfaces
		fi
	fi
	if [ $tipe = 'wlan' ]; then
		echo "Elige la interface que quieres configurar, Ejm: wlan0\n" `ifconfig -a |grep ^wlan`
	read var
		echo "¿Quieres que la configuracion sea por dhcp? y/n"
		read dhcp
		if [ $dhcp = 'y' ]; then
			echo "\n"auto $var"\n"iface $var inet dhcp"\n"wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf"\n" >> /etc/network/interfaces
		elif [ $dhcp = 'n' ]; then
			echo "Introducza la direccion IP"
			read ip
			echo "Introduzca la direccion de red"
			read dr
			echo "Introduzca la máscara de red"
			read mask
			echo "Introduzca la puerta de acceso"
			read pa
			echo "Introduzca el DNS principal"
			read dns1
			echo domain Home"\n"search Home"\n"nameserver $dns1"\n" > /etc/resolv.conf
			echo "¿Quiere introducir un DNS adicional? y/n"
			read petdns
			while [ $petdns = 'y' ]
			do
				echo "Introduzca el DNS"
				read dnssec
				echo nameserver $dnssec"\n" >> /etc/resolv.conf
				echo "¿Quiere introducir otro DNS adicional? y/n"
				read petdns
			done
			echo "\n"auto $var"\n"iface $var inet static"\n"address $ip"\n"network $dr"\n"netmask $mask"\n"gateway $pa"\n"pre-up wpa_supplicant 	-B -i$var -c/etc/wpa_supplicant/wpa_supplicant	 /etc/wpa_supplicant/wpa_supplicant.conf"\n"post-down killall -q wpa_supplicant >> /etc/network/interfaces
		fi
	echo "¿Quiere ver la lista de redes wifi disponibles? y/n"
	read listwif
	if [ $listwif = 'y' ]; then
		ifconfig $var up
		echo `iwlist $var scan|grep ESSID`
	fi
	echo "Escriba la SSID"
		read ssid
		echo "Escriba la password de la red inalambrica"
		read pass
		echo "¿De que tipo de seguridad es la red? WPA/WPA2/WEP"
		read segur		
		if [ $segur = 'WEP' ]; then
			echo network={"\n"       ssid='"'$ssid'"'"\n"       psk=$pass"\n"}  >> /etc/wpa_supplicant/wpa_supplicant.conf
		else
			echo  network={"\n"       ssid='"'$ssid'"'"\n"       proto=$segur"\n"        key_mgmt=WPA-PSK"\n"        `wpa_passphrase $ssid	$pass|grep psk=[0-9,a-z]`"\n"} >> /etc/wpa_supplicant/wpa_supplicant.conf
		fi
	fi
	if [ $tipe = 'otros' ]; then
	echo `ifconfig -a` "\nElige la interface que quieres configurar, Ejm: usb0\n"
	read var
		echo "¿Quieres que la configuracion sea por dhcp? y/n"
		read dhcp
		if [ $dhcp = 'y' ]; then
			echo "\n"auto $var"\n"iface $var inet dhcp >> /etc/network/interfaces
			dhclient $var
		elif [ $dhcp = 'n' ]; then
			echo "Introducza la direccion IP"
			read ip
			echo "Introduzca la direccion de red"
			read dr
			echo "Introduzca la máscara de red"
			read mask
			echo "Introduzca la puerta de acceso"
			read pa
			echo "Introduzca el DNS principal"
			read dns1
			echo domain Home"\n"search Home"\n"nameserver $dns1"\n" > /etc/resolv.conf
			echo "¿Quiere introducir un DNS adicional? y/n"
			read petdns
			while [ $petdns = 'y' ]
			do
				echo "Introduzca el DNS"
				read dnssec
				echo nameserver $dnssec"\n" >> /etc/resolv.conf
				echo "¿Quiere introducir otro DNS? y/n"
				read petdns
			done
			echo "\n"auto $var"\n"iface $var inet static"\n"address $ip"\n"network $dr"\n"netmask $mask"\n"gateway $pa >> /etc/network/interfaces
		fi
	fi
	echo "¿Desea configurar otra interface? y/n"
	read reload
done
/etc/init.d/networking restart
