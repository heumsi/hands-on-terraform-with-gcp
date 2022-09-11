# 코드 Valdiation 하기

Terraform CLI의 `validate` 명령어를 통해 현재 프로젝트 내 설정에 문제가 있는지 다음처럼 확인할 수 있습니다.

```bash
$ terraform validate

Success! The configuration is valid.
```

현재는 문제가 없기 때문에 결과가 성공으로 나옵니다.

만약 다음과 같이 `main.tf` 내 `terraform` 의 `backend` 값에 오타가 있다고 해봅시다.

```tf title="main.tf"
...
terraform {
  ...
  backends "gcs" {  # backend가 아니라 backends로 오타가 생긴 경우
    bucket = "hotwg-asne3-tfstate-prod-1"
  }
}
```

이 때는 다음과 같이 Validaiton이 실패하게 됩니다.

```
$ terraform validate 
╷
│ Error: Unsupported block type
│ 
│   on main.tf line 9, in terraform:
│    9:   backends "gcs" {
│ 
│ Blocks of type "backends" are not expected here. Did you mean "backend"?
╵
```

!!! Tip

    `validate` 명령어는 다음과 같은 옵션이 존재합니다.

    ```bash
    $ terraform validate --help

    Usage: terraform [global options] validate [options]

      Validate the configuration files in a directory, referring only to the
      configuration and not accessing any remote services such as remote state,
      provider APIs, etc.

      Validate runs checks that verify whether a configuration is syntactically
      valid and internally consistent, regardless of any provided variables or
      existing state. It is thus primarily useful for general verification of
      reusable modules, including correctness of attribute names and value types.

      It is safe to run this command automatically, for example as a post-save
      check in a text editor or as a test step for a re-usable module in a CI
      system.

      Validation requires an initialized working directory with any referenced
      plugins and modules installed. To initialize a working directory for
      validation without accessing any configured remote backend, use:
          terraform init -backend=false

      To verify configuration in the context of a particular run (a particular
      target workspace, input variable values, etc), use the 'terraform plan'
      command instead, which includes an implied validation check.

    Options:

      -json        Produce output in a machine-readable JSON format, suitable for
                  use in text editor integrations and other automated systems.
                  Always disables color.

      -no-color    If specified, output won't contain any color.
    ```

이제 이 기능을 pre-commit에 추가해봅시다.

`.pre-commit-config.yaml` 에 다음 내용을 추가합니다.

```pre-commit title=".pre-commit-config.yaml"
repos:
- repo: https://github.com/antonbabenko/pre-commit-terraform
  rev: v1.74.1
  hooks:
  - id: terraform_validate
```

변경사항을 커밋합니다.

```
$ git add .pre-commit-config.yaml
$ git commit -m "Add terraform_validate hook into .pre-commit-config.yaml"
```

!!! Info

    위 pre-commit-config 에서는 Terraform CLI를 직접 사용하지 않고, [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform)에 정의되어 있는 hook을 가져다 사용합니다.
    이렇게 사용하는 이유는, 이미 위 hook에서 사용하기 편하게 잘 만들어놨기 때문입니다.
