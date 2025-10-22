services = [
  {
    name     = "account"
    image    = "form3tech-oss/platformtest-account"
    username = "account-production"
    password = "123-account-production"
  },
  {
    name     = "gateway"
    image    = "form3tech-oss/platformtest-gateway"
    username = "gateway-production"
    password = "123-gateway-production"
  },
  {
    name     = "payment"
    image    = "form3tech-oss/platformtest-payment"
    username = "payment-production"
    password = "123-payment-production"
  }
]

frontend_port = 4081
network_name  = "vagrant_production"
vault_address = "http://localhost:8301"
vault_token   = "083672fc-4471-4ec4-9b59-a285e463a973"
