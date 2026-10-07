$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
$LlvmVersion = '22.1.8'
$LlvmBin = 'C:\Program Files\LLVM\bin'
$LlvmInstaller = "$env:RUNNER_TEMP\LLVM-22.1.8-woa64.exe"
$LlvmUrl = "https://github.com/llvm/llvm-project/releases/download/llvmorg-$LlvmVersion/LLVM-$LlvmVersion-woa64.exe"
Invoke-WebRequest $LlvmUrl -UseBasicParsing -OutFile $LlvmInstaller
Start-Process -FilePath $LlvmInstaller -ArgumentList '/S' -Wait
$env:PATH = "$LlvmBin;$env:PATH"
$LlvmBin | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
$LlvmRuntime = "$LlvmBin\..\lib\clang\22.1.8\lib\windows"
$FlangRuntime = "$LlvmBin\..\lib\clang\22\lib\aarch64-pc-windows-msvc"
$env:LIB = "$FlangRuntime;$LlvmRuntime;$env:LIB"
"LIB=$env:LIB" | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append
@(
    'CC=clang-cl'
    'CXX=clang-cl'
    'FC=flang-new'
    'AR=llvm-ar'
    'ODRPACK_WIN_ARM64=1'
) | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

$OpenBlasVersion = '0.3.34'
$OpenBlasDir = 'C:\openblas'
$zip = "$env:RUNNER_TEMP\openblas.zip"
$tmp = "$env:RUNNER_TEMP\openblas_extract"
$url = "https://github.com/OpenMathLib/OpenBLAS/releases/download/v$OpenBlasVersion/OpenBLAS-$OpenBlasVersion-woa64-64-dll.zip"
Invoke-WebRequest -Uri $url -OutFile $zip -UseBasicParsing

# Extract to a temp dir, then flatten the top-level OpenBLAS folder
Expand-Archive -LiteralPath $zip -DestinationPath $tmp -Force
Move-Item "$tmp\OpenBLAS" $OpenBlasDir

$pkgConfigDir = "$OpenBlasDir\lib\pkgconfig"
$prefix = $OpenBlasDir.Replace('\', '/')

@"
libdir=$prefix/lib
libnameprefix=
libnamesuffix=
libsuffix=
includedir=$prefix/include/openblas

Name: OpenBLAS
Description: OpenBLAS is an optimized BLAS library based on GotoBLAS2 1.13 BSD version
Version: $OpenBlasVersion
URL: https://github.com/OpenMathLib/OpenBLAS
Libs: -L`${libdir} -l`${libnameprefix}openblas`${libnamesuffix}`${libsuffix}
Cflags: -I`${includedir}
"@ | Set-Content -LiteralPath "$pkgConfigDir\openblas.pc" -Encoding ASCII
@(
    "PKG_CONFIG_PATH=$($pkgConfigDir.Replace('\', '/'))"
    "OPENBLAS_DIR=$OpenBlasDir"
) | Out-File -FilePath $env:GITHUB_ENV -Encoding utf8 -Append

"$OpenBlasDir\bin" | Out-File -FilePath $env:GITHUB_PATH -Encoding utf8 -Append
