# aws-wireguard
AWS EC2 Instance with Wireguard Installed

# Usage
1. Create an S3 bucket named `wireguard-tfstate-3f1a86f1`. This name is specified in the file `aws.tf`. Necessary for S3 backend to work correctly.
2. Clone this repo, `git clone https://github.com/ocaflash/aws-wireguard` 
3. Run command `terraform init` to initializes a working directory containing Terraform configuration files. 
4. Run `terraform plan` and `terraform apply` for deploying.
5. After execution, the following information will be received: 
```
management_dashboard = "http://3.125.179.178:6423"
project_uuid = "bee7dc332753c8ae"
```
6. Go to this address and create a new administrator.