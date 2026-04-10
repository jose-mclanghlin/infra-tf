output "organization_id" {
  description = "ID of the AWS Organization"
  value       = aws_organizations_organization.this.id
}

output "organization_arn" {
  description = "ARN of the AWS Organization"
  value       = aws_organizations_organization.this.arn
}

output "master_account_id" {
  description = "Account ID of the master (management) account"
  value       = aws_organizations_organization.this.master_account_id
}

output "master_account_arn" {
  description = "ARN of the master (management) account"
  value       = aws_organizations_organization.this.master_account_arn
}

output "root_id" {
  description = "ID of the organization root"
  value       = local.root_id
}

output "top_level_ou_ids" {
  description = "Map of top-level OU keys to their IDs"
  value       = { for k, v in aws_organizations_organizational_unit.top_level : k => v.id }
}

output "top_level_ou_arns" {
  description = "Map of top-level OU keys to their ARNs"
  value       = { for k, v in aws_organizations_organizational_unit.top_level : k => v.arn }
}

output "nested_ou_ids" {
  description = "Map of nested OU keys to their IDs"
  value       = { for k, v in aws_organizations_organizational_unit.nested : k => v.id }
}

output "nested_ou_arns" {
  description = "Map of nested OU keys to their ARNs"
  value       = { for k, v in aws_organizations_organizational_unit.nested : k => v.arn }
}

output "all_ou_ids" {
  description = "Map of all OU keys (top-level and nested) to their IDs. Useful for SCP and IAM modules."
  value = merge(
    { for k, v in aws_organizations_organizational_unit.top_level : k => v.id },
    { for k, v in aws_organizations_organizational_unit.nested : k => v.id }
  )
}

output "account_ids" {
  description = "Map of account keys to their AWS account IDs"
  value       = { for k, v in aws_organizations_account.this : k => v.id }
}

output "account_arns" {
  description = "Map of account keys to their ARNs"
  value       = { for k, v in aws_organizations_account.this : k => v.arn }
}

output "organizational_structure" {
  description = "Full organizational structure: org, OUs, and accounts"
  value = {
    organization = {
      id                = aws_organizations_organization.this.id
      arn               = aws_organizations_organization.this.arn
      master_account_id = aws_organizations_organization.this.master_account_id
      feature_set       = aws_organizations_organization.this.feature_set
    }
    root_id = local.root_id
    top_level_ous = {
      for k, v in aws_organizations_organizational_unit.top_level : k => {
        id   = v.id
        arn  = v.arn
        name = v.name
      }
    }
    nested_ous = {
      for k, v in aws_organizations_organizational_unit.nested : k => {
        id         = v.id
        arn        = v.arn
        name       = v.name
        parent_key = var.organizational_units[k].parent_key
      }
    }
    accounts = {
      for k, v in aws_organizations_account.this : k => {
        id     = v.id
        arn    = v.arn
        name   = v.name
        email  = v.email
        ou_key = var.accounts[k].ou_key
      }
    }
  }
}
