output "pipeline_name" {
  value = aws_codepipeline.pipeline.name
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.pipeline_bucket.arn
}