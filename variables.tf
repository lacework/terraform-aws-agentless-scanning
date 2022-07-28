variable "image_url" {
  type        = string
  default     = "public.ecr.aws/p5r4i7k7/sidekick:latest"
  description = "Container Image"
}
variable "resource_name_prefix" {
  type        = string
  description = ""
}
variable "resource_name_suffix" {
  type        = string
  description = ""
}

