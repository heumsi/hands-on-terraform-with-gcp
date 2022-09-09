# External Static IP 생성하기

생성한 GCE 인스턴스에 퍼블릭 인터넷에서 접근할 수 있도록 외부 고정 IP를 부여해봅시다.

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
  network_interface {
    ...
    access_config {
      nat_ip = google_compute_address.hotwg_asne3_prod_1.address
    }
  }
  ...
}

resource "google_compute_address" "hotwg_asne3_prod_1" {
  name = "hotwg-asne3-prod-1"
  region = "asia-northeast3"
}
```

!!! Info

    `google_compute_address` 리소스는 [공식 문서](https://registry.terraform.io/providers/hashicorp/google/4.33.0/docs/resources/compute_address)에서 더 자세하게 확인하실 수 있습니다.

!!! Tip

    External IP의 네이밍 컨벤션은 `{프로젝트 이름}-{리전 이름}-{환경 이름}-{시퀀스 넘버}` 로 주었습니다.

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
    }

    resource "google_compute_address" "hotwg_asne3_prod_1" {
      name = "hotwg-asne3-prod-1"
      region = "asia-northeast3"
    }
    ```

## 플랜 확인하기

다음처럼 플랜을 확인합니다.

```bash
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create
  ~ update in-place

Terraform will perform the following actions:

  # google_compute_address.hotwg_asne3_prod_1 will be created
  + resource "google_compute_address" "hotwg_asne3_prod_1" {
      + address            = (known after apply)
      + address_type       = "EXTERNAL"
      + creation_timestamp = (known after apply)
      + id                 = (known after apply)
      + name               = "hotwg-asne3-prod-1"
      + network_tier       = (known after apply)
      + project            = (known after apply)
      + purpose            = (known after apply)
      + region             = "asia-northeast3"
      + self_link          = (known after apply)
      + subnetwork         = (known after apply)
      + users              = (known after apply)
    }

  # google_compute_instance.hotwg_asne3_prod_1 will be updated in-place
  ~ resource "google_compute_instance" "hotwg_asne3_prod_1" {
        id                   = "projects/storied-channel-359115/zones/asia-northeast3-c/instances/hotwg-asne3-prod-1"
        name                 = "hotwg-asne3-prod-1"
        tags                 = []
        # (17 unchanged attributes hidden)

      ~ network_interface {
            name               = "nic0"
            # (6 unchanged attributes hidden)

          + access_config {
              + nat_ip = (known after apply)
            }
        }

        # (4 unchanged blocks hidden)
    }

Plan: 1 to add, 1 to change, 0 to destroy.
```

## 적용하기

다음처럼 플랜을 적용합니다.

```bash
$ terraform apply
```
