variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "common_tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}