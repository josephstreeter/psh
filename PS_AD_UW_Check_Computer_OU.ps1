get-adcomputer -f * -pr comment, whencreated, whenchanged -searchbase "ou=computers,ou=orgunits,dc=ad,dc=wisc,dc=edu" | sort enabled, comment| ft name, enabled, comment, whencreated, whenchanged -auto