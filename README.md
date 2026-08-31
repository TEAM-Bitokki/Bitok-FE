# Bitok

**Before you bite, check if it's OK.**

## 소개

Bitok은 Bite와 OK를 결합한 이름으로, 먹기 전 음식이 나의 식이 조건에 맞는지 확인한다는 의미입니다. 메뉴판이나 식품 포장지를 촬영하면 알레르기·채식·종교적 조건에 맞춰 주의 정보를 안내하고, 직원에게 보여줄 한국어 확인 문장을 만들어줍니다.

## Background

방한·체류 외국인이 늘어나면서, 알레르기와 채식, 종교적 식이 조건을 가진 사람들도 함께 늘고 있습니다. 하지만 메뉴판에는 음식 이름만 적혀 있고, 포장식품의 원재료 표시는 전부 한국어입니다. 이들에게는 먹기 전 안전을 확인할 수 있는 최소한의 장치가 필요합니다.

## Pain Point

1. **번역기를 돌려도, 알 수 없는 숨은 재료**
   음식명은 번역할 수 있지만, 메뉴판에 표시되지 않은 육수·소스·젓갈 등의 재료는 확인하기 어렵습니다.
2. **원재료가 표시되어 있어도, 이해하기 어려운 정보**
   포장식품에는 알레르기 정보가 표시돼 있지만 전부 한국어입니다. 생소한 원재료명까지 표기돼 있어, 정보가 있어도 정확히 확인하기 어렵습니다.
3. **직원에게 물어보고 싶어도, 막히는 의사소통**
   재료를 확인하고 싶어도 언어 장벽 때문에 질문을 포기하거나, 불확실한 상태로 주문하게 됩니다.

## Solution

1. **자동 분류, 유형별 분석**
   AI가 메뉴판과 포장식품을 자동으로 구분합니다. 메뉴판은 숨은 재료를 안내하고, 포장식품은 표시된 원재료와 알레르기 정보를 분석합니다.
2. **등록한 조건과 직접 대조**
   인식된 원재료를 미리 등록한 알레르기·채식·종교적 조건과 대조합니다. 충돌하거나 주의가 필요한 성분을 알려줍니다.
3. **한국어 확인 문장 자동 생성**
   확인이 필요한 내용은 직원에게 보여줄 한국어 질문으로 변환됩니다. 말이 통하지 않아도 화면을 보여주고 답변받을 수 있습니다.

## How It Works

| 단계 | 이름 | 설명 |
| --- | --- | --- |
| 01 | 식이 조건 등록 | 알레르기·채식·종교적 식이 조건과 교차 오염 주의 여부를 등록합니다. |
| 02 | 메뉴판·포장지 촬영 | 메뉴판과 포장식품을 촬영하거나 갤러리에서 이미지를 불러옵니다. |
| 03 | 자동 분류·맞춤 분석 | AI가 이미지 유형을 구분하고 인식된 정보를 개인 조건과 대조합니다. |
| 04 | 결과 확인·직원 질문 | 결과와 판단 근거를 확인하고 필요한 한국어 질문을 직원에게 보여줍니다. |

## Brand

- **Brand Essence:** "Before you bite, check if it's OK."
- **Keywords:** Calm, Clear, Friendly, Trustworthy, Inclusive
- **Primary Color:** BitOK Blue `#3DADFF`

## 디렉토리 구조

프로젝트는 **Feature-first** 구조를 기반으로 하며, 상태 관리는 **Riverpod**을 사용합니다.

```
lib/
├── core/
│   ├── config/
│   ├── design_system/
│   ├── network/
│   ├── utils/
│   └── providers/
│
├── common/
│   └── widgets/
│
└── features/
    └── auth/
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        └── presentation/
            ├── screens/
            │   └── login_screen.dart
            ├── widgets/
            │   ├── login_form.dart
            │   ├── login_header.dart
            │   └── social_login_buttons.dart
            └── providers/
                ├── login_provider.dart
                └── login_state.dart
```

### 구조 설명

- **core/**: 앱 전역에서 사용하는 설정, 디자인 시스템, 네트워크 클라이언트, 유틸리티, 전역 provider를 모아둡니다.
- **common/**: 특정 feature에 속하지 않고 여러 화면에서 재사용되는 공용 위젯을 둡니다.
- **features/**: 기능(도메인) 단위로 폴더를 나누며, 각 feature 폴더 안에 `data`와 `presentation`을 함께 둡니다.
    - **data/**: `datasources`, `models`, `repositories`로 구성되며, 외부 데이터 소스 및 도메인 모델을 관리합니다.
    - **presentation/screens/**: 화면은 UI 조립 역할만 담당하도록 얇게 유지합니다.
    - **presentation/widgets/**: 화면을 구성하는 개별 UI 섹션을 분리하여 화면 파일의 비대화를 방지합니다.
    - **presentation/providers/**: Riverpod 기반 상태 관리 로직(Notifier, State)을 담당합니다.