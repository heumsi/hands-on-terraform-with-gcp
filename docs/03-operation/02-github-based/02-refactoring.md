# 리팩토링

Github Action을 추가하기 전 기존 코드의 일부를 조금 수정하려고 합니다.

수정하려고 하는 부분은 Terraform Variable과 관련된 부분입니다.
앞으로 Github의 Secret에 Terraform Variable을 저장하고, Github Action 파이프라인에서는 이 Secret에서 필요한 Varaible을 가져오게 됩니다.

이를 위해 일부 파일의 코드들을 다음처럼 수정합니다.

`main.tf` 에서는 GCP에 접근하는 ServiceAccount Credentials을 지정하는 부분을 삭제합니다.
Credentials는 앞으로 환경 변수 지정을 통해 가져올 것입니다.

```tf title="main.tf"
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.33.0"
    }
  }

  backend "gcs" {
    bucket = "hotwg-asne3-tfstate-prod-1"
  }
}

provider "google" {
  project     = var.project
}

module "compute" {
  source = "./modules/compute"

  subnetwork       = module.network.google_compute_subnetwork["hotwg_asne3_prod_1"]
  nat_ip           = module.network.google_compute_address["hotwg_asne3_prod_1"]
  service_account  = module.iam.service_accounts["gce"]
}

module "iam" {
  source = "./modules/iam"
}

module "network" {
  source = "./modules/network"
}

module "storage" {
  source = "./modules/storage"
}
```

`variables.tf` 에서도 꼭 필요한 Variable이 아닌 것들을 삭제합니다.

```tf title="variables.tf"
variable "project" {
  type        = string
  description = "gcp project id"
  default     = "storied-channel-359115"
}
```

Variable 주입은 Github Secret을 통해서 할 것이기 때문에 `variables.tfvars` 은 이제 필요치 않습니다.
이 파일을 삭제합니다.

```
$ rm variables.tfvars
```

`modules/compute/main.tf` 에서 `ssh-keys` 도 Variable을 사용하지 않고 직접 입력합니다.

```tf title="modules/compute/main.tf"
resource "google_compute_instance" "hotwg_asne3_prod_1" {
  name         = "hotwg-asne3-prod-1"
  machine_type = "e2-medium"
  zone         = "asia-northeast3-c"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    subnetwork = var.subnetwork.id
    access_config {
      nat_ip = var.nat_ip.address
    }
  }

  service_account {
    email  = var.service_account.email
    scopes = ["cloud-platform"]
  }

  tags = ["allow-http", "allow-ssh"]

  metadata = {
    ssh-keys = "default:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwdCxPcVEslNkuIA508cd8xRucUIIdKy8PNdHzoFLOzt1HXUtDD6y/pVmqEut4P6DMPPt7WNI8JkqBL7a9FlFIHmLK5hR7aHVKJt7bL/bHacdIH3MagjfwRBmHGY2kTEP+/WSVW6bhqyI5P5dFy22RZt7POqvvzCYnp5rzzl8JBDOjjtLmQz1XwK0Hoa5ue3W1GX8N+TxUo5/psNM4WhHHPZRkRr/lSZqhO4QfwjGK3K88YVyR0kZWWCDsEW/zRZrJgU9/q8oU161Fu/vTZBDw9FoYRfCQ1FfjAw1Wpp1ftXI3hkAyGFf9Ezvfuv5teVO0JnAs5HQ7h8BFw92J45AUSAXcG/yoezqMj/vW3FP08geQhLCZaohc70A5PNkBv90ByACebsOaQ6dbrcdzlZr2KMe2noT9zyr0KMcDmrB7wyUf8jqdRJE7HY4epK+VNwqeZnpvj3n+fHURD2k+Bs8Cpoa6FYfXYW1iRCb+Xe7V7eqHBHTvtGz9o2SfY2a/cC8= user@AL02261967.local"
  }
```

`modules/compute/variables.tf` 에서도 꼭 필요한 Variable만 남깁니다.

```tf title="modules/compute/variables.tf"
variable "service_account" {
  description = "terraform google_service_account resource"
}

variable "subnetwork" {
  description = "terraform google_compute_subnetwortk resource"
}

variable "nat_ip" {
  description = "terraform google_compute_address resource"
}
```

변경되는 플랜을 확인해보면 다음과 같습니다.

```
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated
with the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # module.compute.google_compute_instance.hotwg_asne3_prod_1 will be updated in-place
  ~ resource "google_compute_instance" "hotwg_asne3_prod_1" {
        id                   = "projects/storied-channel-359115/zones/asia-northeast3-c/instances/hotwg-asne3-prod-1"
      ~ metadata             = {
          ~ "ssh-keys" = <<-EOT
                default:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwdCxPcVEslNkuIA508cd8xRucUIIdKy8PNdHzoFLOzt1HXUtDD6y/pVmqEut4P6DMPPt7WNI8JkqBL7a9FlFIHmLK5hR7aHVKJt7bL/bHacdIH3MagjfwRBmHGY2kTEP+/WSVW6bhqyI5P5dFy22RZt7POqvvzCYnp5rzzl8JBDOjjtLmQz1XwK0Hoa5ue3W1GX8N+TxUo5/psNM4WhHHPZRkRr/lSZqhO4QfwjGK3K88YVyR0kZWWCDsEW/zRZrJgU9/q8oU161Fu/vTZBDw9FoYRfCQ1FfjAw1Wpp1ftXI3hkAyGFf9Ezvfuv5teVO0JnAs5HQ7h8BFw92J45AUSAXcG/yoezqMj/vW3FP08geQhLCZaohc70A5PNkBv90ByACebsOaQ6dbrcdzlZr2KMe2noT9zyr0KMcDmrB7wyUf8jqdRJE7HY4epK+VNwqeZnpvj3n+fHURD2k+Bs8Cpoa6FYfXYW1iRCb+Xe7V7eqHBHTvtGz9o2SfY2a/cC8= user@AL02261967.local
            EOT
        }
        name                 = "hotwg-asne3-prod-1"
        tags                 = [
            "allow-http",
            "allow-ssh",
        ]
        # (16 unchanged attributes hidden)

        # (5 unchanged blocks hidden)
    }

Plan: 0 to add, 1 to change, 0 to destroy.
```

이제 변경 사항을 적용합니다.

```
$ terraform apply
```
