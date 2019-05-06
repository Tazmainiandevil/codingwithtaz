$ResourceGroup = "<your apim resource group>"
$DeploymentName = "apim-product-deploy"
$Template = "product-config.json"
$TemplateParameters = "product-config-parameters.json"
$Subscription = "<your subscription>"

Connect-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName $Subscription

New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $ResourceGroup -TemplateFile $Template -TemplateParameterFile $TemplateParameters -DeploymentDebugLogLevel None
