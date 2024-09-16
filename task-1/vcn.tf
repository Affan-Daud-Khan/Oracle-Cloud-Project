# create Hub VCN
resource "oci_core_vcn" "hub_vcn" {
  cidr_block = var.hub_vcn_cidr
  compartment_id = var.compartment_id
  display_name = "Hub-VCN"
}

# create VCN for first spoke
resource "oci_core_vcn" "spoke1_vcn" {
  cidr_block = var.spoke1_vcn_cidr
  compartment_id = var.compartment_id
  display_name = "spoke-one-VCN"
}

# create VCN for second spoke
resource "oci_core_vcn" "spoke2_vcn" {
  cidr_block = var.spoke2_vcn_cidr
  compartment_id = var.compartment_id
  display_name = "spoke-two-VCN"
}

# create subnet for the hub VCN
resource "oci_core_subnet" "hub_subnet" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_vcn.hub_vcn.id
  cidr_block = "10.0.1.0/24"
  display_name = "Hub-Subnet"
}

# create subnet for spoke one
resource "oci_core_subnet" "spoke1_subnet" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_vcn.spoke1_vcn.id
  cidr_block = "10.1.1.0/24"
  display_name = "spoke-one-subnet"
}

# create subnet for spoke two
resource "oci_core_subnet" "spoke2_subnet" {
  compartment_id = var.compartment_id
  vcn_id = oci_core_vcn.spoke2_vcn.id
  cidr_block = "10.2.1.0/24"
  display_name = "spoke-two-subnet"
}
