#!/bin/bash

sha='/tmp/1'
sha_tmp='/tmp/2'
tmp_dir='/tmp/croco'
repo='https://api.github.com/repos/megacrab/tmp'
clone_repo='https://github.com/megacrab/tmp.git'
cron_dir='/etc/cron.d'
src_dir='/etc/crocodile'
conf_dir="${src_dir}/conf.d"
code='ororo'
flag='old'

#checking directory
dir_chk() {
        if [ ! -d $tmp_dir ]; then
                mkdir $tmp_dir
        fi
        if [ ! -d $src_dir ]; then
                mkdir $src_dir
		flag='new'
		echo 'New installation'
        fi
        if [ ! -d $conf_dir ]; then
                mkdir $conf_dir
        fi;
}

#main part which clone all staff from repo
cloner() {
        cd $tmp_dir
        git clone $clone_repo
        cp tmp/config/supervisord.conf /etc/supervisor/conf.d/crocodile.conf
	cp tmp/cron.d/* ${cron_dir}/
        cp -r tmp/crocodile/* ${src_dir}
        chmod -R +x ${src_dir}
        mv $sha_tmp $sha
        rm -rf $tmp_dir
	supervisorctl reread && supervisorctl update
	/etc/init.d/supervisor restart
}

#checking if there is any new commits with $code word
updater() {
	if [ $flag == 'new' ]; then
		echo 'Clean installation'
		cloner
		exit 0
	fi
#checking code word in last commit
	if [[ `shasum $sha |awk {'print $1'}` != `shasum $sha_tmp |awk {'print $1'}` ]] && [ `grep $code $sha_tmp | wc -l` -ge 1 ]; then
		echo 'special word found!'
                cloner
		exit 0
	fi
}

main() {
        dir_chk
        wget -O $sha_tmp "${repo}/commits?per_page=1"
        updater
}

main
