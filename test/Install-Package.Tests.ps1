﻿#requires -modules AnyPackage.PSResourceGet

Describe Install-Package {
    AfterEach {
        Uninstall-PSResource -Name SNMP, PSWindowsUpdate -ErrorAction Ignore
    }

    Context 'with -Name parameter'  {
        It 'should install <_> successfully' -TestCases 'SNMP', @('SNMP', 'PSWindowsUpdate') {
            $results = Install-Package -Name $_ -PassThru

            $results | Should -Not -BeNullOrEmpty
            $results | Should -HaveCount @($_).Length
        }

        It 'should write error for <_> non-existent package' -TestCases 'doesnotexist' {
            { Install-Package -Name $_ -ErrorAction Stop } |
            Should -Throw -ExpectedMessage "Package not found. (Package '$_')"
        }
    }

    Context 'with -Version parameter' {
        AfterEach {
            Uninstall-PSResource -Name Cobalt -ErrorAction Ignore
        }

        It 'should install with <_> version range' -TestCases '0.1.0',
                                                              '[0.1.0]',
                                                              '[0.2.0,]',
                                                              '(0.1.0,)',
                                                              '(,0.3.0)',
                                                              '(0.2.0,0.3.0]',
                                                              '(0.2.0,0.3.0)',
                                                              '[0.2.0,0.3.0)' {
            Install-Package -Name Cobalt -Version $_ -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Source parameter' {
        BeforeAll {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root
            New-Item -Path $path/repo -ItemType Directory
            Register-PSResourceRepository -Name Test -Uri $path/repo -Trusted
            Save-PSResource -Name PSWindowsUpdate, SNMP -Path $path/repo -TrustRepository -AsNupkg
        }

        AfterAll {
            Unregister-PSResourceRepository -Name Test
        }

        It 'should install <Name> from <Source> repository' -TestCases @{ Name = 'SNMP'; Source = 'PSGallery' } {
            $results = Install-Package -Name $name -Source $source -PassThru
            $results.Source | Should -Be $source
        }
    }

    Context 'with -Scope parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' {
            Install-Package -Name $_ -Provider PSResourceGet -Scope CurrentUser -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Prerelease parameter' {
        AfterAll {
            Get-InstalledPSResource -Name PSReadLine -Version '2.0.0-rc2' |
            Where-Object IsPrerelease |
            Uninstall-PSResource
        }

        It 'should install <_> successfully' -TestCases 'PSReadLine' {
            $package = Install-Package -Name $_ -Version '2.0.0-rc2' -Prerelease -PassThru

            $package.Version.IsPrerelease | Should -BeTrue
        }
    }

    Context 'with -AuthenticodeCheck parameter' {
        It 'should install <_> successfully' -TestCases 'Microsoft.PowerShell.Archive' {
            Install-Package -Name $_ -Provider PSResourceGet -AuthenticodeCheck -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Credential parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' -Skip {

        }
    }

    Context 'with -SkipDependencyCheck parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' {
            Install-Package -Name $_ -Provider PSResourceGet -SkipDependencyCheck -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -TemporaryPath parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root
            Install-Package -Name $_ -Provider PSResourceGet -TemporaryPath $path -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -NoClobber parameter' {
        # Install-PSResource -NoClobber fails
        # https://github.com/PowerShell/PSResourceGet/issues/946
        It 'should install <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PSResourceGet -NoClobber -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -AcceptLicense parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' {
            Install-Package -Name $_ -Provider PSResourceGet -AcceptLicense -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Reinstall parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' {
            Install-Package -Name $_ -Provider PSResourceGet -Reinstall -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with pipeline' {
        It 'should install <_> package from Find-Package' -TestCases 'SNMP', @('SNMP', 'PSWindowsUpdate') {
            $results = Find-Package -Name $_ |
            Install-Package -PassThru

            $results | Should -HaveCount @($_).Length
        }

        It 'should install <_> package from string' -TestCases 'SNMP', @('SNMP', 'PSWindowsUpdate') {
            $results = $_ |
            Install-Package -PassThru

            $results | Should -HaveCount @($_).Length
        }
    }
}
