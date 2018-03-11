output "site_bucket" {
  description = "Name of the bucket where all the website files are stored"
  value       = "${aws_s3_bucket.site.id}"
}

output "logs_bucket" {
  description = "Name of the bucket where all the request logs are stored"
  value       = "${aws_s3_bucket.logs.id}"
}

output "site_deploy_policy_id" {
  description = "Policy ID for deploying the website"
  value       = "${aws_iam_policy.site_deploy.id}"
}

output "log_reader_policy_id" {
  description = "Policy ID for reading logs"
  value       = "${aws_iam_policy.log_reader.id}"
}
