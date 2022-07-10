# A Terraform deployment of a highly available web application on AWS

Use Terraform to deploy a highly available web application on EC2 instances in multiple availability zones.

## Steps
- Fork this git and clone the fork in your local machine.
- Sign up for free at Terraform cloud, create an organisation and workspace, and generate an API key.
- In the `base.tf ` file, replace the organisation make (line 5) and workspace (line 7) with your organisation name and workspace.
- Save the generated Terraform API key as TF_API_TOKEN in your git repository secrets.
- Add AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY and AWS_DEFAULT_REGION as secret variables to your Terraform workspace.
- (Optional) to execute the infrastructure deployment, locally, run:
  ```
  terraform init
  terraform apply
  ```
- To execute the infrastructure deployment (also automatically destroys the deployment after creation), push your changes to your repo.
