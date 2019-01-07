# SFDX  App

## Step

> `create project`
> `create temp scratch org`
> `install unmanaged pkg in temp scratch org`
> `sfdx force:mdapi:retrieve -s -r ./temp -u mydevorg -p mypackage`
> `unzip ./temp/unpackaged.zip -d ./temp/`
> `sfdx force:mdapi:convert -r ./temp`
> `create permission set`
> `create scratch org and push source`
> `create pkg and pkg version and install in test org`