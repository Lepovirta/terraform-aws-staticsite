variable "name" {
  type        = "string"
  description = "Name of the site"
}

variable "zone_domain" {
  type        = "string"
  description = "Zone domain for the website. This is the zone where the DNS records are attached to."
}

variable "domain" {
  type        = "string"
  description = "Domain name for the website"
}

variable "subdomains" {
  type        = "list"
  description = "Subdomains for the website"
  default     = ["www"]
}

variable "s3_site_config" {
  type        = "map"
  description = "S3 website configuration. See aws_s3_bucket.website for documentation."

  default = {
    index_document = "index.html"
  }
}

variable "env" {
  type        = "string"
  description = "Environment the site is used in"
}

variable "site_expiration_enabled" {
  description = "Enable expiration for the site files."
  default     = false
}

variable "log_expiration_enabled" {
  description = "Enable expiration for the log files."
  default     = false
}

variable "site_expiration_days" {
  description = "Number of days after objection creation to consider site file expired"
  default     = 2147483647
}

variable "log_expiration_days" {
  description = "Number of days after objection creation to consider log file expired"
  default     = 2147483647
}

variable "price_class" {
  type        = "string"
  description = "Price class for the CDN"
  default     = "PriceClass_100"
}

variable "min_ttl" {
  description = "Minimum TTL for the CDN"
  default     = 0
}

variable "max_ttl" {
  description = "Maximum TTL for the CDN"
  default     = 86400
}

variable "default_ttl" {
  description = "Default TTL for the CDN"
  default     = 3600
}
