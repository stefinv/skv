# Form3 Platform Interview

Platform engineers at Form3 build highly available distributed systems using infrastructure as code. Our take home test is designed to evaluate real world activities that are involved with this role. We recognise that this may not be as mentally challenging and may take longer to implement than some algorithmic tests that are often seen in interview exercises. Our approach however helps ensure that you will be working with a team of engineers with the necessary practical skills for the role (as well as a diverse range of technical wizardry).


## 🧪 Sample application
The sample application consists of four services:

```
┌─────────────┐     ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│             │     │              │    │              │    │              │
│   payment   │     │   account    │    │   gateway    │    │   frontend   │
│             │     │              │    │              │    │              │
└─────────┬───┘     └──────┬───────┘    └──────┬───────┘    └──────────────┘
          │                │                   │
          │                │                   │
          │                ▼                   │
          │         ┌──────────────┐           │
          │         │              │           │
          └────────►│    vault     │◄──────────┘
                    │              │
                    └──────────────┘
```                    

Three of those services connect to [vault](https://www.vaultproject.io/) to retrieve database credentials. The frontend container serves a static file.

The project structure is as follows:

```
.
├── docker-compose.yml
├── form3.crt
├── README.md
├── run.sh
├── Vagrantfile
├── services
│   ├── account
│   ├── gateway
│   └── payment
└── tf
    ├── main.tf # Terraform resources (Vault secrets, users, Docker containers)
    ├── variables.tf # Terraform variables
    ├── outputs.tf # Terraform outputs
    ├── providers.tf # Terraform providers (Docker, Vault)
    ├── environments # Environment-specific tfvars
│      ├── dev.tfvars
│      ├── staging.tfvars
│      └── prod.tfvars
```
## Terraform Environments

| Environment | Vault Container   | Vault Port | Docker Network      | Frontend Port |
| ----------- | ----------------- | ---------- | ------------------- | ------------- |
| Dev         | vault-development | 8201       | vagrant_development | 4080          |
| Staging     | vault-staging     | 8251       | vagrant_staging     | 4085          |
| Prod        | vault-production  | 8301       | vagrant_production  | 4081          |

   Each environment has its own Vault container, Docker network, and frontend port.


## Using an M1 Mac?
If you are using an M1 Mac then you need to install some additional tools:
- [Multipass](https://github.com/canonical/multipass/releases) install the latest release for your operating system
- [Multipass provider for vagrant](https://github.com/Fred78290/vagrant-multipass)
    - [Install the plugin](https://github.com/Fred78290/vagrant-multipass#plugin-installation)
    - [Create the multipass vagrant box](https://github.com/Fred78290/vagrant-multipass#create-multipass-fake-box)

## 👟 Running the sample application
- Make sure you have installed the [vagrant prerequisites](https://learn.hashicorp.com/tutorials/vagrant/getting-started-index#prerequisites)
- In a terminal execute `vagrant up`
- Once the vagrant image has started you should see a successful terraform apply:
```
default: vault_audit.audit_dev: Creation complete after 0s [id=file]
    default: vault_generic_endpoint.account_production: Creation complete after 0s [id=auth/userpass/users/account-production]
    default: vault_generic_secret.gateway_development: Creation complete after 0s [id=secret/development/gateway]
    default: vault_generic_endpoint.gateway_production: Creation complete after 0s [id=auth/userpass/users/gateway-production]
    default: vault_generic_endpoint.payment_production: Creation complete after 0s [id=auth/userpass/users/payment-production]
    default: vault_generic_endpoint.gateway_development: Creation complete after 0s [id=auth/userpass/users/gateway-development]
    default: vault_generic_endpoint.account_development: Creation complete after 0s [id=auth/userpass/users/account-development]
    default: vault_generic_endpoint.payment_development: Creation complete after 1s [id=auth/userpass/users/payment-development]
    default: 
    default: Apply complete! Resources: 30 added, 0 changed, 0 destroyed.
    default: 
    default: ~
```
*Verify the services are running*

- `vagrant ssh`
- `docker ps` should show all containers running:

```
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS          PORTS                                       NAMES
6662939321b3   nginx:latest                         "/docker-entrypoint.…"   3 seconds ago    Up 2 seconds    0.0.0.0:4080->80/tcp                        frontend_development
b7e1a54799b0   nginx:1.22.0-alpine                  "/docker-entrypoint.…"   5 seconds ago    Up 4 seconds    0.0.0.0:4081->80/tcp                        frontend_production
4a636fcd2380   form3tech-oss/platformtest-payment   "/go/bin/payment"        16 seconds ago   Up 9 seconds                                                payment_development
3f609757e28e   form3tech-oss/platformtest-account   "/go/bin/account"        16 seconds ago   Up 12 seconds                                               account_production
cc7f27197275   form3tech-oss/platformtest-account   "/go/bin/account"        16 seconds ago   Up 10 seconds                                               account_development
caffcaf61970   form3tech-oss/platformtest-payment   "/go/bin/payment"        16 seconds ago   Up 8 seconds                                                payment_production
c4b7132104ff   form3tech-oss/platformtest-gateway   "/go/bin/gateway"        16 seconds ago   Up 13 seconds                                               gateway_development
2766640654f3   form3tech-oss/platformtest-gateway   "/go/bin/gateway"        16 seconds ago   Up 11 seconds                                               gateway_production
96e629f21d56   vault:1.8.3                          "docker-entrypoint.s…"   2 minutes ago    Up 2 minutes    0.0.0.0:8301->8200/tcp, :::8301->8200/tcp   vagrant-vault-production-1
a7c0b089b10c   vault:1.8.3                          "docker-entrypoint.s…"   2 minutes ago    Up 2 minutes    0.0.0.0:8201->8200/tcp, :::8201->8200/tcp   vagrant-vault-development-1
```
## Docker Services

| Service  | Description                                                                             |
| -------- | --------------------------------------------------------------------------------------- |
| Vault    | Secret storage for each environment (`dev`, `staging`, `prod`). Tokens match `.tfvars`. |
| Account  | Sample service container storing secrets in Vault                                       |
| Gateway  | Sample service container storing secrets in Vault                                       |
| Payment  | Sample service container storing secrets in Vault                                       |
| Frontend | Nginx container exposing all services per environment                                   |


## Docker Networks:

  * Each environment has a dedicated Docker network (vagrant_development, vagrant_staging, vagrant_production)

  * All service containers are attached to their corresponding network


##  Outputs

  After applying Terraform, check container names:

   terraform output services_containers   # Lists service container names
   terraform output frontend_container    # Shows frontend container name


## Refactored Changes vs Original Form3 README

| Change / Improvement               | Description                                                              |
| ---------------------------------- | ------------------------------------------------------------------------ |
| Multiple Environments              | Added `dev`, `staging`, `prod` environments with separate `.tfvars`.     |
| Vault Integration per Environment  | Each environment now has its own Vault container and root token.         |
| Docker Networks per Environment    | Services attached to dedicated networks for isolation.                   |
| Frontend Container                 | Single Nginx frontend container per environment to expose services.      |
| Terraform Refactor                 | `for_each` loops used for Vault secrets, users, and Docker services.     |
| Automation with `run.sh`           | Builds Docker images, starts Vault, and applies Terraform automatically. |
| Vagrantfile M1 / Multipass support | Detects architecture and provisions VM accordingly.                      |
| Clearer Ports & Config             | Frontend ports and Vault ports defined per environment for clarity.      |
| Easier Maintenance                 | Centralized `.tfvars` and reusable resources for future scalability.     |


## How the Code Fits into a CI/CD Pipeline

 Pipeline Stages:

 | Stage                      | Description                                            | How Your Code Fits                                                         |
| -------------------------- | ------------------------------------------------------ | -------------------------------------------------------------------------- |
| **Checkout**               | Pull latest code                                       | Repository with Terraform, Dockerfiles, `docker-compose.yml`, `.tfvars`    |
| **Build Docker Images**    | Build service images (`account`, `gateway`, `payment`) | Uses `docker build` commands from `run.sh`                                 |
| **Start Vault**            | Launch Vault container for secrets                     | `docker-compose up -d vault-<environment>`                                 |
| **Terraform Apply**        | Deploy secrets, users, and Docker containers           | `terraform init` + `terraform apply -var-file="environments/<env>.tfvars"` |
| **Verify**                 | Check containers and services                          | `docker ps`, Vault secret checks, frontend access                          |
| **Optional Notifications** | Alert on success/failure                               | Slack, email, or Teams notifications                                       |
