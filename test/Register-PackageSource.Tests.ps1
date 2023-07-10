#requires -modules AnyPackage.PSResourceGet

Describe Register-PackageSource {
    AfterEach {
        try {
            Register-PSResourceRepository -PSGallery
        }
        catch {
            Write-Verbose -Message 'PSGallery already exists.'
        }

        try {
            Unregister-PSResourceRepository -Name Test
        }
        catch {
            Write-Verbose -Message 'Test not registered.'
        }
    }

    Context 'with -Uri parameter' {
        It 'should register' {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root

            $registerPackageSourceParams = @{
                Name = 'Test'
                Location = $path
                Provider = 'PSResourceGet'
                PassThru = $true
            }

            $source = Register-PackageSource @registerPackageSourceParams

            $source | Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Trusted parameter' {
        It 'should be trusted' {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root

            $registerPackageSourceParams = @{
                Name = 'Test'
                Location = $path
                Provider = 'PSResourceGet'
                Trusted = $true
                PassThru = $true
            }

            $source = Register-PackageSource @registerPackageSourceParams

            $source | Should -Not -BeNullOrEmpty
            $source.Trusted | Should -BeTrue
        }

        It 'should not be trusted' {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root

            $registerPackageSourceParams = @{
                Name = 'Test'
                Location = $path
                Provider = 'PSResourceGet'
                Trusted = $false
                PassThru = $true
            }

            $source = Register-PackageSource @registerPackageSourceParams

            $source | Should -Not -BeNullOrEmpty
            $source.Trusted | Should -BeFalse
        }
    }

    Context 'with -Priority parameter' {
        It 'should have priority <_>' -TestCases 10 {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root

            $registerPackageSourceParams = @{
                Name = 'Test'
                Location = $path
                Provider = 'PSResourceGet'
                PassThru = $true
                Priority = $_
            }

            $source = Register-PackageSource @registerPackageSourceParams

            $source.Metadata['Priority'] | Should -Be $_
        }
    }

    Context 'with -PSGallery parameter' {
        BeforeAll {
            Unregister-PSResourceRepository -Name PSGallery
        }

        AfterAll {
            try {
                Register-PSResourceRepository -PSGallery
            }
            catch {
                Write-Verbose -Message 'PSGallery already registered.'
            }
        }

        It 'should register' {
            $registerPackageSourceParams = @{
                Provider = 'PSResourceGet'
                PassThru = $true
                PSGallery = $true
            }

            Register-PackageSource @registerPackageSourceParams |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -CredentialInfo parameter' {
        It 'should register with vault name <VaultName> and secret name <SecretName>' -TestCases @{ VaultName = 'Test'; SecretName = 'shhh' } {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root

            $registerPackageSourceParams = @{
                Name = 'Test'
                Location = $path
                Provider = 'PSResourceGet'
                PassThru = $true
                CredentialInfo = $_
            }

            $source = Register-PackageSource @registerPackageSourceParams

            $source | Should -Not -BeNullOrEmpty
            $source.Metadata['CredentialInfo'].VaultName | Should -Be $VaultName
            $source.Metadata['CredentialInfo'].SecretName | Should -Be $SecretName
        }
    }
}
