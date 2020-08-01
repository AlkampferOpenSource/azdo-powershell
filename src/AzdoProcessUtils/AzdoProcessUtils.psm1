Write-Host "Azure PowersHell Process Customization utilities installed"

<#
.SYNOPSIS
List all processes

.DESCRIPTION
List all processes that are available in connected organization

.EXAMPLE

.NOTES

#>
function Get-AzdoProcessList {
  param (
  )  
    $processList = $azdoUtilsUri + "/_apis/work/processes?api-version=6.0-preview.2"  
    $processes = Invoke-RestMethod -Uri $processList -Method get -Headers $azdoUtilsAuthHeader 
    
    return $processes
}

<#
.SYNOPSIS
Add a field to azure devops inherited process

.DESCRIPTION
Allows you to add a field to a specific work item in Azure Devops
inherited process

.EXAMPLE

.NOTES

#>
function Add-AzdoProcessField {
    param (
        [string] $ProcessName,
        [string] $WorkItemType
    ) 

    $processId = Get-AzdoProcessId -ProcessName $ProcessName

    $uri = $azdoUtilsUri + "/_apis/work/processes/$processId/workItemTypes/bug/fields?api-version=6.0-preview.2"
    $fields = Invoke-RestMethod -Uri $uri -Method get -Headers $azdoUtilsAuthHeader 
    
    Write-Host $fields.value
}

<#
.SYNOPSIS
Add a field to azure devops inherited process

.DESCRIPTION
Allows you to retrieve the id of a process that is
needed to perform almost all interaction with process
api.

.EXAMPLE

.NOTES

#>
function Get-AzdoProcessId {
    param (
        [string] $ProcessName
    ) 

    $processes = Get-AzdoProcessList 
    $process = $processes.value | Where-Object { $_.name -eq $ProcessName } 
    return $process.typeId
}

<#
.SYNOPSIS
Get id of the work item, used for subsequent calls

.DESCRIPTION
Allows you to add a field to a specific work item in Azure Devops
inherited process

.EXAMPLE

.NOTES

#>
function Get-AzdoWorkItemTypeId {
    param (
        [string] $ProcessName,
        [string] $WorkItemName
    ) 

    $processId = Get-AzdoProcessId -ProcessName $ProcessName

    $uri = $azdoUtilsUri + "/_apis/work/processes/{$processId}/workitemtypes?api-version=6.0-preview.2"
    $workItemTypes = Invoke-RestMethod -Uri $uri -Method get -Headers $azdoUtilsAuthHeader 
    $workItem = $workItemTypes.value | Where-Object { $_.name -eq $ProcessName } 
}

Export-ModuleMember -Function * -Cmdlet *
  