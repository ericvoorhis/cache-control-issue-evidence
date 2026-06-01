# CONTROL deploy — pristine UPSTREAM module, pinned to the released tag the fork
# was branched from (v3.6.2). Reproduces the broken behaviour: no Cache-Control
# header on any S3 asset.
#
# No domain_config -> the module serves on the default *.cloudfront.net domain
# with the default CloudFront cert and creates no Route53 records. Keep this
# block as close to afterfix.tf as possible — the ONLY meaningful difference
# should be the `source`, so the header contrast is attributable to the patch.
module "beforefix" {
  source = "github.com/RJPearson94/terraform-aws-open-next//modules/tf-aws-open-next-zone?ref=v3.6.2"

  prefix            = "cache-control-test-beforefix"
  folder_path       = abspath("${path.module}/../app/.open-next")
  open_next_version = "v3.x.x"

  # Marker so a maintainer can tell the two deploys apart (Lambda env / logs).
  server_function = {
    additional_environment_variables = {
      CACHE_CONTROL_FIX_VARIANT = "beforefix"
    }
  }

  # Simple single distribution that invalidates CloudFront on every apply.
  # The default (use=true) is continuous-deployment mode, where a plain apply
  # does NOT create the invalidation resource — you'd invalidate via the
  # staging -> PROMOTE flow instead. use=false is what we want for a test repo.
  continuous_deployment = {
    use        = false
    deployment = "NONE"
  }

  providers = {
    aws.global          = aws.global
    aws.server_function = aws.server_function
    aws.iam             = aws.iam
    aws.dns             = aws.dns
  }
}

output "beforefix_bucket_name" {
  description = "S3 assets bucket for the control deploy"
  value       = module.beforefix.bucket_name
}

output "beforefix_cloudfront_distribution_id" {
  value = module.beforefix.cloudfront_distribution_id
}

output "beforefix_url" {
  description = "Default *.cloudfront.net URL for the control deploy"
  value       = module.beforefix.cloudfront_url
}
