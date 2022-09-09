# Project 초기화 하기

Project에 사용할 디렉토리를 만들고, Terraform 프로젝트를 초기화해봅시다.

## 프로젝트 디렉토리 만들기

Terraform 실습 프로젝트를 구성할 디렉토리를 다음처럼 만들고 진입합니다.

```bash
$ mkdir practice
$ cd practice 
```

## 코드 작성하기

다음과 같이 3개의 파일을 작성할 예정입니다.

```tree
.
├── main.tf
├── terraform.tfvars
└── variables.tf
```

각 파일을 다음처럼 작성합니다.

```tf title="variables.tf"
variable "project" {
}

variable "credentials_file" {
}
```

```tf title="terraform.tfvars"
project          = "storied-channel-359115"
credentials_file = "/Users/user/Desktop/heumsi/credentials/gcp/sa/terraform.json"
```

!!! Info

    Terraform이 사용할 ServiceAccount JSON 파일이 미리 `credentials_file` 로 지정한 경로에 있다고 전제합니다. 

    만약 아직 ServiceAccount JSON 파일을 로컬에 저장하지 않았다면, [이 문서](https://learn.hashicorp.com/tutorials/terraform/google-cloud-platform-build#set-up-gcp)를 참고하여 로컬에 저장해주세요.

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
  region  = var.region
  zone    = var.zone
}
```

## 프로젝트 초기화 하기

이제 다음 프로젝트를 다음처럼 초기화합니다.

```bash
$ terraform init
```
