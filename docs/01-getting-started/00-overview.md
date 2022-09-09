# 개요

이번 챕터에서는 컴퓨팅 인스턴스를 프로비저닝해 볼 것입니다.
간단하기는 하지만 그 과정에 대해 차근차근 알아가며 Terraform으로 작업하는 것에 익숙해져봅시다.

## 사전 준비

다음과 같이 Terraform이 로컬에 설치되어 있어야 합니다.

```bash
$ terraform -version

Terraform v1.2.8
on darwin_arm64
+ provider registry.terraform.io/hashicorp/google v4.33.0

Your version of Terraform is out of date! The latest version
is 1.2.9. You can update by downloading from https://www.terraform.io/downloads.html
```

만약 설치하지 않았다면, [공식 설치 문서](https://learn.hashicorp.com/tutorials/terraform/install-cli)를 참고하시어 설치하시기를 바랍니다.

또한 이 문서에서 Terraform에 대해 모든 걸 알려주지 않는다는 것을 알고계셔야 합니다.
이 문서는 실습을 중심으로 작성되었습니다.
만약 Terraform에 대한 개념이 처음이라면 [공식 튜토리얼 문서](https://learn.hashicorp.com/collections/terraform/gcp-get-started)를 한번 읽고오시기를 권장드립니다. 

## 버전 및 환경

이 문서에서는 다음 버전을 사용합니다.

- Terraform: 1.2.8
- GCP Provider: 4.33.0

그리고 다음 환경에서 진행합니다.

- macOS Monterey 12.3
