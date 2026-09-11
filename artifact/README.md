# 채집 아카이브 — 아티팩트 배포본

같은 앱의 **아티팩트(claude.ai) 배포본**입니다. 저장소 루트의 `index.html`과
화면·기능은 같지만 데이터 계층이 다릅니다.

| | 루트 `index.html` | `artifact/index.html` |
|---|---|---|
| 저장소 | Supabase (`entries` / `entry_likes` / `entry_comments`) | 아티팩트 내장 DB (`entries` / `likes` / `comments`) |
| 파일 업로드 | Supabase Storage (`entries-media` 버킷) | 아티팩트 `assets` |
| 배포처 | 외부 호스팅 (GitHub Pages 등) | claude.ai 아티팩트 |

## 왜 파일이 두 개인가

아티팩트는 보안 정책(CSP)상 **외부로 나가는 fetch/XHR을 전부 차단**합니다.
supabase-js 스크립트 자체는 jsdelivr라 로드되지만 Supabase API 호출이 막히므로,
루트 `index.html`을 그대로 아티팩트에 올리면 화면만 뜨고 아무것도 저장·조회되지 않습니다.

## 게시된 아티팩트

https://claude.ai/code/artifact/eb09539e-5d69-4eb4-aed5-03bf172139bb

## 수정 후 다시 올리기

Claude Code에서 `artifact/index.html`을 고친 뒤, 위 URL을 함께 넘겨 게시하면
**같은 링크**가 유지됩니다. URL을 빼고 게시하면 별도의 새 아티팩트가 만들어집니다.

기능을 한쪽에만 추가하면 두 파일이 다시 벌어집니다. 변경은 가급적 양쪽에 함께 반영하세요.
