# terraform-azure-sql-always-on-ha

Setup you private Azure creds before running the script :

```
subscription_id     = "---"
client_id           = "---"
client_secret       = "---"
tenant_id           = "---"
```

Note: Above should be stored in a file called terraform.tfvars

## Getting Started

- Enter all the variables in variable file (terraform.tfvars)
- Add storage account , container name , Access Key at the end of  azure_vm.tf file for storing terraform state file remotely to azure (you need to have a already created storage account for storing the state file )

Run following commands to run & test Terraform scripts :

- terraform init        (To initialize the project)
- terraform plan        (To check the changes to be made by Terraform on azure )
- terraform apply       (To apply the changes to azure)


## Links

https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sql/virtual-machines-windows-portal-sql-availability-group-prereq
