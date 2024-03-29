# cyberpatriots-ubuntu

This repo contains a comprehensive script and checklist for use on CyberPatriots Ubuntu images.

## Get started

* Download the repo on your host machine
* Copy the contents of the `scripts` folder onto a USB drive. Everything should be in the same directory
* Remove the USB drive
* Start the VM
* Once booted into Ubuntu, insert the USB drive
* In the same directory as the script files, add `users.txt` and `admins.txt` and populate the files with the lists of authorized users and administrators, respectively
* Replace the password in the script with the default user's password
* Comment out any necessary services or programs in `services.txt` and `software.txt` to prevent them from being removed
* Follow the checklist
