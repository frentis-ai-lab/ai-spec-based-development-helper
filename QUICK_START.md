# 빠른 시작 가이드

## 5분 안에 시작하기

### 1단계: 설치 (30초)

```bash
# 현재 프로젝트에서
cp -r /path/to/ai-spec-based-development-helper/.claude .
chmod +x .claude/hooks/*.sh
```

### 2단계: Claude Code 실행 (10초)

```bash
claude
```

### 3단계: 기능 확인 (20초)

```bash
# Claude Code 프롬프트에서
/agents       # Sub-agents 목록 확인
/spec-init    # 첫 스펙 생성 시도
```

---

## 첫 기능 개발 (10분 튜토리얼)

### 시나리오: 간단한 할일 목록 API

#### 1. 스펙 초기화 (3분)

```
You: /spec-init
할일 목록 CRUD API를 만들고 싶어요.
- 할일 생성, 조회, 수정, 삭제
- RESTful API
- PostgreSQL 사용
```

**결과**: `.specs/todo-api-spec.md` 생성됨

#### 2. 스펙 리뷰 (2분)

```
You: /spec-review
```

**가능한 결과**:
- 90점 이상: ✅ 바로 구현 진행
- 90점 미만: 피드백 확인 → 보완 → 재리뷰

#### 3. 구현 (3분)

```
You: 스펙대로 구현해줘
```

Hook이 스펙 존재 확인 → 구현 진행

#### 4. 검증 (2분)

```
You: /validate
```

**결과**:
- 85점 이상: ✅ 배포 준비 완료
- 85점 미만: 수정 사항 적용 → 재검증

---

## 핵심 명령어 치트시트

| 상황 | 명령어 | 설명 |
|------|--------|------|
| 새 기능 시작 | `/spec-init` | 스펙 템플릿 생성 |
| 스펙 완성도 확인 | `/spec-review` | 90점 목표 |
| 아키텍처 검토 | `/arch-review` | 복잡한 시스템용 |
| 구현 검증 | `/validate` | 85점 목표 |
| 현재 상태 | `/spec-status` | 대시보드 |

---

## 문제 해결

### Hook이 실행 안 됨
```bash
chmod +x .claude/hooks/*.sh
# hooks.json에서 enabled: true 확인
```

### Agents가 안 보임
```bash
ls .claude/agents/
# 파일 3개 있어야 함:
# - spec-analyzer.md
# - architecture-reviewer.md
# - implementation-validator.md
```

### 스펙 없이 코딩하고 싶음
```bash
# 긴급 상황만 사용
mkdir -p .specs
touch .specs/.bypass
# 완료 후 삭제: rm .specs/.bypass
```

---

## 다음 단계

1. **README.md 전체 읽기**: 고급 기능 및 모범 사례
2. **템플릿 탐색**: `templates/` 디렉토리
3. **실제 프로젝트 적용**: 작은 기능부터 시작

---

**도움말**: `/help`로 Claude Code 전체 명령어 확인
