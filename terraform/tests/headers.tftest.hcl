# Integration test: assert the DEPLOYED S3 cache-control metadata for both
# variants. This is the Terraform-native form of Evidence blocks (2) and (3) in
# ../../REPORT.md.
#
# Prerequisite: the stacks must already be deployed (run `terraform apply`
# first). Each run below uses a read-only helper module, so the test reads the
# live bucket metadata without creating or destroying any infrastructure.
#
#   AWS_PROFILE=<your-test-account-profile> terraform test
#
# Bucket names are deterministic from the module `prefix` values in
# beforefix.tf / afterfix.tf.

run "afterfix_assets_have_correct_cache_control" {
  command = apply

  module {
    source = "./tests/headers_check"
  }

  variables {
    bucket = "cache-control-test-afterfix-website-bucket"
  }

  assert {
    condition     = output.chunk_cache_control == "public,max-age=31536000,immutable"
    error_message = "afterfix: content-hashed _next/static chunk must be immutable, got '${output.chunk_cache_control}'"
  }

  assert {
    condition     = output.build_id_cache_control == "public,max-age=0,s-maxage=31536000,must-revalidate"
    error_message = "afterfix: BUILD_ID must be must-revalidate, got '${output.build_id_cache_control}'"
  }
}

run "beforefix_assets_have_no_cache_control" {
  command = apply

  module {
    source = "./tests/headers_check"
  }

  variables {
    bucket = "cache-control-test-beforefix-website-bucket"
  }

  assert {
    condition     = output.chunk_cache_control == ""
    error_message = "beforefix (the bug): content-hashed chunk should have NO Cache-Control, got '${output.chunk_cache_control}'"
  }

  assert {
    condition     = output.build_id_cache_control == ""
    error_message = "beforefix (the bug): BUILD_ID should have NO Cache-Control, got '${output.build_id_cache_control}'"
  }
}
