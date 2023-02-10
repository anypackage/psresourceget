#requires -modules AnyPackage.PowerShellGet

Describe Publish-Package {
    # BeforeAll {
    #     $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root
    #     New-Item -Path $path\repo -ItemType Directory
    #     Register-PSResourceRepository -Name Test -Uri $path\repo
    #     Save-PSResource -Name AnyPackage, Scoop -Path $path\repo -AsNupkg
    # }

    # AfterAll {
    #     Unregister-PSResourceRepository -Name Test
    # }
    
    Context 'with -Path parameter' {
        It 'should publish <_> to local repository' -TestCases 'SNMP' {
            Save-PSResource -Name $_ -Path TestDrive:
        }
    }

    Context 'with -DestinationPath parameter' {

    }

    Context 'with -Proxy parameter' {

    }

    Context 'with -ProxyCredential parameter' {

    }

    Context 'with -Repository parameter' {

    }

    Context 'with -SkipDependenciesCheck parameter' {

    }

    Context 'with -SkipModuleManifestValidate parameter' {

    }
}
