# AWS Template for demo site
## Features
- VPC containing ECS ASG (only 1 EC2 instance) with ALB in public subnet, and MySQL RDS in private subnet
- S3 buckets for storing staticfiles, uploaded media, terraform state and secrets (environment file)
- Task definitions for dashboard app and nginx containers, with images stored on ECR

<br/><br/>

## To use
1. Replace project name, tf bucket name and DynamoDB table in ./global/variables/outputs.tf

2. Replace profile in:
    1. ./data-stores/mysql/main.tf
    2. ./global/s3/main.tf
    3. ./services/main.tf
    4. ./vpc/main.tf

3. Replace tfstate bucket name, key and DynamoDB table:
    1. ./data-stores/mysql/main.tf
    2. ./global/s3/main.tf
    3. ./vpc/main.tf

4. Specify DB name, username and password in ./data-stores/mysql/main.tf

5. Specify CORS rules in ./services/main.tf

6. Specify container definitions in ./services/service.json
