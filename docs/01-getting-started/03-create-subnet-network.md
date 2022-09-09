# Subnet Network 생성하기

VPC 생성 이후 일반적으로 Subnet 구축까지 같이 생성해주곤 합니다.
Terraform으로 Subnet 네트워크를 구축해봅시다.

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
resource "google_compute_subnetwork" "hotwg_asne3_prod_1" {
  name          = "hotwg-asne3-prod-1"
  ip_cidr_range = "10.1.0.0/16"
  region        = "asia-northeast3"
  network       = google_compute_network.hotwg_prod_1.id
}
```

!!! Info

    `google_compute_subnetwork` 리소스는 [공식 문서](https://registry.terraform.io/providers/hashicorp/google/4.33.0/docs/resources/compute_subnetwork)에서 더 자세하게 확인하실 수 있습니다.

!!! Tip

    Subnet 네트워크의 네이밍 컨벤션은 `{프로젝트 이름}-{리전 이름}-{환경 이름}-{시퀀스 넘버}` 로 주었습니다.

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
      project = var.project
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
    ```

## 플랜 확인하기

다음처럼 플랜을 확인합니다.

```bash
$ terraform plan  

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_subnetwork.hotwg_asne3_prod_1 will be created
  + resource "google_compute_subnetwork" "hotwg_asne3_prod_1" {
      + creation_timestamp         = (known after apply)
      + external_ipv6_prefix       = (known after apply)
      + fingerprint                = (known after apply)
      + gateway_address            = (known after apply)
      + id                         = (known after apply)
      + ip_cidr_range              = "10.1.0.0/16"
      + ipv6_cidr_range            = (known after apply)
      + name                       = "hotwg-asne3-prod-1"
      + network                    = "projects/storied-channel-359115/global/networks/hotwg-prod-1"
      + private_ipv6_google_access = (known after apply)
      + project                    = (known after apply)
      + purpose                    = (known after apply)
      + region                     = "asia-northeast3"
      + secondary_ip_range         = (known after apply)
      + self_link                  = (known after apply)
      + stack_type                 = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

## 적용하기

다음처럼 플랜을 적용합니다.

```bash
$ terraform apply
```
