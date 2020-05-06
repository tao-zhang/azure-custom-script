# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# If the firewall rule does not exist, create one
try {
    Get-NetFirewallRule -DisplayName 'OpenSSH SSH Server (sshd)' -ErrorAction Stop | Set-NetFirewallRule -LocalPort 2222
}
catch {
    New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH SSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 2222
}     

# Copy administrators_authorized_keys
Copy-Item -Path $args[0] -Destination "$Env:ProgramData\ssh\administrators_authorized_keys" -Force

# Remove permission inheritate
$acl=Get-Acl -LiteralPath "$Env:ProgramData\ssh\administrators_authorized_keys"
$acl.SetAccessRuleProtection($true, $true)
Set-Acl -LiteralPath "$Env:ProgramData\ssh\administrators_authorized_keys" -AclObject $acl

# Fix permission
$acl=Get-Acl -LiteralPath "$Env:ProgramData\ssh\administrators_authorized_keys"
$rule = $acl.Access | Where-Object {$_.identityreference -match "NT AUTHORITY\\Authenticated Users"}
$acl.RemoveAccessRuleAll($rule) | Out-Null
Set-Acl -LiteralPath "$Env:ProgramData\ssh\administrators_authorized_keys" -AclObject $acl 

# Copy sshd_config
Copy-Item -Path $args[1] -Destination "$Env:ProgramData\ssh\" -Force

# Start sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'
