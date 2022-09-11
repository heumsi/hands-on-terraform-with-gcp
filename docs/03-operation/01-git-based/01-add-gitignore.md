# .gitignore 추가하기

Terraform 프로젝트에서 `*.tfvars` 등의 파일들은 비밀 정보를 포함하고 있을 수 있기 때문에 일반적으로 커밋 내역에 포함시키지 않아야 합니다. `.gitignore` 에 포힘시킬 항목들을 추가해봅시다.

먼저 프로젝트 최상단에 다음처럼 `.gitignore` 파일을 만듭니다.

```bash
$ touch .gitignore
```

파일을 열어 다음처럼 작성하고 저장합니다.

```gitignore title=".gitignore"
# Local .terraform directories
**/.terraform/*

# .tfstate files
*.tfstate
*.tfstate.*

# Crash log files
crash.log
crash.*.log

# Exclude all .tfvars files, which are likely to contain sensitive data, such as
# password, private keys, and other secrets. These should not be part of version 
# control as they are data points which are potentially sensitive and subject 
# to change depending on the environment.
*.tfvars
*.tfvars.json

# Ignore override files as they are usually used to override resources locally and so
# are not checked in
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# Include override files you do wish to add to version control using negated pattern
# !example_override.tf

# Include tfplan files to ignore the plan output of command: terraform plan -out=tfplan
# example: *tfplan*

# Ignore CLI configuration files
.terraformrc
terraform.rc
```

이제 프로젝트 내 모든 파일들을 커밋해도 괜찮습니다.

```bash
$ git add .
$ git commit -m "Add all currrent terraform files"
```
