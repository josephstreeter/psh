Invoke-Command -comp $((Get-ADComputer -f {name -like "cadsdc-warf-0*"} -searchbase "ou=domain controllers,dc=ad,dc=wisc,dc=edu").dnshostname) -ScriptBlock {restart-service netlogon} -UseSSL