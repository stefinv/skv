services = [
  {
    name     = "account"
    image    = "form3tech-oss/platformtest-account"
    username = "account-staging"
    password = "123-account-staging"
  },
  {
    name     = "gateway"
    image    = "form3tech-oss/platformtest-gateway"
    username = "gateway-staging"
    password = "123-gateway-staging"
  },
  {
    name     = "payment"
    image    = "form3tech-oss/platformtest-payment"
    username = "payment-staging"
    password = "123-payment-staging"
  }
]

frontend_port = 4085
network_name  = "vagrant_staging"
vault_address = "http://localhost:8251"
vault_token   = "staging-token"
