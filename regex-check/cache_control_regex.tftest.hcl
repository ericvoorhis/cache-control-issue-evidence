# Deploy-free proof of the cache_control_immutable_assets_regex behaviour, using
# the SAME regex engine the module uses (regexall). No AWS, no providers.
#
#   cd test-repo/regex-check && terraform init && terraform test
#
# This is the Terraform-native form of Evidence block (1) in ../../REPORT.md.

# The shipped regex marks content-hashed _next/static assets immutable (incl.
# under a basePath) and excludes stable-URL files like BUILD_ID and favicon.ico.
run "immutable_regex_classifies_assets_correctly" {
  command = plan

  assert {
    condition     = length(regexall(var.immutable_assets_regex, "_next/static/chunks/46598acfa87bc38a.js")) > 0
    error_message = "content-hashed JS chunk should be marked immutable"
  }
  assert {
    condition     = length(regexall(var.immutable_assets_regex, "_next/static/chunks/2c128e3738dd017d.css")) > 0
    error_message = "content-hashed CSS should be marked immutable"
  }
  assert {
    condition     = length(regexall(var.immutable_assets_regex, "_next/static/iWqOTcPImW8OiJ0EscjWg/_buildManifest.js")) > 0
    error_message = "build-id-pathed manifest should be marked immutable"
  }
  assert {
    condition     = length(regexall(var.immutable_assets_regex, "docs/_next/static/chunks/46598acfa87bc38a.js")) > 0
    error_message = "basePath-prefixed _next/static asset should still match"
  }
  assert {
    condition     = length(regexall(var.immutable_assets_regex, "BUILD_ID")) == 0
    error_message = "BUILD_ID must NOT be immutable (stable URL, content changes every deploy)"
  }
  assert {
    condition     = length(regexall(var.immutable_assets_regex, "favicon.ico")) == 0
    error_message = "favicon.ico must NOT be immutable (stable URL)"
  }
  assert {
    condition     = length(regexall(var.immutable_assets_regex, "docs/BUILD_ID")) == 0
    error_message = "basePath-prefixed BUILD_ID must still be excluded"
  }
  assert {
    condition     = length(regexall(var.immutable_assets_regex, "foo_next/static/x.js")) == 0
    error_message = "a segment merely ending in _next must NOT be over-matched"
  }
}
