terraform {
  required_version = ">= 1.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Local state — throwaway test infra, intentionally not co-mingled with the
  # main bouncy-ball-shop state.
}
