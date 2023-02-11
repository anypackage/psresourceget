#requires -modules AnyPackage.PowerShellGet

Describe Uninstall-Package {
    BeforeEach {
        Install-PSResource -Name SNMP, PSWindowsUpdate -TrustRepository -WarningAction SilentlyContinue -ErrorAction Ignore
    }

    AfterAll {
        Uninstall-PSResource -Name SNMP, PSWindowsUpdate -ErrorAction Ignore
    }

    Context 'with -Name parameter' {
        It 'should uninstall <_> successfully' -TestCases 'SNMP', @('SNMP', 'PSWindowsUpdate') {
            $results = Uninstall-Package -Name $_ -PassThru

            $results | Should -Not -BeNullOrEmpty
            $results | Should -HaveCount @($_).Length
        }

        It 'should write error for <_> non-existent package' -TestCases 'doesnotexist' -Skip {
            { Uninstall-Package -Name $_ -ErrorAction Stop } |
            Should -Throw -ExpectedMessage "Package not found. (Package '$_')"
        }
    }

    Context 'with -Version parameter' {
        It 'should uninstall with <_> version range' -TestCases '0.1.0',
                                                              '[0.1.0]',
                                                              '[0.2.0,]',
                                                              '(0.1.0,)',
                                                              '(,0.3.0)',
                                                              '(0.2.0,0.3.0]',
                                                              '(0.2.0,0.3.0)',
                                                              '[0.2.0,0.3.0)' {
            Install-PSResource -Name Cobalt -Version $_ -TrustRepository

            Uninstall-Package -Name Cobalt -Version $_ -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Scope parameter' {
        It 'should uninstall <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PowerShellGet -Scope CurrentUser -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -SkipDependencyCheck' {
        It 'should uninstall <_> successfully' -TestCases 'SNMP' -Skip {
            Install-Package -Name $_ -Provider PowerShellGet -SkipDependencyCheck -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with pipeline' {
        It 'should uninstall <_> package from Get-Package' -TestCases 'SNMP', @('SNMP', 'PSWindowsUpdate') {
            $results = Get-Package -Name $_ |
            Uninstall-Package -PassThru

            $results | Should -HaveCount @($_).Length
        }

        It 'should uninstall <_> package from string' -TestCases 'SNMP', @('SNMP', 'PSWindowsUpdate') {
            $results = $_ |
            Uninstall-Package -PassThru

            $results | Should -HaveCount @($_).Length
        }
    }
}
