# Variables에 타입, 설명 추가하기

Variables에 자료형 타입과 설명을 추가하여 좀 더 풍성하게 표현해봅시다.

## 작업 범위

이번 파트에서 다룰 작업 범위는 다음과 같습니다.

```tree hl_lines="7 21"
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

## 코드 작성하기

코드가 담긴 파일을 열어 다음처럼 `type` 과 `description` 을 추가합니다.

```tf title="variables.tf"
variable "project" {
  type        = string
  description = "gcp project id"
  default     = "storied-channel-359115"
}

variable "credentials_file" {
  type        = string
  description = "gcp serviceaccount used by terraform json file path"
}

variable "gce_ssh_pub_key_file" {
  type        = string
  description = "gce public key used by ssh file path "
}
```

```tf title="modules/compute/variables.tf"
variable "ssh_pub_key_file" {
  description = "gce public key used by ssh file path"
}

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