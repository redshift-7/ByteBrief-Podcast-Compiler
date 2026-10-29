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
\\\powershell
.\Compile-Podcast.ps1
\\\
