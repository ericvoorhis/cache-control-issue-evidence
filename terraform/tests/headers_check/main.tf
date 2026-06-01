# Read-only helper module for the headers.tftest.hcl integration test.
# Contains ONLY data sources, so applying it creates no infrastructure — it just
# reads the cache-control metadata off the already-deployed S3 assets bucket.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.46.0"
    }
  }
}

variable "bucket" {
  description = "The deployed website assets bucket to inspect."
  type        = string
}

variable "key_prefix" {
  description = "OpenNext S3 origin key prefix for assets."
  type        = string
  default     = "nextjs/assets"
}

# Pick any content-hashed JS chunk (the hash varies per build).
data "aws_s3_objects" "chunks" {
  bucket = var.bucket
  prefix = "${var.key_prefix}/_next/static/chunks/"
}

locals {
  chunk_key = [for k in data.aws_s3_objects.chunks.keys : k if endswith(k, ".js")][0]
}

data "aws_s3_object" "chunk" {
  bucket = var.bucket
  key    = local.chunk_key
}

data "aws_s3_object" "build_id" {
  bucket = var.bucket
  key    = "${var.key_prefix}/BUILD_ID"
}

# Normalise an absent Cache-Control to "" so assertions can compare cleanly.
output "chunk_cache_control" {
  value = data.aws_s3_object.chunk.cache_control != null ? data.aws_s3_object.chunk.cache_control : ""
}

output "build_id_cache_control" {
  value = data.aws_s3_object.build_id.cache_control != null ? data.aws_s3_object.build_id.cache_control : ""
}

output "chunk_key" {
  value = local.chunk_key
}
