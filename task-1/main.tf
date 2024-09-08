// I will use Vault for any sensitive values.
provider "oci" {
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  region               = var.region
  compartment_ocid     = var.compartment_ocid
}

// hub VCN
resource "oci_core_vcn" "hub_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "Hub's VCN"
}

resource "oci_core_subnet" "hub_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.hub_vcn.id
  cidr_block     = "10.0.1.0/24"
  display_name   = "Hub's Subnet"
  dns_label      = "hubsubnet"
}

// spoke 1 VCN
resource "oci_core_vcn" "spoke1_vcn" {
  cidr_block     = "10.1.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "Spoke 1 VCN"
}

resource "oci_core_subnet" "spoke1_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.spoke1_vcn.id
  cidr_block     = "10.1.1.0/24"
  display_name   = "Spoke 1 Subnet"
  dns_label      = "spoke1subnet"
}

// spoke 2 VCN
resource "oci_core_vcn" "spoke2_vcn" {
  cidr_block     = "10.2.0.0/16"
  compartment_id = var.compartment_ocid
  display_name   = "Spoke 2 VCN"
}

resource "oci_core_subnet" "spoke2_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.spoke2_vcn.id
  cidr_block     = "10.2.1.0/24"
  display_name   = "Spoke 2 Subnet"
  dns_label      = "spoke2subnet"
}

// LPG for the hub VCN
resource "oci_core_local_peering_gateway" "hub_lpg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.hub_vcn.id
  display_name   = "Hub LPG"
}

// LPGs for the spoke VCNs
resource "oci_core_local_peering_gateway" "spoke1_lpg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.spoke1_vcn.id
  display_name   = "Spoke 1 LPG"
}

resource "oci_core_local_peering_gateway" "spoke2_lpg" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.spoke2_vcn.id
  display_name   = "Spoke 2 LPG"
}

// Peering of the hub VCN with spoke1 VCN
resource "oci_core_local_peering_connection" "hub_to_spoke1" {
  local_peering_gateway_id = oci_core_local_peering_gateway.hub_lpg.id
  peer_id                  = oci_core_local_peering_gateway.spoke1_lpg.id
  peer_compartment_id      = var.compartment_ocid
}

// Peering of the hub VCN with spoke2 VCN
resource "oci_core_local_peering_connection" "hub_to_spoke2" {
  local_peering_gateway_id = oci_core_local_peering_gateway.hub_lpg.id
  peer_id                  = oci_core_local_peering_gateway.spoke2_lpg.id
  peer_compartment_id      = var.compartment_ocid
}

// Update the route table for the hub subnet to route traffic to the spoke VCNs
resource "oci_core_route_table" "hub_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.hub_vcn.id

  route_rules {
    destination        = "10.1.0.0/16"
    network_entity_id  = oci_core_local_peering_gateway.hub_lpg.id
  }

  route_rules {
    destination        = "10.2.0.0/16"
    network_entity_id  = oci_core_local_peering_gateway.hub_lpg.id
  }
}

// Update the route tables for the spoke subnets to route traffic back to the hub:
resource "oci_core_route_table" "spoke1_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.spoke1_vcn.id

  route_rules {
    destination        = "10.0.0.0/16"
    network_entity_id  = oci_core_local_peering_gateway.spoke1_lpg.id
  }
}

resource "oci_core_route_table" "spoke2_route_table" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.spoke2_vcn.id

  route_rules {
    destination        = "10.0.0.0/16"
    network_entity_id  = oci_core_local_peering_gateway.spoke2_lpg.id
  }
}
