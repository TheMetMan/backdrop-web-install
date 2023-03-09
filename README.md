# Install Backdrop using drush 8 
This is a collection of Bash and php Scripts to install a new Backdrop site using Bee (originally Drush) for File Based Workflow in a little under Three Minutes.\
Also there is a script to upgrade Backdrop CMS Core and Modules when required. This is called runBackdropUpgrade. Instructions are at the end of this file.

# Preamble
I am not the only one to have become somewhat disenchanted with Drupal 8. It has become increasingly difficult to keep up to date without problems for Non-Profit Organisations. As a single developer I have decided to move to Backdrop and develop my own scrips to manage updates.\
This project came from an attempt to develop a File Based Workflow using Git, Bash and Drupal 8 and is developed from TheMetMan/drupal8_install also on GitHub. This one however used Drush version 8 with the Backdrop scripts found [here](https://github.com/backdrop-contrib/drush).\
It has now been moved to Bee because Drush does not work on PHP 8. 
We install Backdrop using Bee on the Local site, then update Locally. We then use Git and a clever script or two to push/pull the Content and Config via a remote repo to Dev (Staged) and Production.
We had to develop a hack to prevent the site details overwriting each other. Not too difficult once the workflow was established.\
This is why we developed this script which will Install a Backdrop Site to the location of your choice, and in only a little under three minutes.

# Requirements
This is for Linux Only. We have not considered Windows. It will probably work on a Mac, but we have not tested it.\
You will need to have already installed Bee from here https://github.com/backdrop-contrib/bee and Git globally.\
You will also need a Virtual Host in the web Server (e.g. Apache) setup to match your site. Set the DocumentRoot to be the Install Folder.\
You will need an empty database (mysql) ready to accept the installation.\
The install puts a .htaccess file in the DocRoot to make the web/ folder the DocRoot and then correcting some settings in the web/.htaccess and web/settings.php files to also make this work.\

# Usage
Place the script and the base_files folder in a location of your choice eg ~/bin/backdrop_install\
Copy the config.cfg file as config.cfg.fg and put the correct variables for your location and site in place, then make sure the createBackdropSite.sh script is executable, and run from the above folder.

`chmod +x createBackdropSite.sh`

and execute like so:

`./createBackdropSite.sh`

Wait a little ......

If you do this correctly for the Local site you will end up with the databases in the config/versioned folder.\

# To Sync with Dev and Production
Clone the local site to Dev and Production once you have it working to your satisfaction.\
Here is my file layout\
.
├── config\
│   ├── active\
│   ├── staging\
│   └── versioned\
├── logs\
├── private\
└── web\
    ├── core\
    ├── files\
    ├── layouts\
    ├── modules\
    ├── sites\
    └── themes\

Create a remote Git repository.

I have developed a handy Ansible Project to automate the updating of multiple sites here https://github.com/TheMetMan/backdrop_upgrade_made_easy 

Here is an example of the workflow assuming you have all Local, Dev and Prod in sync and identical.\
ExportConfigSync and Git Push Production Site to Repo. Stop adding Content to the Prod site (put in maintenance Mode)\
On Local Site Git Pull from Repo and importConfigSync. 
This will replace the database with the one in config/versioned and sync the config/versioned/\*.json files to config/staging, overwriting anything you have put in the config/ignoreSettings.php file 
then import into the site database\
Change something on the Local site e.g. add a module or theme, or add some content, or Upgrade Backdrop.\
Then exportConfigSync Locally, git push and on the Dev Site Git Pull then importConfigSync and then the Local and Dev sites are in Sync.\
Check the Dev Site is working OK.\
Do the same for the Prod Site. so they will all be equal. Then put Prod Site out of Maintenance Mode.\

Here is an example of the actual commands you should use in the above example

***On the Prod Site***
```bash
./exportConfigSync
git status
git add -A
git commit -am "Syncing the Prod Site to Local"
git push origin master
```
***On the Local Site***
```bash
git checkout -b update
git pull origin master
./importConfigSync
```
Now make the changes e.g. add a module or something, check all is OK then....\
IF it is OK
```bash
./exportConfigSync
git add -A
git commit -am "Add Text Here"
git checkout master
git merge update
git branch -d update
git push origin master
```
***On the Dev Site***
```bash
git checkout -b update
git pull origin master
./importConfigSync (choose the Local Database to import and say 'y' to importing the config files)
Check all is well on the Dev Site If so.....
git checkout master
git merge update
git branch -d update
```
***On the Prod Site***
```bash
git checkout -b update
git pull origin master
./importConfigSync (choose the Dev or Local Database to import and say 'y' to importing the config files)
Check all is well on the Prod Site If so.....
git checkout master
git merge update
git branch -d update
```
All your sites are updated and in Sync.
------------------------------------------------------------------------------------

**Cloning a Site is Easy**
Using this system it is easy to Clone a Site.
Create an empty Database, Site Folder and Vhost on the Target Server.
On the Source, export the Config settings, then rsync the whole site to the Target Server.
On the Target server you will need to change the following:
In the web/settings.php file, change database settings near the top of the file and the Trusted Hosts and Base URL at the bottom to agree with credentials.
Edit the exportConfigSync file to do the backupEssentials to the correct folder (Matches the Site Folder).
Do the same for the importConfigSync file and the runBackdropUpgrade script.
Remove the old git remote origin repo settings and add again with the correct remote repo.

Now still on the Target Server, run the importConfigSync and you will have a working site matching the source site.

------------------------------------------------------------------------------------

**Upgrading Backdrop Core**
I have created a bash script to upgrade a site when a new version of Backdrop or a module or theme becomes available.\
All you need to do is to run the script runBackdropUpgrade, and you will end up with the new version in place, but the old version backed up.\
There are instructions on what to do should something go wrong at the end of that file.

------------------------------------------------------------------------------------

**Create a Snapshot of the Site**
Use git to create a new branch and make sure everything is committed
```bash
git checkout -b snapshot
git status
./exportConfigSync
git add -A
git commit -am "Creating a Snapshot"
```
Check all is well on the Site If so.....
you have a snapshot you can always go back to as follows
```bash
git checkout snapshot
git status
./importConfigSync
```
You will now have a site as per the snapshot

