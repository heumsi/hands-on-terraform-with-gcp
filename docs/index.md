# 들어가며

이 문서는 Terraform을 이제 막 배우기 시작한 분이 쉽게 Terraform을 실습하며, 최종적으로는 팀에 도입하여 사용할 수 있게끔 도움이 되고자 작성하였습니다.
클라우드 벤더는 GCP를 사용합니다.

Terraform의 내용은 꽤 방대하며, 모든 내용을 여기서 다루기는 어렵습니다. 
여기서는 독자가 Terraform이 어떤 역할을 하는지 이미 알고있고, 어느정도 관심은 있지만 아직 제대로 실습해보지 않은 상태임을 가정하고, 독자가 Terraform 사용에 대한 전반적인 감을 잡는 것을 목표로 합니다.

Terraform에 대한 소개는 구글링하면 많이 나오므로, 여기서 소개는 생략하겠습니다.
구체적으로 다음에 대한 내용들을 다룹니다.

- Terraform으로 빠르게 GCE 인스턴스를 배포하는 방법
- 리팩토링을 하며 Terraform 프로젝트를 표준 모듈 구조로 만드는 방법
- GitOps 기반으로 운영하는 방법

사실 저도 이번에 Terraform을 처음 공부하며 차근차근 정리해본 것이라, 이상하거나 잘못된 내용이 포함될 수 있습니다.
이런 부분을 발견하시면 Github 이슈나 PR 주시면 정말 감사하겠습니다 🙏.

그러면 이제 시작해봅시다!
