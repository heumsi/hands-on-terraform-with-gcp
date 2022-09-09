# Remote Backend 설정하기

현재 프로젝트의 Terraform State는 프로젝트 최상단 경로의 `terraform.tfstate` 에 저장되고 있습니다.
이는 우리가 별도의 Backend 설정을 해주지 않았기 때문입니다.

이렇게 로컬 파일로 관리하면 다음과 같은 문제가 있습니다.

- State는 Terraform에서 매우 중요한 컴포넌트입니다. 실수로 파일을 삭제했을 시, 장애 여파가 매우 큽니다.
- 만약 여러 사람이 같이 Terraform 프로젝트를 작업해야 한다고 할 때 `terraform.tfstate` 파일을 공유하기 쉽지 않습니다.

이에 대한 해결 책으로 Terraform에서는 State 파일을 로컬이 아닌 원격에 저장하고 읽을 수 있는 Remote Backend 기능을 제공합니다. 
이번 장에서는 GCS 버킷을 Remote Backend으로 사용하는 방법에 대해 알아봅시다.

## 작업 범위

이번 파트에서 다룰 작업 범위는 다음과 같습니다.

```tree hl_lines="2 16-17"
.
├── main.tf
├── modules
│   ├── compute
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── iam
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   ├── network
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── storage
│       ├── main.tf
│       ├── output.tf
│       └── variables.tf
├── terraform.tfvars
└── variables.tf
```

## GCS 버킷 생성하기

먼저 State 파일을 담을 GCS 버킷을 생성해야 합니다.

다음처럼 `storage` 모듈을 만든 뒤 코드를 작성합니다.

```bash
$ mkdir modules/storage
$ touch modules/storage/main.tf modules/storage/output.tf modules/storage/variables.tf
```

```tf title="module/storage/main.tf"
resource "google_storage_bucket" "hotwg_asne3_tfstate_prod_1" {
  name          = "hotwg-asne3-tfstate-prod-1"
  force_destroy = false
  location      = "asia-northeast3"
  storage_class = "STANDARD"
  versioning {
    enabled = true
  }
}
```

!!! Info

    `google_storage_bucket` 리소스는 [공식 문서](https://registry.terraform.io/providers/hashicorp/google/4.33.0/docs/resources/storage_bucket)에서 더 자세하게 확인하실 수 있습니다.

!!! Tip

    GCS 버킷의 네이밍 컨벤션은 `{프로젝트 이름}-{리전 이름}-{용도}-{환경 이름}-{시퀀스 넘버}` 로 주었습니다.

`main.tf` 에서 이 모듈을 읽어오도록 코드를 추가합니다.

```tf title="main.tf"
module "storage" {
  source = "./modules/storage"
}
```

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

    module "compute" {
      source = "./modules/compute"

      subnetwork       = module.network.google_compute_subnetwork["hotwg_asne3_prod_1"]
      nat_ip           = module.network.google_compute_address["hotwg_asne3_prod_1"]
      service_account  = module.iam.service_accounts["gce"]
      ssh_pub_key_file = var.gce_ssh_pub_key_file
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

다음처럼 플랜을 확인합니다.

```bash
$ terraform plan

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with
the following symbols:
  + create

Terraform will perform the following actions:

  # module.storage.google_storage_bucket.hotwg_asne3_tfstate_prod_1 will be created
  + resource "google_storage_bucket" "hotwg_asne3_tfstate_prod_1" {
      + force_destroy               = false
      + id                          = (known after apply)
      + location                    = "ASIA-NORTHEAST3"
      + name                        = "hotwg_asne3_tfstate-prod-1"
      + project                     = (known after apply)
      + self_link                   = (known after apply)
      + storage_class               = "STANDARD"
      + uniform_bucket_level_access = (known after apply)
      + url                         = (known after apply)

      + versioning {
          + enabled = true
        }
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

다음처럼 적용합니다.

```bash
$ terraform apply
```

## Remote Backend 설정하기

다음처럼 `main.tf` 에 다음처럼 위에서 생성한 GCS 버킷을 Remote Backend으로 설정합니다.

```tf title="main.tf"
terraform {
  ...
  backend "gcs" {
    bucket = "hotwg-asne3-tfstate-prod-1"
  }
}
```

!!! Tip

    Terraform은 Remote Backend로 GCS 외에 여러 Provider를 사용할 수 있습니다.
    이에 대한 자세한 내용은 [공식 문서](https://www.terraform.io/language/settings/backends/local)를 확인하세요.

??? "전체 코드 보기"

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
      credentials = file(var.credentials_file)
      project     = var.project
    }

    module "compute" {
      source = "./modules/compute"

      subnetwork       = module.network.google_compute_subnetwork["hotwg_asne3_prod_1"]
      nat_ip           = module.network.google_compute_address["hotwg_asne3_prod_1"]
      service_account  = module.iam.service_accounts["gce"]
      ssh_pub_key_file = var.gce_ssh_pub_key_file
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

GCS 버킷을 Remote Backend로 사용하려면 다음처럼 `GOOGLE_CREDENTIALS` 라는 이름의 환경 변수에 Terraform이 사용하는 GCP ServiceAccount JSON 파일 경로를 지정해줘야 합니다.

```bash
$ export GOOGLE_CREDENTIALS="./terraform.json
```

이제 다음처럼 State를 Remote Backend로 초기화하고 State를 마이그레이션합니다.

```bash
$ terraform init -migrate-state

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.
```

