# Coding With Taz

Code used in blog posts for https://codingwithtaz.blog/

azure-pipelines.yml is an example of a multi-stage release pipeline with ARM templates for use with Azure Pipelines.
azure-pipelines-ansible.yml is an example of a multi-stage release pipeline with Ansible for use with Azure Pipelines.
azure-pipelines-terraform.yml is an example of a multi-stage release pipeline with Terraform for use with Azure Pipelines.

## API Management

In folder azure\apim there is example ARM templates for deploying API Management Product and API configurations.

This folder also contains powershell to deploy the ARM templates.

## Storage

In folder azurezstorage there is examples for deploying a storage account using different IaC methods, these are
- ARM template - storage.json
- Ansible playbook - storage.yml
- Terraform configuration - storage.tf
