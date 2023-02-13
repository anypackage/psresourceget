# Copyright (c) Thomas Nieto - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the MIT license.

using module AnyPackage
using module PowerShellGet

using namespace System.Collections.Generic
using namespace AnyPackage.Provider
using namespace Microsoft.PowerShell.PowerShellGet.UtilClasses

[PackageProvider('PowerShellGet')]
class PowerShellGetProvider : PackageProvider, IGetPackage, IFindPackage,
IInstallPackage, ISavePackage, IUninstallPackage,
IUpdatePackage, IPublishPackage, IGetSource, ISetSource {

    PowerShellGetProvider() : base('c9a39544-274b-4935-9cad-7423e8c47e6b') { }

    #region GetPackage
    [void] GetPackage([PackageRequest] $request) {
        $params = @{ Name = $request.Name }

        if ($request.Version) {
            $params['Version'] = $request.Version
        }

        if ($request.DynamicParameters.Path) {
            $params['Path'] = $request.DynamicParameters.Path
        }

        if ($request.DynamicParameters.Scope) {
            $params['Scope'] = $request.DynamicParameters.Scope
        }

        Get-PSResource @params |
        Write-Package -Request $request
    }
    #endregion

    #region FindPackage
    [void] FindPackage([PackageRequest] $request) {
        $params = @{
            Name       = $request.Name
            Prerelease = $request.Prerelease
        }

        if ($request.Version) {
            $params['Version'] = $request.Version
        }

        if ($request.Source) {
            $params['Repository'] = $request.Source
        }

        if ($request.DynamicParameters.Tag) {
            $params['Tag'] = $request.DynamicParameters.Tag
        }

        if ($request.DynamicParameters.Type) {
            $params['Type'] = $request.DynamicParameters.Type
        }

        $resources = Find-PSResource @params

        if ($request.DynamicParameters.Latest) {
            $resources = $resources | Get-Latest
        }

        $resources | Write-Package -Request $request
    }
    #endregion

    #region InstallPackage
    [void] InstallPackage([PackageRequest] $request) {
        $params = @{
            Name       = $request.Name
            Prerelease = $request.Prerelease
        }

        if ($request.Version) {
            $params['Version'] = $request.Version
        }

        if ($request.Source) {
            $params['Repository'] = $request.Source
        }

        Find-PSResource @params |
        Get-Latest |
        Install-PSResource -TrustRepository -PassThru |
        Write-Package -Request $request
    }
    #endregion

    #region SavePackage
    [void] SavePackage([PackageRequest] $request) {
        $params = @{
            Name       = $request.Name
            Prerelease = $request.Prerelease
        }

        if ($request.Version) {
            $params['Version'] = $request.Version
        }

        if ($request.Source) {
            $params['Repository'] = $request.Source
        }

        Find-PSResource @params |
        Get-Latest |
        Save-PSResource -Path $request.Path -TrustRepository -PassThru |
        Write-Package -Request $request
    }
    #endregion

    #region UninstallPackage
    [void] UninstallPackage([PackageRequest] $request) {
        $params = @{
            Name = $request.Name
        }

        if ($request.Version) {
            $params['Version'] = $request.Version
        }

        # Issue to get PassThru parameter added
        # https://github.com/PowerShell/PowerShellGet/issues/667

        # Prerelease parameter causes it to silently fail
        # https://github.com/PowerShell/PowerShellGet/issues/842
        Get-PSResource @params |
        ForEach-Object {
            try {
                $_ | Uninstall-PSResource -ErrorAction Stop
                $_ | Write-Package -Request $request
            }
            catch {
                $_
            }
        }
    }
    #endregion

    #region UpdatePackage
    [void] UpdatePackage([PackageRequest] $request) {
        $params = @{
            Prerelease = $request.Prerelease
        }

        if ($request.Version) {
            $params['Version'] = $request.Version
        }

        if ($request.Source) {
            $params['Repository'] = $request.Source
        }

        # Find-PSResource pipeline input
        # https://github.com/PowerShell/PowerShellGet/issues/666
        Get-PSResource -Name $request.Name |
        Select-Object -ExpandProperty Name -Unique |
        Find-PSResource @params |
        Select-Object -ExpandProperty Name -Unique |
        Update-PSResource @params -TrustRepository -PassThru |
        Write-Package -Request $request
    }
    #endregion

    #region PublishPackage
    [void] PublishPackage([PackageRequest] $request) {
        $params = @{
            Path = $request.Path
        }

        if ($request.Source) {
            $params['Repository'] = $request.Source
        }

        try {
            # PassThru parameter
            # https://github.com/PowerShell/PowerShellGet/issues/718
            Publish-PSResource @params -ErrorAction Stop

            $params.Remove('Path')
            $params['Name'] = Get-Item -Path $request.Path |
            Select-Object -ExpandProperty BaseName

            Find-PSResource @params |
            Get-Latest |
            Write-Package -Request $request
        }
        catch {
            throw $_
        }
    }
    #endregion

    #region Source
    [void] GetSource([SourceRequest] $sourceRequest) {
        Get-PSResourceRepository -Name $sourceRequest.Name |
        Write-Source -SourceRequest $sourceRequest
    }

    [void] SetSource([SourceRequest] $sourceRequest) {
        $params = @{
            PassThru = $true
        }

        if ($sourceRequest.Location) {
            $params.Uri = $sourceRequest.Location
        }

        if ($null -ne $sourceRequest.Trusted) {
            $params.Trusted = $sourceRequest.Trusted
        }

        Get-PSResourceRepository -Name $sourceRequest.Name |
        Set-PSResourceRepository @params |
        Write-Source -SourceRequest $sourceRequest
    }

    [void] RegisterSource([SourceRequest] $sourceRequest) {
        $params = @{
            Name     = $sourceRequest.Name
            Uri      = $sourceRequest.Location
            Trusted  = $sourceRequest.Trusted
            PassThru = $true
        }

        Register-PSResourceRepository @params |
        Write-Source -SourceRequest $sourceRequest
    }

    [void] UnregisterSource([SourceRequest] $sourceRequest) {
        Get-PSResourceRepository -Name $sourceRequest.Name |
        Unregister-PSResourceRepository -PassThru |
        Write-Source -SourceRequest $sourceRequest
    }
    #endregion

    [object] GetDynamicParameters([string] $commandName) {
        return $(switch ($commandName) {
            'Get-Package' { return [GetPackageDynamicParameters]::new() }
            'Find-Package' { return [FindPackageDynamicParameters]::new() }
            default { return $null }
        })
    }
}

class GetPackageDynamicParameters {
    [Parameter()]
    [string] $Path

    [Parameter()]
    [ScopeType] $Scope
}

class FindPackageDynamicParameters {
    [Parameter()]
    [string[]] $Tag

    [Parameter()]
    [ResourceType] $Type

    [Parameter()]
    [switch]
    $Latest
}

[PackageProviderManager]::RegisterProvider([PowerShellGetProvider], $MyInvocation.MyCommand.ScriptBlock.Module)

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    [PackageProviderManager]::UnregisterProvider([PowerShellGetProvider])
}

function ConvertTo-PackageMetadata {
    [CmdletBinding()]
    [OutputType([hashtable])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param (
        [PSResourceInfo]
        [Parameter(Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        $InputObject
    )

    begin {
        $properties = $InputObject |
            Get-Member -MemberType Properties |
            Select-Object -ExpandProperty Name
    }

    process {
        $hashtable = @{}

        foreach ($property in $properties) {
            $hashtable[$property] = $InputObject.$property
        }

        $hashtable
    }
}

function Get-Latest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [PSResourceInfo]
        $Resource
    )

    begin {
        $resources = [List[PSResourceInfo]]::new()
    }

    process {
        $resources.Add($resource)
    }

    end {
        $resources |
        Group-Object -Property Name |
        ForEach-Object {
            # PowerShellGet returns the latest as the first object
            $_.Group | Select-Object -First 1
        }
    }
}

function Write-Source {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [PSRepositoryInfo]
        $Source,

        [Parameter(Mandatory)]
        [SourceRequest]
        $SourceRequest
    )

    process {
        $SourceRequest.WriteSource($Source.Name,
                                   $Source.Uri,
                                   [bool]::Parse($Source.Trusted),
                                   @{ Priority = $Source.Priority
                                      CredentialInfo = $Source.CredentialInfo })
    }
}

function Write-Package {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [PSResourceInfo]
        $Resource,

        [Parameter(Mandatory)]
        [PackageRequest]
        $Request
    )

    begin {
        $sources = Get-PackageSource -Provider AnyPackage.PowerShellGet\PowerShellGet
    }

    process {
        $ht = ConvertTo-PackageMetadata $resource

        $deps = [List[PackageDependency]]::new()
        foreach ($dep in $resource.Dependencies) {
            $dependency = [PackageDependency]::new($dep.Name, $dep.VersionRange)
            $deps.Add($dependency)
        }

        $source = $sources |
        Where-Object Name -eq $Request.Source

        if (-not $source) {
            $source = $request.NewSourceInfo($resource.Repository, $resource.RepositorySourceLocation, $false, $null)
        }

        $version = $resource.Version.ToString()

        if ($resource.Prerelease) {
            $version = $version + '-' + $resource.Prerelease
        }

        $request.WritePackage($resource.Name, $version, $resource.Description, $source, $ht, $deps)
    }
}
