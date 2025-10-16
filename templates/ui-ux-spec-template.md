# UI/UX Specification

> **역할**: 사용자 경험, 화면 디자인, 상호작용을 정의하는 가장 중요한 문서
> **독자**: 프론트엔드 개발자, UI/UX 디자이너, 제품 기획자
> **관련 문서**: 시스템 구조는 `program-spec.md`, 사용할 API는 `api-spec.md` 참조

**Status**: Draft
**Version**: 1.0
**Last Updated**: [YYYY-MM-DD]

---

## 1. Design Philosophy

### 1.1 핵심 원칙
- **사용자 중심**: 사용자가 가장 쉽게 목표를 달성할 수 있도록
- **일관성**: 모든 화면에서 동일한 패턴과 용어 사용
- **반응성**: 모든 디바이스에서 최적의 경험
- **접근성**: WCAG 2.1 AA 준수

### 1.2 디자인 가치
1. **Simple**: 복잡하지 않게
2. **Clear**: 명확한 정보 전달
3. **Delightful**: 사용하기 즐거운 경험

---

## 2. Design System

### 2.1 Color Palette

#### Primary Colors
```
Primary:     #3B82F6  (Blue 500)
Secondary:   #10B981  (Green 500)
Accent:      #F59E0B  (Amber 500)
```

#### Neutral Colors
```
Background:  #FFFFFF  (White)
Surface:     #F9FAFB  (Gray 50)
Border:      #E5E7EB  (Gray 200)
Text Primary:    #111827  (Gray 900)
Text Secondary:  #6B7280  (Gray 500)
```

#### Semantic Colors
```
Success:  #10B981  (Green 500)
Warning:  #F59E0B  (Amber 500)
Error:    #EF4444  (Red 500)
Info:     #3B82F6  (Blue 500)
```

### 2.2 Typography

#### Font Family
```
Primary: 'Inter', -apple-system, sans-serif
Monospace: 'Fira Code', 'Courier New', monospace
```

#### Font Scale
```
Heading 1:  2.5rem / 40px  (font-bold)
Heading 2:  2rem / 32px    (font-bold)
Heading 3:  1.5rem / 24px  (font-semibold)
Heading 4:  1.25rem / 20px (font-semibold)
Body:       1rem / 16px    (font-normal)
Caption:    0.875rem / 14px (font-normal)
Small:      0.75rem / 12px (font-normal)
```

#### Line Height
```
Tight:   1.25  (제목용)
Normal:  1.5   (본문용)
Relaxed: 1.75  (긴 글용)
```

### 2.3 Spacing

```
xs:  4px   (0.25rem)
sm:  8px   (0.5rem)
md:  16px  (1rem)
lg:  24px  (1.5rem)
xl:  32px  (2rem)
2xl: 48px  (3rem)
3xl: 64px  (4rem)
```

### 2.4 Border Radius

```
sm:   4px  (0.25rem)  - 버튼, 입력
md:   8px  (0.5rem)   - 카드
lg:   12px (0.75rem)  - 모달
xl:   16px (1rem)     - 큰 컨테이너
full: 9999px          - 원형, 알약형
```

### 2.5 Shadows

```
sm:  0 1px 2px rgba(0, 0, 0, 0.05)
md:  0 4px 6px rgba(0, 0, 0, 0.1)
lg:  0 10px 15px rgba(0, 0, 0, 0.1)
xl:  0 20px 25px rgba(0, 0, 0, 0.15)
```

---

## 3. Component Library

### 3.1 Button

#### Variants

**Primary Button**
```
배경: Primary Color (#3B82F6)
텍스트: White
호버: Primary-600 (#2563EB)
활성: Primary-700 (#1D4ED8)
비활성: Gray-300, 커서 not-allowed
```

**Secondary Button**
```
배경: Transparent
테두리: Primary Color (1px)
텍스트: Primary Color
호버: Primary-50 배경
```

**Danger Button**
```
배경: Error Color (#EF4444)
텍스트: White
호버: Red-600
```

#### Sizes
```
Small:  px-3 py-1.5, text-sm
Medium: px-4 py-2, text-base (기본)
Large:  px-6 py-3, text-lg
```

#### States
- Default
- Hover (색상 변경)
- Active (약간 어둡게)
- Disabled (투명도 50%, 클릭 불가)
- Loading (스피너 표시)

### 3.2 Input Field

#### Basic Input
```html
<label class="block text-sm font-medium text-gray-700 mb-1">
  이메일
</label>
<input
  type="email"
  class="w-full px-3 py-2 border border-gray-300 rounded-md
         focus:outline-none focus:ring-2 focus:ring-primary-500"
  placeholder="email@example.com"
/>
```

#### States
- **Default**: border-gray-300
- **Focus**: ring-2 ring-primary-500
- **Error**: border-red-500, 아래 에러 메시지 표시
- **Disabled**: bg-gray-100, cursor-not-allowed
- **Success**: border-green-500 (선택적)

#### Error Display
```html
<input class="border-red-500" />
<p class="mt-1 text-sm text-red-600">
  이메일 형식이 올바르지 않습니다
</p>
```

### 3.3 Modal

#### Structure
```
┌─────────────────────────────┐
│  Backdrop (bg-black/50)     │
│  ┌───────────────────────┐  │
│  │ Modal                 │  │
│  │ ┌─────────────────┐   │  │
│  │ │ Header (X버튼)  │   │  │
│  │ ├─────────────────┤   │  │
│  │ │ Body            │   │  │
│  │ ├─────────────────┤   │  │
│  │ │ Footer (버튼들) │   │  │
│  │ └─────────────────┘   │  │
│  └───────────────────────┘  │
└─────────────────────────────┘
```

#### Sizes
- Small: max-w-md (448px)
- Medium: max-w-lg (512px)
- Large: max-w-2xl (672px)
- Full: max-w-4xl (896px)

#### Behavior
- Backdrop 클릭 시 닫기 (선택적으로 비활성화 가능)
- ESC 키로 닫기
- 열릴 때: 배경 스크롤 잠금
- 애니메이션: Fade in + Scale up (200ms)

### 3.4 Toast Notification

#### Position
```
우측 상단: top-4 right-4
중앙 상단: top-4 center
```

#### Types
```
Success: 녹색 아이콘 + 메시지
Error:   빨간 아이콘 + 메시지
Warning: 노란 아이콘 + 메시지
Info:    파란 아이콘 + 메시지
```

#### Duration
- 기본: 3초
- Success: 2초
- Error: 5초 (또는 수동 닫기)

#### Behavior
- 순차 표시 (최대 3개)
- 자동 사라짐 (슬라이드 아웃)
- 클릭 시 즉시 닫기

### 3.5 Loading States

#### Spinner
```html
<div class="animate-spin h-5 w-5 border-2 border-primary-500
            border-t-transparent rounded-full"></div>
```

#### Skeleton
```
화면 로딩 시: 실제 컴포넌트 모양의 회색 박스
애니메이션: 왼쪽→오른쪽 shimmer
```

#### Progress Bar
```html
<div class="w-full bg-gray-200 rounded-full h-2">
  <div class="bg-primary-500 h-2 rounded-full"
       style="width: 45%"></div>
</div>
```

---

## 4. Screen Layouts

### 4.1 전체 레이아웃 구조

```
┌──────────────────────────────────────┐
│         Navigation Bar               │ 64px
├──────────────────────────────────────┤
│  ┌────────┬──────────────────────┐   │
│  │Sidebar │  Main Content        │   │
│  │(선택)  │                      │   │
│  │240px   │                      │   │
│  │        │                      │   │
│  └────────┴──────────────────────┘   │
└──────────────────────────────────────┘
│         Footer (선택)                │
└──────────────────────────────────────┘
```

### 4.2 Container Widths
```
Small:    640px  (모바일)
Medium:   768px  (태블릿)
Large:    1024px (데스크탑)
XLarge:   1280px (큰 화면)
Max:      1536px (최대)
```

### 4.3 Responsive Breakpoints
```
Mobile:   < 640px   (sm)
Tablet:   640-1024px (md-lg)
Desktop:  > 1024px  (xl+)
```

---

## 5. User Flows

### 5.1 사용자 여정 맵

#### Journey 1: 신규 사용자 온보딩
```
1. 랜딩 페이지 방문
   ↓
2. "시작하기" 버튼 클릭
   ↓
3. 회원가입 폼 작성
   ↓
4. 이메일 인증
   ↓
5. 프로필 설정
   ↓
6. 대시보드로 이동
```

**예상 소요 시간**: 3-5분
**이탈 가능 지점**: 3단계 (복잡한 폼), 4단계 (이메일 확인 대기)
**개선 방안**: 소셜 로그인 추가, 이메일 인증 선택사항으로

#### Journey 2: 기존 사용자 로그인
```
1. 로그인 페이지
   ↓
2. 이메일/비밀번호 입력
   ↓
3. 대시보드
```

**예상 소요 시간**: 30초
**개선**: "로그인 유지" 옵션

---

## 6. Screen Specifications

### 6.1 로그인 화면

#### Wireframe
```
┌──────────────────────────────┐
│                              │
│      [Logo]                  │
│                              │
│   로그인                      │
│                              │
│   ┌────────────────────┐     │
│   │ 이메일             │     │
│   └────────────────────┘     │
│                              │
│   ┌────────────────────┐     │
│   │ 비밀번호           │     │
│   └────────────────────┘     │
│                              │
│   [ ] 로그인 유지            │
│                              │
│   ┌────────────────────┐     │
│   │   로그인           │     │
│   └────────────────────┘     │
│                              │
│   비밀번호를 잊으셨나요?      │
│                              │
│   계정이 없으신가요? 회원가입  │
│                              │
└──────────────────────────────┘
```

#### Elements

**헤더**
- Logo (중앙 정렬)
- "로그인" 제목 (H2, center)

**폼**
- 이메일 입력 (type="email", required, autocomplete="email")
- 비밀번호 입력 (type="password", required, autocomplete="current-password")
- "로그인 유지" 체크박스 (optional)
- "로그인" 버튼 (Primary, full-width)

**링크**
- "비밀번호를 잊으셨나요?" → 비밀번호 재설정 화면
- "회원가입" → 회원가입 화면

#### Interactions

**로그인 버튼 클릭 시**:
1. 입력 유효성 검증
   - 이메일 형식 확인
   - 비밀번호 입력 확인
2. 버튼 → Loading 상태
3. API 호출: `POST /auth/login` (참조: `api-spec.md#POST-auth-login`)
4. 성공 시:
   - 토큰 저장 (localStorage 또는 cookie)
   - 대시보드로 리다이렉트
   - Toast: "환영합니다!"
5. 실패 시:
   - 에러 메시지 표시 (폼 아래)
   - 버튼 → 원래 상태
   - 비밀번호 입력 초기화

#### Validation Rules

| Field | Rule | Error Message |
|-------|------|---------------|
| 이메일 | Required, email format | "올바른 이메일을 입력하세요" |
| 비밀번호 | Required, min 8자 | "비밀번호를 입력하세요" |

#### Error States

**네트워크 에러**
```
Toast (Error): "연결에 실패했습니다. 다시 시도해주세요"
```

**인증 실패 (401)**
```
폼 아래 메시지: "이메일 또는 비밀번호가 올바르지 않습니다"
```

**계정 잠김 (403)**
```
폼 아래 메시지: "계정이 잠겼습니다. 고객센터에 문의하세요"
```

#### Accessibility
- [ ] 모든 입력에 label 연결
- [ ] 키보드 네비게이션 지원 (Tab, Enter)
- [ ] 에러 메시지 screen reader 읽기
- [ ] Focus indicator 명확하게

#### 반응형 동작
- **Mobile (< 640px)**: 폼 좌우 패딩 16px
- **Tablet**: 폼 최대 너비 400px, 중앙 정렬
- **Desktop**: 동일, 배경 이미지 추가 고려

---

### 6.2 대시보드 화면

#### Wireframe
```
┌────────────────────────────────────────┐
│ [Logo] Dashboard  [알림] [프로필▾]    │ Navigation
├────────────────────────────────────────┤
│                                        │
│  안녕하세요, 홍길동님! 👋              │
│                                        │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐  │
│  │총 사용자│ │활성 사용│ │수익     │  │
│  │ 1,234  │ │  567   │ │$12,345 │  │
│  └─────────┘ └─────────┘ └─────────┘  │
│                                        │
│  최근 활동                              │
│  ┌────────────────────────────────┐   │
│  │ [아이콘] 새 사용자 가입        │   │
│  │          2분 전                │   │
│  ├────────────────────────────────┤   │
│  │ [아이콘] 주문 완료             │   │
│  │          5분 전                │   │
│  └────────────────────────────────┘   │
│                                        │
└────────────────────────────────────────┘
```

#### Elements

**Navigation Bar**
- Logo (좌측)
- "Dashboard" 제목
- 알림 아이콘 (우측, badge 표시)
- 프로필 드롭다운 (우측)

**Welcome Section**
- "안녕하세요, {사용자명}님!" (H2)
- 이모지: 👋

**Stats Cards** (3개 가로 배치)
- 각 카드: 제목, 숫자, 아이콘
- API: `GET /dashboard/stats` (참조: `api-spec.md`)

**활동 피드**
- 최근 10개 활동
- 각 항목: 아이콘, 텍스트, 시간
- API: `GET /dashboard/activities`

#### Interactions

**알림 아이콘 클릭**:
- 드롭다운 표시
- 최근 알림 5개
- "모두 보기" 링크

**프로필 드롭다운**:
- 프로필 보기
- 설정
- 로그아웃

**Stats Card 클릭**:
- 해당 상세 페이지로 이동

#### Loading States
- 초기 로딩: 전체 Skeleton
- Stats 로딩: Card별 Skeleton
- Activities 로딩: List Skeleton

#### 반응형 동작
- **Mobile**: Stats Cards 세로 배치
- **Tablet**: Stats Cards 2+1 배치
- **Desktop**: Stats Cards 3개 가로 배치

---

### 6.3 [추가 화면들...]

각 주요 화면마다 위와 동일한 상세도로 작성:
- 회원가입 화면
- 프로필 화면
- 콘텐츠 목록 화면
- 콘텐츠 편집 화면
- 설정 화면
- 등...

---

## 7. Interaction Patterns

### 7.1 폼 제출

**표준 패턴**:
1. 버튼 클릭
2. 클라이언트 유효성 검증 (즉시)
3. 에러 있으면 → 첫 번째 에러 필드로 포커스
4. 에러 없으면 → 버튼 Loading 상태
5. API 호출
6. 성공 → Toast + 페이지 전환
7. 실패 → 에러 표시 + 버튼 원상태

### 7.2 삭제 확인

**위험한 작업 패턴**:
1. "삭제" 버튼 클릭
2. 확인 모달 표시:
   ```
   정말 삭제하시겠습니까?
   이 작업은 되돌릴 수 없습니다.

   [취소]  [삭제]
   ```
3. "삭제" 버튼 → Danger 스타일
4. "삭제" 클릭 → API 호출
5. 성공 → Toast + 목록에서 제거

### 7.3 무한 스크롤

**구현 패턴**:
1. 초기 20개 로드
2. 스크롤 하단 도달 (viewport 기준 200px 전)
3. 다음 페이지 자동 로드
4. 로딩 중: 하단에 스피너
5. 더 이상 없으면: "모든 항목을 불러왔습니다" 메시지

### 7.4 실시간 검색

**구현 패턴**:
1. 입력 시작
2. Debounce 300ms
3. API 호출
4. 결과 드롭다운 표시
5. ESC → 드롭다운 닫기
6. 항목 클릭 → 선택 + 드롭다운 닫기

---

## 8. Animation & Transitions

### 8.1 Duration
```
Fast:   150ms  (호버, 포커스)
Normal: 200ms  (모달, 드롭다운)
Slow:   300ms  (페이지 전환)
```

### 8.2 Easing
```
Default:    ease-in-out
Enter:      ease-out
Exit:       ease-in
Spring:     cubic-bezier(0.68, -0.55, 0.265, 1.55)
```

### 8.3 Common Animations

**Fade In**
```css
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}
```

**Slide Up**
```css
@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
```

**Scale Up**
```css
@keyframes scaleUp {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}
```

---

## 9. Accessibility (a11y)

### 9.1 WCAG 2.1 AA 준수사항

- [ ] 색상 대비율 4.5:1 이상 (텍스트)
- [ ] 색상 대비율 3:1 이상 (UI 컴포넌트)
- [ ] 키보드만으로 모든 기능 사용 가능
- [ ] Focus indicator 명확하게 표시
- [ ] 모든 이미지에 alt 텍스트
- [ ] 모든 폼 요소에 label 연결
- [ ] ARIA 속성 적절히 사용

### 9.2 Keyboard Navigation

| Key | Action |
|-----|--------|
| Tab | 다음 포커스 가능 요소로 이동 |
| Shift+Tab | 이전 포커스 가능 요소로 이동 |
| Enter | 버튼 클릭, 링크 활성화 |
| Space | 체크박스/라디오 토글 |
| Esc | 모달/드롭다운 닫기 |
| Arrow Keys | 리스트 네비게이션 |

### 9.3 Screen Reader Support

**모든 interactive 요소**:
- 명확한 aria-label
- 상태 변화 시 aria-live로 알림
- 에러 메시지 aria-describedby로 연결

**예시**:
```html
<button aria-label="사용자 프로필 메뉴 열기">
  <img src="avatar.jpg" alt="홍길동 프로필 사진" />
</button>

<div role="alert" aria-live="polite">
  로그인에 성공했습니다
</div>
```

---

## 10. Performance Guidelines

### 10.1 목표 지표

| Metric | Target |
|--------|--------|
| First Contentful Paint (FCP) | < 1.8s |
| Largest Contentful Paint (LCP) | < 2.5s |
| Time to Interactive (TTI) | < 3.8s |
| Cumulative Layout Shift (CLS) | < 0.1 |
| First Input Delay (FID) | < 100ms |

### 10.2 최적화 전략

**이미지**:
- WebP 포맷 사용
- Lazy loading (viewport 밖)
- Responsive images (srcset)
- 최대 크기: 200KB

**코드 분할**:
- 라우트 기반 코드 분할
- 초기 번들 크기 < 200KB (gzip)

**캐싱**:
- Static assets: 1년
- API responses: 적절한 Cache-Control

---

## 11. Cross-Reference

### 11.1 다른 스펙과의 관계

- **Program Spec**: 전체 기능 목록, 사용자 요구사항
- **API Spec**: 각 화면에서 호출할 API 엔드포인트

### 11.2 화면과 API 매핑

| Screen | API Endpoints | Description |
|--------|--------------|-------------|
| 로그인 화면 | `POST /auth/login` (`api-spec.md#POST-auth-login`) | 로그인 처리 |
| 대시보드 | `GET /dashboard/stats`, `GET /dashboard/activities` | 통계 및 활동 |
| 프로필 화면 | `GET /users/:id`, `PATCH /users/:id` | 프로필 조회/수정 |

### 11.3 기능과 화면 매핑

| Feature (from program-spec) | Screens | Priority |
|------------------------------|---------|----------|
| 사용자 관리 (`program-spec.md#기능1`) | 로그인, 회원가입, 프로필 | P0 |
| 콘텐츠 관리 (`program-spec.md#기능2`) | 목록, 편집기, 상세 | P0 |
| 결제 시스템 (`program-spec.md#기능3`) | 결제, 결제내역 | P1 |

---

## 12. Design Assets

### 12.1 필요한 디자인 리소스

- [ ] 로고 (SVG, 여러 크기)
- [ ] 파비콘 (16x16, 32x32, 180x180)
- [ ] 아이콘 세트 (Heroicons 또는 FontAwesome)
- [ ] 이미지 (Hero image, placeholders)
- [ ] 일러스트레이션 (Empty states, 404 page)

### 12.2 Design Handoff

**Figma → 개발**:
- Component 이름과 코드 컴포넌트 일치
- Spacing/Color는 Design System 따름
- Auto-layout 활용 (개발 구조와 동일하게)

---

## 13. Browser Support

### 13.1 지원 브라우저

| Browser | Version |
|---------|---------|
| Chrome | Last 2 versions |
| Firefox | Last 2 versions |
| Safari | Last 2 versions |
| Edge | Last 2 versions |

### 13.2 Progressive Enhancement

- 핵심 기능: 모든 브라우저
- 애니메이션: 최신 브라우저
- CSS Grid: Fallback to Flexbox

---

## 14. Testing Checklist

### 14.1 Visual Testing

- [ ] 모든 화면 스크린샷 비교
- [ ] Light/Dark mode (선택사항)
- [ ] 다양한 화면 크기
- [ ] 텍스트 길이 변화 (짧음/긴 텍스트)

### 14.2 Interaction Testing

- [ ] 모든 버튼 클릭 가능
- [ ] 폼 유효성 검증 동작
- [ ] 에러 상태 표시
- [ ] 로딩 상태 표시
- [ ] 모달/드롭다운 열림/닫힘

### 14.3 Accessibility Testing

- [ ] axe DevTools로 자동 검사
- [ ] 키보드만으로 전체 플로우
- [ ] Screen reader 테스트 (VoiceOver, NVDA)
- [ ] 색상 대비율 확인

---

## 15. Review Checklist

- [ ] 모든 주요 화면이 정의됨
- [ ] Wireframe/Mockup이 포함됨
- [ ] Interaction이 명확히 정의됨
- [ ] 에러 케이스 UI가 정의됨
- [ ] 로딩 상태가 정의됨
- [ ] 접근성 요구사항 충족
- [ ] `program-spec.md` 기능과 매핑됨
- [ ] `api-spec.md` API와 매핑됨
- [ ] 반응형 동작이 정의됨
- [ ] `/spec-review --file ui-ux-spec.md` 실행 (목표: 90점 이상)

---

**문서 버전**: 1.0.0
**최종 수정**: YYYY-MM-DD
**디자이너**: [이름]
**검토자**: [이름]
