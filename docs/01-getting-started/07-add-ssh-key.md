# SSH로 접속하기

GCE 인스턴스에 ssh 접속하기 위해 공개키를 인스턴스에 넣어둔 뒤, ssh 접속을 시도해봅시다.

## 작업 범위

이번 파트에서 다룰 작업 범위는 다음과 같습니다.

```tree hl_lines="2-3"
.
├── main.tf
├── terraform.tfvars
└── variables.tf
```

## 코드 작성하기

코드가 담긴 파일을 열어 다음 내용을 추가합니다.

```tf title="terraform.tfvars"
gce_ssh_pub_key_file = "~/.ssh/id_rsa.pub"
```

!!! Info

    여기서는 사용할 공개키와 비공개키가 `~/.ssh/id_rsa.pub` 과 `~/.ssh/id_rsa` 에 저장되어 있다고 전제합니다.

    만약 공개키와 비공개키를 아직 만들지 않았다면 다음 명령어로 생성합니다.

    ```bash
    $ ssh-keygen
    ```

    자세한 내용은 [이 문서](https://git-scm.com/book/ko/v2/Git-%EC%84%9C%EB%B2%84-SSH-%EA%B3%B5%EA%B0%9C%ED%82%A4-%EB%A7%8C%EB%93%A4%EA%B8%B0)를 확인하세요.

??? "전체 코드 보기"

    ```tf title="terraform.tfvars"
    project              = "storied-channel-359115"
    credentials_file     = "/Users/user/Desktop/heumsi/credentials/gcp/sa/terraform.json"
    gce_ssh_pub_key_file = "~/.ssh/id_rsa.pub"
    ```

```tf title="main.tf"
resource "google_compute_instance" "hotwg_asne3_prod_1" {
  ...
  metadata = {
    ssh-keys = "default:${file(var.gce_ssh_pub_key_file)}"
  }
}
```

??? "전체 코드 보기"

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

      metadata = {
        ssh-keys = "default:${file(var.gce_ssh_pub_key_file)}"
      }
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
      target_tags   = ["allow-ssh"]
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
      target_tags   = ["allow-http"]
    }

## 플랜 확인하기

다음처럼 플랜을 확인합니다.

```bash
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  ~ update in-place

Terraform will perform the following actions:

  # google_compute_instance.hotwg_asne3_prod_1 will be updated in-place
  ~ resource "google_compute_instance" "hotwg_asne3_prod_1" {
        id                   = "projects/storied-channel-359115/zones/asia-northeast3-c/instances/hotwg-asne3-prod-1"
      ~ metadata             = {
          ~ "ssh-keys" = <<-EOT
              - ydrah:ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBA7tkve2eNuUBWPEI+flCju08CEvNggzW/BNwCxUWXnwhhlENQlyqEDUB1UQAheCEIny2BfrDvCehokWx6cdwjs= google-ssh {"userName":"heumsi@gmail.com","expireOn":"2022-08-30T13:38:52+0000"}
              - ydrah:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAHPUhqlbtqD4GKybmqNUBRUSCDNa/nQ7uYEuzUbGbRZLtp6FoJw8o20x/eCaIvO9ZvDFsOx+eJfhNa5/6OoRg8NgGhFKQiwnDgIX9WTAqxXFjkttLUtlXbzwzDaZD6cGE6J/h+PLQ/FfRpyyQ+pjC42wOC5HcIm4D9tyrsstwn5G13VGveedaGrmmqqt3NgdZJUZw78HsZ5OctVpInumofSP5lZVC4GeiKf8azX1jBK0EZG2UrDqvFHQVdGJTy6WKQnik7Ykl4kEDsw49LUZZdcnCuIzuytNuF8yRzBsX/efvv54/5Nsk7oq8JGgxmfaaCKCXvlJu38P8xoOq02daDM= google-ssh {"userName":"heumsi@gmail.com","expireOn":"2022-08-30T13:39:07+0000"}
              + default:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCwdCxPcVEslNkuIA508cd8xRucUIIdKy8PNdHzoFLOzt1HXUtDD6y/pVmqEut4P6DMPPt7WNI8JkqBL7a9FlFIHmLK5hR7aHVKJt7bL/bHacdIH3MagjfwRBmHGY2kTEP+/WSVW6bhqyI5P5dFy22RZt7POqvvzCYnp5rzzl8JBDOjjtLmQz1XwK0Hoa5ue3W1GX8N+TxUo5/psNM4WhHHPZRkRr/lSZqhO4QfwjGK3K88YVyR0kZWWCDsEW/zRZrJgU9/q8oU161Fu/vTZBDw9FoYRfCQ1FfjAw1Wpp1ftXI3hkAyGFf9Ezvfuv5teVO0JnAs5HQ7h8BFw92J45AUSAXcG/yoezqMj/vW3FP08geQhLCZaohc70A5PNkBv90ByACebsOaQ6dbrcdzlZr2KMe2noT9zyr0KMcDmrB7wyUf8jqdRJE7HY4epK+VNwqeZnpvj3n+fHURD2k+Bs8Cpoa6FYfXYW1iRCb+Xe7V7eqHBHTvtGz9o2SfY2a/cC8= user@AL02261967.local
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

## 적용하기

다음처럼 플랜을 적용합니다.

```bash
$ terraform apply
```

## ssh로 접속하기

다음처럼 로컬에서 ssh로 접속을 시도해봅시다.

```bash
$ ssh default@34.64.70.213

Linux hotwg-asne3-prod-1 5.10.0-17-cloud-amd64 #1 SMP Debian 5.10.136-1 (2022-08-13) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Tue Aug 30 13:49:36 2022 from 112.172.225.180

default@hotwg-asne3-prod-1:~$
```

성공적으로 잘 접속한 것을 확인할 수 있습니다.
