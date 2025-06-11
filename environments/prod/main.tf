terraform {
  required_version = ">= 1.5.0"
}

provider "local" {}

resource "local_file" "example" {
  content  = "Hello, world!"
  filename = "${path.module}/hello.txt"
}
