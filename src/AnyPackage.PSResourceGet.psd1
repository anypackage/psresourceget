@{
    RootModule = 'AnyPackage.PSResourceGet.psm1'
    ModuleVersion = '0.2.4'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = '4ffeffd3-7f83-4655-ac94-19eb41ebc792'
    Author = 'Thomas Nieto'
    Copyright = '(c) 2023 Thomas Nieto. All rights reserved.'
    Description = 'PSResourceGet provider for AnyPackage.'
    PowerShellVersion = '5.1'
    RequiredModules = @(
        @{ ModuleName = 'AnyPackage'; ModuleVersion = '0.5.1' },
        'Microsoft.PowerShell.PSResourceGet')
    FunctionsToExport = @()
    CmdletsToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        AnyPackage = @{
            Providers = 'PSResourceGet'
        }
        PSData = @{
            Tags = @('AnyPackage', 'Provider', 'PSResourceGet', 'Windows', 'Linux', 'MacOS')
            LicenseUri = 'https://github.com/anypackage/psresourceget/blob/main/LICENSE'
            ProjectUri = 'https://github.com/anypackage/psresourceget'
        }
    }
    HelpInfoUri = 'https://go.anypackage.dev/help'
}
