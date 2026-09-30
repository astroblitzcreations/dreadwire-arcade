param(
    [string]$Key = "C:\Users\stfub\Documents\Playground\raspberry-pi-arcade-upgrade\ssh\cabinet_ed25519",
    [string]$HostName = "pi@192.168.0.160"
)

$ErrorActionPreference = "Stop"
$systems = @(
    "arcade", "dreamcast", "gamegear", "gb", "gba", "gbc",
    "mastersystem", "megadrive", "n64", "neogeo", "nes", "ngp",
    "ngpc", "pc", "pcengine", "psx", "segacd", "snes",
    "wonderswan", "wonderswancolor"
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
foreach ($system in $systems) {
    $gamelist = Join-Path $root "$system-gamelist.xml"
    & scp -q -i $Key "${HostName}:/home/pi/RetroPie/roms/$system/gamelist.xml" $gamelist
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "No gamelist for $system"
        continue
    }

    [xml]$xml = Get-Content -LiteralPath $gamelist -Raw
    $missing = @(
        $xml.gameList.game |
            Where-Object { $_.image -match "/fallback/" } |
            ForEach-Object { [string]$_.path }
    )
    $list = Join-Path $root "$system-missing.txt"
    [System.IO.File]::WriteAllLines($list, $missing, [System.Text.UTF8Encoding]::new($false))
    Write-Output "$system`t$($missing.Count)"
}
