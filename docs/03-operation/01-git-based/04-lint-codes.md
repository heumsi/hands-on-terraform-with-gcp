# 코드 Linting 하기

Terraform CLI 명령어 중 `validate` 나 `fmt` 는 프로젝트 내 설정 파일에 대한 Validation이나 코드 스타일을 포매팅할 뿐, 기타 다른 문법 오류나 값에 대한 오류는 체크하지 못합니다.

예를 들어, `google_compute_instance` 리소스 내 `machine_type` 이 다음처럼 작성되었다고 합시다.

```tf title="modules/compute/main.tf"
resource "google_compute_instance" "hotwg_asne3_prod_1" {
  ...
  machine_type = "e12-medium"
```

`e12-medium` 은 GCP에서 실제로 존재하지 않는 `machine_type` 값입니다.
이런 값은 타이핑 중 실수로 생긴 오타일 가능성이 높습니다.
그러나 이러한 문제를 `apply` 명령을 치기 전에는 알 수 없습니다.

사전에 이런 문제를 미리 파악하려면 [tflint](https://github.com/terraform-linters/tflint)라는 별도의 도구를 사용해야 합니다.
이번 장에서는 이 tflint를 설치하고 사용하는 방법에 대해 알아봅시다.

## TFLint 설치하기

먼저 다음처럼 tflint를 설치합니다.

```bash
$ brew install tflint
```

!!! Tip

    macOS가 아닌 환경에서의 설치 방법은 [tflint 공식 문서](https://github.com/terraform-linters/tflint)를 확인하세요.

## Plugin 설치하기

Cloud Provider (AWS, GCP, Azure 등등)에 따라 별도의 Plugin을 설치해야 합니다.

`modules/compute` 경로에 `.tflint.hcl` 파일을 만든 뒤, 다음 내용을 작성합니다.

```hcl title="modules/compute/.tflint.hcl"
plugin "google" {
    enabled = true
    version = "0.19.0"
    source  = "github.com/terraform-linters/tflint-ruleset-google"
}
```

이제 다음처럼 초기화합니다.

```bash
$ tflint --init
```

## TFLint 사용하기

이제 tflint를 사용해봅시다.
`machine_type` 값이 다음처럼 되어 있다고 해봅시다.

```tf title="modules/compute/main.tf"
resource "google_compute_instance" "hotwg_asne3_prod_1" {
  ...
  machine_type = "e12-medium"
}
```

`modules/compute` 경로에서 다음 명령어를 입력합니다.

```bash
$ tflint

1 issue(s) found:

Error: "e12-medium" is an invalid as machine type (google_compute_instance_invalid_machine_type)

  on main.tf line 3:
   3:   machine_type = "e12-medium"
```

그러면 위처럼 실패하며 `e12-medium` 값이 잘못되었다는 메시지가 등장하게 됩니다.

## TFLint 모듈 린팅 제한사항

Terraform Project 내 모든 파일에 대해서 이렇게 린팅하려면 어떻게 해야할까요?
`.tflint.hcl` 파일을 프로젝트 상단으로 옮기고, 프로젝트 상단에서 `tflint` 명령어를 입력하면 될거 같습니다.
이 작업을 진행해봅시다.

```bash
$ mv .tflint.hcl ../../
$ cd ../../
$ tflint
```

그러나 아까와 같은 에러 메시지가 등장하지 않습니다. 왜 이럴까요?

TFLint는 현재 디렉토리에 존재하는 모듈에 대해서만 린팅합니다. 즉 `modules/compute`  내에 있는 리소는 현재 디렉토리가 아니기 때문에 `tflint` 의 대상이 되지 못하는 것입니다. 이 이유는 [tflint 공식 문서 중 일부](https://github.com/terraform-linters/tflint#does-tflint-check-modules-recursively)에 잘 설명 되어 있습니다.

TFLint의 기본적인 한계는 현재 디렉토리에 존재하는 모듈만 검사한다는 것입니다.

!!! Info

    `tflint` 의 `--module` 옵션도 존재하지만, 이 역시 모듈 이름을 일일이 넘겨줘야 해서 사용하기가 어렵습니다.


## Pre-commit으로 해결하기

앞으로 모듈이 수정될 때마다 매번 해당 모듈 디렉토리에서 `tflint` 명령어를 입력하여 확인하기는 꽤 번거롭습니다.
그런데 다음처럼 pre-commit을 이용하면 이 부분을 자동화 할 수 있습니다.

`.pre-commit-config.yaml` 에 다음 hook을 추가합니다.

```yaml title=".pre-commit-config.yaml"
repos:
- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: v1.74.1
  hooks:
  ...
  - id: terraform_tflint
    args:
      - --args=--config=__GIT_WORKING_DIR__/practice/.tflint.hcl
```

??? "전체 코드 보기"

    ```pre-commit title=".pre-commit-config.yaml"
    repos:
    - repo: https://github.com/antonbabenko/pre-commit-terraform
      rev: v1.74.1
      hooks:
      - id: terragrunt_validate
      - id: terraform_fmt
      - id: terraform_tflint
        args:
          - --args=--config=__GIT_WORKING_DIR__/practice/.tflint.hcl
    ```

프로젝트 상단에 `.tflint.hcl` 를 두고, 매번 변경되는 파일에 대해 `tflint` 가 수행되도록 한 것입니다.

실제로 잘 작동하는지 확인해봅시다.

```bash
$ git add .pre-commit-config.yaml
$ git add modules/compute/main.tf
$ pre-commit run  
               
[WARNING] Unstaged files detected.
[INFO] Stashing unstaged files to /Users/user/.cache/pre-commit/patch1662188595-38863.
Terraform validate.......................................................Passed
Terraform fmt............................................................Passed
Terraform validate with tflint...........................................Failed
- hook id: terraform_tflint
- exit code: 2

\e[0m\e[33mTFLint in practice/modules/compute/:\e[0m
1 issue(s) found:

Error: "e12-medium" is an invalid as machine type (google_compute_instance_invalid_machine_type)

  on main.tf line 3:
   3:   machine_type = "e12-medium"
```

이제 pre-commit을 통해 자동으로 `tflint` 를 실행해주어서, commit 전에 어떤 문제가 있는지 확인할 수 있습니다.

변경사항을 커밋합니다.

```
$ git add .tflint.hcl
$ git add .pre-commit-config.yaml
$ git commit -m "Add terraform_tflint hook into .pre-commit-config.yaml"
```