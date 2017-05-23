$Speak = new-object -com SAPI.SpVoice
$speak.speak("Warning!....Warning!....Logic and reason detected...Take cover...This is not a test...Logic and reason detected...run for your lives")

#$Hour = (get-date).timeofday.totalhours -gt 12

#    If ($Hour -lt 12) {$speak.speak("Good Morning")}
#    If (($Hour -ge 12) -and ($Hour -lt 18)) {$speak.speak("Good Afternoon")}
#    If ($Hour -ge 18) {$speak.speak("Good Morning")}