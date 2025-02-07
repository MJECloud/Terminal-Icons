properties {
    $PSBPreference.Build.CompileModule   = $true
    $PSBPreference.Build.CopyDirectories = @('Data')
    $PSBPreference.Test.ImportModule     = $true
    $PSBPreference.Test.OutputFile       = "$($PSBPreference.Build.OutDir)/testResults.xml"
}

task default -depends Test

task Pester -FromModule PowerShellBuild -Version '0.6.1' -preaction {Remove-Module Terminal-Icons -ErrorAction SilentlyContinue}

task InstallAct {
    if (-not (Get-Command -Name act -CommandType Application -ErrorAction SilentlyContinue)) {
        if ($IsWindows) {
            choco install act-cli
        } elseif ($IsLinux) {
            curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
        } elseIf ($IsMacOS) {
            brew install nektos/tap/act
        }
    } else {
        'act already installed'
    }
}

task TestGHAction -depends Build, InstallAct  {
    act -j test -P ubuntu-latest=nektos/act-environments-ubuntu:18.04
}
