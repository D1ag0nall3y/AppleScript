###############################################################################
#
#
#
# Copywright Information
#
#
#
################################################################################
#
#
#
# ABOUT THIS PROGRAM
#
# NAME
# USB Imaging Script
#
# SYNOPSIS
#
# Program is currently set with redundancies if any input isn't given to satisfy the 
# core purpose of the program. If it cannot find the volume, userName or passAuth, it will prompt
# for input. The only excepts is the imageDirectory. This variable is required for further input 
# and must not be left blank and must be a real directory. If it cannot find this directory, the
# program will Error.
#
#   the imageDirectory currently uses ((system attribute "HOME") & "file path")
# to determine the image files location relative to the current Users.
# You however can input any file path by using "file path" to replace the whole string list above.
#
## DESCRIPTION
# This script will image an external volume from a specified image file.
# The <userName> and <passAuth> values can be used with a hardcoded value as well as the 
# flashDrive (Voume name you either want or have preset) and the imageDirectory(Location of image files)
#
#
#
################################################################################
#
#
#
# History
#
#   Version: 1.0
#
#   - Created by Josh Turnage on May 31tst, 2016
#
#
#
################################################################################
#
## DEFINE VARIABLES & READ IN PARAMETERS
#
################################################################################

# HARDCODED VALUES ARE SET HERE
set flashDrive to "name_of_drive" as text --> use if continuity is needed. Other wise is will prompt.
set imageDirectory to POSIX file ((system attribute "HOME") & "/imageServices/Services") as alias --> if in home directory repalace last set of quotes with directory. If not in home. replace full string.
set userName to "User_Name" --> Admin Username for computer
set passAuth to "PassWord" --> Admin Password for computer



#Logic Variables
set flashName to flashDrive


tell application "Finder"
  set imageFolder to name of folder imageDirectory
end tell



###############################################################################

# Warning to let end user know that this will erase the flash drive. Option to Cancel.
display dialog "This will Rename and Erase the chosen Flash Drive" buttons {"Cancel", "Proceed"} default button "Proceed"
if button returned of result = "Cancel" then
  return
  #else if button returned of result = "Proceed" then 
end if


################################################################################


#Checks to see if flashDrive is present
set msg to ((flashDrive & " Flash Drive Not Found. Choose another Volume."))
set currentDisks to paragraphs of (do shell script "ls /Volumes")
if (flashName is in currentDisks) then
  set msg to ((flashDrive & " Volume Present."))
end if


################################################################################


#Ask for alternative volume if flashDrive isn't found.
if msg = ((flashDrive & " Volume Present.")) then
  set volumePath to (("Volumes/" & flashDrive))
  
else
  display dialog msg buttons {"Cancel", "Choose Drive"} default button "Choose Drive"
  if button returned of result = "Choose Drive" then
    set volumeName to choose folder with prompt ¬
      "Please choose a file name:" default location "Volumes" without invisibles
    set volumePath to quoted form of POSIX path of volumeName
    do shell script "diskutil rename " & volumePath & " " & flashDrive
    
  else if button returned of result = "Cancel" then
    display dialog "Drive Required, Please Reopen To Try Again"
  end if
  
end if



###############################################################################

#Checks to see if  imageDirectory is present. Offers alternative directory if not present.
try
  set imageFolderPath to imageDirectory as alias
  set msg2 to ((imageFolder & "  Folder Present."))
on error
  set msg2 to "Select " & folderPath & " Folder:"
  display dialog msg2 buttons {"Cancel", "Choose Folder"} default button "Choose Folder"
  if button returned of result = "Choose Folder" then
    set imageFolderPath to choose folder with prompt ¬
      "Select " & folderPath & " Folder:" default location (system attribute "HOME") without invisibles
  else if button returned of result = "Cancel" then
    display dialog ((folderPath & " Folder Required, Please Reopen To Try Again:"))
  end if
end try


###############################################################################


#Prompts for Image file location.
set imagePath to choose file with prompt ¬
  "Choose a Service:" default location imageFolderPath without invisibles


#############################--VARIABLES FOR SHELL SCRIPTS--#############################


set imagePathPosix to POSIX path of imagePath
set volumePathPosix to POSIX path of volumePath

set renamePath to (("/Volumes/" & flashDrive))
##################################--TEMPORARY LOGIC--#################################

#This logic is to get the file name for imagePath and to remove the extension to pass into the Drive Renamer
tell application "Finder"
  set fileName to name of file imagePath
end tell

set restorePath to (("/Volumes/" & fileName))


tell application "Finder"
  set withEXT to restorePath
  set withoutEXT to (characters 1 thru -5 of (withEXT as text)) as text
end tell
####################################--SCRIPTS--####################################


#scripts to Restore Selected Image to either default or selected Volume
try
  do shell script "sudo asr restore --source " & quoted form of POSIX path of imagePathPosix & " --target " & renamePath & " -noprompt -erase" user name userName password passAuth with administrator privileges
on error
  do shell script "sudo asr restore --source " & quoted form of POSIX path of imagePathPosix & " --target " & renamePath & " -noprompt -erase" with administrator privileges
  
end try



#Script to rename restored image. Has wildcard for date consideration of file.
do shell script "diskutil rename " & withoutEXT & " " & flashDrive & ""


################################################################################


#Gives option for user to either eject now or later.
display dialog "Files were added to Flash Drive Successfully" buttons {"Eject Later", "Eject Drive"} default button "Eject Drive"
if button returned of result = "Eject Drive" then
  try
    do shell script "diskutil umount " & renamePath & ""
  on error
    display alert "Flash Drive not ejected properly, manually eject before unplugging"
  end try
  
else if button returned of result = "Eject Later" then
  display alert "Drive not Ejected"
end if


################################################################################
