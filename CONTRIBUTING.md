# 기여 가이드

이 프로젝트에 기여해주셔서 감사합니다!

## 기여 원칙

**메타적 접근**: 이 프로젝트는 자기 자신의 방법론(Specification-First)을 사용합니다.

즉, 모든 변경 사항은:
1. 스펙 작성으로 시작
2. 스펙 리뷰 통과 (90+점)
3. 구현
4. 검증 (85+점)

---

## 🌿 브랜치 전략: GitHub Flow

이 프로젝트는 **GitHub Flow**를 사용합니다:

```
main (항상 배포 가능)
  ├─ feature/new-sub-agent-security
  ├─ feature/command-spec-compare
  ├─ fix/hook-windows-compatibility
  ├─ docs/update-architecture-guide
  └─ refactor/test-runner-performance
```

### 브랜치 규칙

#### `main` 브랜치
- **항상 안정적이고 배포 가능한 상태 유지**
- 직접 커밋 금지 (PR을 통해서만 머지)
- 모든 커밋은 `/spec-review` (90+) 및 `/validate` (85+) 통과 필수
- 태그로 버전 관리 (v0.0.1, v0.1.0, etc.)

#### 작업 브랜치 명명 규칙

```bash
# 기능 추가
feature/<feature-name>
예: feature/sub-agent-security-auditor

# 버그 수정
fix/<issue-description>
예: fix/hook-permission-error

# 문서 업데이트
docs/<document-name>
예: docs/update-quickstart

# 리팩토링
refactor/<component-name>
예: refactor/test-runner-logic

# 성능 개선
perf/<improvement-area>
예: perf/spec-parser-optimization

# 테스트
test/<test-area>
예: test/add-edge-cases-coverage
```

---

## 기여 프로세스

### 1. Issue 생성

먼저 변경 사항을 논의하기 위해 Issue를 생성하세요:

- 버그 수정: 버그 설명, 재현 단계, 예상/실제 동작
- 기능 제안: 문제점, 제안하는 솔루션, 대안

### 2. Fork & Branch

```bash
# Fork 후 클론
git clone https://github.com/yourusername/ai-spec-based-development-helper.git
cd ai-spec-based-development-helper

# main에서 최신 코드 가져오기
git checkout main
git pull origin main

# 작업 브랜치 생성 (브랜치 명명 규칙 준수!)
git checkout -b feature/your-feature-name
```

### 3. 스펙 작성

**필수**: 구현 전에 스펙을 작성하세요.

```bash
# Claude Code 실행
claude

# 스펙 초기화
/spec-init
```

`.specs/your-feature-spec.md` 생성 후:
- 문제 정의
- 아키텍처 설명
- 구현 계획
- 엣지케이스
- 테스트 전략

### 4. 스펙 리뷰

```bash
# Claude Code에서
/spec-review
```

**목표**: 90점 이상

- 점수가 낮으면 피드백 반영 후 재리뷰
- 스펙이 승인되면 `.specs/your-feature-spec.approved.md` 생성됨

### 5. 구현

이제 코드를 작성하세요:

```bash
# Hooks가 자동으로 스펙 존재 확인
```

### 6. 검증

```bash
# Claude Code에서
/validate
```

**목표**: 85점 이상

확인 사항:
- [ ] 스펙 준수
- [ ] 테스트 커버리지 > 80%
- [ ] 코드 품질 (린트, 포맷)
- [ ] 문서 업데이트

### 7. Pull Request

PR 템플릿:

```markdown
## 변경 사항
[간단한 설명]

## 스펙
- **스펙 파일**: .specs/your-feature-spec.md
- **스펙 점수**: 92/100
- **검증 점수**: 88/100

## 체크리스트
- [ ] 스펙 작성 및 승인 (90+)
- [ ] 구현 완료
- [ ] 검증 통과 (85+)
- [ ] 테스트 추가/업데이트
- [ ] 문서 업데이트
- [ ] CHANGELOG.md 업데이트

## 관련 Issue
Closes #123
```

---

## 기여 영역

### 우선순위 높음

1. **새로운 Sub-agents**
   - 예: `security-auditor`, `performance-analyzer`
   - 스펙: 에이전트 목적, 평가 기준, 출력 형식

2. **추가 템플릿**
   - 예: `microservice-spec`, `database-schema-spec`
   - 다양한 도메인 커버

3. **Hooks 개선**
   - 더 정교한 검증 로직
   - 성능 최적화

4. **문서 번역**
   - 영어, 일본어, 중국어 등

### 우선순위 중간

5. **MCP Server 통합**
   - 스펙 저장소 (DB, Git)
   - 외부 도구 연동

6. **VS Code Extension**
   - 시각화 대시보드
   - 인라인 스펙 에디터

7. **CLI 유틸리티**
   - 스펙 관리 명령어
   - 리포트 생성

### 우선순위 낮음

8. **UI 개선**
   - 터미널 출력 포맷
   - 색상/이모지 최적화

9. **예제 프로젝트**
   - 실제 사용 사례 데모

---

## 코드 스타일

### Bash Scripts
- ShellCheck 통과 필수
- 에러 핸들링 철저히
- 주석으로 의도 명확히

### Markdown
- 일관된 헤딩 레벨
- 코드 블록에 언어 지정
- 테이블은 정렬

### JavaScript (있는 경우)
- ESLint 사용
- Prettier 포맷
- JSDoc 주석

---

## 테스트

### Hook 테스트

```bash
# Syntax check
bash -n .claude/hooks/*.sh

# Manual test
cd test-project
# Trigger hooks manually
```

### Agent 테스트

```bash
# Claude Code에서 직접 테스트
/spec-review  # 실제 스펙으로 테스트
```

### Integration 테스트

전체 워크플로우 테스트:
1. `/spec-init` → 스펙 생성
2. `/spec-review` → 90+ 점수 확인
3. 구현
4. `/validate` → 85+ 점수 확인

---

## 리뷰 기준

PR 리뷰 시 확인 사항:

### 필수 (Blocking)
- [ ] 스펙 파일 포함
- [ ] 스펙 점수 90+
- [ ] 검증 점수 85+
- [ ] 테스트 통과
- [ ] 충돌 없음

### 권장 (Non-blocking)
- [ ] 명확한 커밋 메시지
- [ ] 코드 주석
- [ ] 성능 고려
- [ ] 보안 고려

---

## 커뮤니티 가이드라인

- **존중**: 모든 기여자를 존중하세요
- **건설적**: 비판은 건설적으로
- **협력**: 함께 더 나은 솔루션 찾기
- **투명성**: 의사결정 과정 공유
- **인내**: 리뷰에 시간이 걸릴 수 있습니다

---

## 질문?

- **일반 질문**: Discussions 사용
- **버그 리포트**: Issue 생성
- **보안 취약점**: SECURITY.md 참조

---

## 라이선스

기여함으로써 당신의 코드가 MIT 라이선스 하에 배포되는 것에 동의합니다.

---

**Remember**: "Reason before you type" - 스펙부터! 🧠
