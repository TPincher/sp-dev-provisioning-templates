## MVP

1) Fork https://github.com/SharePoint/sp-dev-provisioning-templates
2) Create a new site and apply template (https://github.com/SharePoint/sp-dev-provisioning-templates/tree/master/tenant/contosoworks) to it. This can be on dev tenant vbtnd.onmicrosoft.com or your own. Provide link as response

I have pushed a run of 5 example sites to the vbtnd.onmicrosoft.com group under candidate04.
The template can be found in the file structure at tenant/contosoworks/source/template.xml

3) Modify template to include the new years for Global Country Holiday, include ANZ public holidays.

Available at https://formaccap.sharepoint.com/sites/hr-live/Lists/Global%20Country%20Holidays/AllItems.aspx

- NYE has been changed to Global. Australia and New Zealand has been made it's own category, with identification in the title for country specific holidays. Alternatiely, this could be separated out into both Australia and New Zealand as two locations.

- As the text 'U.S. corporate holidays' is hard coded onto this template, it didn't seem right to add ANZ holidays here. I added them to the HR list, but could change where these are listed in the codebase and the copy to 'ANZ corporate holidays' if that was what was intended.

4) Capture the site and push to forked RP with PR and merge
5) Create script to apply this template to 10000 sites. Remember title, description and URL will be different for each of these sites. Add this script as README.md to GitHub repo

- Scripts are available under the scripts folder. Running batch.ps1 will ask you how many sites you'd like to provision, and will then batch them off in groups of 5, 
and then send individual jobs for the remainders. Please see below for further explanation.

- Note that this script could be modified to just execute 10,000 jobs but this seems both risky and inefficient.

6) Explain your approach for applying this template on demand via Azure

- My initial thought is Azure Functions to host the script so that it can be called on demand and passed in an argument of how many sites to provision.
 However, from what I could read, the -startjob cmdlet does not work in the PowerShell Azure Functions environment. Microsoft's documents advise that it should be substituted for the Start-Threadjob cmdlet instead so the script would have to be modified to accomodate.

(https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/start-job?view=powershell-7.4)
(https://www.powershellgallery.com/packages/ThreadJob/2.0.3)

7) Explain Your approach for integrating a solution in step 6 into other systems

- I have limited experience in GCP, but I believe that the Google Cloud Function product works in a similar vein to the Azure Functions product. I have no experience
with AWS, but it looks like Lambda may be an option in that ecosystem.

## The script

- The script prompts the user for how many sites they would like to provision. Assuming an input of 5 or greater, a while loop sends a batch job request for 5 new sites, decrements that from the input variable, and checks again. Once less than 5, it sends those as individual batch jobs.


Prompts input for total sites and then fires batch jobs.
```
$Sitecount = Read-Host "How many sites do you want to create?"

while ($Sitecount -ge 5) {
    Start-Job -FilePath .\maccap\sp-dev-provisioning-templates\scripts\innerbatch5.ps1
    $Sitecount -= 5
}

for ($j = 0; $j -lt $Sitecount; $j++)
{
Start-Job -FilePath .\maccap\sp-dev-provisioning-templates\scripts\innerbatch1.ps1
}
```

Batch job for leftovers. Could find a way to pass in the remainder as a single job instead of multiple single jobs.
```
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
```


Batch job for 5
```
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
```

#### Issues with this implementation

- As the example sites are generated as hub sites, the HR-live site can only point to one at a time, and is set to point at the most recently created one.
- User credentials are requested for every batch. This should be solveable with environment variables, or some other way to pass them in after a single prompt.
- For a scope of 10,000 new sites, batching in lots greater than 5 may be a better idea. I was already getting throttled when testing for 100 sites though, and I'm not
sure of any limitations sharepoint may have on throughput.
- Input testing for any production script would be required for null, invalid, or negative values.
- Automated receive-job feedback for batch completion
- Try/Catch error handling with log dump for batch scripts in case of failure.
- Current implementation appends five numbers and then five characters to the end of a created URL. Odds of duplication are -very- unlikely with possible variations in
the order of trillions, but not impossible. As site generation is much quicker than template application, a query at the start of the batch could be used with the Get-PnPSite cmdlet, then generate the sites to reserve the names before applying the template to each.





# The below is the original text of the README file, unaltered from https://learn.microsoft.com/en-us/sharepoint/dev/solution-guidance/applying-pnp-templates

# SharePoint Provisioning Templates

Repository for SharePoint PnP Provisioning templates to automate site / tenant level provisioning logic. Templates are divided on different folders based on the structure and needed permissions.

- Site - These templates contain site level provisioning logic. They can be provisioned and used by any site collection administrator and no tenant scoped permissions are needed.

- Tenant - These templates contain tenant level provisioning. They could contain for example multiple site collections, site designs, taxonomy configurations etc. You will need to have tenant level permissions to apply these templates.

Sub folders in specific folders are actual templates. Each template has at least one screenshot file and readme file. The readme file should follow the readme template available in the root of this repository. Each template also has a mandatory json file, which has to follow the provided json file structure. This json file information is used to surface metadata on a web site from where the templates can be used. 

# Contributing

This project welcomes contributions and suggestions on service texts, but not for the templates.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

