#!/usr/bin/perl
# ---------------------------------------------------------------------------------------------------------------
# Name         : cleanxml_svc.pl - based on cleanxml.pl
# Purpose      : This script cleans and moves xml files
# ---------------------------------------------------------------------------------------------------------------
#
# Description:
# This script will read in a parameter from the command line.
# Using that parameter, it will look in the current directory for xml files which begin with that value.
# If it finds one (or more) it will "clean" the xml by removing all new line characters and excess whitespace.
# It will then create a new version of the file in the "cleanedxml" directory with the same name.
# Finally it will move the original file to the cleanedxml_Archives sub directory.
#
#Revision Summary
#----------------
# Version Date      	Programmer	Notes
#-------- ----      	----------	---------
#  1.0  12/05/2006  	Joel Leger	Initial writing
#  1.1	5/6/2007	Joel Leger	Updated to add specific parameter support
#  1.2	01/02/2010	Yogesh HD	Modified the script to create xml files with DIR_ITEM_I in the file name.
#----------------------------------------------------------------------------------------------------------------
# START MAIN SCRIPT ---------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------------------

use File::Find;
use File::Copy;

# read in the script lib
require "/projects/ETL/TCI/utils/scr/TCI_OUTBOUND_FEED_LIB.pl";

# Set global vars
my $env_file = "/projects/ETL/TCI/utils/prop/tci.env";
my %TCIConfig = set_env_variables($env_file,%TCIConfig);


my $root = $TCIConfig{ROOT_IP};
my $dest_dir_root = $TCIConfig{IP_LCL_ROOT_PATH};
my $sw=0;

$intf_desc="Item_IP.+\.xml";

# open the directory and look for appropriate files
	opendir(DIR,$root) || die "NO SUCH Directory: $root";
	my @file_names = readdir(DIR);	
	closedir(DIR);
	foreach $file_name (@file_names)
  	{
		if (($file_name =~ /$intf_desc/gi) && ($file_name ne ".") && ($file_name ne ".."))
  		{
			open (FILE, $root.$file_name) || print "Could not open $root$file_name\n";
			my @lines = <FILE>;
			close FILE;
			my $line;
			my $file = "";
			# Parse out all the new line characters and the excess whitespace
			foreach $line (@lines)
			{
				$line =~ s/\*START_TAG\*/\</gi;
				$line =~ s/\*END_TAG\*/\/\>/gi;
				$line =~ s/\*DbQuotes\*/\"/gi;
				$line =~ s/\s*$//;
				$line =~ s/^\s*//;
				$line =~ s/\n$//;
				$file .= $line;
			}
			
my $string=$file;
$a = "<DirectItemNumber value=";
$b = "></DirectItemNumber>";

$pos1 = index($string, $a);
$pos1 = $pos1+25;
$pos2 = index($string, $b);
$pos2 = ($pos2-1)-$pos1;

$dir_item_id = substr $string , $pos1 , $pos2;

my $partfilenm=substr $file_name, 8;

			$new_file_name = "Item_IP_" . $dir_item_id . "_" . $partfilenm;
			# Create a new file in the cleanedxml subdir and insert clean xml
	open(OUTFILE, ">$dest_dir_root/$new_file_name") || print "Could not open the file $dest_dir_root/$new_file_name\n";
			print OUTFILE $file;
                        close OUTFILE;
copy($TCIConfig{ROOT_IP} . "cleanedxml/" . $new_file_name,"$TCIConfig{IP_ARCHIVE_DIR}" . "$new_file_name")|| print "Could not move " . $TCIConfig{ROOT_IP} . "cleanedxml/" . $new_file_name . " to $TCIConfig{IP_ARCHIVE_DIR}" . "$new_file_name";
			unlink ($TCIConfig{ROOT_IP} . "/" . $file_name);
		}
	}
	

#--------------------------------------
# END MAIN SCRIPT 
#--------------------------------------
