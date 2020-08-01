Write-Host "Azure PowersHell Base utilities installed"

<#
.SYNOPSIS
Connect to an azure devops account, and set a variable that will be reused
in subsequent functions to perform queries

.DESCRIPTION
Connect to an azure devops account, and set a variable that will be reused
in subsequent functions to perform queries

.EXAMPLE

.NOTES

#>
function Set-AzdoConnection {
  param (
      [string] $uri,
      [string] $token 
  )    
    $global:azdoUtilsAuthHeader = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$token")) }
    $global:azdoUtilsUri = $uri
    $projects = $global:azdoUtilsUri + "/_apis/projects?api-version=6.0-preview.4"

    $projects = Invoke-RestMethod -Uri $projects -Method get -Headers $global:azdoUtilsAuthHeader 
    if ($projects.GetType() -match 'String') {
      Write-Host "Connection failed"
    } else {
      Write-Host "Connected to account, found $($projects.count) projects"
    }
}

Export-ModuleMember -Function * -Cmdlet *
  