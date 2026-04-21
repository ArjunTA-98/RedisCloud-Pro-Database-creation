# Redis Cloud Terraform Example

This project creates:

* A Redis Cloud Pro subscription
* A Redis database with configurable size and throughput

---

## Prerequisites

* Terraform installed
* A Redis Cloud account
* API access enabled in the Redis Cloud UI
* A payment method added to the account

---

## Set API Credentials

Set your Redis Cloud API keys as environment variables:

```bash
export REDISCLOUD_ACCESS_KEY=<YOUR_ACCOUNT_KEY>
export REDISCLOUD_SECRET_KEY=<YOUR_USER_KEY>
```

---

## Configure Variables

Create your local variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then update it with your values:

```hcl
payment_card_type      = "Visa"        # or "MasterCard"
payment_card_last_four = "1234"
```

---

## Run Terraform

```bash
terraform init
terraform plan
terraform apply
```

---

## Cloud Provider

The example is configured for AWS:

```hcl
provider = "AWS"
region   = "us-east-1"
```

If you want to use GCP, update the provider and region accordingly:

```hcl
provider = "GCP"
region   = "<GCP_REGION>"
```

Make sure the region you choose is supported by Redis Cloud and that the networking CIDR is valid.

---

## Notes

* Do not commit `terraform.tfvars` or any API keys
* Keep credentials in environment variables
* Make sure the card details match what’s configured in Redis Cloud

---

## What this creates

* A Redis Cloud Pro subscription
* A Redis database with:

  * dataset size
  * throughput
  * persistence
  * replication enabled
