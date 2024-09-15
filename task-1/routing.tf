# create Internet Gateway for the Hub VCN
resource "oci_core_internet_gateway" "hub_internet_gateway" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_vcn.hub_vcn.id
  display_name = "Hub-Internet-Gateway"
  enabled = true
}

# create a Route table for Hub VCN
resource "oci_core_route_table" "hub_route_table" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_vcn.hub_vcn.id
  route_rules {
    destination = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.hub_internet_gateway.id
  }
}
