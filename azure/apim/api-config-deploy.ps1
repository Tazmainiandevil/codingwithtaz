$ResourceGroup = "<your apim resource group>"
$DeploymentName = "apim-api-deploy"
$Template = "api-config.json"
$TemplateParameters = "api-config-parameters.json"
$Subscription = "<your subscription>"

Connect-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName $Subscription

New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroup -TemplateFile $Template -TemplateParameterFile $TemplateParameters -DeploymentDebugLogLevel None