services = [
  {
    name     = "account"
    image    = "form3tech-oss/platformtest-account"
    username = "account-development"
    password = "123-account-development"
  },
  {
    name     = "gateway"
    image    = "form3tech-oss/platformtest-gateway"
    username = "gateway-development"
    password = "123-gateway-development"
  },
  {
    name     = "payment"
    image    = "form3tech-oss/platformtest-payment"
    username = "payment-development"
    password = "123-payment-development"
  }
]

frontend_port = 4080
network_name  = "vagrant_development"
vault_address = "http://localhost:8201"
vault_token   = "f23612cf-824d-4206-9e94-e31a6dc8ee8d"
