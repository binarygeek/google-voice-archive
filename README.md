# Google Voice Archive #

## Description ##

This is a small Ruby site that was built using the Padrino Framework. It allows a user to import Google Voice data (that was already exported from Google Voice) into a website (local or not) allowing for an easier way to view and extract the data as they want.

I made this simply because trying to view all the data associated to a particular person was difficult and cumbersome. I wanted an easy way I could see all texts from a particular person and read them in a linear fashion.

## Prerequisites ##

* Create archive of your Google Voice data from: [https://www.google.com/settings/takeout](https://www.google.com/settings/takeout)
* Download archive above and extract locally or on your server if code is running remotely
* Move the contents of the `Voice` directory from the extracted archive to where you want to import the data  (for example: `tasks/data/import`)
    * note: in the above example, this means the `Phones.vcf` file is in the `tasks/data/import` directory

## Setup ##

* `bundle install` to download all the gems
* Run `rake sq:migrate` in order for the database to be created and migrations to be run (database = sqlite)
* Run the task: `rake import:data['tasks/data/import/']` (where tasks/data/import is the directory with your extracted data)
    * When the import data task is run it will parse the vcard found in the root import directory to find the email and phone number to create a user account to log into the admin as well as a contact user for those text messages that were 'outgoing'