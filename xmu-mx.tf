resource "google_dns_managed_zone" "xmu-mx" {
  name        = "xmu-mx"
  dns_name    = "xmu.mx."
  description = "A domain name for experimenting"
  visibility  = "public"

  # Guards the literal 4 the delegation below indexes into.
  lifecycle {
    postcondition {
      condition     = length(self.name_servers) == 4
      error_message = "Cloud DNS returned ${length(self.name_servers)} nameservers, expected 4."
    }
  }
}

resource "ovh_domain_name_servers" "xmu-mx" {
  domain = "xmu.mx"

  # A `dynamic` block over a literal range rather than over the nameserver list:
  # the values are only known after the zone is created, but the block count has
  # to be known at plan time. Cloud DNS always assigns exactly four to a public
  # zone. Trailing dot trimmed — OVH wants bare hostnames.
  dynamic "servers" {
    for_each = range(4)

    content {
      host = trimsuffix(google_dns_managed_zone.xmu-mx.name_servers[servers.value], ".")
    }
  }
}
