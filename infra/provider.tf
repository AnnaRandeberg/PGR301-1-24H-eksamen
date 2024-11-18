#source: https://github.com/glennbechdevops/terraform-state/tree/main
terraform {
  required_version = ">= 1.9.0"   #fikset til oppdatert versjon ifølge oppgaven
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.74.0"  #fikset til oppdatert versjon ifølge oppgaven
    }
  }
  
  backend "s3" {
    bucket = "pgr301-2024-terraform-state" 
    key    = "41/terraform.tfstate"       
    region = "eu-west-1"                    
  }
}

provider "aws" {
  region = "eu-west-1" 
}
