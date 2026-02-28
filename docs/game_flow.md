# 1 to 50 게임 플로우차트

```mermaid
flowchart TD
    %% ─── 앱 진입 ───
    A([앱 시작]) --> B[TitleView<br/>타이틀 화면]

    B -->|숫자 버튼 🔊 BtnSnd| C[GoRouter → /game?mode=0]
    B -->|알파벳 버튼 🔊 BtnSnd| D[GoRouter → /game?mode=1]
    B -->|SETTING 버튼 🔊 BtnSnd| S[SettingView<br/>설정 화면]
    S -->|뒤로가기| B

    %% ─── 게임 화면 진입 ───
    C --> GV[GameView<br/>GameWidget 마운트]
    D --> GV

    GV --> LOAD[OneToFiftyGame.onLoad<br/>모드별 라벨 초기화 · HUD 추가]
    LOAD --> CD[Countdown 오버레이 표시]

    %% ─── 카운트다운 ───
    CD --> CD3["3 🔊 TimeTic"]
    CD3 -->|1초 후| CD2["2 🔊 TimeTic"]
    CD2 -->|1초 후| CD1["1 🔊 TimeTic"]
    CD1 -->|1초 후| CDS["Start 🔊 Start"]
    CDS -->|0.8초 후| SG[startGame 호출<br/>오버레이 제거]

    %% ─── 게임 시작 ───
    SG --> INIT[초기화<br/>currentNumber = 1<br/>타이머 리셋]
    INIT --> SHUF[1차 테이블 1~25 셔플<br/>2차 테이블 26~50 셔플]
    SHUF --> GRID[5×5 그리드 생성<br/>CubeButton 25개 배치]
    GRID --> PLAY{플레이 중<br/>isPlaying = true}

    %% ─── 게임 루프 ───
    PLAY --> UPD[update 매 프레임<br/>경과 시간 갱신<br/>힌트 타이머 체크]
    UPD -->|5초 경과| HINT[정답 큐브 깜빡임]
    HINT --> WAIT[탭 대기]
    UPD --> WAIT

    %% ─── 큐브 탭 이벤트 ───
    WAIT -->|큐브 탭| CHECK{cube.id ==<br/>currentNumber?}

    %% ─── 정답 ───
    CHECK -->|정답 🔊 Collect| CORRECT[animateCorrect<br/>회전 → 사라짐]
    CORRECT --> LAST{마지막 숫자?<br/>currentNumber == totalCount}

    LAST -->|아니오| NEXT[currentNumber++<br/>HUD 힌트 갱신]
    NEXT --> SEC{2차 테이블<br/>남은 큐브 있음?}
    SEC -->|있음| REPLACE[같은 위치에<br/>새 CubeButton 생성<br/>animateFadeIn]
    SEC -->|없음| PLAY
    REPLACE --> PLAY

    %% ─── 게임 클리어 ───
    LAST -->|예| CLEAR["isPlaying = false<br/>🔊 Clear"]
    CLEAR --> CLR_OV[Clear 오버레이 표시<br/>결과 시간 표시]

    CLR_OV -->|다시하기 🔊 BtnSnd| CD
    CLR_OV -->|나가기 🔊 BtnSnd| B

    %% ─── 오답 ───
    CHECK -->|오답 🔊 Fail| WRONG[animateWrong<br/>좌우 흔들림]
    WRONG --> PLAY

    %% ─── 일시정지 ───
    PLAY -.->|일시정지 트리거| PAUSE[PauseMenu 오버레이]
    PAUSE -->|다시하기 🔊 BtnSnd| PLAY
    PAUSE -->|나가기 🔊 BtnSnd| B

    %% ─── 스타일 ───
    classDef overlay fill:#2D1B69,stroke:#9B59B6,color:#fff
    classDef sound fill:#1A3A2A,stroke:#2ECC71,color:#fff
    classDef action fill:#1A2A3A,stroke:#3498DB,color:#fff
    classDef decision fill:#3A2A1A,stroke:#E67E22,color:#fff

    class CD,CD3,CD2,CD1,CDS,CLR_OV,PAUSE overlay
    class CORRECT,WRONG,REPLACE,HINT action
    class CHECK,LAST,SEC,PLAY decision
```

## 흐름 요약

| 단계 | 설명 | 효과음 |
|------|------|--------|
| 타이틀 | 모드 선택 (숫자/알파벳/설정) | `BtnSnd.mp3` |
| 카운트다운 | 3 → 2 → 1 → Start | `TimeTic.mp3` × 3, `Start.mp3` |
| 정답 탭 | 큐브 회전·사라짐 → 2차 큐브 등장 | `Collect.mp3` |
| 오답 탭 | 큐브 좌우 흔들림 | `Fail.mp3` |
| 힌트 | 5초 무입력 시 정답 큐브 깜빡임 | - |
| 클리어 | 결과 화면 (시간 표시) | `Clear.mp3` |
| 메뉴 버튼 | 다시하기 / 나가기 | `BtnSnd.mp3` |
