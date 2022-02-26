#!/bin/bash
###############################################################################
# Shell Documentation : (alter only required '**' lines)                      #
# ----------------------------------------------------------------------------#
# 01. Shell Name      : import_mount_vol.sh                                   #
# 02. Application     : APPLIC                                                  #
# 03. Creation Date   : 27th March 2020                                       #
# 04. Created By      : Jeeth(jeethendra.kumar@company.com)                       #
# 05. Modified Date   :                                                       #
# 06. Modified By     :                                                       #
# 07. Initiated by    : createAndAttachVolume.py                              #
# 08. Calling Shells  :                                                       #
# 09. Mode of Operation:APPLIC                                                  #
# 10. Schedule        :                                                       #
# 11. Script Location :                                                       #
# 12. PreRequests     : createandAttachVol.py scripts should excecute         #
# 13. PostRequests    :                                                       #
#-----------------------------------------------------------------------------#
# 14. Description/    : This script Imports the Volume and mounts the volume  #
#             Notes   :                                                       #
#                     :                                                       #
#-----------------------------------------------------------------------------#
# 15. Modification    :                                                       #
#         Reason      :                                                       #
###############################################################################


#--------------{ INITIALIZE SCRIPT CALL AND VARIABLE DECLARATIONS }-----------#
initiate()
{
        x='\(.\{'
        y='\}\)'
        DATET=`date '+%m%d%H%M%S'`
        DATETT=`date '+%d-%m-%Y:%m%d%H%M%S'`
		DATET1=`date '+%m-%d-%Y'`
		DATET2=`date '+%d-%m-%Y-%m%d%H%M%S'`
		DATET3=`date '+%m-%d-%Y'`
        HOST=`hostname`
        cur_dir=`pwd`
        backup_dir="/volume_backup"
        APPLIC_LOG=/root/APPLIC/APPLIC_import_pre_log.$timestamp.log
        MAIL_LOG=/root/APPLIC/APPLIC_import_mail_log.$timestamp.log
        ATTACH_LOG=/root/APPLIC/APPLIC_import_log.$timestamp.log
        ATTACH_LOG_NAME=`basename $ATTACH_LOG`
		TEMP_FILE=/root/APPLIC/temp.txt
        MAILTO='jeethendra.kumar@company.com'
        echo -e "Initiating to Import volume and Mount it to Backup folder  \n" | tee -a $ATTACH_LOG $APPLIC_LOG
}
#-----------------------------{ SendMail Module }-------------------------------#
process_mail()
{
export SUBJECT=$1
export BODY=$2
export ATTACH=$ATTACH_LOG
export MAILPART=`uuidgen` ## Generates Unique ID
export MAILPART_BODY=`uuidgen` ## Generates Unique ID
export FROM_ADDRESS=`echo APPLIC_app@${source_fqdn}`

(
 echo "From: $FROM_ADDRESS"
 echo "To: $MAILTO"
 echo "Subject: $SUBJECT"
 echo "MIME-Version: 1.0"
 echo "Content-Type: multipart/mixed; boundary=\"$MAILPART\""
 echo ""
 echo "--$MAILPART"
 echo "Content-Type: multipart/alternative; boundary=\"$MAILPART_BODY\""
 echo ""
 echo "--$MAILPART_BODY"
 echo "Content-Type: text/html; charset=ISO-8859-1"
 echo "Content-Disposition: inline"
 cat $BODY
 echo "--$MAILPART_BODY--"

 echo "--$MAILPART"
 echo 'Content-Type: application; name="'${ATTACH_LOG_NAME}'"'
 echo "Content-Transfer-Encoding: base64"
 echo 'Content-Disposition: attachment;'
 echo ""
 #uuencode -m $ATTACH $(basename $ATTACH)
 base64 $ATTACH
 echo "--$MAILPART--"
) | /usr/sbin/sendmail $MAILTO
}


#----------------------{ FUNCTIONS FOR SENDING ALERT MAILS }----------------------#

send_gen_script()
{
            echo -e '<html><body style="padding:0; margin:0; background:#fefefe">' > $MAIL_LOG
            echo -e '<body style="padding:0; margin:0; background:#fefefe">' >> $MAIL_LOG
            echo -e '<table width="100%" border="0" cellspacing="0" cellpadding="5" bgcolor="#fefefe">' >> $MAIL_LOG
            echo -e '<tr><td align="center" valign="top"><table width="581" cellspacing="10" cellpadding="0">' >> $MAIL_LOG
            echo -e '<tr><td  align="center"><hr width="100%" color="#8DC442" /><font color="green"> APPLIC - Data Restore from Snapshot: '"$DATET3"'  </font><hr width="100%" color="#8DC442" /></td></tr>' >> $MAIL_LOG
            echo -e '<tr><td><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr>	<td valign="top" width="245">' >> $MAIL_LOG
            echo -e '<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr>' >> $MAIL_LOG
            echo -e '<td style="font-family: Georgia; font-size:12px; line-height:16px; text-align:left; color:#333;">' >> $MAIL_LOG
            echo -e '<div style="font-family: Georgia; font-size:12px; line-height:16px; color:green; font-weight:bold; text-transform:uppercase;"> Summary</div>' >> $MAIL_LOG
            echo -e '</td></tr></table></td>' >> $MAIL_LOG
            echo -e '<td valign="top">&nbsp;</td>' >> $MAIL_LOG
            echo -e '</tr></table></td></tr>' >> $MAIL_LOG
            echo -e '<tr><td style="font-family: Georgia; font-size:12px; line-height:16px; text-align:left; color:#333;">' >> $MAIL_LOG
            echo -e 'Status of Newly launched t2.micro instance, look at the following report</td></tr>' >> $MAIL_LOG
            echo -e '<tr><td style="font-family: Georgia; font-size:12px; line-height:16px; text-align:left; color:#333;">' >> $MAIL_LOG
            cat $APPLIC_LOG | sed 's/$/\<br>/g' > $TEMP_FILE
            cat $TEMP_FILE >>$MAIL_LOG
            rm $TEMP_FILE
            echo -e '</td></tr>' >> $MAIL_LOG
            echo -e '<tr><td style="font-family: Georgia; font-size:10px; line-height:16px; text-align:center; color:#333;">' >> $MAIL_LOG
            echo -e 'Note: If you have any Queries or Concern please click <a href="mailto:jeethendra.kumar@company.com?subject=Queries"  style="color:#8DC442; text-decoration:underline;">here</a>.</td></tr>' >> $MAIL_LOG
            echo -e '<tr><td style=""><hr width="100%" /><table width="100%" border="0" cellspacing="0" cellpadding="10"><tr>' >>$MAIL_LOG	
            echo '<td style="font-family: Georgia; font-size:10px; line-height:12px; text-align:center; color:#8DC442;">' >>$MAIL_LOG
            echo 'This mail is generated through the automation process carried out for restoring data from Volume of Snapshot<font style="font-family: Times New Roman; color:#990033">'"$SNAPSHOT_ID"'</font></td>'>>$MAIL_LOG
            echo "</tr></table></td></tr></table></td></tr></table></body></html>" >>$MAIL_LOG
            process_mail "$source_hostname :Import and Mount Volume success" "$MAIL_LOG"

}

#--------------{ get the partition Name, activate LV and mount it  }-------------#
activate_mount_lv(){
        echo "The Partition Name is $partition_name" | tee -a $ATTACH_LOG $APPLIC_LOG
        echo "Proceeding to import the volume.." | tee -a $ATTACH_LOG $APPLIC_LOG
                vg_name=`pvdisplay /dev/xvdf1 | grep "VG Name" | tr -d '\040\011\012\015' | sed "s/VGName//g"`
                lv_path=`lvdisplay $vg_name | grep "LV Path" | tr -d '\040\011\012\015' | sed "s/LVPath//g"`
                    ### Check for dir, if not found create it using the mkdir                     mnt=`mount $lv_path $backup_dir 2>&1 `##
                    [ ! -d "$backup_dir" ] && mkdir -p "$backup_dir"
                    mnt=`mount $lv_path $backup_dir 2>&1`
                    if [ $? -eq 0 ]
                    then
                            echo -e "\n The backup volume $lv_path is Successfully mounted  to $backup_dir" | tee -a $ATTACH_LOG $APPLIC_LOG
                            send_gen_script
                    else
                            echo -e "\n Error in Mounting the volume $lv_path to $backup_dir folder  " | tee -a $ATTACH_LOG $APPLIC_LOG
                             echo "------------ERROR LOG---------------" >> $ATTACH_LOG
                             echo "$mnt \n" >>  $ATTACH_LOG
                             send_gen_script
                             exit 1
                    fi
                
            
}
#------------------{ Check for thr partition and get the Name  }------------------#
check_partition()
{
        echo "Mounting $partition_name" | tee -a $ATTACH_LOG $APPLIC_LOG
        check_partition=`pvdisplay 2>&1 | grep "$partition_name" | wc -l`
        #echo "$check_partition count for $name" >> $APPLIC_LOG
         if [[ $check_partition -gt 0 ]]
         then              
            activate_mount_lv
        else
             echo "Error in Tracing the Partition Name, Please contact Drive app team \n " | tee -a $ATTACH_LOG $APPLIC_LOG
             echo `pvdisplay 2>&1` >> $ATTACH_LOG
             send_gen_script
             exit 1
            fi 
}

#-------------------{ THE EXECUTION OF THE SCRIPT STARTS HERE }------------------#

timestamp=`echo $3`
initiate
partition_name='/dev/xvdf1'
source_hostname=`echo $1`
source_fqdn=`echo $2`
check_partition
exit 0
