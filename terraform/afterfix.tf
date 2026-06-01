# EXPERIMENTAL deploy — PATCHED FORK with both fixes applied.
# Ships the correct Cache-Control headers:
#   - content-hashed _next/static assets -> public,max-age=31536000,immutable
#   - BUILD_ID and other stable-name files -> public,max-age=0,s-maxage=31536000,must-revalidate
#
# Sourced from the fix branch on the fork (symmetric with beforefix's upstream
# git source) so this test repo is self-contained — no sibling checkout needed.
# Identical to beforefix.tf except `source` (the fix branch) and the marker value.
# No domain_config -> default *.cloudfront.net domain, default cert, no Route53.
module "afterfix" {
  source = "github.com/ericvoorhis/terraform-aws-open-next//modules/tf-aws-open-next-zone?ref=fix/immutable-cache-control-headers"

  prefix            = "cache-control-test-afterfix"
  folder_path       = abspath("${path.module}/../app/.open-next")
  open_next_version = "v3.x.x"

  # Marker so a maintainer can tell the two deploys apart (Lambda env / logs).
  server_function = {
    additional_environment_variables = {
      CACHE_CONTROL_FIX_VARIANT = "afterfix"
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

output "afterfix_bucket_name" {
  description = "S3 assets bucket for the experimental deploy"
  value       = module.afterfix.bucket_name
}

output "afterfix_cloudfront_distribution_id" {
  value = module.afterfix.cloudfront_distribution_id
}

output "afterfix_url" {
  description = "Default *.cloudfront.net URL for the experimental deploy"
  value       = module.afterfix.cloudfront_url
}
