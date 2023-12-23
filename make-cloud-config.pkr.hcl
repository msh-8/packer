source "file" "user_data" {
  content = <<EOF
#cloud-config
ssh_pwauth: True
users:
  - name: user
    plain_text_passwd: packer
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: false
EOF
  target  = "user-data.yaml"
}

source "file" "meta_data" {
  content = <<EOF
{"instance-id":"packer-worker.tenant-local","local-hostname":"packer-worker"}
EOF
  target  = "meta-data.yaml"
}

build {
  sources = ["sources.file.user_data", "sources.file.meta_data"]

  provisioner "shell-local" {
    inline = ["cloud-localds -v cloud-test-temp-seed.iso user-data.yaml meta-data.yaml"]
  }
}
