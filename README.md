# SFDX  App

## Step

dumped because of SFDX issue and scratch org issue
but overall it was a good experience to use sfdx to interact with unmanaged pkg
and it worked to some capacity
> `create project`
> `create temp scratch org`
> `install unmanaged pkg in temp scratch org`
> `sfdx force:mdapi:retrieve -s -r ./temp -u mydevorg -p mypackage`
> `unzip ./temp/unpackaged.zip -d ./temp/`
> `sfdx force:mdapi:convert -r ./temp`
> `create permission set`
> `create scratch org and push source`
> `create pkg and pkg version and install in test org`