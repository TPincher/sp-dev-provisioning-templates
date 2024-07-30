Import-Module NameIT

$TenantUrl = "https://vbtnd-admin.sharepoint.com"
$TemplatePath = "maccap\sp-dev-provisioning-templates\tenant\contosoworks\source\template.xml"

Connect-PnPonline -url $TenantUrl -Interactive

    $Randadd = Invoke-Generate "#####?????"
    $SiteUrl = "https://vbtnd.sharepoint.com/sites/example$Randadd"
    $SiteTitle = "ExampleSite$Randadd"
    $SiteDescription = "This is the description for site $Randadd"

    New-PnpSite -Type CommunicationSite -Title "$SiteTitle" -Url $SiteUrl -Owner candidate04@vbtnd.onmicrosoft.com -description "$SiteDescription"
    Invoke-PnPTenantTemplate -Path $TemplatePath -Parameters @{"SiteTitle"="$SiteTitle";"SiteDescription"="$SiteDescription";"SiteUrl"="$SiteUrl"}


 "Completed batch job"
