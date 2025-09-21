#cloud-config
packages:
  - snapd
  - curl
  - apt-transport-https
  - ca-certificates
  - gnupg
  - net-tools
  - arping

write_files:
  - path: /etc/netplan/60-additional-ip.yaml
    content: |
      network:
        version: 2
        ethernets:
          eth0:
            addresses:
              - ${reserved_ip}/32

runcmd:
  - netplan apply
  - snap install microk8s --classic
  - snap install helm --classic
  - microk8s status --wait-ready
  - |
      ufw default allow routed
  - microk8s enable dns ingress hostpath-storage
  - microk8s config > ${kubeconfig_path}
  - echo "ok" > /var/lib/cloud/instance/user-data.success
