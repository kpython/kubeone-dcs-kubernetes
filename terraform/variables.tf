/*
Copyright 2022 The KubeOne Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

# vCloud Director provider configuration
variable "vcd_url" {
  description = "URL of the vCloud Director setup"
  default     = "https://vcd-pod-bravo.swisscomcloud.com/api"
  type        = string
}

# VMware Cloud Director credentials
variable "vcd_user" {
  description = "Username for the VMware Cloud Director access"
  type        = string
}

variable "vcd_password" {
  description = "Password for the VMware Cloud Director access"
  type        = string
}

# VMware Cloud Director tenant configuration
variable "vcd_org" {
  description = "Organization name for the VMware Cloud Director setup"
  type        = string
}

variable "vcd_vdc" {
  description = "Virtual datacenter name"
  type        = string
}

variable "vcd_edge_gateway_name" {
  description = "Name of the Edge Gateway"
  type        = string
}

variable "vcd_allow_insecure" {
  description = "Allow insecure https connection to VMware Cloud Director API"
  default     = false
  type        = bool
}

variable "vcd_logging_enabled" {
  description = "Log VMware Cloud Director API activites to go-vcloud-director.log"
  default     = false
  type        = bool
}

# Cluster specific configuration
variable "cluster_name" {
  description = "Name of the cluster"
  default     = "kubeone"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*$", var.cluster_name))
    error_message = "Value of cluster_name should be lowercase and can only contain alphanumeric characters and hyphens(-)."
  }
}

variable "cluster_hostname" {
  description = "DNS hostname for the Kubernetes cluster"
  default     = ""
  type        = string
}

variable "ssh_public_key_file" {
  description = "SSH public key file"
  default     = "../ssh_key_id_rsa.pub"
  type        = string
}

variable "ssh_port" {
  description = "SSH port to be used to provision instances"
  default     = 22
  type        = number
}

variable "ssh_username" {
  description = "SSH user, used only in output"
  default     = "ubuntu"
  type        = string
}

variable "ssh_private_key_file" {
  description = "SSH private key file used to access instances"
  default     = "ssh_key_id_rsa"
  type        = string
}

variable "ssh_agent_socket" {
  description = "SSH Agent socket, default to grab from $SSH_AUTH_SOCK"
  default     = "env:SSH_AUTH_SOCK"
  type        = string
}

variable "ssh_hosts_keys" {
  default     = null
  description = "A list of SSH hosts public keys to verify"
  type        = list(string)
}

variable "ssh_bastion_port" {
  description = "Bastion SH port"
  default     = 2222
  type        = number
}

variable "ssh_bastion_username" {
  description = "Bastion SSH user"
  default     = "ubuntu"
  type        = string
}

variable "bastion_host_key" {
  description = "Bastion SSH host public key"
  default     = null
  type        = string
}

variable "catalog_name" {
  description = "Name of catalog that contains vApp templates"
  default     = "KubeOne"
  type        = string
}

variable "template_name" {
  description = "Name of the vApp template to use"
  default     = "Ubuntu 22.04 Server"
  type        = string
}

variable "os_image_url" {
  description = "URL of the OS image to upload"
  default     = "https://dcs-kubernetes.scapp.swisscom.com/ubuntu-22.04-server-cloudimg-amd64.ovf"
  type        = string
}

variable "control_plane_vm_count" {
  description = "number of control plane instances"
  default     = 3
  type        = number
}

variable "control_plane_memory" {
  description = "Memory size of each control plane node in MB"
  default     = 4096
  type        = number
}

variable "control_plane_cpus" {
  description = "Number of CPUs for the control plane VMs"
  default     = 2
  type        = number
}

variable "control_plane_cpu_cores" {
  description = "Number of cores per socket for the control plane VMs"
  default     = 1
  type        = number
}

variable "control_plane_disk_size_mb" {
  description = "Disk size in MB"
  default     = 51200
  type        = number
}

variable "control_plane_disk_storage_profile" {
  description = "Name of storage profile to use for disks"
  default     = ""
  type        = string
}

variable "network_interface_type" {
  description = "Type of interface for the routed network"
  # For NSX-T internal is the only supported value
  default = "internal"
  type    = string
  validation {
    condition     = can(regex("^internal$|^subinterface$|^distributed$", var.network_interface_type))
    error_message = "Invalid network interface type."
  }
}

variable "gateway_ip" {
  description = "Gateway IP for the routed network"
  default     = "192.168.1.1"
  type        = string
}

variable "dhcp_start_address" {
  description = "Starting address for the DHCP IP Pool range"
  default     = "192.168.1.50"
  type        = string

  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.dhcp_start_address))
    error_message = "Invalid DHCP start address."
  }
}

variable "dhcp_end_address" {
  description = "Last address for the DHCP IP Pool range"
  default     = "192.168.1.150"
  type        = string
  validation {
    condition     = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.dhcp_end_address))
    error_message = "Invalid DHCP end address."
  }
}

variable "network_dns_server_1" {
  description = "Primary DNS server for the routed network"
  default     = "1.1.1.1"
  type        = string
  validation {
    condition     = length(var.network_dns_server_1) == 0 || can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.network_dns_server_1))
    error_message = "Invalid DNS server provided."
  }
}

variable "network_dns_server_2" {
  description = "Secondary DNS server for the routed network."
  default     = "8.8.8.8"
  type        = string
  validation {
    condition     = length(var.network_dns_server_2) == 0 || can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.network_dns_server_2))
    error_message = "Invalid DNS server provided."
  }
}

variable "external_network_name" {
  description = "Name of the external network to be used to send traffic to the external networks. Defaults to edge gateway's default external network."
  default     = ""
  type        = string
}

variable "external_network_ip" {
  default = ""
  type    = string
  validation {
    condition     = length(var.external_network_ip) == 0 || can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", var.external_network_ip))
    error_message = "Invalid extenral network IP provided."
  }
  description = <<EOF
IP address to which source addresses (the virtual machines) on outbound packets are translated to when they send traffic to the external network.
Defaults to default external network IP for the edge gateway.
EOF
}

variable "initial_machinedeployment_replicas" {
  default     = 3
  description = "number of replicas per MachineDeployment"
  type        = number
}

variable "cluster_autoscaler_min_replicas" {
  default     = 3
  description = "minimum number of replicas per MachineDeployment (requires cluster-autoscaler)"
  type        = number
}

variable "cluster_autoscaler_max_replicas" {
  default     = 5
  description = "maximum number of replicas per MachineDeployment (requires cluster-autoscaler)"
  type        = number
}

variable "worker_os" {
  description = "OS to run on worker machines"
  default     = "ubuntu"
  type        = string
  validation {
    condition     = can(regex("^ubuntu$|^flatcar$", var.worker_os))
    error_message = "Unsupported OS specified for worker machines."
  }
}
variable "worker_memory" {
  description = "Memory size of each worker VM in MB"
  default     = 8192
  type        = number
}

variable "worker_cpus" {
  description = "Number of CPUs for the worker VMs"
  default     = 4
  type        = number
}

variable "worker_cpu_cores" {
  description = "Number of cores per socket for the worker VMs"
  default     = 1
  type        = number
}

variable "worker_disk_size_gb" {
  description = "Disk size for worker VMs in GB"
  default     = 250
  type        = number
}

variable "worker_disk_storage_profile" {
  description = "Name of storage profile to use for worker VMs attached disks"
  default     = "*"
  type        = string
}

variable "initial_machinedeployment_operating_system_profile" {
  default     = "osp-ubuntu"
  type        = string
  description = <<EOF
Name of operating system profile for MachineDeployments, only applicable if operating-system-manager addon is enabled.
If not specified, the default value will be added by machine-controller addon.
EOF
}
