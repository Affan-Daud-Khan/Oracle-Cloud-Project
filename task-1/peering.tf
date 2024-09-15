# Dynamic Routing Gateway for Hub VCN
resource "oci_core_drg" "hub_drg" {
  compartment_id = var.compartment_id
  display_name   = "Hub-DRG"
}

# Dynamic Routing Gateway for spoke one VCN
resource "oci_core_drg" "spoke1_drg" {
  compartment_id = var.compartment_id
  display_name   = "Spoke-one-DRG"
}

# Dynamic Routing Gateway for spoke two VCN
resource "oci_core_drg" "spoke2_drg" {
  compartment_id = var.compartment_id
  display_name   = "Spoke-two-DRG"
}

# Remote Peering Connection for Hub DRG
resource "oci_core_remote_peering_connection" "hub_rpc" {
  compartment_id = var.compartment_id
  drg_id         = oci_core_drg.hub_drg.id
  display_name   = "Hub-RPC"
}

# Remote Peering Connection for Spoke one DRG
resource "oci_core_remote_peering_connection" "spoke1_rpc" {
  compartment_id = var.compartment_id
  drg_id         = oci_core_drg.spoke1_drg.id
  display_name   = "Spoke-one-RPC"
}

# Remote Peering Connection for Spoke two DRG
resource "oci_core_remote_peering_connection" "spoke2_rpc" {
  compartment_id = var.compartment_id
  drg_id         = oci_core_drg.spoke2_drg.id
  display_name   = "Spoke-two-RPC"
}
