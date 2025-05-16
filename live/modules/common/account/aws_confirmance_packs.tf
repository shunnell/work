resource "aws_config_conformance_pack" "eks-security-bestpractices" {
  name          = "EKS-Security-BestPractices"
  template_body = file("conformance_packs/EKS-Security-BestPractices.yaml")
}

resource "aws_config_conformance_pack" "nist_800_53_rev5" {
  name          = "NIST-800-53-rev5"
  template_body = file("conformance_packs/NIST-800-53-rev5.yaml")
}

resource "aws_config_conformance_pack" "operational_for_fedramp" {
  name          = "Operational-Best-Practices-for-FedRAMP"
  template_body = file("conformance_packs/Operational-Best-Practices-for-FedRAMP.yaml")
}

resource "aws_config_conformance_pack" "operational_for_fedramp_high" {
  name          = "Operational-Best-Practices-for-FedRAMP-High"
  template_body = file("conformance_packs/Operational-Best-Practices-for-FedRAMP-High.yaml")
}
