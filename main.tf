resource "aws_vpclattice_resource_gateway" "gateway" {
  name               = var.name
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = [aws_security_group.gateway.id]

  tags = var.tags
}

resource "aws_security_group" "gateway" {
  name        = var.name
  description = "Security group for the VPC Lattice Resource Gateway"
  vpc_id      = var.vpc_id

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  security_group_id            = aws_security_group.gateway.id
  referenced_security_group_id = aws_security_group.gateway.id
  ip_protocol                  = "-1"
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.gateway.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpclattice_resource_configuration" "configuration" {
  name                        = var.name
  resource_gateway_identifier = aws_vpclattice_resource_gateway.gateway.id
  port_ranges                 = ["443"] # eventbridge api destination requires HTTPS
  protocol                    = "TCP"   # currently only TCP is supported

  allow_association_to_shareable_service_network = false

  resource_configuration_definition {
    dns_resource {
      domain_name     = var.http_domain
      ip_address_type = "IPV4"
    }
  }

  tags = var.tags
}

resource "aws_vpclattice_access_log_subscription" "subscription" {
  resource_identifier = aws_vpclattice_resource_configuration.configuration.arn
  destination_arn     = aws_cloudwatch_log_group.logs.arn
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "vpc-lattice-logs-${var.name}"
  tags = var.tags
}

resource "aws_cloudwatch_event_connection" "connection" {
  name               = var.name
  description        = "Connection to the VPC Lattice Resource Gateway"
  authorization_type = "API_KEY"
  auth_parameters {

    dynamic "api_key" {
      for_each = var.api_key == null ? [] : [1]
      content {
        key   = var.api_key["key"]
        value = var.api_key["value"]
      }
    }

    dynamic "basic" {
      for_each = var.basic == null ? [] : [1]
      content {
        username = var.basic["username"]
        password = var.basic["password"]
      }
    }

    dynamic "oauth" {
      for_each = var.oauth == null ? [] : [1]
      content {
        authorization_endpoint = var.oauth["authorization_endpoint"]
        http_method            = var.oauth["http_method"]
        client_parameters {
          client_id     = var.oauth["client_parameters"]["client_id"]
          client_secret = var.oauth["client_parameters"]["client_secret"]
        }
        oauth_http_parameters {
          body {
            key   = var.oauth["oauth_http_parameters"]["body"]["key"]
            value = var.oauth["oauth_http_parameters"]["body"]["value"]
          }
          header {
            key   = var.oauth["oauth_http_parameters"]["header"]["key"]
            value = var.oauth["oauth_http_parameters"]["header"]["value"]
          }
          query_string {
            key   = var.oauth["oauth_http_parameters"]["query_string"]["key"]
            value = var.oauth["oauth_http_parameters"]["query_string"]["value"]
          }
        }
      }
    }

    dynamic "invocation_http_parameters" {
      for_each = var.invocation_http_parameters == null ? [] : [1]
      content {
        body {
          key              = var.invocation_http_parameters["body"]["key"]
          value            = var.invocation_http_parameters["body"]["value"]
          is_value_secret = var.invocation_http_parameters["body"]["is_values_secret"]
        }
        header {
          key              = var.invocation_http_parameters["header"]["key"]
          value            = var.invocation_http_parameters["header"]["value"]
          is_value_secret = var.invocation_http_parameters["header"]["is_values_secret"]
        }
        query_string {
          key              = var.invocation_http_parameters["query_string"]["key"]
          value            = var.invocation_http_parameters["query_string"]["value"]
          is_value_secret = var.invocation_http_parameters["query_string"]["is_values_secret"]
        }
      }
    }
  }

  invocation_connectivity_parameters {
    resource_parameters {
      resource_configuration_arn = aws_vpclattice_resource_configuration.configuration.arn
    }
  }

}

resource "aws_cloudwatch_event_api_destination" "destination" {
  name                             = var.name
  description                      = "API Destination for private Endpoint"
  invocation_endpoint              = "https://${var.http_domain}${var.http_path}"
  http_method                      = var.http_method
  invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
  connection_arn                   = aws_cloudwatch_event_connection.connection.arn
}

resource "aws_iam_role" "invoke_api_dest" {
  name        = "eventbridge-invoke-api-destination-${var.name}"
  description = "Role to allow EventBridge to invoke the API Destination"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iam_policy" "invoke_api_dest" {
  name        = "eventbridge-invoke-api-destination-${var.name}"
  description = "Policy to allow EventBridge to invoke the API Destination"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InvokeAPIDestination"
        Effect = "Allow"
        Action = [
          "events:InvokeApiDestination"
        ]
        Resource = aws_cloudwatch_event_api_destination.destination.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "invoke_api_dest" {
  role       = aws_iam_role.invoke_api_dest.name
  policy_arn = aws_iam_policy.invoke_api_dest.arn
}
