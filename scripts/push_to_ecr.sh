#!/bin/bash
set -e

# Get ECR URLs from Terraform output
cd terraform
BACKEND_REPO=$(terraform output -raw backend_repository_url)
FRONTEND_REPO=$(terraform output -raw frontend_repository_url)
cd ..

echo "Backend Repo: $BACKEND_REPO"
echo "Frontend Repo: $FRONTEND_REPO"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $(echo $BACKEND_REPO | cut -d'/' -f1)

# Tag Images
echo "Tagging images..."
docker tag afrimart-ecommerce-backend:latest $BACKEND_REPO:latest
docker tag afrimart-ecommerce-frontend:latest $FRONTEND_REPO:latest

# Push Images
echo "Pushing Backend..."
docker push $BACKEND_REPO:latest

echo "Pushing Frontend..."
docker push $FRONTEND_REPO:latest

echo "Successfully pushed images to ECR!"
