$Page = "http://www.newstalk1130.com/pages/jays_daily_links.html"
$Div_Class = "cunlock_main_content"

$Site = Invoke-WebRequest $Page -UseBasicParsing
$Body = $Site | Select-String -Pattern '(?s)<div class="cunlock_main_content".*?</div>' | % {$_.matches} | % {$_.Value}

$Body.Replace('<div class="cunlock_main_content">','').Replace('</div>','')

Send-MailMessage `
    -to joseph.streeter@doit.wisc.edu `
    -subject "Daily Links" `
    -from joseph.streeter@doit.wisc.edu `
    -body $Body `
    -smtpserver smtp.wiscmail.wisc.edu `
    -BodyAsHtml