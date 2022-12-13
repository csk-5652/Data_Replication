

# PowerShell Robocopy script with e-mail

# --------- Notices Instrucations ------------ #

# In order to get email notifications you should set emails_engine varabile below to 1.
# You should as well to request for SMTP relay in TAG with the workstation domain name that this script run from.
# If you want to get a full notice even in success set the full_notice varabile below to 1.
# if you want to get only when fail please change the full_notice varabile below to 0.
 
$emails_engine = 1
$full_notices = 1

# --------- Variable Declaration------------ #

$date = Get-Date -UFormat "%m%d%y"
$appname = "test"  #Appname can be anything
$source = "C:\Users\Csk\Downloads\source" #need to change
$destination = "C:\Users\Csk\Downloads\destination" #need to Change
$logfile = "$appname-backup_log-$date.txt"
$logs_folder = "C:\Users\Csk\Downloads\log_folder"  #need to change
$robocopyaction = @("/E","/np")
$robocopyoptions = @("/R:3","/W:1","/mt")
$robocopylog = @("/log+:$logs_folder\$logfile")
$cmdArgs = @("$source","$destination",$robocopyaction,$robocopyoptions,$robocopylog)
$last_logs_to_keep = "14"
$time_stamp = Get-Date -format "MM-dd-yyyy HH:mm:ss"
$host_name= hostname


# Function for sending mail
function sendMail($message){
    $EmailFrom = "Example@gmail.com"  #need to change
    $EmailTo = "Example2@gmail.com"   #need to change
    $Subject = "Backup"      #Can be anything
    $Body= @"
    <h1 style="color: green;">
        Backup Alert Notification
    </h1>
    <p style="margin: auto;">
    <h3 style="margin: 8px;">Date and Time :  $time_stamp  </h3>
    <br>
    <h3 style="margin: 8px;">Status: $message </h3>
    <h3>System name :- $host_name </h3>
    </p>
    <script>

    </script>
"@

    $file = "$logs_folder\$logfile"

    $message = new-object System.Net.Mail.MailMessage
    
    $message.From = $EmailFrom
    $message.To.Add($EmailTo)
    $message.IsBodyHtml = $True 
    $message.Subject = $Subject 

    $attach = new-object Net.Mail.Attachment($file) 
    $message.Attachments.Add($attach) 
    $message.body = $Body 

    $smtp = new-object Net.Mail.SmtpClient("smtp.gmail.com", 25) 
    $smtp.EnableSsl = $true
    #Need to chnage credentials ("Example@gmail.com","Passoword")
    $smtp.Credentials = New-Object System.Net.NetworkCredential("Example@gmail.com", "***********")   
    $smtp.Send($message)


}



function clearlog{
Get-ChildItem $logs_folder -Recurse| Where-Object{-not $_.PsIsContainer}| Sort-Object CreationTime -desc| 
    Select-Object -Skip $last_logs_to_keep | Remove-Item -Force
}

if (!(Test-Path $logs_folder -PathType Container)) {
    New-Item -ItemType Directory -Force -Path $logs_folder}
If (!(Test-Path $logfile)){ New-Item -ItemType file $logfile } 
robocopy @cmdArgs
if ($emails_engine -eq 1){
    if ($lastexitcode -lt 8){
    if ($full_notices -eq 1){
        sendMail("Backup was successful for $appname.")
        clearlog
        }
        else{
        clearlog
        }
    }
    elseif ($lastexitcode -gt 7){
        if ($full_notices -eq 1){
        sendMail("Backup failed for $appname.")
        clearlog
        }
        else{
        clearlog
        }
    }
    else{
        sendMail("Unknown Error. Backup did not complete successfully." + "`r`n`n" + "This is an automated email please do not respond.")
        clearlog
        }
}


