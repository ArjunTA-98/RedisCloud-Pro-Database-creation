terraform {
  required_providers {
    rediscloud = {
      source  = "RedisLabs/rediscloud"
      version = "~> 2.14"
    }
  }
}

# Credentials are read from the environment:
#   REDISCLOUD_ACCESS_KEY  -> API account key
#   REDISCLOUD_SECRET_KEY  -> API user key
provider "rediscloud" {}

############################################
# INPUT VARIABLES
############################################

variable "payment_card_type" {
  description = "Card network of the payment method saved in Redis Cloud"
  type        = string
  default     = "Visa"
}

variable "payment_card_last_four" {
  description = "Last 4 digits of the payment card saved in Redis Cloud"
  type        = string
}

variable "subscription_name" {
  description = "Name of the Redis Cloud Pro subscription"
  type        = string
  default     = "example-redis-subscription"
}

variable "database_name" {
  description = "Name of the Redis Cloud database"
  type        = string
  default     = "example-redis-database"
}

variable "aws_region" {
  description = "AWS region in which the subscription will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "deployment_cidr" {
  description = "CIDR block for the Redis Cloud deployment network"
  type        = string
  default     = "10.0.0.0/24"
}

variable "dataset_size_in_gb" {
  description = "Dataset size of the database in GB"
  type        = number
  default     = 3
}

variable "ops_per_second" {
  description = "Throughput target in operations per second"
  type        = number
  default     = 3000
}

variable "data_persistence" {
  description = "Database persistence mode"
  type        = string
  default     = "aof-every-second"
}

############################################
# FETCH PAYMENT METHOD
############################################

data "rediscloud_payment_method" "card" {
  card_type         = var.payment_card_type
  last_four_numbers = var.payment_card_last_four
}

############################################
# CREATE SUBSCRIPTION (PRO - AWS)
############################################

resource "rediscloud_subscription" "pro" {
  name              = var.subscription_name
  payment_method_id  = data.rediscloud_payment_method.card.id
  memory_storage    = "ram"

  cloud_provider {
    provider = "AWS"

    region {
      region                     = var.aws_region
      networking_deployment_cidr = var.deployment_cidr
    }
  }

  creation_plan {
    dataset_size_in_gb = var.dataset_size_in_gb
    quantity                    = 1
    replication                 = true
    throughput_measurement_by   = "operations-per-second"
    throughput_measurement_value = var.ops_per_second
  }
}

############################################
# CREATE DATABASE
############################################

resource "rediscloud_subscription_database" "db" {
  subscription_id = rediscloud_subscription.pro.id
  name            = var.database_name

  dataset_size_in_gb           = var.dataset_size_in_gb
  throughput_measurement_by    = "operations-per-second"
  throughput_measurement_value  = var.ops_per_second
  data_persistence             = var.data_persistence
  replication                  = true
}

############################################
# OUTPUTS
############################################

output "subscription_id" {
  value = rediscloud_subscription.pro.id
}

output "database_id" {
  value = rediscloud_subscription_database.db.db_id
}