variable "hub_vcn_cidr" {
  description = "CIDR block for hub VCN"
  default = "10.0.0.0/16"
}

variable "spoke1_vcn_cidr" {
  description = "CIDR block for spoke-1 VCN"
  default = "10.1.0.0/16"
}

variable "spoke2_vcn_cidr" {
  description = "CIDR block for spoke-2 VCN"
  default = "10.2.0.0/16"
}

variable "compartment_id" {
  description = "compartment ID"
  type = string
  default = "<value>"
}
