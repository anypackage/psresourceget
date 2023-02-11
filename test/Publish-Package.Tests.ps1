#requires -modules AnyPackage.PowerShellGet

Describe Publish-Package {
    BeforeAll {
        $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root
        New-Item -Path $path\repo -ItemType Directory
        Register-PSResourceRepository -Name Test -Uri $path\repo
    }

    AfterAll {
        Unregister-PSResourceRepository -Name Test
    }

    Context 'with -Path parameter' {
        It 'should publish <_> to local repository' -TestCases 'SNMP' {
            # https://github.com/PowerShell/PowerShellGet/issues/940
            $testRoot = Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root
            Save-PSResource -Name $_ -Path $testRoot -TrustRepository

            $path = Get-ChildItem -Path TestDrive: -Recurse -Include "$_.psd1"

            { Publish-PSResource -Path $path -Repository Test } |
            Should -Not -Throw
        }
    }

    Context 'with -DestinationPath parameter' {
        It 'should publish and create nupkg' -TestCases 'SNMP' {
            # https://github.com/PowerShell/PowerShellGet/issues/940
            $testRoot = Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root
            Save-PSResource -Name $_ -Path $testRoot -TrustRepository

            $path = Get-ChildItem -Path TestDrive: -Recurse -Include "$_.psd1"
            $destinationPath = Get-PSDrive -Name TestDrive | Select-Object -ExpandProperty Root

            { Publish-PSResource -Path $path -Repository Test -DestinationPath $destinationPath } |
            Should -Not -Throw
        }
    }

    Context 'with -Proxy parameter' {
        It 'should publish package' -Skip {

        }
    }

    Context 'with -ProxyCredential parameter' {
        It 'should publish package' -Skip {

        }
    }

    Context 'with -SkipDependenciesCheck parameter' {
        It 'should publish package' -Skip {

        }
    }

    Context 'with -SkipModuleManifestValidate parameter' {
        It 'should publish package' -Skip {

        }
    }
}
