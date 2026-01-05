variable "name" {
  description = "Cluster name (and prefix for related resources)."
  type        = string
}

variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "tags" {
  description = "Base tags applied to all resources."
  type        = map(string)
  default     = {}
}

variable "kubernetes_version" {
  description = "EKS Kubernetes version."
  type        = string
  default     = "1.30"
}

variable "node_ssh_key_name" {
  type        = string
  description = "EC2 key pair name for SSH to worker nodes"
  default     = null
}

variable "node_ssh_source_sgs" {
  type        = list(string)
  description = "Arn of Security Group to match source host IPs on bastion"
  default     = []
}
