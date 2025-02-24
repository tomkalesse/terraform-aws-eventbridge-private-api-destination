variable "name" {
  description = "(Required) The name for the created resource."
  type        = string
}

variable "vpc_id" {
  description = "(Required) The VPC ID for the resource you want to reach."
  type        = string
}

variable "subnet_ids" {
  description = "(Required) The subnet IDs of the private subnets your resource is in."
  type        = list(string)
}

variable "http_domain" {
  description = "(Required) The domain to invoke. Without the protocol. Example: 'example.com'."
  type        = string
}

variable "http_path" {
  description = "(Optional) The path of the endpoint to invoke."
  type        = string
  default     = ""
}

variable "http_method" {
  description = "(Optional) The HTTP method to invoke. Default: 'GET'."
  type        = string
  default     = "GET"
}

variable "api_key" {
  description = "(Optional) Parameters used for API_KEY authorization. An API key to include in the header for each authentication request. A maximum of 1 are allowed. https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection#api_key-1"
  type        = map(string)
  default     = null
}

variable "basic" {
  description = "(Optional) Parameters used for BASIC authorization. A maximum of 1 are allowed. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection#basic-1"
  type        = map(string)
  default     = null
}

variable "oauth" {
  description = "(Optional) Parameters used for OAUTH_CLIENT_CREDENTIALS authorization. A maximum of 1 are allowed. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection#oauth-1"
  type        = map(any)
  default     = null
}

variable "invocation_http_parameters" {
  description = "(Optional) Invocation Http Parameters are additional credentials used to sign each Invocation of the ApiDestination created from this Connection. Supports only 1 set of values. See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_connection#invocation_connectivity_parameters-1"
  type        = map(any)
  default     = null
}

variable "invocation_rate_limit_per_second" {
  description = "(Optional) Number of invocations per second to allow for this destination. Default: 300."
  type        = number
  default     = 300
}

variable "tags" {
  description = "(Optional) The tags for the created resource."
  type        = map(string)
  default     = {}
}
