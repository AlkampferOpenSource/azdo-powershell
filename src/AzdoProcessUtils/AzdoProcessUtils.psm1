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
        [string] $WorkItemTypeName,
        [string] $FieldName
    ) 

    $processId = Get-AzdoProcessId -ProcessName $ProcessName
    $workItemTypeId = Get-AzdoWorkItemTypeId -ProcessName $ProcessName -WorkItemTypeName $WorkItemTypeName
    $uri = $azdoUtilsUri + "/_apis/work/processes/$processId/workItemTypes/$workItemTypeId/fields?api-version=6.0-preview.2"
    $fields = Invoke-RestMethod -Uri $uri -Method get -Headers $azdoUtilsAuthHeader 
    $field = $processes.value | Where-Object { $_.referenceName -eq $FieldName } 

    if ($field -eq $null) {
       Write-Host "Field name $FieldName does not exists will be created" 
       $bodyObject = @{ 
           "referenceName" = $FieldName; 
           "defaultValue" = "";
           "allowGroups" = $false;
        }

       $body     = $bodyObject | ConvertTo-Json -Compress
       $createUri = $azdoUtilsUri + "/_apis/work/processes/$processId/workItemTypes/$workItemTypeId/fields?api-version=6.0-preview.2"
       
       $postAzdoUtilsAuthHeader = $azdoUtilsAuthHeader.Clone()
       $postAzdoUtilsAuthHeader["Content-Type"] = "application/json"
       $result =  Invoke-RestMethod -Uri $uri -Body $body -Method POST -Headers $postAzdoUtilsAuthHeader 
    }
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
        [string] $WorkItemTypeName
    ) 

    $processId = Get-AzdoProcessId -ProcessName $ProcessName

    $uri = $azdoUtilsUri + "/_apis/work/processes/{$processId}/workitemtypes?api-version=6.0-preview.2"
    $workItemTypes = Invoke-RestMethod -Uri $uri -Method get -Headers $azdoUtilsAuthHeader 
    $workItem = $workItemTypes.value | Where-Object { $_.name -eq $WorkItemTypeName } 
    return $workItem.referenceName
}

Export-ModuleMember -Function * -Cmdlet *
  