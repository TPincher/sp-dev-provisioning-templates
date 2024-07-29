$TenantUrl = "https://formaccap-admin.sharepoint.com"
$TemplatePath = "C:\Users\Seer\maccap\sp-dev-provisioning-templates\tenant\contosoworks\source\template.xml"
$CSVPath = "C:\Users\Seer\maccap\scripts\csvtest.csv"

Connect-PnPonline -url $TenantUrl -Interactive

$Data = Import-Csv -Path $CSVPath

ForEach ($Site in $Data)
 {
    $SiteUrl = $Site.Url
    $SiteTitle = $Site.Title
    $SiteDescription = $Site.Description

    Invoke-PnPTenantTemplate -Path $TemplatePath -Parameters @{"SiteTitle"="$SiteTitle";"SiteDescription"="$SiteDescription";"SiteUrl"="$SiteUrl"}
 }