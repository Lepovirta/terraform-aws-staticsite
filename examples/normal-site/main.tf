provider "aws" {
  region = "us-east-1"
  alias  = "acm"
}

variable "domain" {
  type        = "string"
  description = "Domain for the website"
}

module "normal_site" {
  source                 = "../../"
  name                   = "myexamplesite"
  zone_domain            = "${var.domain}"
  domain                 = "${var.domain}"
  subdomains             = ["www"]
  env                    = "test"
  log_expiration_enabled = true
  log_expiration_days    = 10
}
