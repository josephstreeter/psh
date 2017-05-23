$file = "C:\" + $env:computername + ".TXT"

get-service | out-file $file

Copy-Item $File \\mcdc1\c$