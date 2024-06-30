name: Terraform Apply

on:
  push:
    branches:
      - main
  
jobs:
  terraform:
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v2

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_wrapper: false

      - name: Create SSH Key File
        run: |
          mkdir -p /home/runner/.ssh
          echo "${{ secrets.ASHOK_EC2_KEY }}" > /home/runner/.ssh/Veera.pem
          chmod 600 /home/runner/.ssh/Veera.pem
          ls -al /home/runner/.ssh  # Verify permissions and existence
          
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.ASHOK_AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.ASHOK_AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
          
      - name: Initialize Terraform
        run: terraform init
        working-directory: ./terraform  # Update this path if necessary

      - name: Apply Terraform
        run: terraform apply -auto-approve -var="private_key_path=/home/runner/.ssh/Veera.pem"
        working-directory: ./terraform  # Update this path if necessary
