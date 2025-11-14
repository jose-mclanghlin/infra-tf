infrastructure/
├── live/
│   ├── prod/
│   │   ├── vpc/
│   │   │   └── terragrunt.hcl
│   │   ├── ecs/
│   │   │   └── terragrunt.hcl
│   │   ├── rds/
│   │   │   └── terragrunt.hcl
│   │   └── terragrunt.hcl     # prod environment root
│   ├── staging/
│   │   ├── vpc/
│   │   │   └── terragrunt.hcl
│   │   ├── ecs/
│   │   │   └── terragrunt.hcl
│   │   ├── rds/
│   │   │   └── terragrunt.hcl
│   │   └── terragrunt.hcl     # staging environment root
│   └── terragrunt.hcl         # common config for all environments
└── modules/
    ├── vpc/
    │   └── main.tf
    ├── ecs/
    │   └── main.tf
    └── rds/
        └── main.tf