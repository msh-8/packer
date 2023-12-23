# Plugin_section
packer {
  required_plugins {
    libvirt = {
      version = ">= 0.5.0"
      source  = "github.com/thomasklein94/libvirt"
    }
  }
}
# Variables_section

variable "ubuntu_version" {
  type    = string
  default = "22.04"
}

variable "iso_file_name" {
  type    = string
  default = "ubuntu-22.04.3-live-server-amd64.iso"
}

variable "iso_website_url" {
  type    = string
  default = "https://releases.ubuntu.com"
}


variable "vm_template_name" {
  type    = string
  default = "packer_test_vm_temp"
}
locals {
  ssh_username      = "ubuntu"
  ssh_password      = "test"
  vm_name           = "4{var.vm_template_name}-${var.ubuntu_version}"
  iso_checksum_file = "file:${var.iso_website_url}/${var.ubuntu_version}/SHA256SUMS"
  PACKER_LOG        = 1
  PACKER_LOG_PATH   = "/var/log/packer.log"
  http_directory    = "http"
}
source "libvirt" "test_source" {
  libvirt_uri = "qemu:///system"
  #vm_name      = "${local.vm_name}"
  #iso_url      = "${var.iso_website_url}/${var.ubuntu_version}/${var.iso_file_name}"
  #iso_checksum = "${local.iso_checksum_file}"
  # Location of user-data and meta-data file
  #http_directory = "${local.http_directory}"
  #boot_wait      = "5s"
  vcpu           = 4
  memory         = 4096
  #accelerator    = "kvm"
  #disk_size      = "6G"
  boot_command   = [
   "<spacebar><wait><spacebar><wait><spacebar>",
   "e<wait><down><down><down><end>",
   "<spacebar><wait>autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/","<f10>"]
  #boot_command = ["e<down><down><down><end>", "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/", "<F10>"]
 # cd_files = ["./${local.http_directory}/meta-data",
 # "./${local.http_directory}/user-data"]
 # cd_label     = "cidata"
  #ssh_username = "${local.ssh_username}"
  #ssh_password = "${local.ssh_password}"
  #ssh_timeout  = "20m"
  #headless     = false
}

build {
  sources = ["source.libvirt.test_source"]
}
