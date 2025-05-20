module "tenant_baseline" {
  source = "../../monitoring/tenant_baseline"

  eventbridge_service_name_to_destination_arn = var.eventbridge_service_name_to_destination_arn
  oam_sink_id                                 = var.oam_sink_id
  oam_shared_resource_types                   = var.oam_shared_resource_types
}
