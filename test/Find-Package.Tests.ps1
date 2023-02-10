#requires -modules AnyPackage.PowerShellGet

Describe Find-Package {
    Context 'with -Name parameter' {
        It 'should return results for <_>' -TestCases 'PSReadline', @('PSReadline', 'PowerShellGet'), 'AnyPackage*'  {
            $resources = Find-PSResource -Name $_
            $results = Find-Package -Name $_

            $results | Should -Not -BeNullOrEmpty
            $results | Should -HaveCount @($resources).Length
        }

        It 'should fail with <_> non-existant package' -TestCases 'randombrokenpackage' {
            { Find-Package -Name $_ -ErrorAction Stop } |
            Should -Throw -ExpectedMessage "Package not found. (Package '$_')"
        }
    }

    Context 'with -Version parameter' {
        It 'should return value' {
            $package = Find-PSResource -Name AnyPackage
            Find-Package -Name AnyPackage -Version $package.Version |
            Should -Not -BeNullOrEmpty
        }

        It 'should return correct count for <_> version range' -TestCases '0.1.0',
                                                                          '[0.1.0]',
                                                                          '[0.1.0,]',
                                                                          '(0.1.0,)',
                                                                          '(,0.1.2)',
                                                                          '(0.1.0,0.1.2]',
                                                                          '(0.1.0,0.1.2)',
                                                                          '[0.1.0,0.1.2)' {
            $resources = Find-PSResource -Name AnyPackage -Version $_

            Find-Package -Name AnyPackage -Version $_ |
            Should -HaveCount $resources.Count
        }
    }

    Context 'with -Source parameter' {
        BeforeAll {
            $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root
            New-Item -Path $path\repo -ItemType Directory
            Register-PSResourceRepository -Name Test -Uri $path\repo
            Save-PSResource -Name AnyPackage, Scoop -Path $path\repo -AsNupkg
        }

        AfterAll {
            Unregister-PSResourceRepository -Name Test
        }

        It 'should return Test packages' {
            Find-Package -Name AnyPackage, Scoop -Source Test |
            Select-Object -ExpandProperty Source -Unique |
            Should -Be Test
        }

        # https://github.com/PowerShell/PowerShellGet/issues/722
        It 'file based repository should fail with wildcard' {
            Find-Package -Name * -Source Test |
            Should -BeNullOrEmpty
        }
    }

    Context 'with -Prerelease parameter' {
        It 'should return prerelease versions' {
            Find-Package -Name PowerShellGet -Version * -Prerelease |
            Where-Object { $_.Version.IsPrerelease } |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with -Latest parameter' {
        It 'should return latest version from version range' -Skip {

        }
    }
}
