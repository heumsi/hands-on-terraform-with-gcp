# 개요

Terraform 코드 역시 다른 여타 애플리케이션 코드와 다르지 않은 코드이기 떄문에 Git으로 버전 관리 하는 것이 아주 유용합니다.
이번 서브 챕터애서는 Terraform을 Git을 기반으로 운영하고 자동화하는 방법에 대해 알아봅니다.

## 사전 준비

### Git에 대한 이해

Git에 대해 미리 알고 있어야합니다.

여기서는 Git에 대해 자세히 설명하지는 않습니다. 만약 Git을 처음 접해보시는 분이라면 [튜토리얼 문서](https://www.w3schools.com/git/)를 읽어보시기를 추천드립니다. (이 문서 아니더라도 구글링하면 쉬운 블로그들이 많이 나옵니다.)

적어도 Git의 다음 명령어들에 대해서 이해하고 사용할 줄 알아야 합니다.

- `git switch` 혹은 `git checkout`
- `git add`
- `git commit`
- `git log`
- `git push`
- `git restore`
- `git reset`

### Pre-commit에 대한 이해

pre-commit에 대해 미리 알고 있어야합니다.

pre-commit을 활용하면 Git으로 Commit 하기 전에 현재 프로젝트 내 변경사항이 우리가 요구하는 특정 조건을 만족했는지 미리 검사하거나, 자동으로 조건에 만족하도록 수정하게 만들 수 있습니다.
pre-commit은 Git으로 코드를 지속적으로 관리하는 경우에 일반적으로 많이 쓰이는 도구입니다.

여기서는 pre-commit에 대해 자세히 설명하지는 않습니다.
만약 pre-commit을 처음 접해보시는 분이라면 [공식 문서](https://pre-commit.com/)를 읽어보시기를 추천드립니다. (공식 문서가 조금 부담스러우신 분은 구글링하면 쉬운 블로그 글들이 많이 나오니 참고하세요.)

이번 서브 챕터의 사전 준비가 완료되면 다음이 준비되어 있어야 합니다.

- 로컬에 pre-commit이 설치되어 있어야 합니다.
- Terraform 프로젝트 상단에 `.pre-commit-config.yaml` (빈 파일)이 생성되어 있어야 합니다.
- `pre-commit install` 명령어를 완료한 상태여야 합니다.
