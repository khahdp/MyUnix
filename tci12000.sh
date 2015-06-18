#!/bin/ksh
#################################################################################
# TYPE               : UNIX Shell                                               #
# NAME               : tci70200.sh	                                      	#
# PURPOSE            : This script will be triggered by ControlM		#
# REGULAR Parameters :								#
#			ScriptName:		Name of Script			#
#			Environment:    Name of the Environment                 #
#			JobName:     	Name of the Job                         #
#										#
# Author      	Date        Ver  Description                    		#
# Target Corp 	21-Mar-07	1.0	 PRISM Publish Release 2007 Control-M Script#
#################################################################################

#################################
#Getting Command Line parameters#
#################################
SCRIPTNAME=TCIETLBatchRun_IP.ksh
ENV=prod
JOB=TCISQIPMSTR

echo "*****************************************"
echo "STARTING SCRIPT..."
echo `date`
echo "Script Name	 :"$SCRIPTNAME
echo "DS Job Name	 :"$JOB
echo "*****************************************"

###################################
# Set the environmental parameters#
# #################################
. /apps/Ascential/Projects/TCI/scripts/TCI_set_envirn.ksh $ENV

#######################
#Setting Inital values#
#######################
PUBL_COUNT=0
PUBL_RETRYCOUNT=$PUBL_RETRYCOUNT
PUBL_SLEEP=$PUBL_SLEEP

#################
#Setting Command#
#################
COMMAND="$SCRIPTS_DIR/$SCRIPTNAME $ENV $JOB"

###############################################
# Call script along with necessary parameters.#
###############################################
. $COMMAND
PUBL_STAT=$?

#################################
#RE-TRY LOGIC IN CASE OF FAILURE#
#################################
if [ $PUBL_STAT -ne 0 ]
then
	while [ $PUBL_STAT -ne 0 -a $PUBL_COUNT -le $PUBL_RETRYCOUNT ]
	do
	  sleep $PUBL_SLEEP
	. $COMMAND
	  PUBL_STAT=$?

	  ####################
	  #RESETTING COUNTERS#
	  ####################
	  PUBL_COUNT=`expr $PUBL_COUNT + 1`
	  if [ $PUBL_COUNT -eq $PUBL_RETRYCOUNT -a $PUBL_STAT -ne 0 ]
	  then
		echo "The script "$SCRIPTNAME" failed for more than "$PUBL_RETRYCOUNT" times"
		exit 1
	  fi
	done
fi

echo "*****************************************"
echo "SCRIPT ENDED SUCCESSFULLY..."
echo `date`
echo "*****************************************"
exit 0
