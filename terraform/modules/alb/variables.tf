variable "vpc_id" {
  type = string
}

variable "public_sub_ids" {
  type = list(string)
}

variable "name_prefix" {
  description = "Prefix for naming resources, e.g. 'blue' or 'green'"
  type        = string
}
