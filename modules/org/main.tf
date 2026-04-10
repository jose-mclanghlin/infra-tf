locals {
  root_id = tolist(aws_organizations_organization.this.roots)[0].id

  top_level_ous = {
    for k, v in var.organizational_units : k => v
    if v.parent_key == null
  }

  nested_ous = {
    for k, v in var.organizational_units : k => v
    if v.parent_key != null
  }

  all_ous = merge(
    { for k, v in aws_organizations_organizational_unit.top_level : k => v },
    { for k, v in aws_organizations_organizational_unit.nested : k => v }
  )
}

resource "aws_organizations_organization" "this" {
  feature_set          = var.feature_set
  enabled_policy_types = var.enabled_policy_types
}

resource "aws_organizations_organizational_unit" "top_level" {
  for_each = local.top_level_ous

  name      = each.value.name
  parent_id = local.root_id

  tags = merge(var.tags, {
    Name        = each.value.name
    Environment = var.environment
  })

  depends_on = [aws_organizations_organization.this]
}

resource "aws_organizations_organizational_unit" "nested" {
  for_each = local.nested_ous

  name      = each.value.name
  parent_id = aws_organizations_organizational_unit.top_level[each.value.parent_key].id

  tags = merge(var.tags, {
    Name        = each.value.name
    Environment = var.environment
  })

  depends_on = [aws_organizations_organizational_unit.top_level]
}

resource "aws_organizations_account" "this" {
  for_each = var.accounts

  name                       = each.value.name
  email                      = each.value.email
  parent_id                  = local.all_ous[each.value.ou_key].id
  iam_user_access_to_billing = each.value.iam_user_access_to_billing

  tags = merge(var.tags, {
    Name        = each.value.name
    Environment = var.environment
  })

  depends_on = [
    aws_organizations_organizational_unit.top_level,
    aws_organizations_organizational_unit.nested,
  ]
}
