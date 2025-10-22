#!/usr/bin/env bash

set -e

echo "Installing docker-compose..."
os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)
pro=$(dpkg --print-architecture)
terraform_version="1.11.4"

sudo curl -L "https://github.com/docker/compose/releases/download/v2.1.1/docker-compose-${os}-${arch}" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Installing Terraform..."
mkdir -p "${HOME}/bin"
sudo apt-get update && sudo apt-get install -y unzip jq wget
pushd "${HOME}/bin"
wget -q "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_${pro}.zip"
unzip -q -o "terraform_${terraform_version}_linux_${pro}.zip"
. "${HOME}/.profile"
popd

echo "Building service images..."
pushd /vagrant
docker build ./services/account -t form3tech-oss/platformtest-account
docker build ./services/gateway -t form3tech-oss/platformtest-gateway
docker build ./services/payment -t form3tech-oss/platformtest-payment

echo "Starting supporting services with docker-compose..."
docker-compose up -d
popd

echo "Applying Terraform for all environments..."
pushd /vagrant/tf
terraform init -upgrade

for env in dev staging prod; do
    echo "----------------------------------------"
    echo "Applying Terraform for $env environment"
    echo "----------------------------------------"
    terraform apply -auto-approve -var-file="environments/${env}.tfvars"
done

popd
echo "All environments deployed successfully!"
