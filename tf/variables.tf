variable "services" {
  description = "List of services to deploy"
  type = list(object({
    name     = string
    image    = string
    username = string
    password = string
  }))
}

variable "frontend_port" {
  description = "Port for the frontend container"
  type        = number
}

variable "network_name" {
  description = "Docker network name for the environment"
  type        = string
}

variable "vault_address" {
  description = "Vault server address"
  type        = string
}

variable "vault_token" {
  description = "Vault authentication token"
  type        = string
}
