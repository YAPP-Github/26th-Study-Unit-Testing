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

-   static var count = 0 같은 **static 변수**
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
-
