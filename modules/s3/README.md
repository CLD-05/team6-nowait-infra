# modules/s3

## 개요
NoWait 프로젝트에서 사용하는 S3 버킷 모듈입니다.

## 생성 리소스

### Image Bucket (`image_bucket_enabled = true`)
- 음식점/메뉴 이미지 업로드 파일 저장
- API 서버에서 Presigned URL로 직접 업로드/조회
- Versioning 활성화
- CORS 설정 (Presigned URL 브라우저 직접 요청 허용)
- Public Access 완전 차단

### Frontend Bucket (`frontend_bucket_enabled = true`)
- React 빌드 결과물 정적 파일 호스팅
- CloudFront OAC를 통해서만 접근 허용 (Bucket Policy)
- Public Access 완전 차단
- dev 초기에는 disabled (로컬 실행 기준)

## 환경별 설정
| 변수 | dev | prod |
|------|-----|------|
| image_bucket_enabled | true | true |
| frontend_bucket_enabled | false | true |
| cloudfront_enabled | false | true |

## 참고
- Frontend Bucket Policy는 `cloudfront_distribution_arn`이 있을 때만 생성됩니다.
- CloudFront 모듈과 함께 사용합니다.