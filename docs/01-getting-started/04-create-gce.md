# GCE 인스턴스 생성하기

이제 구축한 Subnet 네트워크 위에 GCE 인스턴스를 프로비저닝 해봅시다.

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
  }

  service_account {
    email  = google_service_account.gce.email
    scopes = ["cloud-platform"]
  }
}
```

!!! Info

    `google_service_account` 리소스는 [공식 문서](https://registry.terraform.io/providers/hashicorp/google/4.33.0/docs/resources/google_service_account)에서, `google_compute_instance` 리소스는 [공식 문서](https://registry.terraform.io/providers/hashicorp/google/4.33.0/docs/resources/compute_instance)에서 더 자세하게 확인하실 수 있습니다.

!!! Tip

    GCE 인스턴스의 네이밍 컨벤션은 `{프로젝트 이름}-{리전 이름}-{환경 이름}-{시퀀스 넘버}` 로 주었습니다.

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
      }

      service_account {
        email  = google_service_account.gce.email
        scopes = ["cloud-platform"]
      }
    }
    ```

## 플랜 확인하기

다음처럼 플랜을 확인합니다.

```bash
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource
actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_instance.hotwg_asne3_prod_1 will be created
  + resource "google_compute_instance" "hotwg_asne3_prod_1" {
      + can_ip_forward       = false
      + cpu_platform         = (known after apply)
      + current_status       = (known after apply)
      + deletion_protection  = false
      + guest_accelerator    = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + label_fingerprint    = (known after apply)
      + machine_type         = "e2-medium"
      + metadata_fingerprint = (known after apply)
      + min_cpu_platform     = (known after apply)
      + name                 = "hotwg-asne3-prod-1"
      + project              = (known after apply)
      + self_link            = (known after apply)
      + tags_fingerprint     = (known after apply)
      + zone                 = "asia-northeast3-c"

      + boot_disk {
          + auto_delete                = true
          + device_name                = (known after apply)
          + disk_encryption_key_sha256 = (known after apply)
          + kms_key_self_link          = (known after apply)
          + mode                       = "READ_WRITE"
          + source                     = (known after apply)

          + initialize_params {
              + image  = "debian-cloud/debian-11"
              + labels = (known after apply)
              + size   = (known after apply)
              + type   = (known after apply)
            }
        }

      + confidential_instance_config {
          + enable_confidential_compute = (known after apply)
        }

      + network_interface {
          + ipv6_access_type   = (known after apply)
          + name               = (known after apply)
          + network            = (known after apply)
          + network_ip         = (known after apply)
          + stack_type         = (known after apply)
          + subnetwork         = "projects/storied-channel-359115/regions/asia-northeast3/subnetworks/hotwg-asne3-prod-1"
          + subnetwork_project = (known after apply)
        }

      + reservation_affinity {
          + type = (known after apply)

          + specific_reservation {
              + key    = (known after apply)
              + values = (known after apply)
            }
        }

      + scheduling {
          + automatic_restart           = (known after apply)
          + instance_termination_action = (known after apply)
          + min_node_cpus               = (known after apply)
          + on_host_maintenance         = (known after apply)
          + preemptible                 = (known after apply)
          + provisioning_model          = (known after apply)

          + node_affinities {
              + key      = (known after apply)
              + operator = (known after apply)
              + values   = (known after apply)
            }
        }

      + service_account {
          + email  = (known after apply)
          + scopes = [
              + "https://www.googleapis.com/auth/cloud-platform",
            ]
        }
    }

  # google_service_account.gce will be created
  + resource "google_service_account" "gce" {
      + account_id   = "google-compute-engine"
      + disabled     = false
      + display_name = "google-compute-engine"
      + email        = (known after apply)
      + id           = (known after apply)
      + name         = (known after apply)
      + project      = (known after apply)
      + unique_id    = (known after apply)
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

## 적용하기

다음처럼 플랜을 적용합니다.

```bash
$ terraform apply
```
