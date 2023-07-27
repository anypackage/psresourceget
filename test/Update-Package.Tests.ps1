#requires -modules AnyPackage.PSResourceGet

Describe Update-Package {
    BeforeEach {
        Install-PSResource -Name SNMP -Version 1.0 -TrustRepository
        Install-PSResource -Name PSWindowsUpdate -Version 2.0 -TrustRepository
    }

    AfterEach {
        Uninstall-PSResource -Name SNMP, PSWindowsUpdate
    }

    Context 'with no additional parameters' {
        It 'should update' {
            Update-Package -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Name parameter' {
        It 'should update <_>' -TestCases 'SNMP', 'PSWindowsUpdate', @('SNMP', 'PSWindowsUpdate') {
            Update-Package -Name $_ -PassThru |
            Should -HaveCount @($_).Length
        }

        It 'should write error for <_> non-existent package' -TestCases 'doesnotexist' {
            { Update-Package -Name $_ -ErrorAction Stop } |
            Should -Throw -ExpectedMessage "Package not found. (Package '$_')"
        }
    }

    Context 'with -Version parameter' {
        BeforeEach {
            Install-PSResource -Name Cobalt -Version 0.0.1 -TrustRepository
        }

        AfterEach {
            Uninstall-PSResource -Name Cobalt
        }

        It 'should update with <_> version range' -TestCases '0.1.0',
                                                              '[0.1.0]',
                                                              '[0.2.0,]',
                                                              '(0.1.0,)',
                                                              #'(,0.3.0)', https://github.com/PowerShell/PSResourceGet/issues/943
                                                              '(0.2.0,0.3.0]',
                                                              '(0.2.0,0.3.0)',
                                                              '[0.2.0,0.3.0)' {
            Update-Package -Name Cobalt -Version $_ -PassThru |
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

        It 'should update <Name> from <Source> repository' -TestCases @{ Name = 'SNMP'; Source = 'PSGallery'},
                                                          @{ Name = 'PSWindowsUpdate'; Source = 'Test' } {
            $results = Update-Package -Name $name -Source $source -PassThru
            $results.Source | Should -Be $source
        }
    }

    Context 'with -Prerelease parameter' {
        BeforeAll {
            Install-PSResource -Name NetworkingDsc -Version 8.0.0 -TrustRepository
        }

        AfterAll {
            Uninstall-PSResource -Name NetworkingDsc
        }

        It 'should update <_> successfully' -TestCases 'NetworkingDsc' {
            $package = Update-Package -Name $_ -Version '8.1.0-preview0001' -Prerelease -PassThru

            $package.Version.IsPrerelease | Should -BeTrue
        }
    }

    Context 'with -AcceptLicense parameter' {
        It 'should update <_> successfully' -TestCases 'SNMP' {
            Update-Package -Name $_ -Provider PSResourceGet -AcceptLicense -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Credential parameter' {
        It 'should update <_> successfully' -TestCases 'SNMP' -Skip {

        }
    }

    Context 'with -TemporaryPath parameter' {
        It 'should update <_> successfully' -TestCases 'SNMP' {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root
            Update-Package -Name $_ -Provider PSResourceGet -TemporaryPath $path -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Scope parameter' {
        It 'should update <_> successfully' -TestCases 'SNMP' {
            Update-Package -Name $_ -Provider PSResourceGet -Scope CurrentUser -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -SkipDependencyCheck' {
        It 'should update <_> successfully' -TestCases 'SNMP' {
            Update-Package -Name $_ -Provider PSResourceGet -SkipDependencyCheck -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with pipeline' {
        It 'should update <_> package from Find-Package' -TestCases 'SNMP', @('SNMP', 'PSWindowsUpdate') {
            $results = Find-Package -Name $_ |
            Update-Package -PassThru

            $results | Should -HaveCount @($_).Length
        }

        It 'should Update <_> package from string' -TestCases 'SNMP', @('SNMP', 'PSWindowsUpdate') {
            $results = $_ |
            Update-Package -PassThru

            $results | Should -HaveCount @($_).Length
        }
    }
}
