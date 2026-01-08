output "webserver-ips" {
  value       = [for instance in google_compute_instance.web-instances : instance.network_interface[0].network_ip]
  description = "List of network IP addresses assigned to the deployed web server instances."
}