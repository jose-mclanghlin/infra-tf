
variable "name" {
  description = "The name of the ECR repository"
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 256
    error_message = "The 'name' variable must not be empty and must be 256 characters or fewer."
  }
}

variable "force_delete" {
  description = "Allow the ECR repository to be deleted even if it contains images"
  type        = bool

  validation {
    condition     = contains([true, false], var.force_delete)
    error_message = "'force_delete' must be either true or false."
  }
}

variable "image_tag_mutability" {
  description = "The image tag mutability of the ECR repository"
  type        = string
  default     = "MUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "'image_tag_mutability' must be either 'MUTABLE' or 'IMMUTABLE'."
  }
}

variable "encryption_type" {
  description = "The encryption type of the ECR repository"
  type        = string
  default     = "AES256"

  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "'encryption_type' must be either 'AES256' or 'KMS'."
  }
}

variable "scan_on_push" {
  description = "Scan the repository for vulnerabilities"
  type        = bool
  default     = true

  validation {
    condition     = contains([true, false], var.scan_on_push)
    error_message = "'scan_on_push' must be true or false."
  }
}
