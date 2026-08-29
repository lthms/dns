resource "google_dns_managed_zone" "soap_coffee" {
  name        = "soap-coffee"
  dns_name    = "soap.coffee."
  description = "User-facing websites and services"
  visibility  = "public"

  # Guards the literal 4 the delegation below indexes into.
  lifecycle {
    postcondition {
      condition     = length(self.name_servers) == 4
      error_message = "Cloud DNS returned ${length(self.name_servers)} nameservers, expected 4."
    }
  }
}

resource "google_dns_record_set" "mx_soap_coffee" {
  name         = google_dns_managed_zone.soap_coffee.dns_name
  managed_zone = google_dns_managed_zone.soap_coffee.name
  type         = "MX"
  ttl          = 3600

  rrdatas = ["10 aspmx1.migadu.com.", "20 aspmx2.migadu.com."]
}

resource "google_dns_record_set" "txt_soap_coffee" {
  name         = google_dns_managed_zone.soap_coffee.dns_name
  managed_zone = google_dns_managed_zone.soap_coffee.name
  type         = "TXT"
  ttl          = 3600

  rrdatas = [
    "\"v=spf1 a mx include:spf.migadu.com ~all\"",

  ]
}

resource "google_dns_record_set" "dkim_soap_coffee" {
  name         = "default._domainkey.${google_dns_managed_zone.soap_coffee.dns_name}"
  managed_zone = google_dns_managed_zone.soap_coffee.name
  type         = "TXT"
  ttl          = 3600

  rrdatas = [
    "\"v=DKIM1; k=rsa; s=email; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC2cvDAUmVc1lHEM8n5uP7IbHWTuSylDz2fcEFAF9SWVJeS4TyJ0mNgGJArtlisZm6j5JMhM0AKp63ak9+kgPJtep4WaORliApwktAL578S9ISL1O4EbGfPo4Jc8aEPXy2GoRN5+TWBMDJmQP2z1i4T15jzLEf2Wws2RyfvTXdM1wIDAQAB\"",
  ]
}

resource "google_dns_record_set" "dmarc_soap_coffee" {
  name         = "_dmarc.${google_dns_managed_zone.soap_coffee.dns_name}"
  managed_zone = google_dns_managed_zone.soap_coffee.name
  type         = "TXT"
  ttl          = 3600

  rrdatas = ["\"v=DMARC1; p=none; fo=1; rua=mailto:admin@soap.coffee\""]
}

resource "google_dns_record_set" "atproto_lthms_soap_coffee" {
  name         = "_atproto.lthms.${google_dns_managed_zone.soap_coffee.dns_name}"
  managed_zone = google_dns_managed_zone.soap_coffee.name
  type         = "TXT"
  ttl          = 3600

  rrdatas = ["\"did=did:plc:g3m5ipqdodqbabd4ixjoosxj\""]
}

resource "ovh_domain_name_servers" "soap_coffee" {
  domain = "soap.coffee"

  # A `dynamic` block over a literal range rather than over the nameserver list:
  # the values are only known after the zone is created, but the block count has
  # to be known at plan time. Cloud DNS always assigns exactly four to a public
  # zone. Trailing dot trimmed — OVH wants bare hostnames.
  dynamic "servers" {
    for_each = range(4)

    content {
      host = trimsuffix(google_dns_managed_zone.soap_coffee.name_servers[servers.value], ".")
    }
  }
}
