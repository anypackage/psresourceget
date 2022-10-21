@{
    RootModule = 'UniversalPackageManager.Provider.PowerShellGet.psm1'
    ModuleVersion = '0.1.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = 'cc680200-a0c8-40df-a004-64c3899a72c9'
    Author = 'Thomas Nieto'
    Copyright = '(c) 2022 Thomas Nieto. All rights reserved.'
    Description = 'PowerShellGet provider for UniversalPackageManager.'
    PowerShellVersion = '5.1'
    RequiredModules = @('UniversalPackageManager', @{ ModuleName = 'PowerShellGet'; ModuleVersion = '3.0.17' })
    FunctionsToExport = @()
    CmdletsToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('UniversalPackageManager', 'Provider', 'PowerShellGet')
            LicenseUri = 'https://github.com/ThomasNieto/UniversalPackageManager.Provider.PowerShellGet/blob/main/LICENSE'
            ProjectUri = 'https://github.com/ThomasNieto/UniversalPackageManager.Provider.PowerShellGet'
        }
    }
}
