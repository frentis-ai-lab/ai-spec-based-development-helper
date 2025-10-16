# Program Specification

> **역할**: 전체 프로그램의 아키텍처와 시스템 설계를 정의하는 마스터 문서
> **독자**: PM, 아키텍트, 전체 개발팀
> **관련 문서**: API 상세는 `api-spec.md`, UI/UX 상세는 `ui-ux-spec.md` 참조

---

## 1. 개요

### 1.1 프로젝트 목적
- **문제**: 해결하려는 문제가 무엇인가?
- **솔루션**: 이 프로그램이 제공하는 핵심 가치
- **타겟 사용자**: 누구를 위한 프로그램인가?

### 1.2 핵심 가치 제안
- 왜 이 프로그램을 사용해야 하는가?
- 기존 솔루션 대비 차별점

### 1.3 프로젝트 범위
- **포함**: 이번 버전에서 구현할 기능
- **제외**: 구현하지 않을 것 (명확히)
- **향후 계획**: 차기 버전 고려사항

---

## 2. 시스템 아키텍처

### 2.1 전체 구조도
```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
┌──────▼──────┐
│   API GW    │
└──────┬──────┘
       │
┌──────▼──────────────┐
│  Application Layer  │
└──────┬──────────────┘
       │
┌──────▼──────┐
│  Database   │
└─────────────┘
```

### 2.2 기술 스택
- **Frontend**: React 18, TypeScript, TailwindCSS
- **Backend**: Node.js 20, Express, TypeScript
- **Database**: PostgreSQL 15
- **Infrastructure**: Docker, AWS (EC2, RDS, S3)
- **Tools**: pnpm, ESLint, Prettier, Jest

### 2.3 아키텍처 패턴
- **Frontend**: Component-based architecture
- **Backend**: Layered architecture (Controller → Service → Repository)
- **데이터 플로우**: RESTful API, JSON

### 2.4 핵심 아키텍처 결정 (ADR)

#### ADR-001: 모노레포 vs 멀티레포
- **결정**: 모노레포 (pnpm workspace)
- **이유**: 코드 공유 용이, 일관된 의존성 관리
- **트레이드오프**: 빌드 복잡도 증가

#### ADR-002: REST vs GraphQL
- **결정**: REST API
- **이유**: 단순한 CRUD, 팀 경험, 캐싱 용이
- **트레이드오프**: Over-fetching 가능성

---

## 3. 핵심 기능 목록

### 3.1 사용자 관리
- 회원가입, 로그인, 프로필 관리
- **API**: `api-spec.md#인증API`, `api-spec.md#사용자API` 참조
- **UI**: `ui-ux-spec.md#로그인화면`, `ui-ux-spec.md#프로필화면` 참조

### 3.2 콘텐츠 관리
- CRUD 기능
- **API**: `api-spec.md#콘텐츠API` 참조
- **UI**: `ui-ux-spec.md#콘텐츠목록`, `ui-ux-spec.md#편집기` 참조

### 3.3 결제 시스템
- 결제 처리, 환불, 내역 조회
- **API**: `api-spec.md#결제API` 참조
- **UI**: `ui-ux-spec.md#결제화면` 참조

---

## 4. 데이터 모델

### 4.1 ERD
```
┌──────────────┐         ┌──────────────┐
│    Users     │         │   Content    │
├──────────────┤         ├──────────────┤
│ id (PK)      │────┐    │ id (PK)      │
│ email        │    │    │ user_id (FK) │
│ password     │    └───<│ title        │
│ created_at   │         │ body         │
└──────────────┘         │ created_at   │
                         └──────────────┘
```

### 4.2 주요 엔티티

#### User
```typescript
interface User {
  id: string;          // UUID
  email: string;       // 이메일 (unique)
  password: string;    // bcrypt 해싱
  name: string;
  role: 'user' | 'admin';
  createdAt: Date;
  updatedAt: Date;
}
```

#### Content
```typescript
interface Content {
  id: string;
  userId: string;      // User FK
  title: string;
  body: string;
  status: 'draft' | 'published';
  createdAt: Date;
  updatedAt: Date;
}
```

---

## 5. 비기능 요구사항

### 5.1 성능
- **응답 시간**: API 95th percentile < 200ms
- **동시 사용자**: 1000명 동시 접속 지원
- **처리량**: 초당 100 요청 처리

### 5.2 보안
- **인증**: JWT (Access Token: 15분, Refresh Token: 7일)
- **암호화**: 비밀번호 bcrypt (rounds: 10)
- **HTTPS**: 모든 통신 암호화
- **CORS**: 허용된 도메인만 접근
- **Rate Limiting**: IP당 분당 100 요청

### 5.3 확장성
- **수평 확장**: Stateless API 서버 (로드 밸런서 뒤)
- **데이터베이스**: Read Replica 활용 가능한 구조
- **캐싱**: Redis 준비 (세션, 자주 읽는 데이터)

### 5.4 가용성
- **목표**: 99.9% uptime (월 43분 다운타임 허용)
- **백업**: 일일 자동 백업, 7일 보관
- **모니터링**: 에러율, 응답시간, 리소스 사용량

### 5.5 유지보수성
- **코드 품질**: ESLint, Prettier, 90% 테스트 커버리지
- **문서화**: API 문서 자동 생성 (Swagger)
- **로깅**: 구조화된 로그 (Winston)

---

## 6. 외부 연동

### 6.1 Third-party 서비스
- **결제**: Stripe API
- **이메일**: SendGrid
- **파일 저장**: AWS S3
- **모니터링**: Sentry

### 6.2 연동 전략
- 각 서비스별 Adapter 패턴 적용
- 실패 시 재시도 로직 (exponential backoff)
- Circuit Breaker 패턴 고려

---

## 7. 배포 전략

### 7.1 환경 구성
- **Development**: 로컬 Docker Compose
- **Staging**: AWS EC2 (단일 인스턴스)
- **Production**: AWS EC2 (Auto Scaling Group)

### 7.2 CI/CD
```
Git Push → GitHub Actions
  ├─ Lint & Test
  ├─ Build Docker Image
  ├─ Push to ECR
  └─ Deploy to AWS
```

### 7.3 배포 프로세스
1. Feature branch → PR
2. 코드 리뷰 + 자동 테스트
3. Main 머지 → Staging 자동 배포
4. QA 검증
5. Production 수동 배포 (승인 필요)

### 7.4 롤백 전략
- Docker 이미지 태그 기반 롤백
- 데이터베이스 마이그레이션 롤백 스크립트 필수

---

## 8. 테스트 전략

### 8.1 테스트 레벨
- **Unit Test**: 개별 함수/클래스 (Jest)
- **Integration Test**: API 엔드포인트 (Supertest)
- **E2E Test**: 주요 사용자 플로우 (Playwright)

### 8.2 테스트 커버리지 목표
- **Unit**: 90% 이상
- **Integration**: 주요 API 100%
- **E2E**: Critical path 100%

### 8.3 테스트 데이터
- Fixture 파일 사용
- 테스트 DB 자동 초기화
- Seed 데이터 스크립트

---

## 9. 프로젝트 일정

### 9.1 마일스톤
- **M1 (Week 1-2)**: 인증 시스템 구현
- **M2 (Week 3-4)**: 콘텐츠 CRUD 구현
- **M3 (Week 5-6)**: 결제 시스템 구현
- **M4 (Week 7-8)**: 테스트 및 배포

### 9.2 위험 요소
- **Risk-1**: Stripe 연동 복잡도
  - **완화**: 샌드박스 환경 먼저 테스트
- **Risk-2**: 성능 요구사항 미달
  - **완화**: 주간 성능 테스트, 병목 지점 조기 발견

---

## 10. 개방된 질문 (Open Questions)

### 아직 결정하지 못한 사항:
1. ❓ 프론트엔드 상태관리: Redux vs Zustand vs React Query?
2. ❓ 실시간 기능 필요 여부 (WebSocket)?
3. ❓ 다국어 지원 범위 (i18n)?
4. ❓ 모바일 앱 개발 계획?

### 해결 기한:
- 1번: Week 1 종료 전
- 2번: M1 완료 전
- 3,4번: M2 완료 전

---

## 11. 검토 체크리스트

### 스펙 완성도
- [ ] 모든 섹션이 구체적으로 작성됨
- [ ] API 스펙과 일관성 있음 (`api-spec.md` 교차 확인)
- [ ] UI/UX 스펙과 일관성 있음 (`ui-ux-spec.md` 교차 확인)
- [ ] 개방된 질문들이 해결됨 또는 해결 기한이 명확함
- [ ] 아키텍처 결정의 이유가 명확함
- [ ] 성능/보안 요구사항이 측정 가능함

### 검토 이력
- [ ] `/spec-review` 실행 (목표: 90점 이상)
- [ ] 팀 리뷰 완료
- [ ] 승인 날짜: ___________

---

**문서 버전**: 1.0.0
**최종 수정**: YYYY-MM-DD
**작성자**: [이름]
**승인자**: [이름]
