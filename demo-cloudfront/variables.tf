variable "website_root" {
  type        = string
  description = "Path to the root of website content"
  default     = "content"
}

variable "cloudfront" {
  type        = map(any)
  default     = {
    username = "cloudfront",
    password = "cloudfront234"
  }
}
