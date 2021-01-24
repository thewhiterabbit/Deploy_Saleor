#########################################################################################
# Saleor_Production_Deployment.sh
# Author:       Aaron K. Nall   http://github.com/thewhiterabbit
#########################################################################################
#!/bin/sh
set -e

# Get the actual user that logged in
UN="$(who am i | awk '{print $1}')"
if [[ "$UN" != "root" ]]; then
        HD="/home/$UN"
else
        HD="/root"
fi

while [ -n "$1" ]; do # while loop starts
	case "$1" in
                -name)
                        DEPLOYED_NAME="$2"
                        shift
                        ;;

                -host)
                        API_HOST="$2"
                        shift
                        ;;

                -uri)
                        APP_MOUNT_URI="$2"
                        shift
                        ;;

                -url)
                        STATIC_URL="$2"
                        shift
                        ;;

                -dbhost)
                        PGDBHOST="$2"
                        shift
                        ;;

                -dbport)
                        DBPORT="$2"
                        shift
                        ;;

                -v)
                        vOPT="true"
                        VERSION="$2"
                        shift
                        ;;

                *)
                        echo "Option $1 is invalid."
                        echo "Exiting"
                        exit 1
                        ;;
	esac
	shift
done

#########################################################################################
# Select Operating System specific commands
# Tested working on Ubuntu Server 20.04
# Needs testing on the distributions listed below
# Debian
# Fedora CoreOS
# Kubernetes
# SUSE CaaS
IN=$(uname -a)
arrIN=(${IN// / })
IN2=${arrIN[3]}
arrIN2=(${IN2//-/ })
OS=${arrIN2[1]}
echo ""
echo "$OS detected"
echo ""
sleep 3
echo "Installing core dependencies..."
# For future use to setup Operating System specific commands
case "$OS" in
        Debian)
                sudo apt-get update
                sudo apt-get install -y build-essential python3-dev python3-pip python3-cffi python3-venv
                sudo python3 -m pip install --upgrade pip
                sudo apt-get install -y libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf2.0-0 libffi-dev shared-mime-info
                sudo apt-get install -y nodejs npm postgresql postgresql-contrib
                ;;

        Fedora)
                ;;

        Kubernetes)
                ;;

        SUSE)
                ;;

        Ubuntu)
                sudo apt-get update
                sudo apt-get install -y build-essential python3-dev python3-pip python3-cffi python3-venv
                sudo python3 -m pip install --upgrade pip
                sudo apt-get install -y libcairo2 libpango-1.0-0 libpangocairo-1.0-0 libgdk-pixbuf2.0-0 libffi-dev shared-mime-info
                sudo apt-get install -y nodejs npm postgresql postgresql-contrib
                ;;

        *)
                # Unsupported distribution detected, exit
                echo "Unsupported Linix distribution detected."
                echo "Exiting"
                exit 1
                ;;
esac
#########################################################################################

# Tell the user what's happening
echo ""
echo "Finished installing core dependencies"
echo ""
sleep 3
echo "Setting up security feature details..."
echo ""

# Create randomized 2049 byte keyfile
sudo mkdir /etc/saleor

echo $(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 2048| head -n 1)>/etc/saleor/api_sk
# Set variables for the password, obfuscation string, and user/database names
OBFSTR=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8| head -n 1)
PGSQLUSERPASS=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | fold -w 128 | head -n 1)
PGSQLDBNAME="saleor_db_$OBFSTR"
PGSQLUSER="saleor_dbu_$OBFSTR"

# Tell the user what's happening
echo "Finished setting up security feature details"
echo ""
sleep 1
echo "Creating database..."
echo ""

# Create a superuser for Saleor

sudo -i -u postgres psql -c "CREATE ROLE $PGSQLUSER PASSWORD '$PGSQLUSERPASS' SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN;"
sudo -i -u postgres psql -c "CREATE DATABASE $PGSQLDBNAME;"
# TODO - Secure the postgers user account

# Tell the user what's happening
echo "Finished creating database" 
echo ""
sleep 3
echo "Please provide details for your instillation..."
echo ""

# Ask for the API host IP or domain
while [ "$HOST" = "" ]
do
        echo -n "Enter the Dashboard & GraphQL host domain:"
        read HOST
done

while [ "$API_HOST" = "" ]
do
        echo ""
        echo -n "Enter the API host IP or domain:"
        read API_HOST
done

# Ask for the API port
echo -n "Enter the API port (optional):"
read API_PORT

# Ask for the API Mount URI
while [ "$APP_MOUNT_URI" = "" ]
do
        echo ""
        echo -n "Enter the Dashboard URI:"
        read APP_MOUNT_URI
done

# Ask for the Static URL
echo -n "Enter the Static URL:"
read STATIC_URL

# Ask for the Static URL
while [ "$EMAIL" = "" ]
do
        echo ""
        echo -n "Enter the Dashboard admin's email:"
        read EMAIL
done

# Ask for the Static URL
while [ "$PASSW" = "" ]
do
        echo ""
        echo -n "Enter the Dashboard admin's desired password:"
        read PASSW
done

# Use set parameters for Database or fall back to defaults
if [ "$PGDBHOST" = "" ]; then
        PGDBHOST="localhost"
fi

if [ "$DBPORT" = "" ]; then
        DBPORT="5432"
fi

if [[ "$GQL_PORT" = "" ]]; then
        GQL_PORT="9000"
fi

if [[ "$API_PORT" = "" ]]; then
        API_PORT="8000"
fi

if [ "$APIURI" = "" ]; then
        APIURI="graphql" 
fi

if [ "vOPT" = "true" ]; then
        if [ "$VERSION" = "" ]; then
                VERSION="2.11.1"
        fi
fi

sudo ufw allow $GQL_PORT
sudo ufw allow $API_PORT

# Here goes nothing
cd $HD
if [ "vOPT" = "true" ]; then
        git clone https://github.com/mirumee/saleor.git
else
        git clone https://github.com/thewhiterabbit/saleor.git
fi
wait
cd saleor
if [ "vOPT" = "true" ]; then
        sudo sed "s|{hd}|$HD|
                s/{hostip}/$API_HOST/" $HD/saleor/resources/saleor.service > /etc/systemd/system/saleor.service
        wait

        sudo sed "s|{hd}|$HD|
                s/{api_host}/$API_HOST/
                s/{host}/$HOST/g
                s/{apiport}/$API_PORT/" $HD/saleor/resources/server_block > /etc/nginx/sites-available/saleor
        wait

        sudo sed -i "s/{\"email\": \"admin@example.com\", \"password\": \"admin\"}/{\"email\": \"$EMAIL\", \"password\": \"$PASSW\"}/" $HD/saleor/saleor/core/management/commands/populatedb.py
        wait

        sudo sed -i "s/{\"email\": \"admin@example.com\", \"password\": \"admin\"}/{\"email\": \"$EMAIL\", \"password\": \"$PASSW\"}/" $HD/saleor/saleor/core/tests/test_core.py
        wait

        sudo sed -i "s|SECRET_KEY = os.environ.get(\"SECRET_KEY\")|with open('/etc/saleor/api_sk') as f: SECRET_KEY = f.read().strip()|" $HD/saleor/saleor/settings.py
        wait
else
        sudo sed "s|{hd}|$HD|
                s/{hostip}/$API_HOST/" $HD/saleor/resources/saleor.service > /etc/systemd/system/saleor.service
        wait

        sudo sed "s|{hd}|$HD|
                s/{api_host}/$API_HOST/
                s/{host}/$HOST/g
                s/{apiport}/$API_PORT/" $HD/saleor/resources/server_block > /etc/nginx/sites-available/saleor
        wait

        sudo sed -i "s/{email}/$EMAIL/
                s/{passw}/$PASSW/" $HD/saleor/saleor/core/management/commands/populatedb.py
        wait

        sudo sed -i "s/{email}/$EMAIL/
                s/{passw}/$PASSW/" $HD/saleor/saleor/core/tests/test_core.py
        wait
fi

# Tell the user what's happening
echo "Creating production deployment packages for Saleor API & GraphQL..."
echo ""

DB_URL="postgres://$PGSQLUSER:$PGSQLUSERPASS@$PGDBHOST:$DBPORT/$PGSQLDBNAME"

if [ "vOPT" = "true" ]; then
        git checkout $VERSION
fi
python3 -m venv $HD/saleor/venv
source $HD/saleor/venv/bin/activate
pip3 install -r requirements.txt
export DATABASE_URL=$DB_URL
npm install
npm audit fix
python3 manage.py migrate --createsuperuser
npm run build-schema
npm run build-mails

sudo touch /etc/init.d/saleor
sudo chmod +x /etc/init.d/saleor
sudo update-rc.d /etc/init.d/saleor defaults

APIURL="http://$API_HOST:$API_PORT/$APIURI/"

# Tell the user what's happening
echo "Finished creating production deployment packages for Saleor API & GraphQL"
echo""
sleep 3
echo "Creating production deployment packages for Saleor Dashboard..."
echo ""

# Missing some things here as well
cd $HD
git clone https://github.com/mirumee/saleor-dashboard.git
wait
cd saleor-dashboard

if [ "vOPT" = "true" ]; then
        git checkout $VERSION
fi
npm i
export API_URI=$APIURL
export APP_MOUNT_URI=$APP_MOUNT_URI
if [[ "$STATIC_URL" != "" ]]; then
        export STATIC_URL=$STATIC_URL
fi
npm run build

echo "Restarting nginx..."
sudo systemctl restart nginx
sleep 3

echo "I think we're done here."
echo "Test the installation."