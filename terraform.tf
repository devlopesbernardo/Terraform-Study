terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Set the variable value in *.tfvars file
# or using -var="do_token=..." CLI option
variable "do_token" {}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Pick the amount of instances
variable "instance_count" {
  default = "2"
}

# Create a web server
resource "digitalocean_droplet" "worker" {
  count = var.instance_count
  image  = "debian-10-x64"
  name   = "worker-${count.index}"
  region = "nyc1"
  size   = "s-2vcpu-2gb-amd"
  ssh_keys = ["31016426","31016927"]
  tags  = ["kubernetes"]

  provisioner "local-exec" {
    command = "echo ${self.ipv4_address} >> ./ansible/inventory.txt"
  }
  provisioner "local-exec" {
    command = "sleep 15"
  }
    provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --user root -i ${self.ipv4_address}, ansible/playbooks/docker.yml"
  }
}

# Create the cluster admin
resource "digitalocean_droplet" "master" {
  image  = "debian-10-x64"
  name   = "master"
  region = "nyc1"
  size   = "s-2vcpu-2gb-amd"
  ssh_keys = ["31016426","31016927"]
  tags  = ["kubernetes"]

  provisioner "local-exec" {
    command = "echo [master] >> ./ansible/inventory-master.txt && echo ${self.ipv4_address} >> ./ansible/inventory-master.txt"
  }
    provisioner "local-exec" {
    command = "echo [master] >> ./ansible/inventory.txt && echo ${self.ipv4_address} >> ./ansible/inventory.txt"
  }
  provisioner "local-exec" {
    command = "sleep 15"
  }
    provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --user root -i ${self.ipv4_address}, ansible/playbooks/docker.yml"
  }

      provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --user root -i './ansible/inventory-master.txt' ansible/playbooks/master.yaml"
  }
}


# Grab the IPs from the machines
output "ip-0" {
    value = "${digitalocean_droplet.worker[0].ipv4_address}"
}

output "ip-1" {
    value = "${digitalocean_droplet.worker[1].ipv4_address}"
}

output "ip-2" {
    value = "${digitalocean_droplet.master.ipv4_address}"
}



