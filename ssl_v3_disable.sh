#!/bin/sh
# -*- vim:ft=sh

export LANG="C"
export LC_ALL="C"

#1) Depending on the contents of the /etc/httpd/conf.d/ssl.conf, their newly created /etc/apache2/conf.d/ssl_disablev3.conf may not work, or, worse, it may not work for all services without you realizing some were left vulnerable, such as web-based email, as well as possibly ceasing to work later if Plesk alters ssl.conf.

service="$1"

psa_d="/usr/local/psa"
services="apache nginx postfix courier dovecot proftpd cp_server qmail"

usage()
{
    echo "USAGE: $0 [$services]"
    exit 0
}

die()
{
    echo "$*"
    exit 1
}

service_restart()
{
    cmd="$1"
    need_restart="$2"
    [ "$need_restart" = "1" ] && $cmd >/dev/null
}

set_value()
{
	local variable="$1"
	local value="$2"
	local delimiter="$3"
	local quote="${4:-\\\"}"
	local config="$5"

	grep -q "^[[:space:]]*$variable" $config
	if [ $? -eq 0 ]; then
		sed -i -e "s|^[[:space:]]*${variable}.*|${variable}${delimiter}${quote}${value}${quote}|g" $config
		return 0
	else
		echo "${variable}${delimiter}${quote}${value}${quote}" >> $config
	fi
	return 0
}

do_backup()
{
    local cfg="$1"
    local bkp_cfg="${cfg}_sslv3.bak"

    cp -f $cfg $bkp_cfg
}

get_os()
{
    if [ -e '/etc/debian_version' ]; then
        if [ -e '/etc/lsb-release' ]; then
            # Mostly ubuntu, but debian can have it
            . /etc/lsb-release
            os_name=$DISTRIB_ID
        else
            os_name='Debian'
        fi
        pkgtype="deb"
    elif [ -e '/etc/SuSE-release' ]; then
        os_name='SuSE'
        pkgtype="rpm"
    elif [ -e '/etc/redhat-release' ]; then
        os_name=`awk '{print $1}' /etc/redhat-release`
        pkgtype="rpm"
    else
        die "Unable to detect the operating system."
    fi

    [ -n "$os_name" ]    || die "Unable to detect the operating system."
}

fix_apache()
{
	echo "Fix SSL configuration for apache web server..."

	case $os_name in
	CentOS*|RedHat*|Cloud*)
		apache_d="/etc/httpd"
		apache_conf_d="$apache_d/conf.d"
		service_cmd="service httpd restart"
	;;
	SuSE*)
		apache_d="/etc/apache2"
		apache_conf_d="$apache_d/vhosts.d"
		service_cmd="service apache2 restart"
	;;
	Debian*|Ubuntu*)
		apache_d="/etc/apache2"
		for dir in mods-enabled conf-enabled conf.d; do
			[ -d "$apache_d/$dir" ] && apache_conf_d="$apache_d/$dir" && break
			apache_conf_d=""
		done
		service_cmd="/etc/init.d/apache2 restart"
	;;
	*)
		die "Unable to define apache SSL config file"
	;;
	esac

	cfg="$apache_conf_d/ssl.conf"
	set_value "SSLHonorCipherOrder" "On" " " " " $cfg
	set_value "SSLProtocol" "all -SSLv2 -SSLv3" " " " " $cfg

	service_restart "$service_cmd" "1"
}

fix_nginx()
{
    echo "Fix SSL configuration for nginx web server..."

    nginx_pool_d="/etc/nginx/plesk.conf.d"
    vhost_cfg_default_d="$psa_d/admin/conf/templates/default"
    vhost_cfg_custom_d="$psa_d/admin/conf/templates/custom"

    ssl_cfg_list="
	/etc/nginx/plesk.conf.d/webmail.conf
	/etc/nginx/plesk.conf.d/server.conf
	$psa_d/admin/conf/templates/default/nginxWebmailPartial.php
	$psa_d/admin/conf/templates/default/nginxDomainVirtualHost.php
	$psa_d/admin/conf/templates/default/nginxVhosts.php
	$psa_d/admin/conf/templates/default/server/nginxVhosts.php
	$psa_d/admin/conf/templates/default/domain/nginxDomainVirtualHost.php
    "

    flag=0
    for cfg in $ssl_cfg_list; do
	[ -f "$cfg" ] || continue

	dst_cfg="$cfg"
	if [ -n "`echo $cfg | grep $vhost_cfg_default_d`" ]; then
		dst_cfg="`echo $cfg | sed -e \"s|$vhost_cfg_default_d|$vhost_cfg_custom_d|\"`"
		mkdir -p ${dst_cfg%/*}
		cp $cfg $dst_cfg
	else
		do_backup $dst_cfg
	fi
	sed -i -e "s|^\([[:space:]]*ssl_protocols\).*|\1		TLSv1 TLSv1.1 TLSv1.2;|" $dst_cfg
	flag=1
    done

    [ $flag -eq 0 ] || $psa_d/admin/bin/httpdmng --reconfigure-all

    case $os_name in
	Debian*|Ubuntu*) service_cmd="/etc/init.d/nginx restart" ;;
	*) service_cmd="service nginx restart" ;;
    esac

    service_restart "$service_cmd" "1"
}

fix_postfix()
{
	echo "Fix SSL configuration for postfix mail server..."

	[ -f "/etc/postfix/main.cf" ] || return 0
	do_backup /etc/postfix/main.cf

	#options="smtpd_tls_mandatory_protocols tls_low_cipherlist tls_medium_cipherlist tls_high_cipherlist tls_null_cipherlist"
	options="smtpd_tls_mandatory_protocols"

	flag=0
	for opt in $options; do
		protocols="`postconf $opt | awk -F '=' '{print $2}'`"
		echo $protocols | grep -q '!SSLv3'
		if [ $? -ne 0 ]; then
			postconf ${opt}="${protocols}:!SSLv3"
			flag=1
		fi
	done

	case $os_name in
	Debian*|Ubuntu*) /etc/init.d/postfix restart ;;
	*) service postfix restart ;;
	esac

	service_restart "$service_cmd" "$flag"
}

fix_courier()
{
	echo "Fix SSL accessible protocols for courier-imap mail server"

	cfg_list="/etc/courier-imap/imapd-ssl /etc/courier-imap/pop3d-ssl"

	flag=0
	for cfg in $cfg_list; do
		[ -f "$cfg" ] || continue

		do_backup $cfg

		flag=1
		set_value "TLS_PROTOCOL" "TLSv1+" "=" "" $cfg
		#list="ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:ECDH+3DES:DH+3DES:RSA+AESGCM:RSA+AES:RSA+3DES:!aNULL:!MD5:!DSS"
	done

	case $os_name in
	Debian*|Ubuntu*)
		service_restart "/etc/init.d/courier-imaps restart" "$flag"
                service_restart "/etc/init.d/courier-pop3s restart" "$flag"
		service_restart "/etc/init.d/courier-imapd restart" "$flag"
	;;
	*)
		service_restart "service courier-imaps restart" "$flag"
                service_restart "service courier-pop3s restart" "$flag"
		service_restart "service courier-imapd restart" "$flag"
	;;
	esac
}

fix_dovecot()
{
	echo "Fix SSL accessible protocols for dovecot mail server"

	#cfg_list="/etc/dovecot/conf.d/10-plesk-security.conf /etc/dovecot/conf.d/11-plesk-security-pci.conf"
	cfg_list="/etc/dovecot/conf.d/10-plesk-security.conf"

	flag=0
	for cfg in $cfg_list; do
		[ -f "$cfg" ] || continue
		do_backup $cfg
		flag=1
		set_value "ssl_protocols" "!SSLv2 !SSLv3" "=" " " $cfg
#		set_value "ssl_cipher_list" "HIGH:MEDIUM:!SSLv2:!LOW:!EXP:!aNULL:!ADH:@STRENGTH:!SSLv3" "=" $cfg
	done

	case $os_name in
	Debian*|Ubuntu*) service_cmd="/etc/init.d/dovecot restart" ;;
	*) service_cmd="service dovecot restart" ;;
	esac
	service_restart "$service_cmd" "$flag"
}

fix_proftpd()
{
	echo "Disable SSLv3 for FTP service"

	cfg="/etc/proftpd.d/60-nosslv3.conf"

	echo "<Global>" >$cfg
	echo "<IfModule mod_tls.c>" >>$cfg
	echo "TLSProtocol TLSv1 TLSv1.1 TLSv1.2" >>$cfg
#	echo "TLSCipherSuite ALL:!aNULL:!ADH:!eNULL:!LOW:!EXP:RC4+RSA:+HIGH:+MEDIUM:!SSLv3" >> $cfg
	echo "</IfModule>" >> $cfg
	echo "</Global>" >> $cfg
}

fix_cp_server()
{
    echo "Fix Plesk Panel web service"

    cfg="/etc/sw-cp-server/conf.d/pci-compliance.conf"

    if [ -f "$cfg" ]; then
	do_backup $cfg

	grep -q "^[[:space:]]*ssl_protocols" $cfg
	if [ $? -eq 0 ]; then
		sed -i -e "s|^\([[:space:]]*ssl_protocols\).*|\1		TLSv1 TLSv1.1 TLSv1.2;|" $cfg
	else
		echo  "ssl_protocols           TLSv1 TLSv1.1 TLSv1.2;" >> $cfg
	fi
    else
	echo  "ssl_protocols           TLSv1 TLSv1.1 TLSv1.2;" >> $cfg
	echo  "ssl_ciphers                 HIGH:!aNULL:!MD5;" >> $cfg
	echo  "ssl_prefer_server_ciphers   on;" >> $cfg
    fi

    service_restart "/etc/init.d/sw-cp-server restart" "1"
}

fix_qmail()
{
    echo "Disable SSLv3 in Qmail MTA"
    cfg="/var/qmail/control/tlsserverciphers"
    [ -d "/var/qmail/control" ] || return 0
    echo "ALL:!ADH:!LOW:!SSLv2:!SSLv3:!EXP:+HIGH:+MEDIUM" > $cfg
}

get_os
[ "$service" = "help" ] && usage

flag=0
for mod in $services; do
    if [ -n "$service" ]; then
	if [ "$service" = "$mod" ]; then
           fix_$mod; flag=1; break
	fi
	continue
    fi
    fix_$mod; flag=1
done

[ $flag -eq 0 ] && usage

exit 0
