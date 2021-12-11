# Deployment Playbook

## Architecture

![Architecture diagram](./architecture.png)

## Local development set-up

The backend API is written with Python and Flask. The required packages are listed in `backend/sgmp/requirements.txt`. It is recommended to use a virtual environment (e.g., conda or virtualenv) to prevent conficts with existing packages.

To create and switch to a new virtual environment, run
```
conda create -n sgmp_backend python=3.8
conda activate sgmp_backend
```
or
```
python -m virtualenv ~/sgmp_backend_venv -p python3
source ~/sgmp_backend_venv/bin/activate
```

To install the packages, run
```
cd backend/sgmp
pip install -r requirements.txt
```

To connect to the database, you need to set up an SSH tunnel to the bastion instance since the database is not accessible from the internet.  
Set up an SSH tunnel to bastion instance to remotely access RDS MySQL and TimescaleDB (`rds_endpoint` and `bastion_ip` can be obtained by running `terraform output`):
```
ssh -i <key.pem> -L 5432:master.tsdb.service.consul:5432 -L 3306:<rds_endpoint>:3306 ubuntu@<bastion_ip>
```

Make sure `config.yaml` is properly set.
```
cd backend/sgmp
cp config.example.yaml config.yaml
vim config.yaml
```

You can obtain the parameters from:
- TSDB_PASS, MYSQL_PASS: Use AWS Secrets Manager to view the database credentials
- IOT_CERT_ID, IOT_ENDPOINT, COGNITO_USER_POOL_ID, COGNITO_APP_CLIENT_ID: Run `terraform output` to see the values

You also need to retrieve the AWS IoT priavte key from Secrets Manager:
```
cd backend/sgmp
mkdir iot_certs
cd iot_certs
aws secretsmanager get-secret-value --region us-west-1 --secret-id gismolab_sgmp_iot_backend_key | jq -r ".SecretString" > private.key
```

Now you should be able to run the backend server locally by using
```
python app.py
```

## Deploying a new version

After local deployment is finished, push to GitHub and it will trigger a GitHub Action named `build-web-image`. You can check its output on GitHub web UI for the resulting image tag. Update `backend/terraform/terraform.tfvars` with the new image tag and run `terraform apply` to deploy new image to ECS cluster.

## Deploying a copy of the infrastructure

This document will detail the steps to take if the user wishes to deploy SGMP to another AWS account. Most of the back-end infrastructure is deployed using Terraform. You can find the Terraform code in `backend/terraform`.

### Out-of-band deployment

Some of the resources are deployed out-of-band (i.e. not managed by Terraform). These must be deployed before running Terraform and includes:

- AWS Elastic Container Registry  
  Currently the registry is manually created at `041414866712.dkr.ecr.us-west-1.amazonaws.com/sgmp`.
  This repository is referred to at `backend/terraform/terraform.vars` to set the image URI for deployment and at `backend/terraform/iam/common_data.tf` to set the correct IAM permission for GitHub Actions IAM Role. If separate ECR repository is not required (i.e. user wants to share the image from `slac-gismo` account ECR repository), remove `backend/terraform/iam/common_data.tf` and `backend/terraform/iam/role_github.tf` since GitHub Actions should only push to the `slac-gismo` account ECR repository.
- AWS Secrets Manager
  The database credentials should be generated using a cryptographically secure random number generator and stored in AWS Secrets Manager. The database users will be created with the provided password. Terraform script expects a secret named `gismolab_sgmp_credentials` and with the following format:

        {
          "rds": "password1",
          "tsdb_postgres": "password2",
          "tsdb_replicator": "password3",
          "tsdb_rewind_user": "password4",
          "tsdb_sgmp": "password5"
        }

- AWS Cognito User Pool  
  The Terraform script expects an existing Cognito user pool named `sgmp-user`.

### Terraform deployment

Please first update `provider.tf` and set the state storage location correctly. If deploying to another AWS account a new S3 bucket should be created to store the state. Most frequently adjusted variables could be set in `terraform.tfvars`. There are also some adjustable parameters which has their default values set in `variables.tf` which can be overridden by adding them in `terraform.tfvars`.

After the parameters are set, run
```
$ terraform init
$ terraform apply
```
to deploy the infrastructure.

### Database setup

For new installations, you will need to initialize the database schema.

**TimescaleDB**  
1. Log in to the bastion instance.

        ssh -i <key.pem> ubuntu@<bastion_ip>

2. Install PostgreSQL client.

        sudo apt-get update
        sudo apt-get install postgresql-client

3. Connect to the TimescaleDB master instance.

        psql -h master.tsdb.service.consul -U postgres

4. Create and switch to `sgmp` database.

        CREATE DATABASE sgmp;
        \c sgmp

5. Copy the SQL statements from `schema.sql` to set up the database tables.

**RDS MySQL**
1. Set up an SSH tunnel to bastion instance to remotely access RDS MySQL and TimescaleDB.

        ssh -i <key.pem> -L 5432:master.tsdb.service.consul:5432 -L 3306:<rds_endpoint>:3306 ubuntu@<bastion_ip>

2. We will use `flask-migrate` to initialize the database. Make sure deployment envorionment is installed and `config.yaml` is properly set.
   You can set the host of TimescaleDB and MySQL to `127.0.0.1` since we have set up the SSH tunnel.

        cd backend/sgmp
        cp config.example.yaml config.yaml
        vim config.yaml

3. Apply the database migration.

        flask db upgrade