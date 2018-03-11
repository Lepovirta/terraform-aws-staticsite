provider "aws" {
  region = "us-east-1"
  alias  = "acm"
}

variable "zone_domain" {
  type        = "string"
  description = "Zone domain for the website"
}

variable "domain" {
  type        = "string"
  description = "Domain for the website"
}

variable "redirect_domain" {
  type        = "string"
  description = "Domain to redirect to"
}

module "redirect_site" {
  source                 = "../../"
  name                   = "myredirectsite"
  zone_domain            = "${var.zone_domain}"
  domain                 = "${var.domain}"
  subdomains             = []
  env                    = "test"
  log_expiration_enabled = true
  log_expiration_days    = 10

  s3_site_config = {
    redirect_all_requests_to = "${var.redirect_domain}"
  }
}
