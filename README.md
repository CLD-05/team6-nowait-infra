# nowait-infra

NoWait 서비스의 AWS 인프라를 Terraform으로 관리하는 레포지토리입니다.

---

## 아키텍처 개요

```
사용자
  │
  ▼
CloudFront (CDN + HTTPS 종료)
  ├── /api/*  →  ALB  →  EKS (Spring Boot)
  └── /*      →  S3   (React SPA 정적 파일)
                  ▲
               OAC 방식 접근 제어

EKS 내부
  ├── AWS Load Balancer Controller  (ALB 자동 프로비저닝)
  ├── External Secrets Operator     (Secrets Manager 연동)
  ├── metrics-server                (HPA 지원)
  └── ArgoCD                        (GitOps 배포)

데이터 레이어
  ├── RDS (MySQL)
  └── ElastiCache (Redis)

CI/CD
  GitHub Actions → ECR Push → ArgoCD Sync → EKS
  (GitHub OIDC 인증, IAM Role 직접 발급 없음)
```

---

## 폴더 구조

```
nowait-infra/
├── envs/                        # 환경별 Terraform 루트 모듈
│   ├── dev/
│   │   ├── infra/               # VPC, EKS, RDS, Redis, S3, CloudFront
│   │   └── platform-addons/     # EKS 애드온, Helm 릴리즈 (LBC, ESO, ArgoCD 등)
│   ├── prod/
│   │   ├── infra/
│   │   └── platform-addons/
│   ├── global/
│   │   └── iam/                 # GitHub OIDC Provider (dev/prod 공유)
│   └── shared/
│       └── ecr/                 # ECR 레지스트리 (dev/prod 공유)
└── modules/                     # 재사용 가능한 Terraform 모듈
    ├── addons/                  # EKS 네이티브 애드온 + Helm 애드온
    ├── bastion/                 # (미작업 - prod 전환 시 진행)
    ├── cloudfront/              # CloudFront Distribution + OAC
    ├── database/                # RDS
    ├── ecr/                     # ECR 레지스트리
    ├── eks/                     # EKS 클러스터 + 노드그룹
    ├── elasticache/             # Redis Replication Group
    ├── github_oidc_provider/    # GitHub Actions OIDC 인증 Provider
    ├── github_oidc_role/        # GitHub Actions IAM Role
    ├── network/                 # VPC, 서브넷, NAT GW, 라우트 테이블
    ├── route53/                 # (미작업 - prod 전환 시 진행)
    ├── s3/                      # Image Bucket + Frontend Bucket
    ├── secrets/                 # (미작업 - 팀원 진행 중)
    └── sg/                      # ALB, EKS Node, RDS, Redis, Bastion SG
```

### envs 분리 이유

| 환경 | 설명 |
|---|---|
| `dev / prod` | 환경별 독립 State, 독립 배포 |
| `global/iam` | GitHub OIDC Provider는 AWS 계정당 1개 — dev/prod 공유 |
| `shared/ecr` | ECR은 dev/prod 이미지 동일 레지스트리 사용 |

### infra / platform-addons 분리 이유

EKS 클러스터가 존재해야 Kubernetes/Helm Provider가 동작합니다.
`infra`(클러스터 생성) → `platform-addons`(클러스터 위 리소스 설치) 순서로
**State를 분리**해 의존성을 명시적으로 관리합니다.

---

## 주요 설계 결정

### 1. Helm Provider 3.x — `values + yamlencode` 방식

Helm provider 3.x에서 `set` 블록이 제거되었습니다.
모든 Helm 릴리즈 설정은 `values = [yamlencode({...})]` 방식으로 통일했습니다.

```hcl
# 사용 불가 (Helm provider 3.x)
set {
  name  = "controller.replicaCount"
  value = "2"
}

# 사용 방식
values = [
  yamlencode({
    controller = {
      replicaCount = 2
    }
  })
]
```

### 2. S3 접근 제어 — OAC (Origin Access Control)

기존 OAI(Origin Access Identity) 방식은 deprecated입니다.
CloudFront에서 S3로의 접근을 OAC 방식으로 구현했습니다.

- CloudFront만 S3에 접근 가능 (Bucket은 퍼블릭 차단)
- S3 Bucket Policy에 CloudFront Distribution ARN 기반 조건부 허용

### 3. EKS Pod Identity — IRSA 대신 Pod Identity 사용

AWS EKS Pod Identity는 IRSA(IAM Roles for Service Accounts)의 후속 방식입니다.

| 항목 | IRSA | Pod Identity |
|---|---|---|
| OIDC Provider 설정 | 클러스터마다 필요 | 불필요 |
| Role 수정 없이 클러스터 이동 | 불가 | 가능 |
| 설정 복잡도 | 높음 | 낮음 |

`aws-ebs-csi-driver`와 `AWS Load Balancer Controller`에 Pod Identity를 적용했습니다.

### 4. React SPA 라우팅 처리

CloudFront에서 S3로 직접 서빙 시 `/about` 등 클라이언트 라우팅 경로는
S3에 해당 파일이 없어 403/404가 발생합니다.
CloudFront Custom Error Response로 403/404를 `index.html`로 리다이렉트해 해결했습니다.

### 5. GitHub Actions 인증 — OIDC (Secret 없음)

#### 왜 OIDC를 쓰는가

일반적인 방식은 AWS Access Key를 GitHub Secret에 저장하고 워크플로우에서 사용합니다.
이 방식은 키가 유출되면 AWS 리소스 전체가 노출되고, 키 만료/교체를 수동으로 관리해야 합니다.

OIDC 방식은 **AWS Secret Key를 GitHub에 저장하지 않습니다.**
워크플로우 실행 시 GitHub이 서명된 토큰을 발급하고, AWS가 이를 검증해 임시 자격증명을 발급합니다.

#### 인증 흐름

```
1. GitHub Actions 워크플로우 실행 (예: develop 브랜치 push)
        │
        ▼
2. GitHub이 OIDC Token 발급
   (토큰 안에 레포명, 브랜치명 등 포함)
        │
        ▼
3. AWS STS에 AssumeRoleWithWebIdentity 요청
        │
        ▼
4. AWS가 Trust Policy 조건 검사
   ├── 이 토큰이 등록된 GitHub OIDC Provider에서 온 것인가?  ✓
   └── 허용된 레포 / 브랜치에서 실행된 것인가?              ✓
        │
        ▼
5. 임시 자격증명 발급 (수명 ~1시간)
        │
        ▼
6. ECR Push / EKS 접근 수행
```

#### 구성 요소

| 리소스 | 역할 | 위치 |
|---|---|---|
| `github_oidc_provider` | GitHub을 신뢰할 수 있는 신원 제공자로 AWS에 등록 | `envs/global/iam` |
| `github_oidc_role` | GitHub Actions이 Assume할 IAM Role + ECR 권한 정책 | `envs/global/iam` |

#### 브랜치별 권한 제어

Trust Policy의 `sub` 조건으로 **허용된 브랜치에서 실행된 워크플로우만** Role을 Assume할 수 있습니다.

```hcl
condition {
  test     = "StringLike"
  variable = "token.actions.githubusercontent.com:sub"
  values   = [
    "repo:org/nowait-app:ref:refs/heads/develop"
  ]
}
```

또한 `ecr_access` 변수로 Role의 ECR 권한을 `push` / `read` 중 하나로 결정합니다.
빌드/배포 Role은 `push`, 읽기 전용 Role은 `read`로 분리해 최소 권한 원칙을 적용합니다.

---

## 환경 제약 사항

| 항목 | 값 |
|---|---|
| AWS Account ID | `194722398200` |
| Region | `ap-northeast-2` |
| 필수 태그 | `Team = "team6"` |
| IAM Role 네이밍 | `team6-*` |
| IAM Permissions Boundary | `arn:aws:iam::194722398200:policy/TeamRuntimeBoundary` |
| Terraform State 백엔드 | S3 `tfstate-lionkdt5-team6`, `use_lockfile = true` |
| Terraform 버전 명시 | `= 1.15.3` (`>=` 사용 금지) |

---

## 스택

| 분류 | 기술 |
|---|---|
| 언어 / 프레임워크 | Java 17, Spring Boot 3.5.7 |
| 빌드 | Maven (단일 모듈) |
| 컨테이너 오케스트레이션 | EKS 1.34 |
| IaC | Terraform 1.15.3 |
| CI/CD | GitHub Actions, ArgoCD |
| 컨테이너 레지스트리 | ECR |
| 모니터링 | Prometheus, Grafana |
| 네트워크 진입점 | CloudFront → IGW → ALB → EKS |

---

## 진행 현황

### 완료

- [x] `modules/network` — VPC, 서브넷, NAT GW, 라우트 테이블
- [x] `modules/eks` — EKS 클러스터, 노드그룹, Access Entry, SSM 권한
- [x] `modules/sg` — ALB / EKS Node / RDS / Redis / Bastion SG (조건부 생성)
- [x] `modules/addons` — EKS 네이티브 애드온, Pod Identity, LBC / ESO / metrics-server Helm 릴리즈
- [x] `modules/elasticache` — Redis Replication Group
- [x] `modules/database` — RDS
- [x] `modules/ecr` — ECR 레지스트리
- [x] `modules/s3` — Image Bucket (Versioning + CORS), Frontend Bucket (OAC 전용 Policy)
- [x] `modules/cloudfront` — CloudFront Distribution (OAC, ALB Origin, SPA 라우팅)
- [x] `modules/github_oidc_provider` — GitHub OIDC Provider
- [x] `modules/github_oidc_role` — GitHub Actions IAM Role
- [x] `envs/dev/infra` — dev 환경 인프라 (`terraform apply` 완료, 리소스 51개, kubectl Ready 확인)
- [x] `envs/dev/platform-addons` — 코드 완료 (apply 대기)
- [x] `envs/shared/ecr` — ECR 공용 환경
- [x] `envs/global/iam` — GitHub OIDC Provider 공용 환경


### 미작업 (prod 전환 시)

- [ ] `modules/bastion` — Bastion Host
- [ ] `modules/route53` — 도메인 연결
- [ ] `envs/prod` 환경 전체 apply

---

## 브랜치 전략

```
feature/* → develop → main
```

- `feature/*` : 기능 단위 개발
- `develop` : 통합 및 dev 환경 배포
- `main` : prod 환경 배포
