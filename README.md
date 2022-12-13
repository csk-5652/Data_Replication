# Data_Replication
Backup + Mail_alert Powershell Script



$source = # Source location

$destination = # destination Location

$logs_folder = # Log_folder location

$EmailFrom = # Enter sender mail Address

$EmailTo = # Enter receiver mail address

$smtp = new-object Net.Mail.SmtpClient("SMTP_Server_host", 25)  # eg. ("smtp.gmail.com", 25/587 )

$smtp.Credentials = New-Object System.Net.NetworkCredential("mailaddress", "**********")   # eg.("Example@gmail.com","122@3")

