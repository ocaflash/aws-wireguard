# aws-wireguard
AWS EC2 Instance with Wireguard Installed

# Getting Started
1. Create an S3 bucket named `wireguard-tfstate-3f1a86f1`. This name is specified in the file `aws.tf`. Necessary for S3 backend to work correctly.
2. Clone this repo, `git clone https://github.com/remedyproduct/aws-wireguard` 
3. Run command `terraform init` to initializes a working directory containing Terraform configuration files. 
4. Run `terraform plan` and `terraform apply` for deploying.
5. After execution, the following information will be received: 
```
management_dashboard = "http://3.125.179.178:6423"
project_uuid = "bee7dc332753c8ae"
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_vpc.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_eip.wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.ec2_s3_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2_s3_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_s3_bucket.backup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_security_group.wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [random_id.project_uuid](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_id.uuid_interface](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_integer.client_port](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [random_integer.web_port](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [aws_ami.latest_ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.ec2_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | IAM role name | `string` | `"EC2ToS3Access"` | no |
| <a name="input_iam_role_path"></a> [iam\_role\_path](#input\_iam\_role\_path) | IAM role path | `string` | `"/"` | no |
| <a name="input_iam_role_policy_attachment"></a> [iam\_role\_policy\_attachment](#input\_iam\_role\_policy\_attachment) | List of IAM policies | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/AmazonEC2FullAccess",<br>  "arn:aws:iam::aws:policy/AmazonS3FullAccess"<br>]</pre> | no |
| <a name="input_ip_address_int"></a> [ip\_address\_int](#input\_ip\_address\_int) | IP address for Wireguard interface | `string` | `"192.168.10.2"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix to be used in the naming of some of the created AWS resources | `string` | `"wireguard"` | no |
| <a name="input_region"></a> [region](#input\_region) | Region to be used for AWS resources | `string` | `"eu-central-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_management_dashboard"></a> [management\_dashboard](#output\_management\_dashboard) | Management Dashboard URI |
| <a name="output_project_uuid"></a> [project\_uuid](#output\_project\_uuid) | Project UUID Tag |
<!-- END_TF_DOCS -->
