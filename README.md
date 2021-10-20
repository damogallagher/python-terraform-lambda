# Deploy to AWS Lambda 

cd terraform
terraform init
terraform plan
export AWS_PROFILE=csx
terraform apply --auto-approve

# Destroy infrastructure
cd terraform
export AWS_PROFILE=csx
terraform destroy --auto-approve


### OLD
## Run from root of project
zip lambda lambda.py

## Run from terraform directory
terraform init
export AWS_PROFILE=csx
terraform apply

# Quick Instructions
rm -rf terraform/lambda.zip
zip terraform/lambda app/lambda.py
cd terraform
terraform init
export AWS_PROFILE=csx
terraform apply --auto-approve
cd ../

# Destroy infrastructure
cd terraform
export AWS_PROFILE=csx
terraform destroy --auto-approve
cd ../