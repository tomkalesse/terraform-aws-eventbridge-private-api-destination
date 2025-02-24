# EventBridge Private API Destination AWS Module

This Terraform module creates an EventBridge API Destination resource with a connection to a private endpoint. This endpoint must be associated with a resource inside the private subnets of one of the account's VPCs. It utilizes the VPC Lattice Resource Gateway to provide this connection from EventBridge to the private network.

Note: Creating an EventBridge Connection takes at least 5 minutes.

### Chart

![EventBridge Private API Destination and VPC Lattice Gateway](./_docs/private-api-destination.drawio.svg)

## Usage

This module can be used to implement cron jobs in container environments, utilizing an EventBridge Rule/Schedule to trigger an endpoint of the containerized application to run a specific routine. With the support of the VPC Lattice Gateway, this is now natively integrated for resources inside private subnets that are not reachable from the internet.

### Example

```hcl
module "private-api-destination" {
  source = "tomkalesse/eventbridge-private-api-destination"

  name        = "my-project"
  vpc_id      = "vpc-wf43cz45b1vqvc4rd13"
  subnet_ids  = ["subnet-wf43cz45b1vqvc4rd14", "subnet-wf43cz45b1vqvc4rd15"]
  http_domain = "example.com"
  http_path   = "/my/endpoint"
  http_method = "POST"

  api_key = {
    "key"   = "x-api-key"
    "value" = local.api_key
  }

  tags = {
    "Environment" = "prod"
    "ManagedBy"   = "Terraform"
  }
}

resource "aws_cloudwatch_event_rule" "cron" {
  name                = "my-project-cron"
  description         = "A rule description"
  schedule_expression = "cron(0 12 * * ? *)"
  tags = {
      "Environment" = "prod"
      "ManagedBy"   = "Terraform"
    }
}

resource "aws_cloudwatch_event_target" "private_api_target" {
  rule      = aws_cloudwatch_event_rule.cron.name
  target_id = "my-project-target"
  arn       = module.private-api-destination.arn
  role_arn  = module.private-api-destination.iam_role_arn

  retry_policy {
    maximum_event_age_in_seconds = 60
    maximum_retry_attempts       = 0
  }
}

```