
variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "secret_prefix" {
  description = "Secrets Manager secret prefix. Example: team6-nowait/dev"
  type        = string
}

variable "recovery_window_in_days" {
  description = "Number of days before Secrets Manager permanently deletes a secret"
  type        = number
  default     = 7
}

variable "secrets" {
  description = "Secrets Manager secret containers to create"
  type = map(object({
    name_suffix = string
    description = string
  }))
}

