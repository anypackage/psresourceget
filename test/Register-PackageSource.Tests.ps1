#requires -modules AnyPackage.PowerShellGet

Describe Register-Package {
    AfterEach {
        try {
            Register-PSResourceRepository -PSGallery
        }
        catch {
            Write-Verbose -Message 'PSGallery already exists.'
        }
    }

    AfterEach {
        Unregister-PSResourceRepository -Name Test -ErrorAction Ignore
    }

    Context 'with -Uri parameter' {
        It 'should register' {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root

            $registerPackageSourceParams = @{
                Name = 'Test'
                Location = $path
                Provider = 'PowerShellGet'
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
                Provider = 'PowerShellGet'
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
                Provider = 'PowerShellGet'
                Trusted = $false
                PassThru = $true
            }

            $source = Register-PackageSource @registerPackageSourceParams

            $source | Should -Not -BeNullOrEmpty
            $source.Trusted | Should -BeFalse
        }
    }

    Context 'with -Priority parameter' {
        It 'should have priority <_>' -TestCases 10 -Skip {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root

            $registerPackageSourceParams = @{
                Name = 'Test'
                Location = $path
                Provider = 'PowerShellGet'
                PassThru = $true
                Priority = $_
            }

            $source = Register-PackageSource @registerPackageSourceParams

            $source.Metadata['Priority'] | Should -Be $_
        }
    }

    Context 'with -PSGallery parameter' {
        It 'should register' -Skip {
            Unregister-PSResourceRepository -Name PSGallery

            $registerPackageSourceParams = @{
                Name = 'Test'
                Location = $path
                Provider = 'PowerShellGet'
                PassThru = $true
                PSGallery = $true
            }

            Register-PackageSource @registerPackageSourceParams |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -CredentialInfo parameter' {
        It 'should register with vault <VaultName> and secret <SecretName>' -TestCases @{ VaultName = 'Test'; SecretName = 'shhh' } -Skip {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root

            $registerPackageSourceParams = @{
                Name = 'Test'
                Location = $path
                Provider = 'PowerShellGet'
                PassThru = $true
                CredentialInfo = $_
            }

            $source = Register-PackageSource @registerPackageSourceParams

            $source | Should -Not -BeNullOrEmpty
            $source.Metadata['CredentialInfo']['VaultName'] | Should -Be $VaultName
            $source.Metadata['CredentialInfo']['SecretName'] | Should -Be $SecretName
        }
    }
}
