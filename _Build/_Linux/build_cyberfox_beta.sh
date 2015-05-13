# Cyberfox Beta quick build script
# Version: 1.0
# Release channel linux

#!/bin/bash

# Check for git installation.
function checkGIT(){
	command -v git >/dev/null 2>&1 || { 
	    echo "I require git but it's not installed would you like to install it now!."
	    select yn in "Yes" "No"; do
		case $yn in
		    Yes )
		      x-terminal-emulator -e sudo apt-get install git
		    break;;
		    No ) echo "I require git but it's not installed type 'sudo apt-get install git' to manually install it then run me again!." && exit;;
		esac
	    done   
	 }
}

# Set linux branding identity color.
function setIdentity(){
	    echo "Setting branding identity to Beta"
	    sed -i "s/\(IDENTITY_BRANDING_INTEL *= *\).*/\1/" $WORKDIR/cyberfox-beta/build/defines.sh
	    sed -i "s/\(IDENTITY_BRANDING_BETA *= *\).*/\11/" $WORKDIR/cyberfox-beta/build/defines.sh
	    echo "Setting branding identity complete!"
}

# Set chmod permissons.
function setPerms(){
	echo "Changing chmod of $1 to 777"
	chmod -R 777 $1
}

# Add changing directory information to console.
function changeDirectory(){

	if [ "$1" == ".." ]; then
		echo "Leaving $(dirname "$0") directory!"	
		cd $1
	else
		echo "Entering $(dirname "$0")/$1 directory!"	
		cd $1
	fi	
}

# Set working directory default is ~/Documents
WORKDIR=~/Documents

# Set repository url.
GITURI=https://github.com/InternalError503/cyberfox-beta.git

# Get and set base path.
Dir=$(cd "$(dirname "$0")" && pwd)

checkGIT
cd $WORKDIR

echo "Do you wish to setup or update cyberfox-beta source repository now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )	  
	  if [ -d "cyberfox-beta" ]; then
	      changeDirectory "cyberfox-beta"
	    echo "Auto purge uncommited untracked changes"
	      git checkout -- .
	    echo "Cloning latest cyberfox-beta source files"
	      git pull
			setIdentity
	      changeDirectory ".."
	      	setPerms "cyberfox-beta"
	      changeDirectory "cyberfox-beta"
	  else
	    echo "Downloading cyberfox-beta source repository"
	    git clone $GITURI
	      	setPerms "cyberfox-beta"
	    echo "mozconfig does not exist copying pre-configured to cyberfox-beta root"
	    cp -r $WORKDIR/cyberfox-beta/_Build/_Linux/mozconfig $WORKDIR/cyberfox-beta/
			setIdentity
	      changeDirectory "cyberfox-beta"
	  fi; break;;
        No ) break;;
    esac
done

echo "Do you wish to build cyberfox-beta now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) 
	  if [ -d $WORKDIR/obj64 ]; then
	    echo "Old ojb64 build output found! would you like to remove it now ?"
	      select yn in "Yes" "No"; do
		  case $yn in
		      Yes ) rm -rvf $WORKDIR/obj64; break;;
		      No ) break;;
		  esac
	      done
	  fi
	  if [ -f $WORKDIR/cyberfox-beta/mozconfig ]; then
	      	changeDirectory "$WORKDIR/cyberfox-beta"
		./mach build
	  else
		 echo "Were sorry but we can't build cyberfox-beta the mozconfig is missing!" && exit
	  fi; break;;       
        No ) break;;
    esac
done

echo "Do you wish to test cyberfox-beta now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
	  if [ -d $WORKDIR/obj64/dist/bin ]; then
	      	changeDirectory "cyberfox-beta"
	      ./mach run
	  else
	      echo "Unable to start cyberfox-beta $WORKDIR/obj64/dist/bin does not exist!"
	  fi; break;;
        No ) break;;
    esac
done

echo "Do you wish to package cyberfox-beta now?"
select yn in "Yes" "No"; do
    case $yn in
        Yes )
	  if [ -d $WORKDIR/obj64/dist/bin ]; then
	    	changeDirectory "cyberfox-beta"
	    ./mach package
	  else
	    echo "Unable to package cyberfox-beta $WORKDIR/obj64/dist/bin does not exist!"
	  fi; break;;  
        No ) break;;
    esac
done

if [ -f $Dir/bundle_cyberctr.sh ]; then
  echo "Do you wish to package CyberCTR into cyberfox-beta now?"
  select yn in "Yes" "No"; do
      case $yn in
	  Yes )	  
	    $Dir/bundle_cyberctr.sh; break;;  
	  No ) break;;
      esac
  done
fi