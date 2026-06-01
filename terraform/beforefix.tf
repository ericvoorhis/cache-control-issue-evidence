# CONTROL — pristine upstream module (v3.6.2). Ships assets with no Cache-Control.
module "beforefix" {
  source = "github.com/RJPearson94/terraform-aws-open-next//modules/tf-aws-open-next-zone?ref=v3.6.2"

  prefix            = "cache-control-test-beforefix"
  folder_path       = abspath("${path.module}/../app/.open-next")
  open_next_version = "v3.x.x"

  server_function = {
    additional_environment_variables = {
      CACHE_CONTROL_FIX_VARIANT = "beforefix"
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

output "beforefix_bucket_name" {
  value = module.beforefix.bucket_name
}

output "beforefix_cloudfront_distribution_id" {
  value = module.beforefix.cloudfront_distribution_id
}

output "beforefix_url" {
  value = module.beforefix.cloudfront_url
}
