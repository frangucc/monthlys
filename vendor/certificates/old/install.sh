#!/bin/sh

# run this once to install the ssl certs into their proper place
# you have to reboot apache when you're ready to go live with it
sudo mkdir -p /var/www/rails_apps/monthlys/shared/ssl

cd /home/deploy/code/monthly/vendor/certificates
sudo cp monthlys.key monthlys.crt entrustcert.crt root.crt /var/www/rails_apps/monthlys/shared/ssl
sudo cp /home/deploy/code/monthly/config/server/apache_vhost.conf /etc/apache2/sites-available/monthlys
sudo chown deploy:deploy /var/www/rails_apps -R
