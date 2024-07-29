Import-Module NameIT

$TenantUrl = "https://formaccap-admin.sharepoint.com"
$TemplatePath = "maccap\sp-dev-provisioning-templates\tenant\contosoworks\source\template.xml"

$Sitecount = Read-Host "How many sites do you want to create?"

Connect-PnPonline -url $TenantUrl -Interactive

for ($i = 0; $i -lt $Sitecount; $i++)
{
    $Randadd = Invoke-Generate "####????"
    $SiteUrl = "https://formaccap.sharepoint.com/sites/example$Randadd"
    $SiteTitle = "ExampleSite$Randadd"
    $SiteDescription = "This is the description for site $Randadd"

    Invoke-PnPTenantTemplate -Path $TemplatePath -Parameters @{"SiteTitle"="$SiteTitle";"SiteDescription"="$SiteDescription";"SiteUrl"="$SiteUrl"}
 }
