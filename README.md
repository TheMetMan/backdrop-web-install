# Install Backdrop using drush 8 
This is a collection of Bash and php Scripts to install a new Backdrop site using Drush for File Based Workflow in a little under Three Minutes.

# Preamble
I am not the only one to have become somewhat disenchanted with Drupal 8. It has become increasingly difficult to keep up to date without problems for Non-Profit Organisations. As a single developer I have decided to move to Backdrop and develop my own scrips to manage updates.
This project came from an attempt to develop a File Based Workflow using Git, Bash and Drupal 8 and is developed from TheMetMan/drupal8_install also on GitHub. This one however used Drush version 8 with the Backdrop scripts found [here](https://github.com/backdrop-contrib/drush). 
We install Backdrop using Drush on the Local site, then update Locally. We then used Git and a clever script or two to push/pull the Content and Config via a remote repo to Dev (Staged) and Production seemed to work well.
We had to develop a hack to prevent the site details overwriting each other. Not too dificult once the workflow was established.
This is why we developed this script which will Install a Backdrop Site to the location of your choice, and in only a little under three minutes.

# Requirements
This is for Linux Only. We have not considered Windows. It will probably work on a Mac, but we have not tested it.
You will need to have already installed Drush 8 with the Backdrop Commands (as above) and Git globally.
You will also need a Virtual Host in the web Server (eg Apache) setup to match your site. Set the DocumentRoot to be the Install Folder.
You will need an empty database (mysql) ready to accept the installation.
The install puts a .htaccess file in the DocRoot to make the web/ folder the DocRoot and then correcting some settings in the web/.htaccess and web/settings.php files to also make this work.

# Usage
Place the script and the base_files folder in a location of your choice eg ~/bin/backdrop_install
Copy the config.cfg file as config.cfg.fg and put the correct variables for your location and site in place
Then make sure the createDrupalSite.sh script is executable, and run from the above folder.

`chmod +x createDrupalSite.sh`

and execute like so:

`./createDrupalSite.sh`

Wait a little ......

If you do this correctly for the Local, Dev and Prod sites you will end up with the databases in the correct dev_db, prod_db and local_db folders. If not you will be in a mess, so take time to get this correct!

# To Sync with Dev and Production
Clone the local site to Dev and Production once you have it working to your satisfaction.
Here is my file layout
.
├── config
│   ├── active
│   ├── dev_db
│   ├── local_db
│   ├── prod_db
│   └── staging
├── logs
├── private
└── web
    ├── core
    ├── files
    ├── layouts
    ├── modules
    ├── sites
    └── themes

Create a remote Git repository.

Here is an example of the workflow assuming you have all Local, Dev and Prod in sync and identical.
ExportConfigSync and Git Push Production Site to Repo. Stop adding Content to the Prod site (put in maintenance Mode)
On Local Site Git Pull from Repo and importConfigSync (choosing the Prod Site Database, so the Prod and Local Sites are Identical.
Change something on the Local site eg. add a module or theme, or add some content, or Upgrade Backdrop.
Then exportConfigSync Locally, git push and on the Dev Site Git Pull then importConfigSync choosing the Local Database) and then the Local and Dev sites are in Sync.
Check the Dev Site is working OK.
Do the same for the Prod Site. so they will all be equal. Then put Prod Site out of Maintenance Mode.

Here is an example of the actual commands you sould use in the above example

***On the Prod Site***
./exportConfigSync
git status
git add -A
git commit -am "Syncing the Prod Site to Local"
git push origin master

***On the Local Site***
git checkout -b update
git pull origin master
./importConfigSync (choose the Prod Database to import and say 'y' to importing the config files)

Now make the changes eg add a module or something, check all is OK then....
IF it is OK
git checkout master
git merge update
git branch -d update
./exportConfigSync
git status
git add -A
git commit -am "Added the PERFECT Module"
git push origin master

***On the Dev Site***
git checkout -b update
git pull origin master
./importConfigSync (choose the Local Database to import and say 'y' to importing the config files)
Check all is well on the Dev Site If so.....
git checkout master
git merge update
git branch -d update

***On the Prod Site***
git checkout -b update
git pull origin master
./importConfigSync (choose the Dev or Local Database to import and say 'y' to importing the config files)
Check all is well on the Prod Site If so.....
git checkout master
git merge update
git branch -d update

All your sites are updated and in Sync.
------------------------------------------------------------------------------------
