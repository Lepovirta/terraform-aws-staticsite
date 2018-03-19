output "site_bucket" {
  description = "Name of the bucket where all the website files are stored"
  value       = "${aws_s3_bucket.site.id}"
}

output "logs_bucket" {
  description = "Name of the bucket where all the request logs are stored"
  value       = "${aws_s3_bucket.logs.id}"
}

output "site_deploy_policy" {
  description = "Policy ARN for deploying the website"
  value       = "${aws_iam_policy.site_deploy.arn}"
}

output "log_reader_policy" {
  description = "Policy ARN for reading logs"
  value       = "${aws_iam_policy.log_reader.arn}"
}
