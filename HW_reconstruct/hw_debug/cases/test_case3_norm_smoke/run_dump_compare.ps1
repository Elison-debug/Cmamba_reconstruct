param(
  [string]$RunName = "sim_6_test_case3_norm_smoke",
  [switch]$SkipCompare
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $PSScriptRoot | Split-Path -Parent | Split-Path -Parent | Split-Path -Parent
Set-Location $repo

$caseDir = "HW_reconstruct/hw_debug/cases/test_case3_norm_smoke"
$stageDir = Join-Path $caseDir "stages/reuse_mamba_block_top"
$required = @(
  "h_wr_addr.mem",
  "h_raw_wr_data_q88.mem",
  "norm_weight_q88.mem",
  "h_norm_golden_q88.mem",
  "u_golden_q88.mem",
  "z_golden_q88.mem",
  "u_act_golden_q88.mem",
  "z_silu_golden_q88.mem",
  "dt_golden_q88.mem",
  "lam_golden_q016.mem",
  "ssm_golden_q88.mem",
  "gate_y_golden_q88.mem",
  "y_golden_q88.mem"
)
$missing = $required | Where-Object { -not (Test-Path (Join-Path $stageDir $_)) }
if ($missing.Count -gt 0) {
  Write-Host "Missing regenerated norm-enabled stage files:" -ForegroundColor Yellow
  $missing | ForEach-Object { Write-Host "  $_" }
  Write-Host "Run the export/golden generation flow for test_case3_norm_smoke first." -ForegroundColor Yellow
  exit 2
}

python HW_reconstruct/hw_debug/vivado/run_xsim_stage.py --stage reuse_mamba_block_top_sim6_norm --case_dir $caseDir --run_name $RunName --clean
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

if (-not $SkipCompare) {
  python refactor/bittrue/compare_hw_dump.py --case_dir $caseDir --stage reuse_mamba_block_top --rtl_dir "$caseDir/rtl_out/reuse_mamba_block_top" --signed --lane_bits 16 --lanes 4
  exit $LASTEXITCODE
}
