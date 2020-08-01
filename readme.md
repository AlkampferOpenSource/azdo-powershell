# Content of repository

Simple PowerShell scripts to interact with azure devops

# How to quick test

You can simply go into folder of chosen module, modify source and then remove and reinstall again to force PowerShell to reload module.

Example:

```Powershell
 remove-module 'AzdoBaseUtils'; import-module '.\AzdoBaseUtils'  
```

# How to publish

To publish to standard globa powershell gallery you can use this command

```Powershell

# Publish module to official gallery
Publish-Module `
    -Path C:\develop\github\azdo-powershell\src\AzdoBaseUtils `
    -NuGetApiKey your_key_here `
    -Verbose
    -Verbose
```
