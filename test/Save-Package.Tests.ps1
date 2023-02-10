#requires -modules AnyPackage.PowerShellGet

Describe Save-Package {
    AfterEach {
        Remove-Item -Path TestDrive:\* -Recurse
    }
    
    Context 'with -Name parameter' {
        It 'should save <_>' -TestCases 'SNMP', 'PSWindowsUpdate' {
            $path = Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root

            Save-Package -Name $_ -Path $path -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Version parameter' {
        It 'should save for <_> version range' -TestCases '0.1.0',
                                                          '[0.1.0]',
                                                          '[0.1.0,]',
                                                          '(0.1.0,)',
                                                          '(,0.1.2)',
                                                          '(0.1.0,0.1.2]',
                                                          '(0.1.0,0.1.2)',
                                                          '[0.1.0,0.1.2)' {
            $path = Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root

            Save-Package -Name AnyPackage -Version $_ -Path $path -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Prerelease parameter' {
        It 'should save' {
            $savePackageParams = @{
                Name = 'Microsoft.PowerShell.Archive'
                Version = '[2.0.0,2.0.1)'
                Prerelease = $true
                Path = (Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root)
                PassThru = $true
            }

            $package = Save-Package @savePackageParams

            $package.Version.IsPrerelease | Should -BeTrue
        }
    }

    Context 'with -Source parameter' {
        BeforeEach {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root
            New-Item -Path $path\repo -ItemType Directory
            Save-PSResource -Name AnyPackage, SNMP -Path $path\repo -AsNupkg

            try {
                Register-PSResourceRepository -Name Test -Uri $path\repo -Trusted
            }
            catch {
                Write-Verbose -Message 'Test source already exists.'
            }
        }

        AfterAll {
            Unregister-PSResourceRepository -Name Test
        }

        It 'should save <Name> from <Source> repository' -TestCases @{ Name = 'SNMP'; Source = 'PSGallery'},
                                                          @{ Name = 'AnyPackage'; Source = 'Test' } {
            $savePackageParams = @{
                Name = $Name
                Source = $Source
                Path = (Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root)
                PassThru = $true
                TrustSource = $true
            }
            
            Save-Package @savePackageParams |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -AsNupkg parameter' {
        It 'should save <_> successfully' -TestCases 'AnyPackge' -Skip {
            $savePackageParams = @{
                Name = $_
                Path = (Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root)
                PassThru = $true
                AsNupkg = $true
            }
            
            Save-Package @savePackageParams |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -AuthenticodeCheck parameter' {
        It 'should save <_> successfully' -TestCases 'AnyPackage' -Skip {
            $savePackageParams = @{
                Name = $_
                Path = (Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root)
                PassThru = $true
                AuthenticodeCheck = $true
            }
            
            Save-Package @savePackageParams |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Credential parameter' {

    }

    Context 'with -SkipDependencyCheck parameter' {
        It 'should save <_>' -TestCases 'AnyPackage.Scoop' -Skip {
            $savePackageParams = @{
                Name = $_
                Path = (Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root)
                PassThru = $true
                SkipDependencyCheck = $true
            }
            
            Save-Package @savePackageParams |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -TemporaryPath parameter' {
        It 'should save <_> successfully' -TestCases 'AnyPackage' -Skip {
            $path = Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root
            New-Item -Path $path\temp -ItemType Directory
            
            $savePackageParams = @{
                Name = $_
                Path = $path
                PassThru = $true
                TemporaryPath = "$path\temp"
            }
            
            Save-Package @savePackageParams |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with pipeline' {
        It 'should save <_> from Find-Package' -TestCases 'AnyPackage', @('SNMP', 'PSWindowsUpdate') {
            $savePackageParams = @{
                Path = (Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root)
                PassThru = $true
            }
            
            Find-Package -Name $_ |
            Save-Package @savePackageParams |
            Should -HaveCount @($_).Length
        }

        It 'should save <_> from string' -TestCases 'AnyPackage', @('SNMP', 'PSWindowsUpdate') {
            $savePackageParams = @{
                Path = (Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root)
                PassThru = $true
            }
            
            $_ |
            Save-Package @savePackageParams |
            Should -HaveCount @($_).Length
        }
    }
}
