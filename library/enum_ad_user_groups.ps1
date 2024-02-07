#!powershell

#Requires -Module Ansible.ModuleUtils.Legacy
#AnsibleRequires -OSVersion 6.2
#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
	options = @{
		username = @{type="str"}
	}
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)
$username = $module.Params.username

# Quick check to see if provided username is empty
if ($username -eq "") {
	Write-Host "Empty username value provided!"
	$module.Result.error = "Provided username is empty"
	$module.ExitJson()
}


# Check to see if multiple usernames were provided (EX: Administrator, User1, User2)
if ($username -match ",") {
	$usernameList = $username -split ","
} else {
	# if no comma is found, we assume only a single username was provided
	$usernameList = $username
}


# Get the domain name
$domain = [System.Net.NetworkInformation.IPGlobalProperties]::GetIPGlobalProperties().DomainName

# Load necessary .NET assembly
# We do this instead of using ActiveDirectory PS Module
Add-Type -AssemblyName System.DirectoryServices.AccountManagement
$context = New-Object System.DirectoryServices.AccountManagement.PrincipalContext([System.DirectoryServices.AccountManagement.ContextType]::Domain, $domain)
$returnDict = @{}

# Loop through every user & grab their associated groups
foreach ($value in $usernameList) {
	$user = [System.DirectoryServices.AccountManagement.UserPrincipal]::FindByIdentity($context, $value)
	# Check user existence
	if (-not $user) {
		$returnDict[$value] = @("User not found in AD")
	} else {
		$groups = $user.GetGroups() | ForEach-Object { $_.Name }
		# Add all groups associated with user to dict
		$returnDict[$value] = @($groups)
	}
}

$module.Result.groups = $returnDict
$module.Result.changed = $false
$module.ExitJson()
