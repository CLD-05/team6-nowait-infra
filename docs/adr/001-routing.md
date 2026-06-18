# ADR 001: 프론트엔드/백엔드 라우팅 아키텍처

- 상태: 확정
- 날짜: 2026-06-18
- 담당: 김보경 (트랙 1)

## 결정

**서브도메인 방식**으로 프론트엔드/백엔드를 분리한다.

- 프론트엔드: `nowait.singleuser.cloud` → CloudFront → S3
- 백엔드 API: `api.nowait.singleuser.cloud` → ALB → EKS

## 근거

1. **관심사 분리** — 트랙 3(백엔드 Helm)과 트랙 4(프론트 CDN)가 독립적으로 작업 가능. CloudFront Behavior로 두 오리진을 묶을 필요 없음.
2. **CloudFront 캐시 정책 단순화** — 프론트용 CloudFront는 정적 자산 캐싱만 고려.
3. **확장성** — 와일드카드 인증서 `*.nowait.singleuser.cloud` 1장으로 `admin.`, `staging.` 등 추가 서브도메인 무한 확장.
4. **보안** — `nowait.singleuser.cloud` 와 `api.nowait.singleuser.cloud` 는 eTLD+1 (`singleuser.cloud`) 기준 same-site. 따라서 리프레시 토큰 쿠키에 `SameSite=Strict` 적용 가능.

## DNS 위임

`singleuser.cloud` 는 강성천님이 보유. `nowait.singleuser.cloud` 호스팅 영역은 team6 AWS 계정에 생성하고, NS 4개를 강성천님께 전달하여 부모 영역에 NS 레코드로 등록.
