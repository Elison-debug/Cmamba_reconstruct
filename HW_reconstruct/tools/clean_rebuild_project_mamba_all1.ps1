param(
    [string]$ProjectDir = "E:\course\smamba\HW_reconstruct\project_mamba_all1",
    [string]$VivadoBat  = "E:\Xilinx\Vivado\2024.1\bin\vivado.bat",
    [switch]$RunRebuild
)

$ErrorActionPreference = "Stop"

function Remove-IfExists {
    param([string]$PathToRemove)
    if (Test-Path -LiteralPath $PathToRemove) {
        Write-Host "[clean] remove $PathToRemove"
        try {
            Remove-Item -LiteralPath $PathToRemove -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Warning "partial clean for $PathToRemove : $($_.Exception.Message)"
            Get-ChildItem -LiteralPath $PathToRemove -Recurse -Force -ErrorAction SilentlyContinue |
                Sort-Object FullName -Descending |
                ForEach-Object {
                    try { Remove-Item -LiteralPath $_.FullName -Force -Recurse -ErrorAction Stop } catch {}
                }
            try { Remove-Item -LiteralPath $PathToRemove -Force -Recurse -ErrorAction Stop } catch {}
        }
    }
}

if (!(Test-Path -LiteralPath $ProjectDir)) {
    throw "ProjectDir not found: $ProjectDir"
}

$genDirs = @(
    (Join-Path $ProjectDir "project_mamba_all1.cache"),
    (Join-Path $ProjectDir "project_mamba_all1.gen"),
    (Join-Path $ProjectDir "project_mamba_all1.ip_user_files"),
    (Join-Path $ProjectDir "project_mamba_all1.runs"),
    (Join-Path $ProjectDir "project_mamba_all1.sim"),
    (Join-Path $ProjectDir "project_mamba_all1.hw"),
    (Join-Path $ProjectDir ".Xil")
)

foreach ($d in $genDirs) { Remove-IfExists -PathToRemove $d }

$repoRoot = Split-Path -Parent (Split-Path -Parent $ProjectDir)
Remove-IfExists -PathToRemove (Join-Path $repoRoot ".Xil")
Remove-IfExists -PathToRemove (Join-Path $repoRoot "xsim.dir")

if (-not $RunRebuild) {
    Write-Host "[done] cache/run/sim dirs removed. Re-open xpr and rebuild."
    Write-Host "[hint] pass -RunRebuild to run non-interactive regenerate+synth."
    exit 0
}

if (!(Test-Path -LiteralPath $VivadoBat)) {
    throw "Vivado executable not found: $VivadoBat"
}

$xpr = Join-Path $ProjectDir "project_mamba_all1.xpr"
if (!(Test-Path -LiteralPath $xpr)) {
    throw "xpr not found: $xpr"
}

$tclPath = Join-Path $ProjectDir "rebuild_project_mamba_all1.tcl"
@"
open_project {$xpr}
update_compile_order -fileset sources_1
update_compile_order -fileset sim_3
reset_run synth_1
launch_runs synth_1 -jobs 8
wait_on_run synth_1
launch_simulation -simset sim_3 -mode post-synthesis -type functional
quit
"@ | Set-Content -LiteralPath $tclPath -Encoding ascii

Write-Host "[run] vivado rebuild + synth + post-synth functional sim"
& $VivadoBat -mode batch -source $tclPath

Write-Host "[done] rebuild flow finished"
