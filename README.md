# Install Backdrop using drush 8 
THis is a collection of Bash and php Scripts to install a new Backdrop site using Drush for File Based Workflow in a little over Three Minutes.

# Preamble
I am not the only one to have become somewhat disenchanted with Drupal 8. It has become increasingly difficult to keep up to date without problems for Non-Profit Organmisations. As a single developer I have decided to move to Backdrop and develop my own scrips to manage updates.
This project came from an attempt to develop a File Based Workflow using Git, Bash and Drupal 8 and is developed from TheMetMan/drupal8_install also on GitHub. This one however used Drush version 8 with the Backdrop scripts found [here](https://github.com/backdrop-contrib/drush). 
We have found that installing Backdrop using Drush on the Local site, then update Locally. We then used Git and a clever script or two to push/pull the Content and Config via a remote repo to Dev (Staged) and Production seemed to work well.
We had to develop a hack to prevent the site details overwriting each other. Not too dificult once the workflow was established.
This is why we developed this script which will Install a Backdrop Site to the location of your choice, and in only a little over three minutes.

# Requirements
This is for Linux Only. We have not considered Windows. It will probably work on a Mac, but we have not tested it.
You will need to have already installed Drush 8 and Git globally.
You will also need a Virtual Host in the web Server (Apache)setup to match your site. Set the DocumentRoot to be the Install Folder.
The install puts a .htaccess file in the DocRoot to make the web/ folder the DocRoot and then correcting some settings in the web/.htaccess and web/settings.php files to also make this work.
You will need a database (mysql) ready to accept the installation.

# Usage
Place the script and the base_files folder in a location of your choice eg ~/bin/backdrop_install
Edit the config.cfg file to put the correct variables for your location and site in place
Then make sure the createDrupalSite.sh script is executable, and run from the above folder.

`chmod +x createDrupalSite.sh`

and execute like so:

`./createDrupalSite.sh`

Wait a little ......

You will need to edit the exportConfigSync script to put the correct database info into it. Similarly the importConfigSync script.
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
Change something on the Local site eg. add a module or theme, or add some content.

Export your config and content using exportConfigSync script. 
`./exportConfigSync`
This will have the current config in config/staging folder, and the database in the correct folder (we hope).
Then 
`git add -A`
`git commit -am "add your commit tect here"`
`git push origin master`
Now go to the Dev site, say.
`git checkout -b update`
`git pull origin master`
`./importConfigSync`

You will be prompted for the database to import or none, but you should select 'Local' in this case.
and select 'y' to import config.

Then test the site. It should match the local site. If all is OK

`git checkout master`
`git merge update`
`git branch -d update`

You can then repeat this for the Prod Site.
------------------------------------------------------------------------------------
In real life, you will probably have content added to Production, so will need to reverse the process and pull down to Local before doing updates and testing, then uploading to Dev and PRoduction.


