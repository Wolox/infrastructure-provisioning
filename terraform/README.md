# Infrastructure as Code

The goal of this repository is to have a set of Terraform modules that allow the creation of various infrastructure pieces. It has been designed with modules so that anyone can mix the necessary ones to build the desired stack.

## Installing Terraform

Please visit [this page](https://www.terraform.io/intro/getting-started/install.html) and follow the instructions to install Terraform.

## Usage

Create a folder under `stages` with the name of your stage. Each folder must contain, at least, two files: `main.tf` and `config.tf`.

### Configuration

`config.tf` must contain the basic configuration for `Terraform` to work. For example:

```
provider "aws" {
  region     = "us-east-1",
  profile    = "your-profile"
}
```

It is a good practice to have your AWS credentials saved under `~/.aws/credentials` if a file that looks like this:

```
[account-1]
aws_access_key_id=ACCESS_KEY_FOR_ACCOUNT_1
aws_secret_access_key=SECRET_ACCESS_KEY_FOR_ACCOUNT_1
[account-2]
aws_access_key_id=ACCESS_KEY_FOR_ACCOUNT_2
aws_secret_access_key=SECRET_ACCESS_KEY_FOR_ACCOUNT_2
```

### Putting modules together

`main.tf` will contain the calls to the necessary modules to build the infrastructure. You can find some examples under the `stages` folder of this repository.

## Modules

### VPC

This module builds a basic VPC with a public and private zone. The VPC's CIDR block is **10.0.0.0/16**. Under this CIDR block there are 4 subnets, two public and two private subnets with the following CIDR blocks:

| CIDR Block        | Availability Zone           | Type    |
| -------------     |:-------------:              | -----:  |
| 10.0.0.0/24       | us-east-1b                  | public  |
| 10.0.2.0/24       | us-east-1d                  | public  |
| 10.0.1.0/24       | us-east-1b                  | private |
| 10.0.3.0/24       | us-east-1d                  | private |

#### Inputs
None

#### Outputs
1. **id**: VPC id
2. **public_subnet_a**: Public subnet A id
3. **public_subnet_a_cidr_block**: Public subnet A CIDR block
4. **public_subnet_b**: Public subnet B id
5. **public_subnet_b_cidr_block**: Public subnet B CIDR block
6. **private_subnet_a**: Private subnet A id
7. **private_subnet_a_cidr_block**: Private subnet A CIDR block
8. **private_subnet_b**: Private subnet B id
9. **private_subnet_b_cidr_block**: Private subnet B CIDR block

### Beanstalk

This module builds an Elastic Beanstalk application and environment with **64bit Amazon Linux 2016.09 v2.3.1 running Ruby 2.3 (Puma)** stack by default. This Beanstalk environment must live inside a VPC's public subnets (that's why the VPC module exists).

#### Inputs

1. **environment**: The environment name (eg: 'stage')
2. **application_name**: The application name (eg: 'terraform')
3. **vpc_id**: The id of the VPC in which the environment should be placed
4. **public_subnet_a**: The id of the public subnet
5. **public_subnet_b**: The id of the other public subnet

### RDS

This module builds an RDS instance living in the private subnet of a VPC. It also adds an inbound rule to the SG allowing access from the public subnets

#### Inputs
1. **environment**: The environment name (eg: 'stage')
2. **application_name**: The application name (eg: 'terraform')
3. **private_subnet_a**: The id of the private subnet A
4. **private_subnet_b**: The id of the private subnet B
5. **engine**: The database engine (mysql, postgres)
6. **engine_version**: The version of the engine (for example, "9.5.4" for postgres)
7. **storage**: The size in GB allocated for this DB
8. **instance_class**: eg: db.t2.micro
9. **database_password**: The password for the database

### Redis

This module builds a redis cache instance.

#### Inputs
1. **environment**: The environment name (eg: 'stage')
2. **application_name**: The application name (eg: 'terraform')

### S3

Allows the creation of an S3 bucket.

#### Inputs
1. **bucket_name**: The bucket-name
2. **acl**: The [canned ACL](https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl)
3. **has_policy**: A boolean indicating wether the bucket has a policy file or not

If the bucket needs a policy, set **has_policy** to true and create a file called bucket_name.tpl (replacing bucket_name with the actual bucket name). For example, if your bucket is called www.terraform.com you should create a file called www.terraform.com.tpl with the desired policy.
