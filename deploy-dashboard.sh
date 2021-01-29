
#########################################################################################
echo ""
echo "Creating production deployment packages for Saleor Dashboard..."
echo ""
#########################################################################################



#########################################################################################
# Collect input from the user to assign required installation parameters
#########################################################################################
echo "Please provide details for your Saleor API instillation..."
echo ""
# Get the Dashboard & GraphQL host domain
while [ "$HOST" = "" ]
do
        echo -n "Enter the Dashboard & GraphQL host domain:"
        read HOST
done
# Get the API host IP or domain
while [ "$API_HOST" = "" ]
do
        echo ""
        echo -n "Enter the API host IP or domain:"
        read API_HOST
done
# Get the APP Mount (Dashboard) URI
while [ "$APP_MOUNT_URI" = "" ]
do
        echo ""
        echo -n "Enter the APP Mount (Dashboard) URI:"
        read APP_MOUNT_URI
done
# Get an optional custom API port
echo -n "Enter the API port (optional):"
read API_PORT
#
if [[ "$API_PORT" = "" ]]; then
        API_PORT="8000"
fi
#
#########################################################################################



#########################################################################################
# Setup the environment variables for Saleor API
#########################################################################################
# Build the API URL
APIURL="http://$API_HOST:$API_PORT/$APIURI/"
# Write the production .env file from template.env
sudo sed "s|{apiuri}|$APIURL|
          s|{mounturi}|$APP_MOUNT_URI|
          s|{url}|$HOST|" $HD/Deploy_Saleor/resources/saleor-dashboard/template.env > $HD/saleor-dashboard/.env
wait
#########################################################################################



#########################################################################################
# Build Saleor Dashboard for production
#########################################################################################
# Make sure we're in the user's home directory
cd $HD
# Clone the Saleor Dashboard Git repository
if [ -f "$HD/saleor-dashboard" ]; then
        sudo rm -R $HD/saleor-dashboard
fi
git clone https://github.com/mirumee/saleor-dashboard.git
wait
# Make sure we're in the project root directory
cd saleor-dashboard
# Was the -v (version) option used?
if [ "vOPT" = "true" ]; then
        git checkout $VERSION
fi
# Install dependancies
npm i
wait
npm run build
wait
#########################################################################################



#########################################################################################
# Tell the user what's happening
#########################################################################################
echo "I think we're done here."
echo "Test the installation."
echo "Run python3 manage.py createsuperuser from $HD/saleor"
#########################################################################################