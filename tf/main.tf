# -----------------------------
# Vault secrets for services
# -----------------------------
resource "vault_generic_secret" "services" {
  for_each = { for s in var.services : s.name => s }

  path = "secret/${terraform.workspace}/${each.key}"

  data_json = <<EOT
{
  "db_user": "${each.value.name}",
  "db_password": "${each.value.password}"
}
EOT
}

# -----------------------------
# Vault users
# -----------------------------
resource "vault_generic_endpoint" "users" {
  for_each = { for s in var.services : s.name => s }

  depends_on           = [vault_generic_secret.services]
  path                 = "auth/userpass/users/${each.value.username}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["${each.value.name}-${terraform.workspace}"],
  "password": "${each.value.password}"
}
EOT
}

# -----------------------------
# Docker containers for services
# -----------------------------
resource "docker_container" "services" {
  for_each = { for s in var.services : s.name => s }

  image = each.value.image
  name  = "${each.value.name}_${terraform.workspace}"

  env = [
    "VAULT_ADDR=${var.vault_address}",
    "VAULT_USERNAME=${each.value.username}",
    "VAULT_PASSWORD=${each.value.password}",
    "ENVIRONMENT=${terraform.workspace}"
  ]

  networks_advanced {
    name = var.network_name
  }

  lifecycle {
    ignore_changes = all
  }

  depends_on = [vault_generic_endpoint.users]
}

# -----------------------------
# Docker frontend container
# -----------------------------
resource "docker_container" "frontend" {
  image = "docker.io/nginx:latest"
  name  = "frontend_${terraform.workspace}"

  ports {
    internal = 80
    external = var.frontend_port
  }

  networks_advanced {
    name = var.network_name
  }

  lifecycle {
    ignore_changes = all
  }
}
