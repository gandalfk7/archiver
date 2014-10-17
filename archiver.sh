#VARIABLES:	N=do not touch	E=editable
folder="YOUR_MAIN_WORK_FOLDER"		#E	the main folder used by the script
dayweek=$(date +%u)			#N
daymonth=$(date +%d)			#N
dayyear=$(date +%j)			#N
folderweekly="_weekly/"			#E	where weekly backups will be archived
foldermonthly="_monthly/"		#E	where monthly backups will be archived
folderyearly="_yearly/"			#E	where (bi)yearly backups will be archived
folderlog="_log/"			#E	the logs folder
logname="archiver_"			#E	name of the log, it will be: $logname_YYYY.MM.DD_HHMM.log
dayweekly="6"				#E	day of the weekly archive (1=mon 7=sun)
daymonthly="1"				#E	day of the mothly archive (1-31)
dayyearly1="15"				#E	day of the yearly archive 15=15th Jan (0-366) 
dayyearly2="196"			#E	day of the yearly archive 196=15th Jul (0-366)
date=$(date +"%Y.%m.%d_%H%M")		#N
retweekly="180"				#E	delete files older than 180 days in the folder weekly
retmonthly="366"			#E	delete files older than 1 (bissextile) year
retyearly="1826"			#E	delete files older than 5 years (4x365 + 1x366)

{

cd $folder					#change the work directory
actualfolder=$(pwd)				#store the actual workfolder
if [ $folder = $actualfolder"/" ]; then		#check if the working folder is the same as the actual workfolder
	if [ $dayweek = $dayweekly ]; then		#check if it's tuesday
		echo "starting weekly archiving"
		find $folder -not -path $folder'_log/*' -not -path $folder'_scripts/*' -not -path $folder'_test/*' -not -path $folder'_weekly/*' -not -path $folder'_monthly/*' -not -path $folder'_yearly/*' -type f -ctime -1 -exec rsync -av --log-file=$folder$folderlog"weeklyarchive_"$(date +"%Y.%m.%d_%H%M").log {} $folder$folderweekly \;
		echo "starting pruning of the weekly folder"
		find $folder$folderweekly -type f -ctime +$retweekly -exec rm {} \;	#delete files older than 180 days in the folder weekly
	fi
	if [ $daymonth = $daymonthly ]; then				#check if it's the 1st day of the month 
		echo "starting monthly archiving:"
		find $folder -not -path $folder'_log/*' -not -path $folder'_scripts/*' -not -path $folder'_test/*' -not -path $folder'_weekly/*' -not -path $folder'_monthly/*' -not -path $folder'_yearly/*' -type f -ctime -1 -exec rsync -av --log-file=$folder$folderlog"monthlyarchive_"$(date +"%Y.%m.%d_%H%M").log {} $folder$foldermonthly \;
		echo "starting pruning of the monthly folder"
		find $folder$foldermonthly -type f -ctime +$retmonthly -exec rm {} \;	#delete files older than 1 (bissextile) year
	fi
	if [ $dayyear = $dayyearly1 ] || [ $dayyear = $dayyearly2 ]; then
		echo "starting (bi)yearly archiving"
		find $folder -not -path $folder'_log/*' -not -path $folder'_scripts/*' -not -path $folder'_test/*' -not -path $folder'_weekly/*' -not -path $folder'_monthly/*' -not -path $folder'_yearly/*' -type f -ctime -1 -exec rsync -av --log-file=$folder$folderlog"yearlyarchive_"$(date +"%Y.%m.%d_%H%M").log {} $folder$folderyearly \;
		echo "starting pruning of the yearly folder"
		find $folder$folderyearly -type f -ctime +$retyearly -exec rm {} \;	#delete files older than 5 years (4x365 + 1x366)
	fi
fi

} 2>&1 | tee $folder$folderlog$logname$date.log

