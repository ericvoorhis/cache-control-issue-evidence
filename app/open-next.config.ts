// Minimal OpenNext (v3) config. The `default` server function is the only
// required key; everything else uses OpenNext's defaults. This is enough to
// produce the `.open-next/` artifact (assets + server/image/revalidation
// functions) that the terraform-aws-open-next module consumes.
const config = {
  default: {},
};

export default config;
