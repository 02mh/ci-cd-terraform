### OUTPUTS
output "nginx-public-ip" {
  value       = google_compute_instance.nginx_instance.network_interface[0].access_config[0].nat_ip
  description = "The public IP address of the NGINX instance."
}

output "webserver-ips" {
  value       = module.webservers.webserver-ips
  description = "The IP addresses of all webserver instances created by the webserver module."
}

output "db-private-ip" {
  value       = google_compute_instance.mysqldb.network_interface[0].network_ip
  description = "The private internal IP address of the MySQL database instance."
}