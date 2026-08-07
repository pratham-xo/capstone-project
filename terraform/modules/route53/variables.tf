variable "domain_name" {
  description = "The root domain name (e.g. yourdomain.com)"
  type        = string
}

variable "record_name" {
  description = "The subdomain/record to create (e.g. app.yourdomain.com)"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the currently 'prod' ALB (blue or green) to alias to"
  type        = string
}

variable "alb_zone_id" {
  description = "Hosted zone ID of the currently 'prod' ALB"
  type        = string
}