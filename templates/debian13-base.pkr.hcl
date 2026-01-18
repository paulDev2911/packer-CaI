packer {
  required_plugins {
    proxmox = {
      version = ">= 1.1.8"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variables - werden aus YAML geladen
variable "proxmox_url" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_username" {
  type = string
}

variable "proxmox_token_id" {
  type = string
}

variable "proxmox_token_secret" {
  type      = string
  sensitive = true
}

variable "ssh_username" {
  type = string
}

variable "ssh_password" {
  type      = string
  sensitive = true
}

variable "template_storage" {
  type = string
}

variable "iso_storage" {
  type = string
}

variable "iso_file" {
  type = string
}

variable "template_name" {
  type = string
}

variable "template_description" {
  type = string
}

variable "bridge" {
  type = string
}

variable "cores" {
  type = number
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type = string
}

source "proxmox-iso" "debian13-base" {
  # Proxmox connection
  proxmox_url = var.proxmox_url
  node        = var.proxmox_node
  username    = var.proxmox_username
  token       = "${var.proxmox_token_id}=${var.proxmox_token_secret}"
  
  insecure_skip_tls_verify = true
  
  # Template settings
  vm_name              = var.template_name
  template_description = var.template_description
  
  # ISO
  iso_file     = "${var.iso_storage}:iso/${var.iso_file}"
  unmount_iso  = true
  
  # Hardware
  cores   = var.cores
  memory  = var.memory
  sockets = 1
  
  network_adapters {
    bridge = var.bridge
    model  = "virtio"
  }
  
  disks {
    type         = "scsi"
    disk_size    = var.disk_size
    storage_pool = var.template_storage
    format       = "raw"
  }
  
  scsi_controller = "virtio-scsi-single"
  
  # Boot command - Preseed
  boot_command = [
    "<esc><wait>",
    "auto url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian/preseed.cfg<enter>"
  ]
  boot_wait = "10s"
  http_directory = "http"
  
  # SSH for provisioning
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout  = "20m"
  
  # Cloud-Init prep
  cloud_init              = true
  cloud_init_storage_pool = var.template_storage
}

build {
  sources = ["source.proxmox-iso.debian13-base"]
  
  # Basic setup
  provisioner "shell" {
    inline = [
      "echo '=== Basic System Setup ==='",
      "systemctl enable qemu-guest-agent",
      "systemctl enable ssh",
    ]
  }
  
  # Cleanup
  provisioner "shell" {
    inline = [
      "echo '=== Cleanup ==='",
      "apt-get clean",
      "rm -rf /tmp/*",
      "rm -rf /var/tmp/*",
      "history -c",
    ]
  }
}