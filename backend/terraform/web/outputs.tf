output "staging_lb_arn" {
  value = module.staging.lb_arn
}

output "production_lb_arn" {
  value = module.production.lb_arn
}