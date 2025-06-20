/*
This module addresses some common Security Hub findings re: account owner and security contacts by uniformly managing
the contact information here.

[DS AWS Baseline Compliance](https://usdos.sharepoint.com/:x:/r/sites/DS/DS/CTS/TIE/ETD/TSF/_layouts/15/Doc.aspx?sourcedoc=%7B5CE146B0-8725-4F22-BC63-0BE6AB583EE9%7D&file=Amazon%20Web%20Services%20(AWS)%20Foundations%20Security%20Baseline.xlsx8):
  - AWS-FDN-0001
  - AWS-FDN-0002

Example control: https://docs.aws.amazon.com/securityhub/latest/userguide/account-controls.html#account-1

Note for posterity: originally, the 4Points contractor that provisioned all the accounts set the contact info below,
which will remain in this comment if it ever needs to be restored or refered to for some reason:
Name:
Platform-Infra

Website:
None

Phone:
+1 7036576103

Company:
Four Points Technology

Address:
13221 Woodland Park Rd, Suite 400
Herndon, VA 20171
 */

resource "aws_account_primary_contact" "primary" {
  address_line_1     = "600 19th St NW, Washington, DC 20431"
  address_line_2     = "Bureau of Consular Affairs"
  address_line_3     = "Consular Systems and Technology (CA/CST)"
  city               = "Washington, D.C."
  company_name       = "United States Department of State (CA/CST)"
  country_code       = "US"
  district_or_county = "District of Columbia"
  full_name          = "Department of State Cloud City Platform"
  phone_number       = "+1 7712060567"
  postal_code        = "20431"
  state_or_region    = "DC"
  website_url        = "Email: CA-CST-Cloud-City-Gov@state.gov"
}

resource "aws_account_alternate_contact" "billing" {
  alternate_contact_type = "BILLING"
  name                   = "Nathan Spande"
  title                  = "IT Specialist; Cloud Platform Project Manager"
  email_address          = "spanden@state.gov"
  phone_number           = aws_account_primary_contact.primary.phone_number
}

resource "aws_account_alternate_contact" "security" {
  alternate_contact_type = "SECURITY"
  name                   = "Jeremy Tucker"
  title                  = "Information Systems Security Manager (ISSM)"
  email_address          = "TuckerJC@state.gov"
  phone_number           = "+1 2272337048"
}
