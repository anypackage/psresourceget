#requires -modules AnyPackage.PowerShellGet

Describe Set-PackageSource {
    BeforeAll {
        $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root
        New-Item -Path $path/repo -ItemType Directory
        Register-PSResourceRepository -Name Test -Uri $path/repo
    }

    AfterAll {
        Unregister-PSResourceRepository -Name Test
    }

    Context 'with -Uri parameter' {
        It 'should change uri' {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root

            $source = Set-PackageSource -Name Test -Location $path -PassThru

            if ($IsWindows) {
                $value = [uri]$path
            }
            else {
                $value = "file://$path"
            }

            $source | Should -Not -BeNullOrEmpty
            $source.Location | Should -Be $value
        }
    }

    Context 'with -CredentialInfo parameter' {
        It 'should register with vault <VaultName> and secret <SecretName>' -TestCases @{ VaultName = 'Test'; SecretName = 'shhh' } -Skip {

            $registerPackageSourceParams = @{
                Name = 'Test'
                Provider = 'PowerShellGet'
                PassThru = $true
                CredentialInfo = $_
            }

            $source = Set-PackageSource @registerPackageSourceParams

            $source | Should -Not -BeNullOrEmpty
            $source.Metadata['CredentialInfo']['VaultName'] | Should -Be $VaultName
            $source.Metadata['CredentialInfo']['SecretName'] | Should -Be $SecretName
        }
    }

    Context 'with -Trusted parameter' {
        It 'should be trusted' {
            $registerPackageSourceParams = @{
                Name = 'Test'
                Trusted = $true
                PassThru = $true
            }

            $source = Set-PackageSource @registerPackageSourceParams

            $source | Should -Not -BeNullOrEmpty
            $source.Trusted | Should -BeTrue
        }

        It 'should not be trusted' {
            $registerPackageSourceParams = @{
                Name = 'Test'
                Trusted = $false
                PassThru = $true
            }

            $source = Set-PackageSource @registerPackageSourceParams

            $source | Should -Not -BeNullOrEmpty
            $source.Trusted | Should -BeFalse
        }
    }

    Context 'with pipeline' {
        AfterEach {
            Set-PSResourceRepository -Name Test -Trusted:$false
        }

        It 'should accept values from Get-PackageSource' -TestCases 'Test' {
            $source = Get-PackageSource -Name $_ |
            Set-PackageSource -Trusted -PassThru

            $source | Should -Not -BeNullOrEmpty
            $source.Trusted | Should -BeTrue
        }

        It 'should accept values from string' -TestCases 'Test' {
            $source = $_ |
            Set-PackageSource -Trusted -PassThru

            $source | Should -Not -BeNullOrEmpty
            $source.Trusted | Should -BeTrue
        }
    }
}
