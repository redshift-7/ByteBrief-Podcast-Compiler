[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
$OutputEncoding           = [System.Text.Encoding]::UTF8
$ErrorActionPreference    = "Stop"

Write-Host "=== ByteBrief Podcast Compiler ===" -ForegroundColor Cyan

# --- 1. DYNAMIC INPUTS (IMMUNE TO SCRIPT ENCODING BUGS) ---
# Grabs the actual filename from Windows to avoid hardcoded Cyrillic string corruption
$FoundAudio = Get-ChildItem -Path $PWD -Filter "*BitLocker*.m4a" | Select-Object -First 1
$DefaultAudio = if ($FoundAudio) { $FoundAudio.Name } else { "podcast.m4a" }

$DefaultImage = "Gemini_Generated_Image_obsizgobsizgobsi (1).jpg"

# Prompt for Audio
$AudioInputRaw = Read-Host "1. Enter Audio File (Press Enter for default: $DefaultAudio)"
if ([string]::IsNullOrWhiteSpace($AudioInputRaw)) { $AudioInputRaw = $DefaultAudio }
$AudioInputRaw = $AudioInputRaw.Trim(' ', '"', "'")

# Prompt for Image
$ImageInputRaw = Read-Host "2. Enter Image File (Press Enter for default: $DefaultImage)"
if ([string]::IsNullOrWhiteSpace($ImageInputRaw)) { $ImageInputRaw = $DefaultImage }
$ImageInputRaw = $ImageInputRaw.Trim(' ', '"', "'")

# Prompt for Render Mode
$ModeRaw = Read-Host "3. Render Mode? [T]est (7s) or [F]ull length? (Press Enter for default: T)"
if ([string]::IsNullOrWhiteSpace($ModeRaw)) { $ModeRaw = "T" }

# --- 2. FILE RESOLUTION ---
$AudioPath = Join-Path $PWD ($AudioInputRaw -replace '^\.\\', '')
$ImagePath = Join-Path $PWD ($ImageInputRaw -replace '^\.\\', '')
$TempImage = Join-Path $PWD "temp_16x9_bg.png"

if (!(Test-Path -LiteralPath $AudioPath)) { throw "Missing audio file: $AudioPath" }
if (!(Test-Path -LiteralPath $ImagePath)) { throw "Missing image file: $ImagePath" }

# --- 3. ENVIRONMENT CHECK ---
Write-Host "`n[1/4] Checking FFmpeg environment..." -ForegroundColor Cyan
if (!(Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    throw "FFmpeg is missing from PATH."
}

# --- 4. PREP WORK (THE SQUISH FIX) ---
Write-Host "[2/4] Generating 16:9 4K background plate..." -ForegroundColor Cyan
$PrepFilter = "[0:v]scale=3840:2160,boxblur=luma_radius=50:luma_power=2,setsar=1[bg];[0:v]scale=-1:2160,setsar=1[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2,setsar=1,setdar=16/9"

ffmpeg -i $ImagePath -filter_complex $PrepFilter -y $TempImage -loglevel error

# --- 5. RENDER PHASE ---
$RenderFilter = "[0:v]zoompan=z='1.000+0.000003*on':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=48000:s=1920x1080:fps=30[bg];[1:a]showwaves=s=1920x250:mode=p2p:colors=0x0088FF|0x00FFFF:split_channels=1[wave];[bg][wave]overlay=(W-w)/2:H-h-200,drawtext=text='ByteBrief RU':fontfile='C\:/Windows/Fonts/arial.ttf':fontsize=45:fontcolor=white@0.4:x=w-tw-50:y=50,format=yuv420p[v]"

if ($ModeRaw -match '(?i)^f') {
    $FinalOutput = Join-Path $PWD "ByteBrief_RU_Podcast_01.mp4"
    Write-Host "[3/4] Compiling FULL 26m video with NVENC..." -ForegroundColor Magenta
    
    ffmpeg -loop 1 -i $TempImage -i $AudioPath `
        -filter_complex $RenderFilter `
        -map "[v]" -map 1:a `
        -c:v hevc_nvenc -preset p6 -tune hq -b:v 4M -multipass 2 -rc vbr `
        -c:a aac -b:a 192k `
        -shortest `
        -y $FinalOutput

} else {
    $FinalOutput = Join-Path $PWD "ByteBrief_RU_Podcast_TEST.mp4"
    Write-Host "[3/4] Compiling 7-SECOND TEST video with NVENC..." -ForegroundColor Yellow
    
    ffmpeg -loop 1 -i $TempImage -i $AudioPath `
        -filter_complex $RenderFilter `
        -map "[v]" -map 1:a `
        -c:v hevc_nvenc -preset p6 -tune hq -b:v 4M -multipass 2 -rc vbr `
        -c:a aac -b:a 192k `
        -shortest `
        -t 7 `
        -y $FinalOutput
}

# --- 6. CLEANUP ---
Write-Host "[4/4] Removing temporary assets..." -ForegroundColor Cyan
Remove-Item -LiteralPath $TempImage -ErrorAction SilentlyContinue

Write-Host "Success! Render completed: $FinalOutput" -ForegroundColor Green