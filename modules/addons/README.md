# modules/addons

`addons` 관련 재사용 Terraform 모듈을 작성하는 위치입니다.

공통 구조 단계에서는 README만 둡니다.  
실제 리소스 코드는 이후 PR에서 추가합니다.


## IAM Role 주의

이 모듈에서 IAM Role을 생성한다면 반드시 다음을 지켜야 합니다.

```hcl
name                 = "${var.name_prefix}-..."
permissions_boundary = var.iam_role_permissions_boundary
```

학원 정책상 Role 이름은 `team6-*` 형태여야 하며, permissions boundary가 없으면 생성이 거부될 수 있습니다.

