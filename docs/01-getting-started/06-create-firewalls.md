# Firewall 생성하기

우리가 프로비저닝한 GCE 인스턴스에 80, 22번 포트를 열어주는 방화벽을 추가하여 http, ssh 접속이 가능하도록 해봅시다.

## 작업 범위

이번 파트에서 다룰 작업 범위는 다음과 같습니다.

```tree hl_lines="2"
.
├── main.tf
├── terraform.tfvars
└── variables.tf
```

## 코드 작성하기

코드가 담긴 파일을 열어 다음 내용을 추가합니다.

```tf title="main.tf"
resource "google_compute_instance" "hotwg_asne3_prod_1" {
  ...
  tags = ["allow-http", "allow-ssh"]
}

resource "google_compute_firewall" "hotwg_prod_1_allow_ssh" {
  name        = "hotwg-prod-1-allow-ssh"
  network     = google_compute_network.hotwg_prod_1.name
  description = "Allow ssh from anywhere"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["allow-ssh"]
}

resource "google_compute_firewall" "hotwg_prod_1_allow_http" {
  name        = "hotwg-prod-1-allow-http"
  network     = google_compute_network.hotwg_prod_1.name
  description = "Allow http from anywhere"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["allow-http"]
}
```

!!! Info

    `google_compute_firewall` 리소스는 [공식 문서](https://registry.terraform.io/providers/hashicorp/google/4.33.0/docs/resources/compute_firewall)에서 더 자세하게 확인하실 수 있습니다.

!!! Tip

    Firewall의 네이밍 컨벤션은 `{프로젝트 이름}-{리전 이름}-{allow | deny}-{프로토콜 이름}` 로 주었습니다.

??? "전체 코드 보기"

    ```tf title="main.tf"
    terraform {
      required_providers {
        google = {
          source  = "hashicorp/google"
          version = "4.33.0"
        }
      }
    }

    provider "google" {
      credentials = file(var.credentials_file)
      project     = var.project
    }

    resource "google_compute_network" "hotwg_prod_1" {
      name                    = "hotwg-prod-1"
      auto_create_subnetworks = false
    }

    resource "google_compute_subnetwork" "hotwg_asne3_prod_1" {
      name          = "hotwg-asne3-prod-1"
      ip_cidr_range = "10.1.0.0/16"
      region        = "asia-northeast3"
      network       = google_compute_network.hotwg_prod_1.id
    }

    resource "google_service_account" "gce" {
      account_id   = "google-compute-engine"
      display_name = "google-compute-engine"
    }

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
        subnetwork = google_compute_subnetwork.hotwg_asne3_prod_1.id
        access_config {
          nat_ip = google_compute_address.hotwg_asne3_prod_1.address
        }
      }

      service_account {
        email  = google_service_account.gce.email
        scopes = ["cloud-platform"]
      }

      tags = ["allow-http", "allow-ssh"]
    }

    resource "google_compute_address" "hotwg_asne3_prod_1" {
      name   = "hotwg-asne3-prod-1"
      region = "asia-northeast3"
    }

    resource "google_compute_firewall" "hotwg_prod_1_allow_ssh" {
      name        = "hotwg-prod-1-allow-ssh"
      network     = google_compute_network.hotwg_prod_1.name
      description = "Allow ssh from anywhere"

      allow {
        protocol = "tcp"
        ports    = ["22"]
      }

      source_ranges = ["0.0.0.0/0"]
      target_tags = ["allow-ssh"]
    }

    resource "google_compute_firewall" "hotwg_prod_1_allow_http" {
      name        = "hotwg-prod-1-allow-http"
      network     = google_compute_network.hotwg_prod_1.name
      description = "Allow http from anywhere"

      allow {
        protocol = "tcp"
        ports    = ["80"]
      }

      source_ranges = ["0.0.0.0/0"]
      target_tags = ["allow-http"]
    }
    ```

## 플랜 확인하기

다음처럼 플랜을 확인합니다.

```bash
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # google_compute_firewall.hotwg_prod_1_allow_http will be created
  + resource "google_compute_firewall" "hotwg_prod_1_allow_http" {
      + creation_timestamp = (known after apply)
      + description        = "Allow http from anywhere"
      + destination_ranges = (known after apply)
      + direction          = (known after apply)
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "hotwg-prod-1-allow-http"
      + network            = "hotwg-prod-1"
      + priority           = 1000
      + project            = (known after apply)
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]
      + target_tags        = [
          + "allow-http",
        ]

      + allow {
          + ports    = [
              + "80",
            ]
          + protocol = "tcp"
        }
    }

  # google_compute_firewall.hotwg_prod_1_allow_ssh will be created
  + resource "google_compute_firewall" "hotwg_prod_1_allow_ssh" {
      + creation_timestamp = (known after apply)
      + description        = "Allow ssh from anywhere"
      + destination_ranges = (known after apply)
      + direction          = (known after apply)
      + enable_logging     = (known after apply)
      + id                 = (known after apply)
      + name               = "hotwg-prod-1-allow-ssh"
      + network            = "hotwg-prod-1"
      + priority           = 1000
      + project            = (known after apply)
      + self_link          = (known after apply)
      + source_ranges      = [
          + "0.0.0.0/0",
        ]
      + target_tags        = [
          + "allow-ssh",
        ]

      + allow {
          + ports    = [
              + "22",
            ]
          + protocol = "tcp"
        }
    }

  # google_compute_instance.hotwg_asne3_prod_1 will be updated in-place
  ~ resource "google_compute_instance" "hotwg_asne3_prod_1" {
        id                   = "projects/storied-channel-359115/zones/asia-northeast3-c/instances/hotwg-asne3-prod-1"
        name                 = "hotwg-asne3-prod-1"
      ~ tags                 = [
          + "allow-http",
          + "allow-ssh",
        ]
        # (17 unchanged attributes hidden)

        # (5 unchanged blocks hidden)
    }

Plan: 2 to add, 1 to change, 0 to destroy.
```

## 적용하기

다음처럼 플랜을 적용합니다.

```bash
$ terraform apply
```
