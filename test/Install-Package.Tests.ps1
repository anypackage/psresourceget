#requires -modules AnyPackage.PowerShellGet

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

        It 'should write error for <_> non-existant package' -TestCases 'doesnotexist' {
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
            New-Item -Path $path\repo -ItemType Directory
            Register-PSResourceRepository -Name Test -Uri $path\repo
            Save-PSResource -Name PSWindowsUpdate, SNMP -Path $path\repo -AsNupkg
        }

        AfterAll {
            Unregister-PSResourceRepository -Name Test
        }

        It 'should install <Name> from <Source> repository' -TestCases @{ Name = 'SNMP'; Source = 'PSGallery'},
                                                          @{ Name = 'PSWindowsUpdate'; Source = 'Test' } {
            $results = Install-Package -Name $name -Source $source -PassThru
            $results.Source | Should -Be $source
        }
    }

    Context 'with -Scope parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PowerShellGet -Scope CurrentUser -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Prerelease parameter' {
        It 'should install <_> sucessfully' -TestCases '' -Skip {
            # TODO: Find a good package for this test.
        }
    }

    Context 'with -AuthenticodeCheck parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PowerShellGet -AuthenticodeCheck -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Credential parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PowerShellGet -SkipDependencyCheck -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -SkipDependencyCheck parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PowerShellGet -SkipDependencyCheck -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -TemporaryPath parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PowerShellGet -TemporaryPath TempDrive: -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -NoClobber parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PowerShellGet -NoClobber -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -AcceptLicense parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PowerShellGet -AcceptLicense -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Reinstall parameter' {
        It 'should install <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PowerShellGet -Reinstall -PassThru |
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
