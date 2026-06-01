# Regex reproduction — `cache_control_immutable_assets_regex`

A standalone, **deploy-free** proof of the regex half of the
`terraform-aws-open-next` Cache-Control fix (Bug 2), written as a native
`terraform test`. It evaluates the shipped regex with the **same engine the
module uses** (`regexall`) — no AWS, no providers, ~1 second.

## What it proves

The module decides each file's `Cache-Control` with:

```hcl
cache_control = length(regexall(var.cache_control_immutable_assets_regex, file)) > 0
  ? "public,max-age=31536000,immutable"        # immutable branch
  : "public,max-age=0,s-maxage=31536000,must-revalidate"
```

`file` is the path **relative to `.open-next/assets/`** (e.g.
`_next/static/chunks/<hash>.js`, `BUILD_ID`) — note: **no leading slash**.

`cache_control_regex.tftest.hcl` asserts the shipped default
`^(?:.*/)?_next/static/.*$`:

- **matches** content-hashed assets — `_next/static/chunks/*.js`, `*.css`, the
  build-id-pathed `_buildManifest.js`, and the same **under any `basePath`**
  (`docs/_next/static/...`);
- **excludes** stable-URL files — `BUILD_ID`, `favicon.ico` (and `docs/BUILD_ID`);
- does **not** over-match a segment merely ending in `_next` (`foo_next/static/...`).

## Why `_next/static` is safe to mark `immutable`

`immutable` is interpreted by the **browser** (serve from local cache without
revalidating for the full `max-age`), so it's only safe when the **URL changes
with the content**. Everything under `_next/static/` is content-hashed by
construction; stable-URL files (`BUILD_ID`, service workers, `manifest.json`,
`favicon.ico`, root `public/`) are not, and are deliberately excluded. Per
Next.js's own docs:

- **CDN Caching → "Static assets":** assets from `/_next/static/` "include
  content hashes in their filenames and have a 1 year `max-age` and `immutable`
  directive: `public,max-age=31536000,immutable`."
  <https://nextjs.org/docs/app/guides/cdn-caching>
- **Self-Hosting → "Automatic Caching":** the immutable header "cannot be
  overridden … These immutable files contain a SHA-hash in the file name, so
  they can be safely cached indefinitely."
  <https://nextjs.org/docs/app/guides/self-hosting#automatic-caching>

## Run

```bash
cd test-repo/regex-check
terraform init   # no providers to download — just initializes the test
terraform test
```

Expected:

```
  run "immutable_regex_classifies_assets_correctly"... pass
Success! 1 passed, 0 failed.
```

You can also see the classification directly:

```bash
terraform console <<<'[for p in var.sample_paths : { path = p, immutable = length(regexall(var.immutable_assets_regex, p)) > 0 }]'
```

The sample paths are illustrative — only the path *shape* matters, so the result
is identical regardless of the actual content hashes in your build.

This is the Terraform-native form of **Evidence block (1)** in `../../REPORT.md`.
The deployed S3-metadata and browser-header checks (blocks 2–5) live there; the
S3-metadata check is also encoded as an apply-time `terraform test` under
`../terraform/tests/`.
