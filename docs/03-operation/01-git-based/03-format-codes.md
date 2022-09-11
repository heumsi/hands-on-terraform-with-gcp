# 코드 Formatting 하기

Terraform에는 공식적인 코드 스타일이 존재합니다. 
다음 CLI 명령어로 현재 프로젝트 내 모든 코드를 이 스타일에 맞게 포매팅할 수 있습니다.

```bash
$ terraform fmt
```

현재는 문제가 없기 때문에 결과에 아무것도 등장하지 않습니다.

만약 다음과 같이 `main.tf` 이 다음과 같이 작성되었다고 해봅시다.

```tf title="main.tf"
...
module "compute" {
  ...
  subnetwork = module.network.google_compute_subnetwork["hotwg_asne3_prod_1"]
  nat_ip = module.network.google_compute_address["hotwg_asne3_prod_1"]
  service_account = module.iam.service_accounts["gce"]
}
```

위 코드는 문법적으로 문제가 될건 없지만, Terraform 공식 코드 스타일은 아닙니다.
이제 다시 다음처럼 CLI 명령어를 입력해봅시다.

```bash
$ terraform fmt

main.tf
```

이번엔 출력 결과로 `main.tf` 가 등장하는데, 위 명령어로 포매팅이 수행된 파일의 이름입니다.

이제 `main.tf` 를 열어 확인해보면 다음처럼 포매팅이 되어있는 것을 확인할 수 있습니다.

```tf title="main.tf"
...
module "compute" {
  ...
  subnetwork      = module.network.google_compute_subnetwork["hotwg_asne3_prod_1"]
  nat_ip          = module.network.google_compute_address["hotwg_asne3_prod_1"]
  service_account = module.iam.service_accounts["gce"]
}
```

!!! Tip

    `fmt` 명령어는 다음과 같은 옵션이 존재합니다.

    ```bash
    $ terraform fmt --help

    Usage: terraform [global options] fmt [options] [TARGET]

      Rewrites all Terraform configuration files to a canonical format. Both
      configuration files (.tf) and variables files (.tfvars) are updated.
      JSON files (.tf.json or .tfvars.json) are not modified.

      If TARGET is not specified, the command uses the current working directory.
      If TARGET is a file, the command only uses the specified file. If TARGET
      is "-" then the command reads from STDIN.

      The content must be in the Terraform language native syntax; JSON is not
      supported.

    Options:

      -list=false    Don't list files whose formatting differs
                    (always disabled if using STDIN)

      -write=false   Don't write to source files
                    (always disabled if using STDIN or -check)

      -diff          Display diffs of formatting changes

      -check         Check if the input is formatted. Exit status will be 0 if all
                    input is properly formatted and non-zero otherwise.

      -no-color      If specified, output won't contain any color.

      -recursive     Also process files in subdirectories. By default, only the
                    given directory (or current directory) is processed.
    ```

이제 이 기능을 pre-commit에 추가해봅시다.

`.pre-commit-config.yaml` 내 `hooks` 에 다음 내용을 추가합니다.

```pre-commit title=".pre-commit-config.yaml"
repos:
- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: v1.74.1
  hooks:
  ...
  - id: terraform_fmt
```

??? "전체 코드 보기"

    ```pre-commit title=".pre-commit-config.yaml"
    repos:
    - repo: https://github.com/antonbabenko/pre-commit-terraform
      rev: v1.74.1
      hooks:
      - id: terragrunt_validate
      - id: terraform_fmt
    ```

변경사항을 커밋합니다.

```
$ git add .pre-commit-config.yaml
$ git commit -m "Add terraform_fmt hook into .pre-commit-config.yaml"
```