#!/usr/bin/bash
#
# https://github.com/TheMetMan/backdrop_web_install 
#
# 2023-05-07 version 0.2.0
# Changed form Drush to Bee
#
# 2022-05 version 0.1.0
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
        read -rp "$1 [Y/n]" REPLY </dev/tty
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
############ Import Config copied from config.cfg with details for this site added
configFile=config.cfg.fg
if [ -e "${configFile}" ]; then
  echo "Using ${configFile} config file"
else
  echo "I cannot find the Config File ${configFile} You MUST create this file"
  exit 1
fi
#-----------------------------------------------------------------------------
# shellcheck disable=SC2154
cd "$apacheRoot" || exit
echo "----------- This is a Backdrop CMS Install using Bee ----------------"
# shellcheck disable=SC2154
echo "---------- with the DocumentRoot as $apacheRoot/$siteFolder/web --------------"
echo "                Installing to $apacheRoot/$siteFolder"
echo
echo "           Make sure you have an empty database setup ready"
echo "=============================================================================="
if [ -d "$siteFolder" ]; then
  echo "**** The Old Site Folder is still present ****"
  echo "     you will need to remove this site."
  echo "  So as ROOT rm -fvr $apacheRoot/$siteFolder"
  echo "           then re-run this script"
  echo "Quitting Install Backdrop CMS for File Based Workflow"
#  exit 1
fi
if askfg "Do you really want to continue?" ; then
    echo "Installing now"
    mkdir -p "${apacheRoot}/${siteFolder}/web"
  else
    exit 1
  fi
cd "${apacheRoot}/${siteFolder}" || exit
echo and creating a git repository
git init
echo 'Downloading Backdrop CMS ....'
bee dl-core "${apacheRoot}/${siteFolder}/web"
echo
echo "create and copy .htaccess file to private folder"
mkdir private
# shellcheck disable=SC2154
cp "$workingFolder/base_files/htaccess" private/.htaccess
echo "create the other folders"
mkdir logs
configFolder=config
mkdir -p $configFolder/staging
mkdir $configFolder/active
mkdir $configFolder/versioned
cp "$workingFolder/base_files/htaccess" $configFolder/.htaccess
echo "Adjust some settings on the settings.php file"
# shellcheck disable=SC2154
sed -i "s,user:pass,${dbUser}:${dbPwd}," web/settings.php
# shellcheck disable=SC2154
sed -i "s,database_name,${db}," web/settings.php
sed -i "s/RewriteRule \^ index.php \[L\]/RewriteRule \^(\.*)\$ index.php?q=\$1 \[L,QSA\]/"  web/.htaccess
echo "RewriteBase /web" >> web/.htaccess
sed -i '/config_directories/d' ./web/settings.php
cat "$workingFolder/base_files/default.settings.xtra" >> ./web/settings.php
echo "adding Private Files Path and Trusted Hosts to settings.php file"
echo "\$settings['file_private_path'] = '$privatePath';" >> ./web/settings.php
echo  "\$settings['trusted_host_patterns'] = array('$trustedHosts',);" >> ./web/settings.php
echo  "\$base_url = 'http://$siteFolder'; # NO Trailing Slash!" >> ./web/settings.php
echo
echo "copy useful files across and clean up a little"
cp "$workingFolder/base_files/FixPermissions" ./
cp "$workingFolder/base_files/backupEssentials" ./
echo "Copying a .gitignore file for you and removing the web/.gigignore file. It causes probs"
cp "$workingFolder/base_files/gitignore" ./.gitignore
echo "remove the .gitignore file in the web folder. it messes up my gitignore file!"
rm "$apacheRoot/$siteFolder/web/.gitignore"
echo "Copying import and export Sync scripts for you"
cp "$workingFolder/base_files/importConfigSync" ./
cp "$workingFolder/base_files/exportConfigSync" ./
cp "$workingFolder/base_files/runBackdropUpgrade" ./
echo "Creating a .htaccess access file in DocumentRoot to redirect Document Root to web"
cp "$workingFolder/base_files/htaccess_docroot" ./.htaccess
sed -i "s,SITEFOLDER,$siteFolder," .htaccess
echo "Updating FixPermissions User and Group"
# shellcheck disable=SC2154
sed -i "s,USER,$apacheUser," FixPermissions
# shellcheck disable=SC2154
sed -i "s,GROUP,$apacheGroup," FixPermissions
chmod +x FixPermissions
cd web || exit
echo "Fix permissions on install script"
chmod 755 core/scripts/install.sh
echo 'Install Site using Bee'
# shellcheck disable=SC1073
# shellcheck disable=SC2086
bee si \
--auto \
--db-name=$db \
--db-user=$dbUser \
--db-pass=$dbPwd \
--db-host=localhost \
--username=$acName \
--password=$acPwd \
--email=$acMail \
--site-name=$siteName \
--site-mail=$siteMail \
--profile=standard \
--langcode=en \
echo
bee updb
bee cc all
cd ..
echo
echo "-------------------[ Finished the Install ]-------------------"
echo
echo " Now run down this check list"
echo "	1. DO NOT FORGET TO PUT THE Site URL INTO THE LAST LINE OF web/settings.php"
echo "	2. Run FixPermissions as ROOT from the $apacheRoot/$siteFolder folder"
echo "	3. The $siteName Site should now be up and running so go the URL of the site and log in as $acName"
echo "		Test it out, check the Reports->Status Report and Reports->Log Messages"
echo "		then Fix any Problems iif necessary, clear the caches as well"
echo "	4. Remember to export your site settings using the exportConfigSync script"
echo "	5. git add -A"
echo "	6. git commit -am 'Initial Commit'"
echo " Now you should create a remote repo, and push"
echo
echo " The scripts 'backupEssentials', 'exportConfigSync', 'importConfigSync'"
echo " and 'runBackdropUpgrade' are there for you to use"
echo " Enjoy!"
echo
echo "---------------------[ All Done ]-------------------"

