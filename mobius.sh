#!/bin/bash
# trap '' 2 # ignore control + c
export LC_ALL=C
echo -e "
 __  __  ____  ____ _____ _    _  _____ 
|  \/  |/ __ \|  _ \_   _| |  | |/ ____|
| \  / | |  | | |_) || | | |  | | (___  
| |\/| | |  | |  _ < | | | |  | |\___ \ 
| |  | | |__| | |_) || |_| |__| |____) |
|_|  |_|\____/|____/_____|\____/|_____/ 
"

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

check_os() {

    case "$OSTYPE" in
    darwin*)
        # echo "OSX"
        os=mac
        ;;
    linux*)
        # echo "LINUX"
        os=linux
        ;;
    *) echo "unknown: $OSTYPE" ;;
    esac
}
check_os

check_brew_status() {
    brew_status=true
    if ! which 'brew' &>/dev/null; then
        brew_status=false
    else
        brew_status=true

    fi
}
check_brew_status
# echo $brew_status

install_homebrew() {

    echo "brew status $brew_status"

    echo -e "brew is not installed"
    echo "Do you wish to install this program?"
    select yn in "Yes" "No"; do
        case $yn in
        Yes)
            /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

            break
            exit
            ;;
        No)
            echo -e "
        
 _                         _                   _
| |__  _ __ _____      __ (_)___   _ __   ___ | |_
| '_ \| '__/ _ \ \ /\ / / | / __| | '_ \ / _ \| __|
| |_) | | |  __/\ V  V /  | \__ \ | | | | (_) | |_
|_.__/|_|  \___| \_/\_/   |_|___/ |_| |_|\___/ \__|

 _           _        _ _          _
(_)_ __  ___| |_ __ _| | | ___  __| |
| | '_ \/ __| __/ _' | | |/ _ \/ _' |
| | | | \__ \ || (_| | | |  __/ (_| |
|_|_| |_|___/\__\__,_|_|_|\___|\__,_|

        "

            exit
            ;;
        esac
    done

}
if [[ $os = mac && $brew_status = false ]]; then
    install_homebrew
fi

install_postgres() {

    if ! which 'psql' &>/dev/null; then
        psql_status=false
    else
        psql_status=true
    fi
    if [[ $os = mac && $brew_status = true && $psql_status = false ]]; then
        echo "installing psql in mac"
        brew install postgresql

    elif [[ $os = linux && $psql_status = false ]]; then
        echo "installing psql in linux"

        sudo apt-get install postgresql -y
    elif [[ $os = mac && $brew_status = true && $psql_status = true ]]; then
        echo -e "Postgres is already installed"
        echo "Do you want to update this program?"
        select yn in "Yes" "No"; do
            case $yn in
            Yes)
                versions=" $(brew search postgresql 2>/dev/null)"
                new=($(echo "$versions" | grep -Eo '[0-9][\.]?[0-9]{1,4}'))
                echo 'versions'
                arr_len=$(echo ${#new[@]})
                echo $arr_len
                echo "Current Verson: $(psql --version)"
                echo "Enter the version number from the choices below"
                # for a in $arr_len
                # do

                #     echo " $a"

                # done
                new+=('Quit')
                arr_len=$((arr_len + 1))
                select v in ${new[@]}; do
                    echo " array length= $arr_len"
                    echo $v
                    q=Quit
                    if [[ $v == $q ]]; then
                        exit
                    elif [[ $v == "" ]]; then
                        echo "Invalid Choice; Please try again"
                    else
                        echo "brew install postgresql@$v"
                    fi

                done
                break

                exit
                ;;
            No)

                exit
                ;;
            esac
        done

    else

        echo "Postgres is already installed"

    fi

}

install_mysql() {

    if ! which 'mysql' &>/dev/null; then
        mysql_status=false
    else
        mysql_status=true
    fi
    if [[ $os = mac && $brew_status = true && $mysql_status = false ]]; then
        echo "installing mysql in mac"
        brew install mysql

    elif [[ $os = linux && $mysql_status = false ]]; then
        echo "installing mysql in linux"

        sudo apt-get install mysql-server -y
    elif [[ $os = mac && $brew_status = true && $mysql_status = true ]]; then
        echo -e "Mysql is already installed"
    else
        echo "mysql is already installed"

    fi

}

install_virtualenv() {

    if ! which 'virtualenv' &>/dev/null; then
        virtualenv_status=false
    else
        virtualenv_status=true
    fi
    if [[ $os = mac && $brew_status = true && $virtualenv_status = false ]]; then
        echo "installing virtualenv in mac"
        brew install virtualenv

    elif [[ $os = linux && $virtualenv_status = false ]]; then
        echo "installing virtualenv in linux"

        sudo apt-get install virtualenv -y
    elif [[ $os = mac && $brew_status = true && $virtualenv_status = true ]]; then
        echo -e "virtualenv is already installed"
    else
        echo "virtualenv is already installed"

    fi

}

create_psql_db() {

    read -p "Enter the database name: " dbname
    if echo $OSTYPE | grep darwin*; then
        echo Macos
        echo "CREATE DATABASE $dbname"

        psql postgres -c "CREATE DATABASE $dbname"

    else
        echo Linux

        sudo -i -u postgres bash <<EOF
echo "In"
        echo "CREATE DATABASE $dbname"
        psql postgres -c "CREATE DATABASE $dbname"
EOF

    fi

}

create_mysql_db() {

    read -p "Enter Username: " usernamemysql
    #    read -s -p "Enter Password: " passmysql
    echo
    read -p "Enter Database Name: " createdbname

    echo "mysql -u $usernamemysql -p$passmysql -e "CREATE DATABASE $createdbname""
    mysql -u $usernamemysql -p -e "CREATE DATABASE $createdbname"
    echo $createdbname Database created

}

import_psql_db() {

    default="postgres"
    read -p "Username [default=$default] " user_postgres
    : ${user_postgres:=$default}
    # echo "you answered: $user_postgres"
    read -p "Database name: " db_postgres
    read -e -p "File path: " backupfilepath

    if [ -z $backupfilepath ]; then
        echo "Empty path entered"
    else

        if [ -f $backupfilepath ]; then
            if echo $OSTYPE | grep darwin*; then
                echo Macos
                echo "psql -d $db_postgres -f $backupfilepath"

                psql postgres -c "psql -d $db_postgres -f $backupfilepath"

            else
                echo Linux
                if echo $backupfilepath | grep '^/' >/dev/null; then

                    sudo -i -u postgres bash <<EOF
echo "In"
        echo "psql -d $db_postgres -f $backupfilepath"
        psql -d $db_postgres -f $backupfilepath
EOF
                    echo -e " Database Imported"

                elif echo $backupfilepath | grep '../' >/dev/null; then
                    echo "Relative path is passed"
                    echo "exiting.."
                    exit

                else
                    backupfilepath="$(pwd)/$backupfilepath"
                    echo $backupfilepath
                    sudo -i -u postgres bash <<EOF
echo "In"
        echo "psql -d $db_postgres -f $backupfilepath"
        psql -d $db_postgres -f $backupfilepath
EOF
                    echo -e " Database Imported"
                fi
            fi

        else
            echo "file doesn't exist or Directory is passed"
        fi

    fi

}

import_mysql_db() {

    default="root"
    read -p "Username [default=$default] " user_mysql
    # read -s -p "Enter Password: " pass_mysql
    : ${user_mysql:=$default}
    # echo "you answered: $user_postgres"
    read -p "Database name: " db_mysql
    read -e -p "File path: " backupfilepathmysql

    if [ -z $backupfilepathmysql ]; then
        echo "Empty path entered"
    else

        if [ -f $backupfilepathmysql ]; then
            if echo $OSTYPE | grep darwin*; then
                echo Macos
                echo "mysql -u $user_mysql -p $db_mysql < $backupfilepathmysql"

                mysql -u $user_mysql -p $db_mysql <$backupfilepathmysql
                echo -e " Database Imported"

            else

                echo Linux

                echo "mysql -u $user_mysql -p$pass_mysql $db_mysql   < $backupfilepathmysql"
                mysql -u $user_mysql -p$pass_mysql $db_mysql <$backupfilepathmysql

                echo -e " Database Imported"

            fi

        else
            echo "file doesn't exist or Directory is passed"
        fi

    fi

}

create_virtualenv() {

    if ! which 'virtualenv' &>/dev/null; then
        virtualenv_status=false
    else
        virtualenv_status=true
    fi

    if [[ $os = mac && $brew_status = true && $virtualenv_status = false ]]; then
        echo "installing virtualenv in mac using brew"

        select yn in "Yes" "No"; do
            case $yn in
            Yes)
                install_virtualenv

                exit
                ;;
            No)
                exit
                ;;
            esac
        done
        brew install mysql

    elif [[ $os = linux && $virtualenv_status = false ]]; then
        echo "installing virtualenv in linux"

        select yn in "Yes" "No"; do
            case $yn in
            Yes)
                install_virtualenv

                exit
                ;;
            No)
                exit
                ;;
            esac
        done
    else
        read -e -p "Enter Python Version[Default: 3.5] :" venv_python_version
        venv_python_version=${venv_python_version:-3.5}
        read -p "Enter Virtualenv name[Default: venv]: " virtual_name
        virtual_name=${virtual_name:-venv}
        virtualenv -p python$venv_python_version $virtual_name

    fi

}
change_psql_db_owner() {

    read -p "Enter DB name: " YOUR_DB
    read -p "Enter New Owner [Default=postgres]: " NEW_OWNER

    if [[ $os = mac && $brew_status = true ]]; then
        for tbl in $(psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" $YOUR_DB); do psql -c "alter table \"$tbl\" owner to $NEW_OWNER" $YOUR_DB; done
    else
        sudo -i -u postgres bash <<EOF
echo "In"
for tbl in $(psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" $YOUR_DB) ; do  psql -c "alter table \"$tbl\" owner to $NEW_OWNER" $YOUR_DB ; done
EOF
    fi
    exit
}

create_swap() {

    read -p "Enter Swapfile Size: " swap_size
    read -p "Enter Swapfile Path [Default=/swapfile]: " swap_path

    curl https://raw.githubusercontent.com/bhardwajkonark/Swap/master/swap.sh | sudo sh -s $swap_size $swap_path

}

add_python_ppa() {

    the_ppa=deadsnakes/ppa # e.g. the_ppa="ondrej/apache2"

    if ! grep -q "^deb .*$the_ppa" /etc/apt/sources.list /etc/apt/sources.list.d/*; then
        # commands to add the ppa ...
        sudo add-apt-repository ppa:deadsnakes/ppa
        sudo apt-get update
    fi

}

install_python() {

    if [ -z "$1" ]; then
        read -p "Python version to use :" version

    else
        version=$1
    fi

    sudo apt-get install python$version python$version-venv python$version-minimal python$version-dev python3-pip -y

}

install_uwsgi() {
    read -p "Python version to use :" version

    read -p "Are you sure you want to use $version?(y/n) " -n 1 -r
    echo # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # do dangerous stuff
        if ! command -v pip &>/dev/null && ! command -v python$version &>/dev/null; then
            echo "COMMAND could not be found, Install python$version"
            read -p "Do you want to install python$version?(y/n) " -n 1 -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                install_python $version
            fi

            exit

        else

            sudo apt install libpython"$version"-dev
            sudo pip install --upgrade pip
            sudo pip install --upgrade setuptools
            sudo python"$version" -m pip install uwsgi
            sudo cp /root/.local/bin/uwsgi /usr/local/bin/uwsgi
            sudo mkdir -p /etc/uwsgi/sites
            sudo mkdir /var/log/uwsgi/
            sudo touch /var/log/uwsgi/my.log

            sudo cat >/etc/systemd/system/uwsgi.service <<EOF

[Unit]
Description=uWSGI Emperor service
After=syslog.target

[Service]
ExecStart=/usr/local/bin/uwsgi --emperor /etc/uwsgi/sites
Restart=always
KillSignal=SIGQUIT
Type=notify
StandardError=syslog
NotifyAccess=all

[Install]
WantedBy=multi-user.target
EOF

            sudo systemctl enable uwsgi

            sudo systemctl start uwsgi

        fi

    fi

    echo "UWSGI Installed"

}

install_nvm() {

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash

}

read -p "What do you want to do
        1. Install Postgres
        2. Install Mysql
        3. Create postgres database 
        4. Create mysql database
        5. Import Postgresql database 
        6. Import Mysql database
        7. Create Virtualenv
        8. Install Virtualenv
        9. Change Owner of all tables in Postgres
        10. Create Swap File 
        11. Install Python Deadsnake PPA (Ubuntu only)
        12. Install Python (Ubuntu only)
        13. Install UWSGI  (Ubuntu only)
        14. Install NVM
        q. Quit
:" option

for i in ${option//,/ }; do
    # call your procedure/other scripts here below

    case "$i" in

    1)
        install_postgres
        ;;
    2)
        install_mysql
        ;;

    3)
        create_psql_db
        ;;

    4)
        create_mysql_db
        ;;

    5)
        import_psql_db
        ;;

    6)
        import_mysql_db
        ;;

    7)
        create_virtualenv
        ;;

    8)
        install_virtualenv
        ;;

    9)
        change_psql_db_owner
        ;;
    10)
        create_swap
        ;;
    11)
        add_python_ppa
        ;;
    12)
        add_python_ppa
        install_python
        ;;
    13)
        install_uwsgi
        ;;
    14)
        install_nvm
        ;;
    q)
        exit
        ;;
    esac

done

exit
