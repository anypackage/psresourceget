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

        [List[PSResourceInfo]] $resources = [List[PSResourceInfo]]::new()
        
        try {
            $resources = Get-PSResource @params -ErrorAction Stop
        }
        catch {
            throw $_
        }

        $this.ProcessResources($resources, $request)
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

        [List[PSResourceInfo]] $resources = [List[PSResourceInfo]]::new()
        
        try {
            $resources = Find-PSResource @params -ErrorAction Stop
        }
        catch {
            throw $_
        }

        $this.ProcessResources($resources, $request)
    }
    #endregion

    #region InstallPackage
    [void] InstallPackage([PackageRequest] $request) {
        $params = @{
            Name            = $request.Name
            Prerelease      = $request.Prerelease
            TrustRepository = $true
            PassThru        = $true
        }

        if ($request.Version) {
            $params['Version'] = $request.Version
        }

        if ($request.Source) {
            $params['Source'] = $request.Source
        }

        [List[PSResourceInfo]] $resources = [List[PSResourceInfo]]::new()
        
        try {
            $resources = Install-PSResource @params -ErrorAction Stop
        }
        catch {
            throw $_
        }

        $this.ProcessResources($resources, $request)
    }
    #endregion

    #region SavePackage
    [void] SavePackage([PackageRequest] $request) {
        $params = @{
            Name            = $request.Name
            Path            = $request.Path
            Prerelease      = $request.Prerelease
            TrustRepository = $true
            PassThru        = $true
        }

        if ($request.Version) {
            $params['Version'] = $request.Version
        }

        if ($request.Source) {
            $params['Source'] = $request.Source
        }

        [List[PSResourceInfo]] $resources = [List[PSResourceInfo]]::new()
        
        try {
            $resources = Save-PSResource @params -ErrorAction Stop
        }
        catch {
            throw $_
        }

        $this.ProcessResources($resources, $request)
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

        [List[PSResourceInfo]] $beforeResources = [List[PSResourceInfo]]::new()
        $beforeResources = Get-PSResource @params

        if (-not $beforeResources) { return }

        # Issue to get PassThru parameter added
        # https://github.com/PowerShell/PowerShellGet/issues/667
        try {
            Uninstall-PSResource @params -Prerelease:$request.Prerelease -ErrorAction Stop
        }
        catch {
            throw $_
        }

        $afterResources = Get-PSResource @params

        if ($afterResources) {
            throw "Failed uninstalling package '$($request.Name)'. One or more versions are still installed."
        }
        else {
            $this.ProcessResources($beforeResources, $request)
        }
    }
    #endregion

    #region UpdatePackage
    [void] UpdatePackage([PackageRequest] $request) {
        $params = @{
            Name            = $request.Name
            Prerelease      = $request.Prerelease
            TrustRepository = $true
            PassThru        = $true
        }

        if ($request.Version) {
            $params['Version'] = $request.Version
        }

        if ($request.Source) {
            $params['Source'] = $request.Source
        }

        [List[PSResourceInfo]] $resources = [List[PSResourceInfo]]::new()

        try {
            $resources = Update-PSResource @params -ErrorAction Stop
        }
        catch {
            throw $_
        }

        $this.ProcessResources($resources, $request)
    }
    #endregion

    #region PublishPackage
    [void] PublishPackage([PackageRequest] $request) {
        $params = @{
            Path = $request.Path
        }

        if ($request.Source) {
            $params['Source'] = $request.Source
        }

        try {
            Publish-PSResource @params -ErrorAction Stop

            $resourceName = Get-Item -Path $request.Path | Select-Object -ExpandProperty BaseName

            if ($request.Source) {
                $resource = Find-PSResource -Name $resourceName -Source $request.Source
            }
            else {
                $resource = Find-PSResource -Name $resourceName
            }

            $this.ProcessResource($resource, $request)
        }
        catch {
            throw $_
        }
    }
    #endregion

    #region Source
    [void] GetSource([SourceRequest] $request) {
        $repos = Get-PSResourceRepository -Name $request.Name -ErrorAction SilentlyContinue

        foreach ($repo in $repos) {
            $request.WriteSource($repo.Name, $repo.Uri, [bool]::Parse($repo.Trusted), @{ Priority = $repo.Priority })
        }
    }

    [void] SetSource([SourceRequest] $request) {
        $params = @{
            Name     = $request.Name
            PassThru = $true
        }

        if ($request.Location) {
            $params.Uri = $request.Location
        }

        if ($null -ne $request.Trusted) {
            $params.Trusted = $request.Trusted
        }

        $repo = Set-PSResourceRepository @params

        $request.WriteSource($repo.Name, $repo.Uri, [bool]::Parse($repo.Trusted), @{ Priority = $repo.Priority })
    }

    [void] RegisterSource([SourceRequest] $request) {
        $params = @{
            Name     = $request.Name
            Uri      = $request.Location
            Trusted  = $request.Trusted
            PassThru = $true
        }

        $repo = Register-PSResourceRepository @params

        $request.WriteSource($repo.Name, $repo.Uri, [bool]::Parse($repo.Trusted), @{ Priority = $repo.Priority })
    }

    [void] UnregisterSource([SourceRequest] $request) {
        $params = @{
            Name     = $request.Name
            PassThru = $true
        }

        $repo = Unregister-PSResourceRepository @params

        $request.WriteSource($repo.Name, $repo.Uri, [bool]::Parse($repo.Trusted), @{ Priority = $repo.Priority })
    }
    #endregion

    [object] GetDynamicParameters([string] $commandName) {
        switch ($commandName) {
            'Get-Package' { return [GetPackageDynamicParameters]::new() }
            'Find-Package' { return [FindPackageDynamicParameters]::new() }
            default { return $null }
        }

        #bug shouldn't have to do this.
        return $null
    }

    #region ProcessResource
    hidden [void] ProcessResources([IEnumerable[PSResourceInfo]] $resources, [PackageRequest] $request) {
        foreach ($resource in $resources) {
            $this.ProcessResource($resource, $request)
        }
    }

    hidden [void] ProcessResource([PSResourceInfo] $resource, [PackageRequest] $request) {
        $request.WriteVerbose("Processing '$($resource.Name)' resource.")
            
        $repo = Get-PSResourceRepository -Name $resource.Repository
        $ht = ConvertTo-PackageMetadata $resource
        
        $deps = [List[PackageDependency]]::new()
        foreach ($dep in $resource.Dependencies) {
            $dependency = [PackageDependency]::new($dep.Name, $dep.VersionRange)
            $deps.Add($dependency)
        }
        
        if ($repo) {
            $repoInfo = $request.NewSourceInfo($repo.Name, $repo.Url, [bool]::Parse($repo.Trusted), @{ Priority = $repo.Priority; CredentialInfo = $repo.CredentialInfo })
        }
        else {
            $repoInfo = $request.NewSourceInfo($resource.Repository, $resource.RepositorySourceLocation, $false, $null)
        }

        $version = $resource.Version.ToString()

        if ($resource.Prerelease) {
            $version = $version + '-' + $resource.Prerelease
        }

        $request.WritePackage($resource.Name, $version, $resource.Description, $repoInfo, $ht, $deps)
    }
    #endregion
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
}

[PackageProviderManager]::RegisterProvider([PowerShellGetProvider], $MyInvocation.MyCommand.ScriptBlock.Module)

$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = { 
    [PackageProviderManager]::UnregisterProvider([PowerShellGetProvider])
}

function ConvertTo-PackageMetadata {
    [CmdletBinding()]
    [OutputType([hashtable])]
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
