# AnyPackage.PSResourceGet

AnyPackage.PSResourceGet is an AnyPackage provider that facilitates installing PSResourceGet resources from NuGet repositories.

## Documentation

AnyPackage.PSResourceGet documentation is located in [Provider Catalog](https://www.anypackage.dev/docs/provider-catalog/psresourceget/about_PSResourceGet_Provider) on how to use the provider and what dynamic parameters exist.

## Install AnyPackage.PSResourceGet

> NOTE! Microsoft.PowerShell.PSResourceGet is required.
Due to a PSResourceGet issue, prerelease modules cannot be defined as dependencies, so manual installation of PSResourceGet is required.

```PowerShell
# Install Microsoft.PowerShell.PSResourceGet
Install-Module Microsoft.PowerShell.PSResourceGet -AllowPrerelease -AllowClobber -Force

Install-Module AnyPackage.PSResourceGet
```

## Import AnyPackage.PSResourceGet

```PowerShell
Import-Module AnyPackage.PSResourceGet
```

## Sample usages

### Search for a package

```PowerShell
Find-Package -Name PSReadLine

Find-Package -Name PS*
```

### Install a package

```PowerShell
Find-Package Scoop | Install-Package

Install-Package -Name Scoop
```

### Get list of installed packages

```PowerShell
Get-Package -Name Scoop
```

### Uninstall a package

```PowerShell
Get-Package -Name 7zip | Uninstall-Package

Uninstall-Package -Name 7zip
```

### Update a package

```PowerShell
Get-Package -Name 7zip | Update-Package

Uninstall-Package
```

### Saving a package

```PowerShell
Find-Package -Name PSReadLine | Save-Package

Save-Package -Name PSReadLine -Path C:\Temp
```

### Publishing a package

```PowerShell
Publish-Package -Path C:\Temp\module\module.psd1
```

### Manage official package sources

```PowerShell
Register-PackageSource -Provider PSResourceGet -PSGallery
Find-Package -Name Scoop | Install-Package
Unregister-PackageSource -Name PSGallery
```

### Manage unofficial package sources

```PowerShell
Register-PackageSource -Name Test -Location C:\Temp\repo
Find-Package -Name Scoop -Source Test | Install-Package
Unregister-PackageSource -Name Test
```

## Known Issues

### Missing PSResourceGet parameters

There are a few missing dynamic parameters:

* Save-Package -AsNupkg
* Save-Package -IncludeXml
* Install-Package -NoClobbler
