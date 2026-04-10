variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string

  validation {
    condition     = length(var.environment) > 0
    error_message = "Environment must be a non-empty string."
  }
}

variable "feature_set" {
  description = "Feature set for the organization. Valid values: ALL, CONSOLIDATED_BILLING."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ALL", "CONSOLIDATED_BILLING"], var.feature_set)
    error_message = "feature_set must be either 'ALL' or 'CONSOLIDATED_BILLING'."
  }
}

variable "enabled_policy_types" {
  description = "List of policy types to enable in the organization."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]

  validation {
    condition = alltrue([
      for p in var.enabled_policy_types :
      contains(["SERVICE_CONTROL_POLICY", "TAG_POLICY", "BACKUP_POLICY", "AISERVICES_OPT_OUT_POLICY"], p)
    ])
    error_message = "Valid policy types are: SERVICE_CONTROL_POLICY, TAG_POLICY, BACKUP_POLICY, AISERVICES_OPT_OUT_POLICY."
  }
}

variable "organizational_units" {
  description = "Map of Organizational Units. Set parent_key to null for top-level OUs (children of Root), or to another OU key to nest it."
  type = map(object({
    name       = string
    parent_key = optional(string, null)
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.organizational_units : length(v.name) > 0])
    error_message = "All organizational unit names must be non-empty strings."
  }
}

variable "accounts" {
  description = "Map of member accounts to create within the organization."
  type = map(object({
    name                      = string
    email                     = string
    ou_key                    = string
    iam_user_access_to_billing = optional(string, "DENY")
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.accounts : length(v.name) > 0])
    error_message = "All account names must be non-empty strings."
  }

  validation {
    condition     = alltrue([for k, v in var.accounts : can(regex("^[^@]+@[^@]+\\.[^@]+$", v.email))])
    error_message = "All account emails must be valid email addresses."
  }

  validation {
    condition = alltrue([
      for k, v in var.accounts :
      contains(["ALLOW", "DENY"], v.iam_user_access_to_billing)
    ])
    error_message = "iam_user_access_to_billing must be either 'ALLOW' or 'DENY'."
  }
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for key, value in var.tags : can(regex("^[a-zA-Z0-9-_]+$", key))])
    error_message = "All tag keys must contain only letters, numbers, hyphens, or underscores."
  }

  validation {
    condition     = alltrue([for key, value in var.tags : length(value) > 0])
    error_message = "All tag values must be non-empty strings."
  }
}
