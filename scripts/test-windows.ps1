$ErrorActionPreference='Stop'
$ProgressPreference='SilentlyContinue'
$root=Join-Path ([IO.Path]::GetTempPath()) ('fclaude-packages-'+[guid]::NewGuid().ToString('N'))
New-Item -Type Directory $root|Out-Null
try {
    foreach($name in @('brote','coigue')) {
        $m=Get-Content "$PSScriptRoot\..\bucket\$name.json" -Raw|ConvertFrom-Json
        $a=$m.architecture.'64bit'
        if($a.url -notmatch "^https://github.com/fclaude/$name/releases/download/v[0-9.]+/" -or $a.hash -notmatch '^[0-9a-f]{64}$'){throw 'Unexpected package origin or checksum'}
        $zip=Join-Path $root "$name.zip"
        Invoke-WebRequest $a.url -OutFile $zip
        if((Get-FileHash $zip -Algorithm SHA256).Hash.ToLower() -ne $a.hash){throw "Checksum mismatch: $name"}
        Expand-Archive $zip (Join-Path $root $name)
        $dir=Join-Path (Join-Path $root $name) $a.extract_dir
        if(!(Test-Path "$dir\LICENSE")){throw "Missing license: $name"}
        foreach($bin in @($m.bin)){if(!(Test-Path (Join-Path $dir $bin))){throw "Missing executable: $bin"}}
        $p=Start-Process "$dir\$name.exe" -ArgumentList '--version' -PassThru -NoNewWindow -RedirectStandardOutput "$root\$name-version.txt"
        $null=$p.Handle
        if(!$p.WaitForExit(30000)){& taskkill.exe /PID $p.Id /T /F;if($LASTEXITCODE -ne 0){throw 'Cleanup failed'};$p.WaitForExit();throw 'Version check timed out'}
        $p.WaitForExit();$p.Refresh();if($p.ExitCode -ne 0){throw "Version failed: $name"}
        $v=Get-Content "$root\$name-version.txt" -Raw
        if($v -notmatch [regex]::Escape($m.version)){throw "Version mismatch: $name ($v)"}
        if($name -eq 'coigue' -and !(Test-Path "$dir\THIRD_PARTY_NOTICES.md")){throw 'Missing third-party notices'}
        if($name -eq 'brote') {
            $p=Start-Process "$dir\brote.exe" -ArgumentList '-e "(+ 20 22)"' -PassThru -NoNewWindow -RedirectStandardOutput "$root\scheme.txt"
            $null=$p.Handle
            if(!$p.WaitForExit(30000)){& taskkill.exe /PID $p.Id /T /F;if($LASTEXITCODE -ne 0){throw 'Cleanup failed'};$p.WaitForExit();throw 'Scheme check timed out'}
            $p.WaitForExit();$p.Refresh();if($p.ExitCode -ne 0 -or (Get-Content "$root\scheme.txt" -Raw).Trim() -ne '42'){throw 'Scheme evaluation failed'}
        }
        Write-Output "$name $($m.version): native checks passed"
    }
} finally {Remove-Item $root -Recurse -Force}
