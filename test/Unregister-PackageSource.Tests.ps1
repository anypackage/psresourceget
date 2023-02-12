#requires -modules AnyPackage.PowerShellGet

Describe Unregister-PackageSource {
    BeforeEach {
        $path = Get-PSDrive TestDrive | Select-Object -ExpandProperty Root
        New-Item -Path $path/repo -ItemType Directory -ErrorAction Ignore

        try {
            Register-PSResourceRepository -Name Test -Uri $path/repo
        }
        catch {
            Write-Verbose -Message 'Test repository already exists.'
        }

        try {
            Register-PSResourceRepository -PSGallery
        }
        catch {
            Write-Verbose -Message 'PSGallery already exists.'
        }
    }

    AfterAll {
        Unregister-PSResourceRepository -Name Test -ErrorAction Ignore

        try {
            Register-PSResourceRepository -PSGallery
        }
        catch {
            Write-Verbose -Message 'PSGallery already exists.'
        }
    }

    Context 'with -Name parameter' {
        It 'should unregister <_>' -TestCases 'Test', 'PSGallery' {
            Unregister-PackageSource -Name $_ -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }

    Context 'with pipeline' {
        It 'should unregister <_> from Get-PackageSource' -TestCases 'Test' {
            Get-PackageSource -Name $_ |
            Unregister-PackageSource -PassThru |
            Should -Not -BeNullOrEmpty
        }

        It 'should unregister <_> from string' -TestCases 'Test' {
            $_ |
            Unregister-PackageSource -PassThru |
            Should -Not -BeNullOrEmpty
        }
    }
}
