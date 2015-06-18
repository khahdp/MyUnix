#!/bin/sh
cd /home_dir/z063077/TalendJobs/EventDataSplitToCMPN_0.1/EventDataSplitToCMPN 

#######################
#Setting Inital values#
#######################
PUBL_COUNT=0
PUBL_RETRYCOUNT=5
PUBL_SLEEP=5

#################
#Setting Command#
#################
COMMAND="sh EventDataSplitToCMPN_run.sh --context_param SourceFilePath=/home_dir/z063077/TalendJobs/EventDataSplitToCMPN_0.1/  --context_param  InputFileName=prv_demandtec_event.dat"

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
