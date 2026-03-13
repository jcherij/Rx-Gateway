locals {
  app    = "rxgateway"
  env    = "production"
  labels = { app = local.app, env = local.env, "data-sensitivity" = "phi" }
}
