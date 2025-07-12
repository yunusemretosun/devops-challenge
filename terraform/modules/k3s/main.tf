terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

resource "null_resource" "install_k3s" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command     = "${path.module}/install_k3s.sh"
    interpreter = ["bash"]
  }
}

