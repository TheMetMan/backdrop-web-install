#!/bin/bash
#
# https://github.com/TheMetMan/backdrop_web_install 
# 
# This is the Install script for a Drush Install 
#
# script to create a Backdrop CMS site for File Based Workflow in DocumentRoot web
# 
# The scripts, config file and base_files folder should be together
# perhaps in a folder such as ~/bin/backdrop_web_install or some such
#
# make sure you have an empty MySql Database setup ready
#
# Edit the config.cfg file with the correct information for your setup
# and run this script
#
# Dec  2019 Francis Greaves
#
askfg(){
  local REPLY
  while true; 
    do
        read -p "$1 [Y/n]" REPLY </dev/tty
        # Default is Y
        if [ -z "$REPLY" ]; then
          REPLY=Y
        fi
        # Check if the reply is valid
        case "$REPLY" in
          Y*|y*) return 0 ;;
          N*|n*) return 1 ;;
        esac
    done
}       # End of ask()
#
############ Import Config
configFile=config.cfg
if [ -e "$configFile" ]; then
  source $configFile
else
  echo "I cannot find the Config File $configFile"
  exit 1
fi
#-----------------------------------------------------------------------------
cd $apacheRoot
echo "----------- This is a Backdrop CMS Install using Drush ----------------"
echo "---------- with the DocumentRoot as $apacheRoot/$siteFolder/web --------------"
echo "                Installing to $apacheRoot/$siteFolder"
echo
echo "           Make sure you have an empty database setup ready"
echo "=============================================================================="
if [ -d "$siteFolder/web" ]; then
  echo "**** The Old Site Folder is still present ****"
  echo "     you will need to remove this site."
  echo "  So as ROOT rm -fvr $apacheRoot/$siteFolder/web"
  echo "           then re-run this script"
  echo "Quitting Install Backdrop CMS for File Based Workflow"
#  exit 1
fi
if askfg "Do you really want to continue?" ; then
    echo "Installing now"
    mkdir "$apacheRoot/$siteFolder"
  else
    exit 1
  fi
cd "$apacheRoot/$siteFolder"
echo and creating a git repository
git init
echo "Set correct version of Drush"
git config drush.version 8
echo 'Downloading Backdrop CMS ....'
drush dlb backdrop
mv backdrop web
echo
echo "create and copy .htaccess file to private folder"
mkdir private
cp "$workingFolder/base_files/htaccess" private/.htaccess
echo "create the other folders"
mkdir logs
configFolder=config
mkdir -p $configFolder/staging
mkdir $configFolder/active
mkdir $configFolder/local_db
mkdir $configFolder/dev_db
mkdir $configFolder/prod_db
cp "$workingFolder/base_files/htaccess" $configFolder/.htaccess
echo "Adjust some settings on the settings.php file"
sed -i 's/^$config/#&/' web/settings.php
sed -i 's/RewriteRule \^ index.php \[L\]/RewriteRule \^(\.*)\$ index.php?q=\$1 \[L,QSA\]/'  web/.htaccess
echo "RewriteBase /web" >> web/.htaccess
cat "$workingFolder/base_files/default.settings.xtra" >> ./web/settings.php
echo "adding Private Files Path and Trusted Hosts to settings.php file"
echo "\$settings['file_private_path'] = '$privatePath';" >> web/settings.php
echo "\$settings['trusted_host_patterns'] = array('$trustedHosts',);" >> web/settings.php 
echo "\$base_url = 'http://$siteFolder'; # NO Trailing Slash!" >> web/settings.php 
echo
echo "copy useful files across and clean up a little"
cp "$workingFolder/base_files/FixPermissions" ./
cp "$workingFolder/base_files/backupEssentials" ./
echo "Copying a .gitignore file for you"
cp "$workingFolder/base_files/gitignore" ./.gitignore
cp "$workingFolder/base_files/htaccess_docroot" ./.htaccess
echo "Copying import and export Sync scripts for you"
cp "$workingFolder/base_files/importConfigSync" ./
cp "$workingFolder/base_files/exportConfigSync" ./
echo "Creating a .htaccess access file in DocumentRoot to redirect Document Root to web"
sed -i "s,SITEFOLDER,$siteFolder," .htaccess
sed -i "s,SITEFOLDER,$siteFolder," exportConfigSync
sed -i "s,SITEFOLDER,$siteFolder," importConfigSync
sed -i "s,DATABASE_USER_NAME,$dbUser," importConfigSync
sed -i "s,DATABASE_PASSWORD,$dbPwd," importConfigSync
sed -i "s,DATABASE,$db," importConfigSync
echo "Updating FixPermissions User and Group"
sed -i "s,USER,$apacheUser," FixPermissions
sed -i "s,GROUP,$apacheGroup," FixPermissions
chmod +x FixPermissions
cd web
echo 'Install Site using Drush'
drush si standard \
--db-url="mysql://$dbUser:$dbPwd@localhost:3306/$db" \
--account-name=$acName \
--account-pass=$acPwd \
--account-mail=$acMail \
--site-name="$siteName" \
--site-mail=$siteMail \
-y
drush updb
drush cc all
echo "There is a bug in the Drush install which does not create the password correctly, so fix here"
drush upwd $acName --password=$acPwd
cd ..
echo
echo
echo "You need to Check, Add and Commit to repository"
echo
echo "now run FixPermissions as ROOT from the $apacheRoot/$siteFolder folder"
echo "DO NOT FORGET TO PUT THE Site URL INTO THE LAST LINE OF web/settings.php"
echo
echo "The $siteName Site should now be up and running so go the URL of the site and log in as $acName"
echo "Test it out, check the Reports->Status Report and Reports->Log Messages then tidy it up"
echo 
echo "The scripts 'exportConfigSync' and 'importConfigSync' assume you have already"
echo "installed the drupal/config_ignore module and added 'system.site' to the ignore list"
echo
echo " ------------------------------ IMPORTANT -------------------------------------"
echo "Then AFTER fixing folders and entries in the importConfigSync and exportConfigSync files"
echo "remember to export your site settings using the exportConfigSync script"
echo
echo "Then use git to add and commit and push"
echo 
echo "There is more info regarding a git workflow at https://themetman.net/drupal"
echo
