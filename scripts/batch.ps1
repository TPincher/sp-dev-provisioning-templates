

$Sitecount = Read-Host "How many sites do you want to create?"

while ($Sitecount -ge 5) {
    Start-Job -FilePath .\maccap\sp-dev-provisioning-templates\scripts\innerbatch5.ps1
    $Sitecount -= 5
}

for ($j = 0; $j -lt $Sitecount; $j++)
{
Start-Job -FilePath .\maccap\sp-dev-provisioning-templates\scripts\innerbatch1.ps1
}