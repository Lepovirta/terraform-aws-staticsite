# Static website Terraform module for AWS

Terraform module provides resources for hosting static websites.

## Requirements

* Route 53 hosted zone for hosting the static website DNS records.
* TLS certificate in ACM that covers the site domain and sub domains.
  The certificate must be stored in region `us-east-1` for CloudFront access

## Provides

* S3 backed site file hosting
* CloudFront backed CDN with logs stored in S3
* HTTPS using ACM
* DNS using Route 53
* Optional site wide forwarding to another domain.
