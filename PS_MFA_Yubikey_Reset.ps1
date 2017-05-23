$Path="C:\Program Files (x86)\Yubico\YubiKey PIV Manager"

cd $Path

"Block the Yubikey pin"
for ($i = 1; $i -lt 6; $i++)
    { 
    Invoke-Command -scriptBlock {.\yubico-piv-tool -a verify-pin -P 4711}
    }

"Block the Yubikey pin"
for ($i = 1; $i -lt 6; $i++)
    { 
    Invoke-Command -scriptBlock {.\yubico-piv-tool -a change-puk -P 4711 -N 67567}
    }

"Reset the Yubikey"
Invoke-Command -scriptBlock {.\yubico-piv-tool -a reset}

"The Yubikey reset has been completed"