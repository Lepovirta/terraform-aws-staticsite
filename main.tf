# TLS certificate for the domain
data "aws_acm_certificate" "site" {
  provider = "aws.acm"
  domain   = "${var.domain}"
}

# Route 53 zone for the root domain
data "aws_route53_zone" "site" {
  name = "${var.zone_domain}"
}

# Bucket for website files
resource "aws_s3_bucket" "site" {
  acl = "public-read"

  website = ["${var.s3_site_config}"]

  lifecycle_rule {
    enabled = "${var.site_expiration_enabled}"

    expiration {
      days = "${var.site_expiration_days}"
    }
  }

  tags {
    Name        = "${var.name}"
    Domain      = "${var.domain}"
    Environment = "${var.env}"
    Purpose     = "StaticSiteHosting"
  }
}

# Bucket for CloudFront logs
resource "aws_s3_bucket" "logs" {
  acl = "private"

  lifecycle_rule {
    enabled = "${var.log_expiration_enabled}"

    expiration {
      days = "${var.log_expiration_days}"
    }
  }

  tags {
    Name        = "${var.name}"
    Domain      = "${var.domain}"
    Environment = "${var.env}"
    Purpose     = "StaticSiteLogs"
  }
}

# Make the website bucket contents public
resource "aws_s3_bucket_policy" "public_website_bucket" {
  bucket = "${aws_s3_bucket.site.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${aws_s3_bucket.site.arn}/*"
        }
    ]
}
POLICY
}

# Deployment access
resource "aws_iam_policy" "site_deploy" {
  description = "Deployment access for ${var.name} in domain ${var.domain}"
  path        = "${var.policy_path}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:AbortMultipartUpload",
                "s3:DeleteObject",
                "s3:GetObject",
                "s3:GetObjectAcl",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "${aws_s3_bucket.site.arn}",
                "${aws_s3_bucket.site.arn}/*"
            ]
        }
    ]
}
POLICY
}

# Log reader access
resource "aws_iam_policy" "log_reader" {
  description = "Log access for ${var.name} in domain ${var.domain}"
  path        = "${var.policy_path}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject"
            ],
            "Resource": [
                "${aws_s3_bucket.logs.arn}",
                "${aws_s3_bucket.logs.arn}/*"
            ]
        }
    ]
}
POLICY
}

locals {
  fully_qualified_subdomains = "${formatlist("%s.%s", var.subdomains, var.domain)}"
}

# CloudFront distribution for the website
resource "aws_cloudfront_distribution" "site" {
  comment = "CDN for ${var.name} in domain ${var.domain}"
  enabled = true

  aliases = "${concat(list(var.domain), local.fully_qualified_subdomains)}"

  default_root_object = "index.html"
  is_ipv6_enabled     = true
  price_class         = "${var.price_class}"

  origin {
    domain_name = "${aws_s3_bucket.site.website_endpoint}"
    origin_id   = "SiteOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "SiteOrigin"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = "${var.min_ttl}"
    max_ttl                = "${var.max_ttl}"
    default_ttl            = "${var.default_ttl}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = "${data.aws_acm_certificate.site.arn}"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  logging_config {
    bucket          = "${aws_s3_bucket.logs.bucket_domain_name}"
    include_cookies = false
  }

  tags {
    Name        = "${var.name}"
    Domain      = "${var.domain}"
    Environment = "${var.env}"
  }
}

# A record for the main domain
resource "aws_route53_record" "main_a" {
  zone_id = "${data.aws_route53_zone.site.zone_id}"
  name    = "${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.site.domain_name}"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

# AAAA record for the main domain
resource "aws_route53_record" "main_aaaa" {
  zone_id = "${data.aws_route53_zone.site.zone_id}"
  name    = "${var.domain}"
  type    = "AAAA"

  alias {
    name                   = "${aws_cloudfront_distribution.site.domain_name}"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

# A record for the sub domain
resource "aws_route53_record" "sub_a" {
  count   = "${length(var.subdomains)}"
  zone_id = "${data.aws_route53_zone.site.zone_id}"
  name    = "${var.subdomains[count.index]}.${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.site.domain_name}"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

# AAAA record for the sub domain
resource "aws_route53_record" "sub_aaaa" {
  count   = "${length(var.subdomains)}"
  zone_id = "${data.aws_route53_zone.site.zone_id}"
  name    = "${var.subdomains[count.index]}.${var.domain}"
  type    = "AAAA"

  alias {
    name                   = "${aws_cloudfront_distribution.site.domain_name}"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
