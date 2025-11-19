###############################################################
# 1. Create a New Active Directory User
###############################################################

# Variables
$UserName = "jdoe"
$DisplayName = "John Doe"
$Password = ConvertTo-SecureString "P@ssw0rd123" -AsPlainText -Force
$OU = "OU=Users,OU=ViaMonstra,DC=corp,DC=viaMonstra,DC=com"

# Create the user
New-ADUser `
    -Name $DisplayName `
    -SamAccountName $UserName `
    -UserPrincipalName "$UserName@example.com" `
    -AccountPassword $Password `
    -Enabled $true `
    -Path $OU


###############################################################
# 2. Create a New Active Directory Group
###############################################################

$GroupName = "FileShare-ReadWrite"
$GroupOU   = "OU=Security Groups,OU=ViaMonstra,DC=corp,DC=viamonstra,DC=com"

New-ADGroup `
    -Name $GroupName `
    -GroupScope Global `
    -GroupCategory Security `
    -Path $GroupOU

###############################################################
# 3. Add the User to the Group
###############################################################

Add-ADGroupMember -Identity $GroupName -Members $UserName

###############################################################
# 4. Assign NTFS Permissions to a File Share
###############################################################

# Folder path
$FolderPath = "C:\Logs"

# Example: Grant Modify permission
$Rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    $GroupName,
    "Modify",
    "ContainerInherit, ObjectInherit",
    "None",
    "Allow"
)

# Get ACL, add rule, set ACL
$ACL = Get-Acl $FolderPath
$ACL.AddAccessRule($Rule)
Set-Acl -Path $FolderPath -AclObject $ACL
