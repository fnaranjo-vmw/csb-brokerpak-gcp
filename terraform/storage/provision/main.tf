resource "google_storage_bucket" "bucket" {
  name                        = var.name
  location                    = var.region
  storage_class               = var.storage_class
  labels                      = var.labels
  public_access_prevention    = var.public_access_prevention
  uniform_bucket_level_access = var.uniform_bucket_level_access

  dynamic "custom_placement_config" {
    for_each = length(toset(var.placement_dual_region_data_locations)) > 0 ? [true] : []
    content {
      data_locations = toset([for region in var.placement_dual_region_data_locations : upper(region)])
    }
  }

  versioning {
    enabled = var.versioning
  }

  # Having a permanent encryption block with default_kms_key_name = "" works but results in terraform applying a change every run
  # There is no enabled = false attribute available to ask terraform to ignore the block
  dynamic "encryption" {
    for_each = trimspace(var.default_kms_key_name) != "" ? [true] : []
    content {
      default_kms_key_name = var.default_kms_key_name
    }
  }

  dynamic "autoclass" {
    for_each = var.autoclass ? [true] : []
    content {
      enabled = var.autoclass
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy_retention_period != 0 ? [true] : []
    content {
      is_locked        = var.retention_policy_is_locked
      retention_period = var.retention_policy_retention_period
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}
