# 단위 테스트

# 1. 단위 테스트의 목표

단위 테스트를 사용할때는 최대한의 이득을 얻을 수 있도록 노력해야 함.

테스트에 드는 노력을 가능한 한 줄이고, 그에 따른 이득을 최대화.

## 1.1 단위 테스트 현황

대부분의 회사에서 필수로 간중

많은 코드가 수많은 단위 테스트, 통합테스트로 좋은 테스트 커버리지를 달성중

제품 코드와 테스트 코드의 비율은 보통 1:1 ~ 1:3

## 1.2 단위테스트의 목표

단위 테스트는 보통 더 나은 설계로 이어짐(주목표 아님)

소프트웨어 프로젝트의 지속 가능한 성장을 위함임(소프트웨어 엔트로피를 줄이기 위함).

## 1.3 **테스트 스위트 품질 측정을 위한 두 가지 커버리지 지표**

커버리지 지표 : 테스트 스위트가 소스 코드를 얼마나 실행하는지를 나타내는 백분율. 높을 수록 좋음

좋은 부정지표이자 좋지 않은 긍정지표

-   코드 커버리지: 테스트하는 코드 라인 / 전체 코드 라인
-   분기 커버리지: 통과 분기 / 전체 분기

100퍼센트를 달성해도 사이드 이펙트, 검증이 되지 않는다면 소용 없다

## 1.4 무엇이 성공적인 테스트 스위트를 만드는가?

스위트(test suite): 관련있는 **여러 개의 테스트 케이스들을 하나로 묶은 집합**

스위트 내 각 테스트를 하나씩 평가

성공적인 테스트 스위트의 특성

-   개발 주기에 통합
-   코드베이스에서 가장 중요한 부분만 대상으로 함(비지니스 로직)
-   최소한의 유지비로 최대 가치

# 2. 단위 테스트란 무엇인가

## 2.1 단위 테스트의 정의

세 가지 속성이 있음

-   **작은 코드 조각을 검증**
    함수나 메서드 단위의 아주 작은 범위를 테스트함.
-   **빠르게 수행**
    테스트 전체를 자주 반복 실행할 수 있을 만큼 빠르게 돌아가야 함.
-   **격리된 방식으로 처리하는 자동화된 테스트**
    테스트 대상 외의 모든 의존성을 끊어낸 상태로 테스트함.

### 격리된 방식으로의 처리란?

테스트 대상 객체를 **협력자(coworker/collaborator)** 로부터 **완전히 분리**하는 것.

-   대상 객체 외의 나머지 의존성은 전부 **목(mock)** 으로 대체함.
-   그렇게 해야 **정확히 어디서 문제가 생겼는지 알기 쉬움**.

장점

-   **오류 위치 추적이 쉬움**
-   **객체 그래프를 잘게 나눌 수 있음**

### 고전 스타일 코드

```swift
import XCTest

enum Product {
  case shampoo
  case book
}

class Store {
  private var inventory: [Product: Int] = [:]

  func addInventory(_ product: Product, quantity: Int) {
    inventory[product, default: 0] += quantity
  }

  func getInventory(_ product: Product) -> Int {
    return inventory[product, default: 0]
  }

  func purchase(product: Product, quantity: Int) -> Bool {
    let current = inventory[product, default: 0]
    guard current >= quantity else { return false }

    inventory[product] = current - quantity
    return true
  }
}

class Customer {
  func purchase(from store: Store, product: Product, quantity: Int) -> Bool {
    return store.purchase(product: product, quantity: quantity)
  }
}

final class StoreTests: XCTestCase {

  func test_PurchaseSucceeds_WhenEnoughInventory() {
    // 준비
    let store = Store()
    store.addInventory(.shampoo, quantity: 10)
    let customer = Customer()

    // 실행
    let success = customer.purchase(from: store, product: .shampoo, quantity: 5)

    // 검증
    XCTAssertTrue(success)
    XCTAssertEqual(store.getInventory(.shampoo), 5)
  }

  func test_PurchaseFails_WhenNotEnoughInventory() {
    // 준비
    let store = Store()
    store.addInventory(.shampoo, quantity: 10)
    let customer = Customer()

    // 실행
    let success = customer.purchase(from: store, product: .shampoo, quantity: 15)

    // 검증
    XCTAssertFalse(success)
    XCTAssertEqual(store.getInventory(.shampoo), 10)
  }
}

```

협력자인 Store 클래스를 대체하지 않고 운영용을 사용

Customer가 올바르게 작용하더라고 Store에 에러가 있으면 실패 가능

→ 테스트에서 두 클래스는 격리되어 있지 않음

### 런던 스타일

```swift
import XCTest

enum Product {
  case shampoo, book
}

// IStore 프로토콜
protocol StoreProtocol {
  func hasEnoughInventory(for product: Product, quantity: Int) -> Bool
  func removeInventory(for product: Product, quantity: Int)
}

// 목 객체
class MockStore: StoreProtocol {
  var inventoryCheckResult: Bool = true
  var removeInventoryCallCount: Int = 0
  var lastRemoved: (Product, Int)?

  func hasEnoughInventory(for product: Product, quantity: Int) -> Bool {
    return inventoryCheckResult
  }

  func removeInventory(for product: Product, quantity: Int) {
    removeInventoryCallCount += 1
    lastRemoved = (product, quantity)
  }
}

// Customer는 StoreProtocol만 의존
class Customer {
  func purchase(from store: StoreProtocol, product: Product, quantity: Int) -> Bool {
    guard store.hasEnoughInventory(for: product, quantity: quantity) else { return false }
    store.removeInventory(for: product, quantity: quantity)
    return true
  }
}

final class CustomerTests: XCTestCase {

  func test_PurchaseSucceeds_WhenEnoughInventory() {
    // 준비
    let mockStore = MockStore()
    mockStore.inventoryCheckResult = true
    let customer = Customer()

    // 실행
    let success = customer.purchase(from: mockStore, product: .shampoo, quantity: 5)

    // 검증
    XCTAssertTrue(success)
    XCTAssertEqual(mockStore.removeInventoryCallCount, 1)
    XCTAssertEqual(mockStore.lastRemoved?.0, .shampoo)
    XCTAssertEqual(mockStore.lastRemoved?.1, 5)
  }

  func test_PurchaseFails_WhenNotEnoughInventory() {
    // 준비
    let mockStore = MockStore()
    mockStore.inventoryCheckResult = false
    let customer = Customer()

    // 실행
    let success = customer.purchase(from: mockStore, product: .shampoo, quantity: 5)

    // 검증
    XCTAssertFalse(success)
    XCTAssertEqual(mockStore.removeInventoryCallCount, 0)
    XCTAssertNil(mockStore.lastRemoved)
  }
}

```

실제 클래스를 사용하지 않고 인터페이스를 가진 목으로 사용했음

스토어의 실제 상태와는 관련 없이 테스트가 요구하는 방식을 inventoryCheckResult 에 저장 했음

### 공유 의존성 (Shared Dependency)

테스트끼리 **같이 사용하는 자원**,

**한 테스트가 이걸 바꾸면 다른 테스트 결과에도 영향을 줄 수 있음**

-   **static 변수**
-   하나의 **공통 데이터베이스**
-   로컬 **파일 시스템** (파일 생성/삭제 등)
-   싱글턴 객체의 내부 상태

문제가 되는 이유:

-   테스트 A가 static 값을 3으로 바꿈
-   테스트 B는 그게 **초기값일 거라고 가정하고 실행**
-   결과적으로 B는 실패하거나, 더 무서운 건 **간헐적으로 실패함 (flaky test)**

→ 테스트가 **서로 영향을 주면 단위 테스트가 아님**

→ 다시 말해, **테스트의 결과가 테스트 순서나 타이밍에 따라 달라짐**

→ 이러면 테스트를 신뢰할 수 없음

고전파의 해결 방법:

**상태 기반 검증**을 하더라도테스트 **간 상태 공유는 없게 함.**

즉, **테스트 대상 객체와 그것의 협력자들도 모두 격리**

## 2.2 단위 테스트의 런던파와 고전파

격리특성으로 나뉘어짐.

런던파는 테스트 대상 시스템에서 협력자를 격리

고전파는 단위테스트끼리 격리

주로 세 가지에서 의견이 갈림

-   격리 요구 사항
-   테스트 대상 코드 조각의 구성 요소
-   의존성 처리

| 구분   | 격리 주체       | 단위의 크기                  | 테스트 대역 사용 대상      |
| ------ | --------------- | ---------------------------- | -------------------------- |
| 런던파 | 단위            | 단일 클래스                  | 불변 의존성 외 모든 의존성 |
| 고전파 | 단위 테스트끼리 | 단일 클래스 또는 클래스 세트 | 공유 의존성                |

비공개 의존성(테스트 대상 내부에서 **직접 생성되거나 고정된 방식으로 사용되는 의존성)은 교체 불가능**

### 고전파와 런던파가 의존성을 다루는 방법

런던파는 테스트의 일부 의존성을 그대로 사용하기도 함

기준은 의존성의 변경 가능 여부, 불변 객체는 교체하지 않아도 된다.

### 의존성 개념 정리

-   **값 객체(Value Object)**
    상태가 불변이고, 오직 값 자체로만 의미를 가지는 객체. mock/stub 필요 없음.상수처럼 사용해도 됨 - **특징** - 내부 상태 변경 없음 - 동등성은 "내용"으로 비교함 (`==`) - 생성된 인스턴스 간 차이가 없음 - **예시:**`Product.shampoo`
-   **변경 가능한 의존성 (Mutable Dependency)**
    내부 상태가 바뀌며, 테스트 대상의 결과나 동작에 영향을 주는 객체 - **예시:** `Store` (재고를 바꿈) - **테스트 시 처리** - 테스트마다 새로 생성해야 함 - 경우에 따라 **mock/stub 교체** 필요 - 공유 시 테스트 결과가 오염될 위험
-   **공유 의존성 (Shared Dependency)
    여러 테스트 간에 공유되는 전역 상태나 외부 시스템** - **특징** - 한 테스트의 실행이 다른 테스트에 영향을 미침 - static 변수, 싱글톤, 전역 DB, 파일 시스템 등이 여기에 포함 - **예시:** `static var counter, UserDefaults.standard, Database.shared` - **테스트 시 처리** - 최대한 피하거나, 테스트 전후 초기화 필요 - 대체 가능한 테스트 대역(in-memory DB 등)으로 격리
-   **비공개 의존성 (Hidden Dependency)
    정의**: 외부에서는 안 보이지만 내부적으로 사용되고 있는 의존성

## 2.3 고전파와 런던파의 비교

고전파와 런던파의 주요차이는 테스트할 단위, 의존성 취급에 있음

런던파의 장점

-   입자성이 좋음. 세밀한 테스트로 한 테스트에 한 클래스 확인
-   연결된 클래스의 그래프가 커져도 테스트 용이. 협력자 걱정 필요 없음
-   테스트 실패 시 원인 파악 용이.

고전파와 런던파의 차이점

-   테스트 주도 개발을 통한 시스템 섥계 방식
-   과도한 명세 문제

**테스트 주도 개발:**

테스트에 의존해 개발하는 프로세스

-   추가해야할 기능과 동작 방식을 나타내는 실패 테스트 작성
-   테스트를 통과할 코드 작성(지저분해도 됨)
-   리팩터링

### 두 분파의 통합 테스트

런던파 기준, 실제 협력자 객체를 사용하면 통합테스트

→ 거의 모든 고전파 테스트가 통합테스트 취급

단위 테스트의 특징

-   단일 동작 검증
-   빠르게 수행
-   다른 테스트와 격리

통합 테스트는 이를 만족하지 못하는 테스트

-   공유의존성(디비)을 사용하면 다른 테스트와 분리 불가능
-   외부의존성(api?)을 사용하면 느려짐
-   모듈이 둘 이상일 때 여러 동작 단위를 테스트

### 엔드 투 엔드 테스트

통합테스트의 일부

코드가 외부 종속성과 어떻게 작동하는지 검증

최종 사용자의 관점에서 검증하는걸 뜻함(UI, GUI, 기능 테스트)

# 3. 단위 테스트 구조

## 3.1 단위 테스트를 구성하는 방법

### AAA 테스트

준비, 실행, 검증으로 나누어 검증하는 테스트. 쉽게 읽고 이해 가능

-   준비: sut와 의존성을 원하는 상태로 만듦
-   실행: sut의 메서드를 호출하고 준비된 의존성을 전달하며 출력을 캡쳐
-   검증: 반환값, sut와 협력자의 최종 상태 등으로 결과를 검증한다

검증 구절이 여러개라면, 캡슐화가 부족하다는 뜻

if 문을 삭제하고 여러 테스트로 나눠야 함

생성자에서 픽스처를 초기화 → 테스트간 결합도를 높임

비공개 팩토리 메서드를 이용하는게 바람직

# 4. 좋은 단위 테스트의 4대 요소

-   회귀 방지
-   리팩터링 내성
-   빠른 피드백
-   유지 보수성

### **회귀 방지**

회귀: 코드를 수정한 후 버그 발생하는 것

-   테스트 중 실행되는 코드 양을 늘리고
-   코드 복잡도를 낮춰서

발생 방지 가능

### **리팩터링 내성**

테스트를 실패로 바꾸지 않고 기존 소스코드를 리팩터링 할 수 있는가? 의 척도

리팩터링 후에 실패하는 테스트가 증가해 거짓 양성을 띄면 테스트를 신뢰 할 수 없음(오류 나도 무시)

리팩터링이 줄어든다

구현 세부 요소보다 최종 결과를 중요시 해서 개선할 수 있다.

### 빠른 피드백

테스트를 실행하는 속도가 빠를수록 더 자주 돌릴 수 있고, 이는 피드백 루프를 돌려 버그 생길 일을 줄인다.

### 유지보수성

두 요소로 구성됨

-   얼마나 이해하기 어려운가?
    테스트의 코드가 적을수록 이해하기 쉬움
-   얼마나 실행하기 어려운가?
    테스트가 프로세스 외부 종속성으로 작동하면 디비서버를 재부팅, 네트워크 연결 문제 해결등의 의존성 운영에 비용이 든다.

### 충돌하는 테스트 속성

-   빠른 피드백 vs 회귀 방지: 회귀 방지를 위해서는 많은 코드 실행, 빠른 피드백 달성 어려움
-   회귀 방지 vs 리팩터링 내성: 회귀 방지를 위해서는 내부 구현까지 테스트 필요, 리팩터링 내성 약해짐

# 5. 목과 테스트의 취약성

### 목과 스텁

-   목:
    외부로 나가는 상호작용을 모방하고 검사
-   스텁:
    내부로 들어오는 상호작용을 모방

스텁으로 상호작용을 검사하는것은 안티패턴

→ 구현 세부사항에 해당하기 때문

### **명령 조회 분리**

Command(명령)과 Query(조회)의 역할을 구분하는 설계 원칙

-   Command(명령) : 변경하는 작업을 수행하며 값을 반환하지 않음
-   Query(조회) : 조회하는 작업을 수행하며 값을 반환

모든 메서드는 둘 중 하나지만 둘을 동시에 수행하면 안됨

-   명령은 목으로 대체
-   조회는 스텁으로 대체

### **식별할 수 있는 동작과 구현 세부 사항**

코드를 다음과 같은 기준으로 분류 가능

-   **공개 API** 또는 **비공개 API**
-   **식별할 수 있는 동작** 또는 **구현 세부 사항**

공개 API가 식별할 수 있는 동작의 범위를 넘어 구현 세부 사항을 노출하면 안됨

클라이언트가 목표를 달성하는 데 도움이 되는 작업, 상태를 노출하는 것이 좋음

### **육각형 아키텍처**

상호 작용하는 애플리케이션의 집합

각 육각형은 도메인과 애플리케이션 서비스라는 레이어로 나뉨

다음과 같은 관점 중요

-   도메인과 애플리케이션 서비스 계층간의 영향분리
    -   도메인은 비지니스 로직을 책임짐
    -   애플리케이션 서비스는 도메인 계층과 외부 애플리케이션간의 작업을 조정해야함
-   두 가지 통신 유형
    -   시스템 내부 통신(구현 세부사항)
    -   시스템간 통신(외부 애플리케이션)
-   시스템 내 통신을 검증하고자 목을 사용하면 취약.
    → 시스템 간 통신, 그 사이트이펙트가 외부에서 보일때만 목을 사용하는 것이 타당

# 6. 단위테스트 스타일

세가지 스타일이 존재한다

1. 출력 기반 테스트(output-based testing)
2. 상태 기반 테스트(state-based testing)
3. 통신 기반 테스트(communication-based testing)

### 출력 기반 테스트

-   SUT에 입력을 넣고 생성되는 출력을 확인함
-   숨은 입출력이 없다고 가정(순수함수, 함수형)
-   반환값으로만 결과를 확인
-   테스트가 직관적이고 빠름, 디버깅 쉬움
-   리팩터링 내성 우수
-   반환값이 없는 함수에는 적용할 수 없음

### **상태 기반 스타일**

-   작업이 완료된 후 시스템의 상태를 확인하는 방식
-   상태기준 정의가 어려움
-   리팩터링 내성 낮음
-   유지보수 어려움(헬퍼 메서드로 그나마 유지보수성 완화 가능)
-   고전파 추구

### 행위 기반 테스트

-   출력이나 상태를 직접확인하지 않고, 무엇이 호출되었는지 검증
-   목 객체를 사용함
-   런던파 추구

### 함수형 아키텍쳐

비지니스로직과 사이드이펙트를 분리하는것이 지향점

유지보수성을 위해 성능을 희생

코드를 함수형 코어, 가변 셸로 나눔

가변셸이 입력을 코어에 공급하고 코어가 내린 결정을 가변 셸이 사이드이펙트로 변환한다

육각형 아키텍쳐와의 차이는 사이드 이펙트의 처리에 있다.

함수형은 사이드 이펙트를 도메인 계층 밖으로 밀어냄

육각형은 도메인 계층에 해당할 경우 사이드 이펙트를 일부 허용
