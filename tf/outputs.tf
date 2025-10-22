output "services_containers" {
  value = [for c in docker_container.services : c.name]
}

output "frontend_container" {
  value = docker_container.frontend.name
}
