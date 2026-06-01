# Credentials are taken from the standard AWS resolution chain (environment,
# AWS_PROFILE, shared config, etc.) — intentionally NOT pinned to a named
# profile here, so a maintainer can reproduce this with their own credentials:
#
#   AWS_PROFILE=<your-profile> terraform plan
#
# All providers target the same account directly (no cross-account assume_role).
# The zone module REQUIRES all four aliases
# (configuration_aliases = [aws.server_function, aws.iam, aws.dns, aws.global]),
# so each is defined and passed.

provider "aws" {
  region = "us-west-2"
}

# us-east-1 — CloudFront / Lambda@Edge global resources must live here.
provider "aws" {
  alias  = "global"
  region = "us-east-1"
}

# Regional functions (server / image-opt / revalidation / warmer lambdas).
provider "aws" {
  alias  = "server_function"
  region = "us-west-2"
}

# IAM is a global service; region is immaterial.
provider "aws" {
  alias  = "iam"
  region = "us-west-2"
}

# Route53 records. Zone is in the same account, so this is just a regional
# provider (would be a cross-account assume_role if the zone lived elsewhere).
provider "aws" {
  alias  = "dns"
  region = "us-west-2"
}
