#requires -modules AnyPackage.PowerShellGet

using namespace NuGet.Versioning

Describe Get-Package {
    BeforeAll {
        Install-PSResource -Name SNMP, PSWindowsUpdate, DellBIOSProvider -TrustRepository
        Find-PSResource -Name Cobalt -Version '[0.1.0,0.3.0]' | Install-PSResource -TrustRepository
    }

    AfterAll {
        Uninstall-PSResource -Name SNMP, PSWindowsUpdate, DellBIOSProvider
    }

    Context 'with no additional parameters' {
        It 'should return results' {
            Get-Package |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Name parameter' {
        It 'should return results for <_>' -TestCases 'SNMP', @('PSWindowsUpdate', 'DellBIOSProvider'), '*win*' {
            $resources = Get-PSResource -Name $_
            $results = Get-Package -Name $_

            $results | Should -Not -BeNullOrEmpty
            $results | Should -HaveCount @($resources).Length
        }

        It 'should fail with <_> non-existent package' -TestCases 'brokenpackage' {
            { Get-Package -Name $_ -ErrorAction Stop } |
            Should -Throw -ExpectedMessage "Package not found. (Package '$_')"
        }

        It 'should have correct properties for <_>' -TestCases 'SNMP' {
            $resource = Get-PSResource -Name $_
            $package = Get-Package -Name $_

            if ($resource.Prerelease) {
                $version = [NuGetVersion]::Parse($resource.Version.ToString() + '-' + $resource.Prerelease)
            }
            else {
                $version = $resource.Version
            }

            $package.Name | Should -Be $resource.Name
            $package.Version.ToString() | Should -Be $version.ToString()
            $package.Description | Should -Be $resource.Description
            $package.Source | Should -Be $resource.Repository
            $package.Source.Location | Should -Be $resource.RepositorySourceLocation

            $properties = $resource |
            Get-Member -MemberType Properties |
            Select-Object -ExpandProperty Name

            $package.Metadata.Keys | Should -HaveCount $properties.Length
        }
    }

    Context 'with -Version parameter' {
        It 'should return correct count for <_> version range' -TestCases '0.1.0',
                                                                          '[0.1.0]',
                                                                          '[0.2.0,]',
                                                                          '(0.1.0,)',
                                                                          '(,0.3.0)',
                                                                          '(0.2.0,0.3.0]',
                                                                          '(0.2.0,0.3.0)',
                                                                          '[0.2.0,0.3.0)' {
            $resources = Get-PSResource -Name Cobalt -Version $_

            Get-Package -Name Cobalt -Version $_ |
            Should -HaveCount $resources.Count
        }
    }
}
