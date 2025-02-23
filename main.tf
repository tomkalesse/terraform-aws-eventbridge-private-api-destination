resource "aws_vpclattice_resource_gateway" "gateway" {
  name       = var.name
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
	security_group_ids = [ aws_security_group.gateway.id ]

  tags = var.tags
}

resource "aws_security_group" "gateway" {
  name = var.name
	description = "Security group for the VPC Lattice Resource Gateway"
	vpc_id = var.vpc_id

	tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  security_group_id = aws_security_group.gateway.id
  referenced_security_group_id = aws_security_group.gateway.id
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  security_group_id = aws_security_group.gateway.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpclattice_resource_configuration" "configuration" {
  name = var.name
  resource_gateway_identifier = aws_vpclattice_resource_gateway.gateway.id
  port_ranges = var.port_ranges
  protocol = "TCP" # currently only TCP is supported

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
	destination_arn = aws_cloudwatch_log_group.logs.arn
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "vpc-lattice-logs-${var.name}"
  tags = var.tags
}

resource "aws_cloudwatch_event_connection" "connection" {
	name = var.name
	description = "Connection to the VPC Lattice Resource Gateway"
	authorization_type = "API_KEY"
	auth_parameters {
		api_key {
			key = var.api_key["key"]
			value = var.api_key["value"]
		}
	}

	invocation_connectivity_parameters {
		resource_parameters {
			resource_configuration_arn = aws_vpclattice_resource_configuration.configuration.arn
		}
	}

}

resource "aws_cloudwatch_event_api_destination" "destination" {
	name = var.name
	description = "API Destination for private Endpoint"
	invocation_endpoint = "https://${var.http_domain}${var.http_path}"
	http_method = var.http_method
	invocation_rate_limit_per_second = var.invocation_rate_limit_per_second
	connection_arn = aws_cloudwatch_event_connection.connection.arn
}