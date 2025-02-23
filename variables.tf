variable "name" {
  description = "(Required) The name for the created resource"
  type = string
}

variable "vpc_id" {
  description = "(Required) The VPC ID for the created resource"
  type = string
}

variable "subnet_ids" {
  description = "(Required) The subnet IDs of the private subnets"
  type = list(string)
}

variable "port_ranges" {
  description = "(Required) Port ranges to access the VPC Resource. Either single port ['80'] or range ['80-81'] range"
  type = list(string)
}

variable "api_key" {
  description = "(Required) The API key for the created resource"
  type = map(string)
}

variable "http_domain" {
  description = "(Required) The domain to invoke"
  type = string
}

variable "invocation_rate_limit_per_second" {
  description = "(Optional) Number of invocations per second to allow for this destination. Default: 300"
  type = number
  default = 300
}

variable "http_path" {
  description = "(Optional) The path of the endpoint to invoke"
  type = string
  default = ""
}

variable "http_method" {
  description = "(Optional) The HTTP method to invoke. Default: 'GET'"
  type = string
  default = "GET"
}

variable "tags" {
  description = "(Optional) The tags for the created resource"
  type = map(string)
  default = {}
}