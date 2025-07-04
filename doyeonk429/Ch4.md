# Ch 4. The Four Pillars of a good Unit Test

- Exploring dichotomies between aspects of a good unit test  
  좋은 단위 테스트의 여러 측면 간의 이분법을 탐구한다  
- Defining an ideal test  
  이상적인 테스트를 정의한다  
- Understanding the Test Pyramid  
  테스트 피라미드를 이해한다  
- Using black-box and white-box testing  
  블랙박스 테스트와 화이트박스 테스트를 사용한다  

### 좋은 단위 테스트의 4가지 핵심 요소

- 회귀로부터의 보호한다  
- 리팩터링에 대한 저항성을 갖춘다  
- 빠른 피드백을 제공한다  
- 유지보수성을 확보한다  

## Protection against regressions

- regression: 새로운 기능을 추가한 뒤 코드가 수정되면서 기존 기능이 의도대로 작동하지 않게 되는 현상을 의미한다  
- 기능이 많아질수록 새 릴리스를 통해 기존 기능이 깨질 가능성도 함께 높아진다  

- 테스트를 회귀로부터 보호하는 수단으로 사용하기 위해 고려할 점은 다음과 같다  
  - 테스트 중에 실행되는 코드의 양을 확인한다  
  - 해당 코드의 복잡도를 평가한다  
  - 해당 코드의 도메인 중요도를 판단한다  

## Resistance to refactoring

### False Positive(FP)

잘못된 경고, 즉 테스트가 실패했다고 표시하지만 실제로는 해당 기능이 의도한 대로 정상적으로 작동하는 경우를 의미한다 → 리팩터링하면 FP가 발생한다  

- 테스트가 리팩터링에 대한 저항성 지표에서 얼마나 좋은 점수를 받을 수 있는지 평가하려면, 테스트가 얼마나 자주 거짓 양성을 발생시키는지를 확인해야 한다  
- 단위 테스트는 기능이 깨졌을 때 빠르게 알려주고 리팩터링 시에도 기존 기능이 유지된다는 확신을 제공하여 코드베이스의 지속적 성장을 돕는다 → 그러나 테스트가 이유 없이 실패하는(FP) 경우 실제 문제가 있어도 경고를 무시하게 되고 테스트 전체에 대한 신뢰가 떨어져 리팩터링이 줄어들며 코드 품질이 악화될 위험이 커진다  

### False Positive(FP)은 왜 발생하는가?

테스트가 SUT의 구현 방식에 더 많이 의존할수록 거짓 경고를 더 많이 만들어낸다. 즉, 테스트가 SUT의 구현 세부사항에 결합되어 있고 SUT가 생성하는 결과 자체에는 관심을 두지 않으면 FP가 발생한다  

→ 테스트와 코드 내부 동작 사이에 가능한 한 많은 거리를 두고 대신 최종 결과를 검증하는 데 집중한다(블랙박스 테스팅)  

## Interim Summary

1, 2번 요소는 서로 반대되는 관점에서 Test Suite의 정확도를 높이는 데 기여한다.  

프로젝트가 시작된 직후에는 회귀 방지가 매우 중요하지만 리팩터링 저항성의 필요성은 즉각적으로 나타나지 않는다.  

### 테스트 정확도 극대화

<img width="800" alt="스크린샷 2025-06-03 오전 1 17 35" src="https://github.com/user-attachments/assets/1e8d1d54-482e-400e-bc5e-d9ae3288f7c7" />

- 버그가 존재함을 얼마나 잘 나타내는가 (거짓 음성 FN의 부재 — 회귀 방지 능력의 영역)  
- 버그가 존재하지 않음을 얼마나 잘 나타내는가 (거짓 양성 FP의 부재 — 리팩터링 저항성의 영역)  

FP(잘못된 경고)는 초기에는 그다지 부정적인 영향을 미치지 않는다. 장기적인 프로젝트에 참여하고 있다면 FN(놓친 버그)과 FP(잘못된 경고) 모두에 집중해야 한다.  

## Fast feedback & Maintainability

- 코드를 망가뜨리자마자 테스트가 바로 버그를 경고하여 해당 버그를 수정하는 비용을 거의 0에 가깝게 줄인다  
- 느린 테스트는 자주 실행되는 것을 꺼리게 하여 결국 잘못된 방향으로 개발을 진행하는 데 더 많은 시간을 낭비하게 만든다  

### 유지보수성

- 테스트를 이해하기 어렵다면 유지보수가 힘들어진다 — 테스트 코드의 줄 수가 적을수록 더 읽기 쉽고 수정하기 쉬운 테스트가 된다  
- 테스트를 실행하기 어려운 경우 외부 의존성을 유지해야 하므로 해당 의존성을 관리하는 노력이 추가로 필요하다  

## 이상적인 테스트를 찾아서

> 진정으로 이상적인 테스트를 만들 수 있는가? → 🙅‍♂️  

- 회귀 방지, 리팩터링에 대한 저항성, 빠른 피드백은 서로 상충되는 요건이다  
- 곱셈 원칙 때문에 균형을 유지하기 어렵다(하나의 조건을 완전히 포기하면 가치 없는 테스트가 된다)  
- 리팩터링에 대한 저항성은 on/off이므로 협상의 여지가 없다. 따라서 속성 간 균형은 회귀에 대한 보호와 빠른 피드백 중 어느 것을 선택할지 문제다  
  - 테스트가 얼마나 잘 버그를 찾아내느냐와 얼마나 빠르게 수행하느냐 사이에서 선택한다  

### Case Study

1. 엔드 투 엔드(E2E) 테스트: 회귀 오류와 거짓 경고에 대해 훌륭한 보호 기능을 제공하지만 속도 면에서는 부족하고 유지보수 비용이 더 높다  

   <img width="800" alt="스크린샷 2025-06-04 오전 12 22 48" src="https://github.com/user-attachments/assets/11250b8e-82d9-4a33-8ef4-233a8da2bf59" />  

2. 사소한 테스트: 리팩토링에 대한 저항성이 좋고 빠른 피드백을 제공하지만 회귀로부터 보호해 주지는 않는다(회귀 오류를 발견할 가능성이 매우 낮다)  

   <img width="800" alt="스크린샷 2025-06-04 오전 12 24 27" src="https://github.com/user-attachments/assets/943fb4c7-05c1-4729-ba05-901c29d56628" />  

3. 취약한 테스트(brittle test): 실행 속도가 빠르고 회귀 오류에 대한 보호는 잘해주지만 리팩토링에 대한 저항성이 거의 없다  

   <img width="800" alt="스크린샷 2025-06-04 오전 12 27 24" src="https://github.com/user-attachments/assets/66bfe0e3-1e73-40dd-b2ed-b621fa304bb1" />  

## Well-known Test Automation Concepts

### 테스트 피라미드

- 테스트 스위트 내에서 서로 다른 유형의 테스트 간 특정 비율을 권장한다  
- 층의 **너비**는 해당 유형의 테스트가 **스위트 내에서 얼마나 많이 존재하는지**를 나타낸다  
- 층이 넓을수록 해당 유형의 **테스트 개수가 많다**는 의미다  
- 층의 **높이**는 이러한 테스트가 **최종 사용자의 행동을 얼마나 잘 모방하는지**를 측정한다  

→ 피라미드 상단에 위치한 테스트일수록 회귀 방지에 중점을 두고, 하단에 위치한 테스트일수록 실행 속도(빠른 피드백)를 더 중요하게 여긴다  

> **각 계층 중 어느 것도 리팩터링 저항성을 포기하지 않는다**  

### Black-box or White-box testing

- 블랙박스 테스트: **시스템의 내부 구조를 알지 못한 채 시스템의 기능을 검사한다**  
  - 이러한 테스트는 명세서와 요구사항을 기반으로 하여 애플리케이션이 “어떻게 작동하는지”가 아니라 **“무엇을 해야 하는지”**를 확인한다  
- 화이트박스 테스트: **애플리케이션의 내부 동작을 검증하는 테스트 방법이다**  
  - 테스트는 요구사항이나 명세서에서가 아니라 **소스 코드로부터 도출한다**  
  - 리팩토링에 대한 저항성이 부족하다: 코드의 특정 구현에 밀접하게 결합되어 테스트가 쉽게 깨지고 많은 수의 FP(거짓 경고)를 발생시키기 때문이다  

<img width="800" alt="스크린샷 2025-06-04 오전 12 37 08" src="https://github.com/user-attachments/assets/20828b09-394d-484c-914c-848785f1c6b4" />

- 테스트 작성 단계에서는 블랙박스 테스트를 권장한다  
- 테스트 분석 단계에서는 화이트박스 테스트를 사용한다  
