# Cache-Control response header fix evidence

## Overview

Version 3.6.2 of https://github.com/RJPearson94/terraform-aws-open-next has a bug where the static, content-hashed, build assets (everything under `_next/static/`) are not getting marked with the `immutable` directive in their `Cache-Control` response headers as they should be according to https://nextjs.org/docs/app/guides/cdn-caching#static-assets.

This test repo reproduces the `terraform-aws-open-next` Cache-Control fix by
deploying **the same Next.js app twice** from a single Terraform root:

- **beforefix** — the pristine **upstream** module (`?ref=v3.6.2`): ships assets
  with **no `Cache-Control` header**.
- **afterfix** — the **patched fork** (`?ref=fix/immutable-cache-control-headers`):
  ships the intended headers (`immutable` for content-hashed `_next/static`,
  `must-revalidate` for stable-name files like `favicon.ico`).

Because both deploys read the *same* `app/.open-next` build artifact, the asset
filenames are identical and the only meaningful difference is the module
`source` — so any header difference is attributable to the patch alone.

```
cache-control-issue-evidence/
  app/          Next.js app, built ONCE with OpenNext; shared by both deploys
  regex-check/  standalone, deploy-free proof of the regex fix (terraform test)
  terraform/    single root: beforefix.tf + afterfix.tf (+ providers/versions)
```

## Prerequisites

- **Node** per `app/.nvmrc` (Node 24) — `nvm use` in `app/`.
- **Terraform** >= 1.14 (or OpenTofu).
- **AWS credentials** for a throwaway/test account. Nothing is pinned to a named
  profile in the code (see `terraform/providers.tf`); supply your own via the
  standard AWS chain, e.g. `AWS_PROFILE`. Region defaults to `us-west-2`
  (CloudFront cert/global resources use `us-east-1`).
- No DNS or ACM setup needed because the deploys use the default `*.cloudfront.net`
  domain and the default CloudFront certificate (no `domain_config`).

## Reproduce

```bash
# 1. Build the shared OpenNext artifact once.
cd app
nvm use             # Node 24, per .nvmrc
npm install
npx open-next build # produces app/.open-next/

# 2. Deploy both variants from the single Terraform root.
cd ../terraform
terraform init
AWS_PROFILE=<your-test-account-profile> terraform apply

# 3. Read the two CloudFront URLs + bucket names.
AWS_PROFILE=<your-test-account-profile> terraform output
```

`terraform apply` stands up two independent OpenNext stacks (`cache-control-test-beforefix-*` and `cache-control-test-afterfix-*`). The URLs are in the above `terraform output` output keyed by `beforefix_url` and `afterfix_url`.

Each site renders a `CACHE_CONTROL_FIX_VARIANT` server environment variable on their home page so that you can quickly tell them apart.

You can identify the fix, by pulling up the dev console for each deployment and checking an app chunk's `Cache-Control` response headers side by side.

Before fix:


After fix:


## What to look at

- **`regex-check/`** — run `terraform init && terraform test` for a ~1-second,
  AWS-free proof that the shipped regex marks `_next/static` (incl. under a
  basePath) immutable and excludes stable-URL files like `favicon.ico`.

## Teardown

When you're done testing, you can destroy the test infra with:

```bash
cd terraform
AWS_PROFILE=<your-test-account-profile> terraform destroy
```
