# 개요

Git을 사용하면서 코드를 팀원과 공유하며 협업해야할 때 Git 호스팅 서비스는 거의 필수적으로 사용하곤 합니다. 또한 Git 호스팅 서비스의 여러 기능을 활용하면 좀 더 정교하게 운영하는 것이 가능해집니다.

이번 서브 챕터에서는 Terraform 프로젝트를 Github 기반으로 운영하고 자동화하는 방법에 대해 알아봅니다.

## 사전 준비

### Github에 대한 이해

Github에 대해 미리 알고 있어야합니다. 만약 Github를 처음 접하시는 분들은 [44BITS 블로그 글](https://www.44bits.io/ko/keyword/github)을 읽어보시길 추천드립니다.

사전 준비가 완료되면 다음과 같은 것들이 준비가 되어있어야 합니다.

- Terraform 프로젝트를 저장할 수 있는 Github Repository

### Github Actions에 대한 이해

Github가 제공하는 기능 중 하나인 Github Actions에 대해 미리 알고 있어야합니다. 만약 Github Actions를 처음 접하시는 분들은 [Daleseo 블로그 글](https://www.daleseo.com/github-actions-basics/)을 읽어보시길 추천드립니다. 

사전 준비가 완료되면 다음의 것들을 이해할 수 있어야 합니다.

- Github Actions을 위한 yaml을 작성하는 방법
  