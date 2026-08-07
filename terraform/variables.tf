variable "cidr_block" {

}

variable "public_subnet1_cidr" {

}

variable "public_subnet2_cidr" {

}

variable "private_subnet1_cidr" {

}

variable "private_subnet2_cidr" {

}

variable "db_subnet1_cidr" {

}

variable "db_subnet2_cidr" {

}

variable "key_name" {

}

variable "sonarqube_token" {
  
}

variable "my_ip" {
  
}

variable "SONAR_HOST_URL" {
  
}

variable "alert_email" {
  
}

variable "domain_name" {
  description = "The root domain name (e.g. yourdomain.com)"
  type        = string
}

variable "record_name" {
  description = "The subdomain/record to create (e.g. app.yourdomain.com)"
  type        = string
}

variable "hosted_zone_id" {
}