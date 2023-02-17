variable "project_name" {
  type        = string
  description = "The name of the project."
  default     = ""
}

variable "environment" {
  type        = string
  description = "The environment type."
  default     = ""
}

variable "region" {
  type        = string
  description = "Servers location in Amazon's data centers."
  default     = ""
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance."
  type        = string
  default     = ""
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2."
  default     = "t3.micro"
}

variable "root_volume_size" {
  type        = number
  default     = null
  description = "Instance root volume size in gibibytes (GiB)."
}

variable "root_volume_type" {
  type        = string
  default     = ""
  description = "Instance root volume type."
}

variable "ebs_volume_size" {
  type        = number
  default     = null
  description = "EBS volume size in gibibytes (GiB)."
}

variable "ebs_volume_type" {
  type        = string
  default     = ""
  description = "EBS volume type."
}

variable "user_data_script_name" {
  type        = string
  default     = ""
  description = "Script name in /scripts folder to run on EC2."
}
