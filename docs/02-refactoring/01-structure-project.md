# 프로젝트 구조화하기

프로젝트를 좀 더 정교하게 구조화해봅시다. 구조화 방법은 여러가지가 있지만, 여기서는 리소스 중심으로 모듈을 나누어 구조화합니다.

!!! Tip

    이번 장에서는 Terraform의 모듈이라는 문법을 사용합니다. 모듈에 대한 더 자세한 내용이 궁금하시다면 [공식 문서](https://www.terraform.io/language/modules)를 참고하시면 좋을거 같습니다.

## 작업 범위

이번 파트를 통해 프로젝트 구조는 다음처럼 바뀌게 됩니다.

```tree 
# as-is
.
├── main.tf
├── terraform.tfvars
└── variables.tf

# to-be
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
│   └── network
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── terraform.tfvars
└── variables.tf
```

## 리팩토링 하기

각 모듈 별로 리팩토링을 진행해봅시다. 

다음처럼 기존 파일을 수정하거나, 새로운 파일을 추가합니다.

### root

최상단 디렉토리에는 별도의 모듈은 없고, 하위 모듈들을 모두 가져오는 코드를 `main.tf` 에 작성합니다.

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
```

```tf title="terraform.tfvars"
project              = "storied-channel-359115"
credentials_file     = "/Users/user/Desktop/heumsi/credentials/gcp/sa/terraform.json"
gce_ssh_pub_key_file = "~/.ssh/id_rsa.pub"
```

### modules/network

네트워크와 관련된 리소스들을 이 모듈에 담습니다.

```tf title="modules/network/main.tf"
# google_compute_network
resource "google_compute_network" "hotwg_prod_1" {
  name                    = "hotwg-prod-1"
  auto_create_subnetworks = false
}

# google_compute_subnetwork
resource "google_compute_subnetwork" "hotwg_asne3_prod_1" {
  name          = "hotwg-asne3-prod-1"
  ip_cidr_range = "10.1.0.0/16"
  region        = "asia-northeast3"
  network       = google_compute_network.hotwg_prod_1.id
}

# google_compute_firewall
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

# google_compute_address
resource "google_compute_address" "hotwg_asne3_prod_1" {
  name   = "hotwg-asne3-prod-1"
  region = "asia-northeast3"
}
```

```tf title="modules/network/output.tf"
output "google_compute_subnetwork" {
  value = {
    "hotwg_asne3_prod_1" : google_compute_subnetwork.hotwg_asne3_prod_1
  }
}

output "google_compute_address" {
  value = {
    "hotwg_asne3_prod_1" : google_compute_address.hotwg_asne3_prod_1
  }
}
```

### modules/iam

IAM과 관련된 리소스들을 이 모듈에 담습니다.

```tf title="modules/iam/main.tf"
resource "google_service_account" "gce" {
  account_id   = "google-compute-engine"
  display_name = "google-compute-engine"
}
```

```tf title="modules/iam/outputs.tf"
output "service_accounts" {
  value = {
    "gce" : google_service_account.gce
  }
}
```

### modules/compute

컴퓨팅과 관련된 리소스들을 이 모듈에 담습니다.

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
    ssh-keys = "default:${file(var.ssh_pub_key_file)}"
  }
}
```

```tf title="modules/compute/variables.tf"
variable "ssh_pub_key_file" {
}

variable "service_account" {
}

variable "subnetwork" {
}

variable "nat_ip" {
}
```

## State 이전하기

위처럼 파일을 수정 또는 추가 한뒤 `terraform plan` 을 하면 기존에 만들어두었던 리소스들이 모두 삭제된다는 플랜을 보게됩니다.
이렇게 나오는 이유는, 기존 리소스들과 모듈 안으로 옮겨진 리소스를 완전히 다른 리소스로 인식하기 때문입니다. 

리소스는 모두 Terraform State 파일에 저장됩니다. 
따라서 State 파일에 직접 수동으로 기존 리소스와 모듈 내 리소스가 동일한 리소스 임을 1:1로 매핑하며 알려줘야합니다.

이를 위해 `moved` 문법이 존재합니다.
 `main.tf` 에 다음 코드를 추가합니다.

```tf title="main.tf"

moved {
  from = google_compute_firewall.hotwg_prod_1_allow_http
  to   = module.network.google_compute_firewall.hotwg_prod_1_allow_http
}

moved {
  from = google_compute_firewall.hotwg_prod_1_allow_ssh
  to   = module.network.google_compute_firewall.hotwg_prod_1_allow_ssh
}

moved {
  from = google_compute_subnetwork.hotwg_asne3_prod_1
  to   = module.network.google_compute_subnetwork.hotwg_asne3_prod_1
}

moved {
  from = google_service_account.gce
  to   = module.iam.google_service_account.gce
}

moved {
  from = google_compute_network.hotwg_prod_1
  to   = module.network.google_compute_network.hotwg_prod_1
}

moved {
  from = google_compute_instance.hotwg_asne3_prod_1
  to   = module.compute.google_compute_instance.hotwg_asne3_prod_1
}

moved {
  from = google_compute_address.hotwg_asne3_prod_1
  to   = module.network.google_compute_address.hotwg_asne3_prod_1
}
```

!!! Tip

    `moved` 문법에 대해서 더 자세한 내용은 [공식 문서](https://www.terraform.io/language/modules/develop/refactoring#moved-block-syntax)에서 확인해보세요.

??? "전체 코드 보기"

    ```tf title="terraform.tfvars"
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

    moved {
      from = google_compute_firewall.hotwg_prod_1_allow_http
      to   = module.network.google_compute_firewall.hotwg_prod_1_allow_http
    }

    moved {
      from = google_compute_firewall.hotwg_prod_1_allow_ssh
      to   = module.network.google_compute_firewall.hotwg_prod_1_allow_ssh
    }

    moved {
      from = google_compute_subnetwork.hotwg_asne3_prod_1
      to   = module.network.google_compute_subnetwork.hotwg_asne3_prod_1
    }

    moved {
      from = google_service_account.gce
      to   = module.iam.google_service_account.gce
    }

    moved {
      from = google_compute_network.hotwg_prod_1
      to   = module.network.google_compute_network.hotwg_prod_1
    }

    moved {
      from = google_compute_instance.hotwg_asne3_prod_1
      to   = module.compute.google_compute_instance.hotwg_asne3_prod_1
    }

    moved {
      from = google_compute_address.hotwg_asne3_prod_1
      to   = module.network.google_compute_address.hotwg_asne3_prod_1
    }
    ```


이는 State 파일 내 기존 리소스 (`from`) 새로운 리소스 (`to`) 로 매핑하여 새로 저장하겠다는 의미입니다.
이 `moved` 는 한번 적용된 이후 State에 새로이 저장되면 이후 사라져도 될 코드이기도 합니다.

### 플랜 확인하기

이제 다음처럼 플랜을 확인했을 때, State 변화가 없어야 합니다.

```bash
$ terraform plan

No changes. Your infrastructure matches the configuration.
```

## 플랜 적용하기

이제 다음처럼 State를 저장해줍니다.

```bash
$ terraform apply
```
