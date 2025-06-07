<h1><center> Unit Testing Chapter 2 - TIL </center></h1>

###### tags: `💻 TIL`
###### date: `2024-05-2917:21:33.284Z`

> [color=#724cd1][name=데릭]

## 2장. 단위 테스트란 무엇인가?

---

### 단위 테스트의 정의 (3가지 조건)

1. **작은 코드 단위(unit)**를 검증한다  
2. **빠르게 실행되어야** 한다  
3. **고립된 환경**에서 실행되어야 한다  

> 단위 테스트는 이 세 가지 조건을 모두 만족해야 한다

#### 런던파 (London School)

- 테스트 대상 클래스를 **모든 협력 객체로부터 격리**해야 한다
- 의존 객체는 전부 **테스트 더블(mock, stub 등)**로 대체
- 테스트는 항상 **한 클래스만**을 단위(unit)로 검증

**장점**

- 테스트 실패 시 원인을 빠르게 특정할 수 있다
- 복잡한 의존 그래프를 단순화할 수 있다
- 구조가 명확하고 테스트 범위가 작음

**단점**

- **구현에 지나치게 의존**한 테스트가 되기 쉬움 (over-specification)
- 리팩토링 시 테스트가 쉽게 깨짐
- 테스트가 실제 의미 있는 동작을 보장하지 않을 수 있음

```swift 

// MARK: - 실제 클래스 정의
protocol Store {
    func getPrice() -> Int
}

class Customer {
    func buy(store: Store) -> Bool {
        return store.getPrice() <= 100  // 예산 100 이하만 구매
    }
}

// MARK: - 테스트 더블 (Mock)
class MockStore: Store {
    var stubbedPrice: Int = 0

    func getPrice() -> Int {
        return stubbedPrice
    }
}

// MARK: - 런던파 테스트
func test_customer_buys_if_price_is_under_budget() {
    let mockStore = MockStore()
    mockStore.stubbedPrice = 50

    let customer = Customer()
    assert(customer.buy(store: mockStore) == true)
}

```

---

#### 클래식파 (Classic School)

- **테스트들 간의 상호 간섭을 막는 것**이 핵심
- 공유 상태(DB, 파일 등)는 테스트 더블로 대체
- 단일 클래스 또는 여러 클래스를 단위로 테스트할 수 있음

**장점**

- 실제 객체를 사용하므로 **비즈니스 로직 중심의 테스트 가능**
- 시스템의 실제 동작을 잘 반영
- 설계 결함이 테스트에 잘 드러남

**단점**

- 테스트가 더 복잡해질 수 있음
- 실패 원인 추적이 어려운 경우도 있음

```swift 

// MARK: - 실제 클래스 정의
class RealStore: Store {
    func getPrice() -> Int {
        return 70
    }
}

// MARK: - 클래식파 테스트
func test_customer_buys_real_store() {
    let realStore = RealStore()

    let customer = Customer()
    assert(customer.buy(store: realStore) == true)
}

```

---

### 단위 테스트 vs 통합 테스트

## | 기준 | 단위 테스트 | 통합 테스트 |

|------|-------------|-------------|
| 실행 속도 | 빠름 | 상대적으로 느림 |
| 격리성 | 완전 고립 | 외부 의존성 포함 |
| 범위 | 작은 단위 (함수/클래스) | 시스템 간 상호작용 |
| 예시 | 도메인 로직 검증 | DB + API 연동 테스트 |


> [단위 테스트] → [통합 테스트] → [E2E 테스트]

**단위 테스트(Unit Test)**

- 아주 작고 빠름. 주로 함수/클래스 하나만 검증.

**통합 테스트(Integration Test)**

- 여러 컴포넌트(DB, 네트워크 등)가 함께 잘 동작하는지 확인.

**E2E 테스트(End-to-End Test)**

- 전체 시스템이 실제 사용자 시나리오대로 문제없이 동작하는지 검증.
