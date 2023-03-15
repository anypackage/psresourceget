@{
    RootModule = 'AnyPackage.PowerShellGet.psm1'
    ModuleVersion = '0.2.2'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = 'cc680200-a0c8-40df-a004-64c3899a72c9'
    Author = 'Thomas Nieto'
    Copyright = '(c) 2023 Thomas Nieto. All rights reserved.'
    Description = 'PowerShellGet provider for AnyPackage.'
    PowerShellVersion = '5.1'
    RequiredModules = @(
        @{ ModuleName = 'AnyPackage'; ModuleVersion = '0.4.1' },
        'PowerShellGet')
    FunctionsToExport = @()
    CmdletsToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        AnyPackage = @{
            Providers = 'PowerShellGet'
        }
        PSData = @{
            Tags = @('AnyPackage', 'Provider', 'PowerShellGet', 'Windows', 'Linux', 'MacOS')
            LicenseUri = 'https://github.com/AnyPackage/AnyPackage.PowerShellGet/blob/main/LICENSE'
            ProjectUri = 'https://github.com/AnyPackage/AnyPackage.PowerShellGet'
        }
    }
    HelpInfoUri = 'https://go.anypackage.dev/help'
}
