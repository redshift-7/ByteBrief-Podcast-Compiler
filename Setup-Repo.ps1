# --- Configuration ---
$ProjectName = "ByteBrief-Podcast-Compiler"
$TargetDir   = "C:\Users\anato\Projects\$ProjectName"
$SourceScript = ".\Compile-Podcast.ps1"

if (!(Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI not found. Install it via Scoop (scoop install gh)."
}

# --- 1. Scaffold Directory ---
Write-Host "Creating project directory at $TargetDir..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

# --- 2. Copy the Active Script ---
Write-Host "Copying compiler script safely..." -ForegroundColor Cyan
Copy-Item -Path $SourceScript -Destination $TargetDir -Force

# --- 3. Generate .gitignore ---
Write-Host "Generating .gitignore..." -ForegroundColor Cyan
$GitIgnore = @"
*.mp4
*.m4a
*.mp3
*.wav
temp_*.png
Gemini_Generated_Image*.jpg
"@
Set-Content -Path "$TargetDir\.gitignore" -Value $GitIgnore -Encoding UTF8

# --- 4. Generate README.md ---
Write-Host "Generating README.md..." -ForegroundColor Cyan
$Readme = @"
# ByteBrief Podcast Compiler

A PowerShell automation script that leverages FFmpeg and NVIDIA's NVENC to generate hardware-accelerated YouTube podcast videos. 

## Features
* **Zero-Squish 4K Widescreen:** Dynamically scales 1:1 square artwork into 16:9 4K pillarboxed backgrounds.
* **Ken Burns Effect:** Calculates a mathematically perfect, continuous slow-zoom over the track duration.
* **Premium Audio Visualizer:** Generates a mirrored, dual-channel P2P waveform.
* **Encoding-Immune:** Bypasses PowerShell legacy ANSI bugs by reading file metadata directly from the Windows kernel.

## Requirements
* Windows 11
* FFmpeg (must be in system PATH)
* NVIDIA RTX GPU (Uses hevc_nvenc and Ada Lovelace optimizations)

## Usage
Run the script interactively. It will auto-detect .m4a files in the current directory and prompt for confirmation.
\`\`\`powershell
.\Compile-Podcast.ps1
\`\`\`
"@
Set-Content -Path "$TargetDir\README.md" -Value $Readme -Encoding UTF8

# --- 5. Self-Replicate This Setup Script ---
Write-Host "Saving GitHub deployment script as code..." -ForegroundColor Cyan
Copy-Item -Path $PSCommandPath -Destination "$TargetDir\Setup-Repo.ps1" -Force -ErrorAction SilentlyContinue

# --- 6. Git & GitHub Push ---
Write-Host "Initializing Git and pushing to GitHub..." -ForegroundColor Cyan
Push-Location $TargetDir

git init
git branch -M main
git add .
git commit -m "feat: initial commit of podcast compiler, github automation, and docs"

# Creates a public repo, sets remote, and pushes
gh repo create $ProjectName --public --source=. --remote=origin --push

Pop-Location
Write-Host "Done! Project safely copied to $TargetDir and pushed to GitHub." -ForegroundColor Green