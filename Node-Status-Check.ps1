$computers = "barracks","bubblegum","carrier"
$global:counter = 0

Foreach($c in $computers) {
IF (Test-Connection -BufferSize 32 -Count 2 -ComputerName $c -Quiet) {
        #Write-Host $global:counter
        $global:counter = $global:counter + 1
        $dnsName = @()
        $dnsName = $dnsName + ((Resolve-DnsName -ErrorAction SilentlyContinue $computers[$global:counter] | Select-Object -ExpandProperty Name) + " | " + (Resolve-DnsName -ErrorAction SilentlyContinue $computers[$global:counter] | Select-Object -ExpandProperty IPAddress))
        Write-Host $dnsName "is online"
        Start-Sleep -Seconds 1
} Else {
        # Start-Sleep -Seconds 600
        ## Script to send email if server is down.

        $SmtpUser = $env:SMTP_USER
        $smtpPassword = $env:SMTP_PASS

        # Get the credential
        $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $SmtpUser, $($smtpPassword | ConvertTo-SecureString -AsPlainText -Force)

        ##New-Object System.Management.Automation.PSCredential -ArgumentList

        ## Define the Send-MailMessage parameters
        $mailParams = @{
            SmtpServer                 = 'smtp.office365.com'
            Port                       = '587' # or '25' if not using TLS
            UseSSL                     = $true ## or not if using non-TLS
            Credential                 = $credential
            From                       = $SmtpUser
            To                         = $SmtpUser
            Subject                    = $computers[$global:counter] + " is Offline - $(Get-Date -Format g)"
            Body                       = "The remote computer " + $computers[$global:counter] + " is Offline"
            DeliveryNotificationOption = 'OnFailure', 'OnSuccess'
        }

        ## Send the message
        Send-MailMessage @mailParams
        Write-Host "The remote computer " $computers[$global:counter] " is Offline"
}}