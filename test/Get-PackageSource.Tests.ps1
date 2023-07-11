#requires -modules AnyPackage.PSResourceGet

Describe Get-PackageSource {
    BeforeAll {
        $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root
        New-Item -Path $path/repo -ItemType Directory
        Register-PSResourceRepository -Name Test -Uri $path/repo
    }

    AfterAll {
        Unregister-PSResourceRepository -Name Test
    }

    Context 'with no additional parameters' {
        It 'should return results' {
            Get-PackageSource |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Name parameter' {
        It 'should return <_> repository' -TestCases 'PSGallery', 'Test', 'PS*' {
            $repos = Get-PSResourceRepository -Name $_
            $sources = Get-PackageSource -Name $_

            $sources | Should -HaveCount @($repos).Length
        }

        It 'should return correct properties for <_>' -TestCases 'PSGallery' {
            $repo = Get-PSResourceRepository -Name $_
            $source = Get-PackageSource -Name $_

            $source.Name | Should -Be $repo.Name
            $source.Location | Should -Be $repo.Uri
            $source.Trusted | Should -Be $repo.Trusted
            $source.Metadata['Priority'] | Should -Be $repo.Priority
        }
    }
}
