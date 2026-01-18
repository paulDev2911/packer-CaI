#!/bin/bash
set -e

export SOPS_AGE_KEY_FILE="$HOME/sops/sops-admin-key.txt"

# Secrets
export PROXMOX_URL=$(sops -d secrets/proxmox.enc.yaml | yq '.proxmox_url')
export PROXMOX_NODE=$(sops -d secrets/proxmox.enc.yaml | yq '.proxmox_node')
export PROXMOX_TOKEN_ID=$(sops -d secrets/proxmox.enc.yaml | yq '.proxmox_token_id')
export PROXMOX_TOKEN_SECRET=$(sops -d secrets/proxmox.enc.yaml | yq '.proxmox_token_secret')
export SSH_USER=$(sops -d secrets/proxmox.enc.yaml | yq '.ssh_username')
export SSH_PASS=$(sops -d secrets/proxmox.enc.yaml | yq '.ssh_password')
export PROXMOX_USERNAME=$(sops -d secrets/proxmox.enc.yaml | yq '.proxmox_username')

# Config
export TPL_STORAGE=$(yq '.proxmox.storage.template' config/common.yaml)
export ISO_STORAGE=$(yq '.proxmox.storage.iso' config/common.yaml)
export BRIDGE=$(yq '.proxmox.network.bridge' config/common.yaml)
export CORES=$(yq '.vm_defaults.cores' config/common.yaml)
export MEM=$(yq '.vm_defaults.memory' config/common.yaml)
export DISK=$(yq '.vm_defaults.disk_size' config/common.yaml)
export ISO=$(yq '.debian13.iso.file' config/debian-13.yaml)
export NAME=$(yq '.debian13.variants.base.name' config/debian-13.yaml)
export DESC=$(yq '.debian13.variants.base.description' config/debian-13.yaml)

# Build
packer build \
  -var "proxmox_url=$PROXMOX_URL" \
  -var "proxmox_node=$PROXMOX_NODE" \
  -var "proxmox_username=$PROXMOX_USERNAME" \
  -var "proxmox_token_id=$PROXMOX_TOKEN_ID" \
  -var "proxmox_token_secret=$PROXMOX_TOKEN_SECRET" \
  -var "ssh_username=$SSH_USER" \
  -var "ssh_password=$SSH_PASS" \
  -var "template_storage=$TPL_STORAGE" \
  -var "iso_storage=$ISO_STORAGE" \
  -var "iso_file=$ISO" \
  -var "template_name=$NAME" \
  -var "template_description=$DESC" \
  -var "bridge=$BRIDGE" \
  -var "cores=$CORES" \
  -var "memory=$MEM" \
  -var "disk_size=$DISK" \
  templates/debian13-base.pkr.hcl