# VPC Network 생성하기

클라우드 리소스를 프로비저닝하기 위해 보통 가장 먼저 해야할 일은 VPC를 구축하는 것입니다. Terraform으로 VPC 네트워크를 구축해봅시다.

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
resource "google_compute_network" "hotwg_prod_1" {
    name                    = "hotwg-prod-1"
    auto_create_subnetworks = false
}
```

!!! Info

    `google_compute_network` 리소스는 [공식 문서](https://registry.terraform.io/providers/hashicorp/google/4.33.0/docs/resources/compute_network)에서 더 자세하게 확인하실 수 있습니다.

!!! Tip

    `hotwg` 은 `hands-on-terraform-with-gcp` 의 약자입니다.
    VPC 네트워크의 네이밍 컨벤션은 `{프로젝트 이름}-{리전 이름}-{환경 이름}-{시퀀스 넘버}` 로 주었습니다.

    한편 Terraform에서는 네이밍에 띄어쓰기로 `_` 을 주로 쓰고, GCP에서는 `-` 를 주로 씁니다.
    Terraform 리소스와 GCP 리소스 네이밍은 이 차이만 가지고 나머지 컨벤션은 동일합니다. 

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
    ```

## 플랜 확인하기

다음처럼 플랜을 확인합니다.

```bash
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are
indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_compute_network.hotwg_prod_1 will be created
  + resource "google_compute_network" "hotwg_prod_1" {
      + auto_create_subnetworks         = false
      + delete_default_routes_on_create = false
      + gateway_ipv4                    = (known after apply)
      + id                              = (known after apply)
      + internal_ipv6_range             = (known after apply)
      + mtu                             = (known after apply)
      + name                            = "hotwg-prod-1"
      + project                         = (known after apply)
      + routing_mode                    = (known after apply)
      + self_link                       = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

## 적용하기

다음처럼 플랜을 적용합니다.

```bash
$ terraform apply
```
