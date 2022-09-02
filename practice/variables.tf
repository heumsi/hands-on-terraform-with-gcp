variable "project" {
  type        = string
  description = "gcp project id"
  default     = "storied-channel-359115"

}

variable "credentials_file" {
  type        = string
  description = "gcp serviceaccount used by terraform json file path"
}

variable "gce_ssh_pub_key_file" {
  type        = string
  description = "gce public key used by ssh file path "
}