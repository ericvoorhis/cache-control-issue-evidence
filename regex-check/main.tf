# Minimal, provider-less config so `terraform test` can evaluate the
# immutable-assets regex in isolation — no AWS, no deploy. This mirrors the
# default shipped by terraform-aws-open-next's `cache_control_immutable_assets_regex`
# and is the deploy-free proof of Bug 2 / the fix (Evidence block 1 in REPORT.md).

variable "immutable_assets_regex" {
  description = "The shipped immutable-assets regex (matches the patched module default)."
  type        = string
  default     = "^(?:.*/)?_next/static/.*$"
}

# Representative asset paths, RELATIVE to .open-next/assets (how the module sees
# them — no leading slash). Hashes are illustrative; only the path SHAPE matters.
variable "sample_paths" {
  description = "Representative OpenNext asset paths to classify."
  type        = list(string)
  default = [
    "_next/static/chunks/46598acfa87bc38a.js",              # content-hashed JS
    "_next/static/chunks/2c128e3738dd017d.css",             # content-hashed CSS
    "_next/static/iWqOTcPImW8OiJ0EscjWg/_buildManifest.js", # build-id-pathed
    "_next/static/media/4fa387ec64143e14-s.c36e1862.woff2", # hashed font
    "docs/_next/static/chunks/46598acfa87bc38a.js",         # basePath-prefixed
    "BUILD_ID",                                             # stable URL, mutable content
    "favicon.ico",                                          # stable URL
    "robots.txt",                                           # stable URL
    "docs/BUILD_ID",                                        # basePath, still stable
    "foo_next/static/x.js",                                 # decoy: NOT a _next segment
  ]
}

output "immutable" {
  description = "Paths that match the regex -> public,max-age=31536000,immutable"
  value       = [for p in var.sample_paths : p if length(regexall(var.immutable_assets_regex, p)) > 0]
}

output "must_revalidate" {
  description = "Paths that do NOT match -> public,max-age=0,s-maxage=31536000,must-revalidate"
  value       = [for p in var.sample_paths : p if length(regexall(var.immutable_assets_regex, p)) == 0]
}
