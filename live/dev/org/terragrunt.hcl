include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/org"
}

inputs = {
  environment          = "dev"
  feature_set          = "ALL"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]

  organizational_units = {
    security       = { name = "Security",       parent_key = null        }
    platform       = { name = "Platform",       parent_key = null        }
    infrastructure = { name = "Infrastructure", parent_key = null        }
    workloads      = { name = "Workloads",      parent_key = null        }
    sandbox        = { name = "Sandbox",        parent_key = null        }

    workloads_dev     = { name = "Dev",     parent_key = "workloads" }
    workloads_staging = { name = "Staging", parent_key = "workloads" }
    workloads_prod    = { name = "Prod",    parent_key = "workloads" }
  }

  accounts = {
    security = {
      name   = "security"
      email  = "aws+security@yourdomain.com"
      ou_key = "security"
    }
    logging = {
      name   = "logging"
      email  = "aws+logging@yourdomain.com"
      ou_key = "security"
    }
    identity = {
      name   = "identity"
      email  = "aws+identity@yourdomain.com"
      ou_key = "platform"
    }
    infra_shared = {
      name   = "infra-shared"
      email  = "aws+infra-shared@yourdomain.com"
      ou_key = "infrastructure"
    }
    dev = {
      name   = "dev"
      email  = "aws+dev@yourdomain.com"
      ou_key = "workloads_dev"
    }
    staging = {
      name   = "staging"
      email  = "aws+staging@yourdomain.com"
      ou_key = "workloads_staging"
    }
    prod = {
      name   = "prod"
      email  = "aws+prod@yourdomain.com"
      ou_key = "workloads_prod"
    }
    sandbox = {
      name   = "sandbox"
      email  = "aws+sandbox@yourdomain.com"
      ou_key = "sandbox"
    }
  }

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

