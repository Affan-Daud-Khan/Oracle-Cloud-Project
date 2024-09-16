variable "compartment_id" {
  type    = string
  default = "<value>"
}

 # I will use a vault to store any sensitive info in Staging and Prod

provider "oci" {
    auth = "InstancePrincipal"
    region="me-jeddah-1"
}

# create manafa vcn
resource "oci_core_vcn" "manafa-vcn" {
  cidr_block = "10.0.0.0/16"
  display_name = "Manafa-VCN"
  dns_label = "manafavcn"
  compartment_id = var.compartment_id
}

# Internet gateway for public subnets
resource "oci_core_internet_gateway" "internet_gateway" {
  vcn_id = oci_core_vcn.manafa-vcn.id
  display_name = "Manafa-Internet-Gateway"
  enabled = true
  compartment_id = var.compartment_id
}

# Route table for public subnets
resource "oci_core_route_table" "public_route_table" {
  vcn_id = oci_core_vcn.manafa-vcn.id
  display_name = "Public-Route-Table"

  compartment_id = var.compartment_id

  route_rules {
    cidr_block = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# security list for public subnets
resource "oci_core_security_list" "public_security_list" {
  vcn_id = oci_core_vcn.manafa-vcn.id
  display_name = "Public-Security-List"
  compartment_id = var.compartment_id

  # allow ingress for SSH and HTTP/HTTPS
  ingress_security_rules {
    protocol = "6"
    source = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "6"
    source = "0.0.0.0/0"
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    protocol = "6"
    source = "0.0.0.0/0"
    tcp_options {
      min = 443
      max = 443
    }
  }

  # allow all outbound traffic
  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
}

# security list for private subnet
resource "oci_core_security_list" "private_security_list" {
  vcn_id = oci_core_vcn.manafa-vcn.id
  display_name = "Private-Security-List"
  compartment_id = var.compartment_id

  # allow ingress for MySQL, Redis, MongoDB
  ingress_security_rules {
    protocol = "6"
    source = "10.0.1.0/24"
    tcp_options {
      min = 3306
      max = 3306
    }
  }

  ingress_security_rules {
    protocol = "6"
    source = "10.0.1.0/24"
    tcp_options {
      min = 6379
      max = 6379
    }
  }

  ingress_security_rules {
    protocol = "6"
    source = "10.0.1.0/24"
    tcp_options {
      min = 27017
      max = 27017
    }
  }

  # allow all outbound traffic
  egress_security_rules {
    protocol = "all"
    destination = "0.0.0.0/0"
  }
}

# public subnet for Ansible VM
resource "oci_core_subnet" "ansible_vm_subnet" {
  vcn_id = oci_core_vcn.manafa-vcn.id
  cidr_block = "10.0.1.0/24"
  display_name = "Ansible-Terraform-VM-Subnet"
  dns_label = "ansibleterraformnet"
  security_list_ids = [oci_core_security_list.public_security_list.id]
  route_table_id = oci_core_route_table.public_route_table.id
  compartment_id = var.compartment_id
  prohibit_public_ip_on_vnic = false
}

# public subnet for application VM
resource "oci_core_subnet" "app_vm_subnet" {
  vcn_id = oci_core_vcn.manafa-vcn.id
  cidr_block = "10.0.2.0/24"
  display_name = "Application-VM-Subnet"
  dns_label = "appnet"
  security_list_ids = [oci_core_security_list.public_security_list.id]
  route_table_id = oci_core_route_table.public_route_table.id
  compartment_id = var.compartment_id
  prohibit_public_ip_on_vnic = false
}

# private subnet for DB VM
resource "oci_core_subnet" "db_vm_subnet" {
  vcn_id = oci_core_vcn.manafa-vcn.id
  cidr_block = "10.0.3.0/24"
  display_name = "Database-VM-Subnet"
  dns_label = "dbnet"
  security_list_ids = [oci_core_security_list.private_security_list.id]
  compartment_id = var.compartment_id
  prohibit_public_ip_on_vnic = true
}
