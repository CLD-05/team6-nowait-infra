# modules/cloudfront

## 개요
NoWait 프로젝트의 CloudFront Distribution 모듈입니다.(서브도메인 방식 채택)

## 생성 리소스

### Origin Access Control (OAC)
- S3 Frontend Bucket 접근을 CloudFront만 허용
- 기존 OAI 방식보다 보안이 강화된 OAC 방식 사용

### CloudFront Distribution
- Origin: S3 Frontend Bucket (React 정적 파일)
- React SPA 라우팅: 403/404 → index.html 리다이렉트
- HTTPS 강제 리다이렉트

## 캐시 정책
| 경로 | TTL | 설명 |
|------|-----|------|
| /* (default) | 1일 | React 정적 파일 |

## 환경별 설정
| 변수 | dev | prod |
|------|-----|------|
| cloudfront_enabled | false | true |
| price_class | - | PriceClass_200 |

## 참고
- dev 초기에는 `cloudfront_enabled = false`로 비활성화합니다.
- `modules/s3`의 `frontend_bucket_domain_name` output을 넘겨받아 사용합니다.