# Plugin_section
packer {
  required_plugins {
    qemu = {
      version = ">=1.0.9"
      source  = "github.com/hashicorp/qemu"
    }
    ansible = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}
# Variables_section

variable "ubuntu_version" {
  type    = string
  default = "22.04"
}

variable "iso_file_name" {
  type = string
  #default = "ubuntu-22.04.3-live-server-amd64.iso"
  default = "jammy-server-cloudimg-amd64.img"
}

variable "iso_website_url" {
  type = string
  #default = "https://releases.ubuntu.com"
  default = "https://cloud-images.ubuntu.com/jammy/current"
}


variable "vm_template_name" {
  type    = string
  default = "packer_test_vm_temp"
}
locals {
  ssh_username      = "ubuntu"
  ssh_password      = "test"
  vm_name           = "${var.vm_template_name}-${var.ubuntu_version}"
  iso_checksum_file = "file:${var.iso_website_url}/SHA256SUMS"
  PACKER_LOG        = 1
  PACKER_LOG_PATH   = "/var/log/packer.log"
  http_directory    = "http"
}
source "qemu" "test_source" {
  vm_name      = "${local.vm_name}.qcow2"
  iso_url      = "${var.iso_website_url}/${var.iso_file_name}"
  iso_checksum = "${local.iso_checksum_file}"
  #qemuargs         = [["-cdrom", "cidata.iso"]]
  qemuargs = [["-cdrom", "cloud-test-temp-seed.qcow2"]]
  #qemuargs         = [["-m", "12G"], ["-smp", "8"], ["-drive", "if=virtio,format=raw,file=cloud-test-temp-seed.iso"], ["-serial", "mon:stdio"]]
  cpus             = 4
  memory           = 4096
  disk_compression = true
  accelerator      = "kvm"
  disk_size        = "3G"
  output_directory = "output_of_test_source"
  format           = "qcow2"
  ssh_username     = "${local.ssh_username}"
  ssh_password     = "${local.ssh_password}"
  ssh_timeout      = "5m"
  disk_image       = true
  headless         = false
}

build {
  sources = ["source.qemu.test_source"]
  #provisioner "shell" {
  #  inline = [
  #    "sudo rm -rf /etc/netplan/*"
  #  ]
  #}
  #provisioner "file" {
  #  source      = "netplan-file/00-installer-config.yaml"
  #  destination = "/home/ubuntu/00-installer-config.yaml"
  #}
  provisioner "shell" {
    inline = [
      #"sudo  cp /tmp/00-installer-config.yaml /etc/netplan/00-installer-config.yaml",
      #"sudo chmod 600 /etc/netplan/00-installer-config.yaml"
      "sleep 60",
      "sudo rm -f /etc/netplan/50-cloud-init.conf"
    ]
  }
  #provisioner "ansible" {
  #    playbook_file = "ansible/playbook.yaml"
  #    user = "ubuntu"
  #    inventory_file_template = "controller ansible_host={{ .Host }} ansible_user={{ .User }} ansible_port={{ .Port }}\n"
  #    #extra_arguments = local.extra_args
  #    extra_arguments = [ 
  #      "-vvvv",
  #      "--become-method=sudo"
  #      #"--connection=chroot"
  #    ]
 #}
 post-processor "shell-local" {
     inline = [
       "mv output_of_test_source/packer_test_vm_temp-22.04.qcow2 /var/lib/libvirt/images/packer-test.qcow2",
       "virt-install --virt-type=kvm --name packer-test --vcpus 2 --ram 4096 --os-variant=ubuntu22.04 --disk path=/var/lib/libvirt/images/packer-test.qcow2 --network=default --graphics=vnc --noautoconsole --import"
     ]
 }
}