# README.md 추가하기

현재 Terraform 프로젝트 내 모든 모듈에는 모듈과 관련하여 문서가 전혀 없습니다.
[Terraform 표준 모듈 구조](https://www.terraform.io/language/modules/develop/structure)에서도 `README.md` 는 모듈 내애 항상 포함이 되어 있습니다.

이번 장에서는 [terraform-docs](https://terraform-docs.io/)라는 도구를 통해 모듈에 대한 기본적인 `README.md` 파일을 작성하는 방법에 대해 알아봅시다.

## terraform-docs 설치

먼저 다음처럼 terraform-docs를 설치합니다.

```bash
$ brew install terraform-docs
```

!!! Tip

    macOS가 아닌 환경에서의 설치 방법은 [terraform-docs 공식 문서](https://terraform-docs.io/user-guide/installation/)를 확인하세요.

## terraform-docs 사용하기

프로젝트 상단에서 다음 명렁어를 입력합니다.

```bash
$ terraform-docs markdown table . 

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.33.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_iam"></a> [iam](#module\_iam) | ./modules/iam | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_credentials_file"></a> [credentials\_file](#input\_credentials\_file) | gcp serviceaccount used by terraform json file path | `string` | n/a | yes |
| <a name="input_gce_ssh_pub_key_file"></a> [gce\_ssh\_pub\_key\_file](#input\_gce\_ssh\_pub\_key\_file) | gce public key used by ssh file path | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | gcp project id | `string` | `"storied-channel-359115"` | no |

## Outputs

No outputs.
```

결과로 위처럼 모듈 내에 대한 정보가 테이블 형태로 표현되고, 마크다운 포맷으로 출력되는 것을 확인할 수 있습니다.

## 설정 파일 작성하기

프로젝트 상단 뿐 아니라 프로젝트 내 모든 모듈에 대해서 `README.md` 를 작성해봅시다.

프로젝트 상단에 다음같이 `.terraform-docs.yml` 파일을 만들고 다음처럼 작성합니다.

```yaml title=".terraform-docs.yml"
formatter: "markdown table"

recursive:
  enabled: true

output:
  file: README.md

settings:
  hide-empty: true
```

이제 다음 명령어를 입력합니다.

```bash
$ terraform-docs .

README.md updated successfully
modules/compute/README.md updated successfully
modules/iam/README.md updated successfully
modules/network/README.md updated successfully
modules/storage/README.md updated successfully
```

모든 모듈에 대해 `README.md` 가 업데이트 되었다는 메시지가 등장합니다.
실제로 그런지 확인해봅시다.

```bash
$ tree . -P "README.md"
.
├── README.md
└── modules
    ├── compute
    │   └── README.md
    ├── iam
    │   └── README.md
    ├── network
    │   └── README.md
    └── storage
        └── README.md

5 directories, 5 files
```

`README.md` 파일을 하나 열어서 잘 작성되었는지도 확인해봅시다.

```bash
$ cat README.md

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | 4.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_compute"></a> [compute](#module\_compute) | ./modules/compute | n/a |
| <a name="module_iam"></a> [iam](#module\_iam) | ./modules/iam | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/network | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_credentials_file"></a> [credentials\_file](#input\_credentials\_file) | gcp serviceaccount used by terraform json file path | `string` | n/a | yes |
| <a name="input_gce_ssh_pub_key_file"></a> [gce\_ssh\_pub\_key\_file](#input\_gce\_ssh\_pub\_key\_file) | gce public key used by ssh file path | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | gcp project id | `string` | `"storied-channel-359115"` | no |
<!-- END_TF_DOCS -->% 
```

잘 작성된 것을 확인하였습니다.

## Pre-commit에 추가하기

이 기능을 pre-commit에 추가해봅시다.
pre-commit에 추가하게 되면 매번 `terraform-docs` 명령어를 입력하지 않더라도, Commit 전에 자동으로 이를 실행하여 `README.md` 문서를 업데이트하거나 새로 만들어줍니다.

먼저 다음처럼 `.terraform-docs.yml` 을 수정하는 작업이 선행되어야 합니다.

```yaml title=".terraform-docs.yml" hl_lines="3-4"
formatter: "markdown table"

# recursive:
#   enabled: true

output:
  file: README.md

settings:
  hide-empty: true
```

pre-commit은 재귀적으로 Git Stage에 올라온 파일에 대하여 작업을 진행하는데, 이 때 terraform-docs의 `recursive` 옵션이 켜져있다면 꼬일 수 있기 때문입니다. 이는 공식 문서에 나온 권고사항입니다.

이제 `.pre-commit-config.yaml` 에 다음 hook을 추가합니다.

```yaml title=".pre-commit-config.yaml"
repos:
- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: v1.74.1
  hooks:
  ...
  - id: terraform_docs
    args:
    - --args=--config=practice/.terraform-docs.yml
```

??? "전체 코드 보기"

    ```yaml title=".pre-commit-config.yaml"
    repos:
    - repo: https://github.com/antonbabenko/pre-commit-terraform
      rev: v1.74.1
      hooks:
      - id: terraform_validate
      - id: terraform_fmt
      - id: terraform_tflint
        args:
        - --args=--config=__GIT_WORKING_DIR__/practice/.tflint.hcl
      - id: terraform_docs
        args:
        - --args=--config=practice/.terraform-docs.yml
    ```

변경사항을 커밋합니다.

```
$ git add .terraform-docs.yml
$ git add .pre-commit-config.yaml
$ git commit -m "Add terraform_docs hook into .pre-commit-config.yaml"
```
