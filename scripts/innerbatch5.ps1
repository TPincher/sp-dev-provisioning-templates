Import-Module NameIT

$TenantUrl = "https://vbtnd-admin.sharepoint.com"
$TemplatePath = "maccap\sp-dev-provisioning-templates\tenant\contosoworks\source\template.xml"

$count = 5

Connect-PnPonline -url $TenantUrl -Interactive

for ($i = 0; $i -lt $count; $i++)
{
    $Randadd = Invoke-Generate "#####?????"
    $SiteUrl = "https://vbtnd.sharepoint.com/sites/example$Randadd"
    $SiteTitle = "ExampleSite$Randadd"
    $SiteDescription = "This is the description for site $Randadd"

    New-PnpSite -Type CommunicationSite -Title "$SiteTitle" -Url $SiteUrl -Owner candidate04@vbtnd.onmicrosoft.com -description "$SiteDescription"
    Invoke-PnPTenantTemplate -Path $TemplatePath -Parameters @{"SiteTitle"="$SiteTitle";"SiteDescription"="$SiteDescription";"SiteUrl"="$SiteUrl"}
 }

 "Completed batch job"
