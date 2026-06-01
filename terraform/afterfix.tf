# EXPERIMENTAL — patched fork branch. Ships the corrected Cache-Control headers.
module "afterfix" {
  source = "github.com/ericvoorhis/terraform-aws-open-next//modules/tf-aws-open-next-zone?ref=fix/immutable-cache-control-headers"

  prefix            = "cache-control-test-afterfix"
  folder_path       = abspath("${path.module}/../app/.open-next")
  open_next_version = "v3.x.x"

  server_function = {
    additional_environment_variables = {
      CACHE_CONTROL_FIX_VARIANT = "afterfix"
    }
  }

  continuous_deployment = {
    use        = false
    deployment = "NONE"
  }

  website_bucket = {
    force_destroy = true
  }

  providers = {
    aws.global          = aws.global
    aws.server_function = aws.server_function
    aws.iam             = aws.iam
    aws.dns             = aws.dns
  }
}

output "afterfix_bucket_name" {
  value = module.afterfix.bucket_name
}

output "afterfix_cloudfront_distribution_id" {
  value = module.afterfix.cloudfront_distribution_id
}

output "afterfix_url" {
  value = module.afterfix.cloudfront_url
}
