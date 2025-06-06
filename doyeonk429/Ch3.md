# Ch 3. The anatomy of a Unit Test

- The structure of a unit test단위 테스트의 구조
- Unit test naming best practices단위 테스트 이름 짓기 모범 사례
- Working with parameterized tests매개변수화된 테스트 사용하기
- Working with fluent assertions

## AAA 패턴

- 배치/준비(Arrange), 실행(Act), 검증(Assert) 패턴
    - 모든 테스트가 일관된 구조를 가지므로, 익숙해지면 어떤 테스트든 쉽게 읽고 이해할 수 있다는 장점
    - 테스트 전체의 유지 비용을 줄일 수 있음
1. Arrange: SUT와 의존성을 원하는 상태로 준비
2. Act: SUT의 method를 호출하고, 준비한 의존성을 전달하며, 출력값을 수집
3. Assert: 결과 검증(ex. 리턴값, SUT의 최종 상태, SUT가 호출한 메서드 등)

### Given-When-Then 패턴

- Given: AAA의 Arrange와 동일
- When: AAA의 Act와 동일
- Then: AAA의 Assert와 동일

기능이 아직 존재하지 않기 때문에 무엇을 기대할지부터 생각하고 Assert를 먼저 작성하는 것도 좋은 전략(TDD)

- TDD라면 ? → Assert부터 작성
- Production code가 존재한다면 ? → Arrange부터 작성

### Guide for AAA

- 여러 개의 Act와 Assert를 갖게 되는 경우 → 통합 테스트에 가까워짐(유닛 테스트 아님!)
- if문 사용 🙅‍♂️
    - 테스트는 분기 없이 단순한 순차적 단계들의 나열이어야 함!(분기문은 테스트가 한 번에 너무 많은 것을 검증하고 있다는 신호)
    - → 통합 테스트도 마찬가지로 해당됨. 분기문이 있다면 더 작은 테스트로 쪼개야 한다
- 섹션 별 적정 크기?
    - Arrange: 보통 가장 큰 파트. 너무 길어진다면, private 메서드나 팩토리 클래스로 분리하자.
    - Act: Ideal하게 1줄. → 여러 줄이 된다면, API가 잘못 설계되었다는 신호(Production code의 Interface를 점검하자. 캡슐화가 잘 되었는지 검토할 필요가 있다.)
    - Assert: 여러 개의 assert를 사용해도 되지만, 섹션이 너무 커지면 안됨 → 행동 단위(unit of behavior)의 테스트를 검증하는 과정에서 여러 개의 결과를 검증해야하는 상황이 있을 수 있다
        - 객체 클래스에 적절한 동등성을 비교(모든 property를 개별적으로 검증할 필요X)
    
    ```swift
    // Not Good Case
        #expect(fetchedInfo.0.id == record.id)
        #expect(fetchedInfo.0.createdAt == record.createdAt)
        #expect(fetchedInfo.0.state == record.state)
        #expect(fetchedInfo.0.starCount == record.starCount)
    
    // Good Case - book struct에 Equatable 채택
        #expect(book == DummyData.dummyBooks[0])
    ```
    
- Teardown 단계
    - 대부분의 단위 테스트는 teardown이 필요 없다. 단위 테스트는 외부 프로세스 종속성과 상호작용하지 않기 때문에.
- AAA 주석 제거 : 주석 대신 섹션 사이의 빈 줄을 넣어서 구분 가능

### SUT 구분

- SUT: 테스트에서 동작을 실행시키는 **단 하나의 진입점** 클래스
- 여러 클래스가 관여하더라도, 테스트에서는 오직 하나의 진입점만 SUT로 간주해야 한다. 의존성이 많을 때도 SUT와 나머지 의존성을 명확히 구분하기 위해, 테스트 코드에서 SUT 인스턴스를 항상 `sut`라는 이름으로 선언하는 걸 권장.

## Test Fixture 재사용

- 설정 코드를 별도의 메서드나 클래스로 추출해놓고 여러 테스트에서 재사용

### Test Fixture

1. 테스트가 실행되는 대상 객체 → Dependency일 수 있으며, SUT에 전달되는 인자, DB의 데이터, Disk의 파일 등이 해당
    - 테스트가 실행되기 전마다 항상 동일하고 예측 가능한 상태를 유지
2. NUnit에서의 정의 (→ 책에서 주로 다루는 의미 🙅‍♂️)

- 공통된 설정 로직(configuration logic)을 갖도록 리팩토링
- 장점: 테스트 코드 양 감소
- 단점: 테스트 간 결합도coupling 상승, 가독성readability 저하

### High coupling

- Anti-pattern
- 수정의 독립성 `하나의 테스트를 수정해도 다른 테스트에 영향을 주어서는 안 된다` 원칙 위배
- 테스트 클래스 내에 공유 상태(shared state)를 도입하면 안됨

### Readability

- 테스트 메서드만 들여다봐서는 전체 테스트 흐름을 알 수 없다 → 다른 클래스까지 봐야 이해 가능

## Better Way

- **private factory methods** in the test class
- 실제 테스트 코드에 적용해본 케이스
    
    ```swift
    // MARK: - Private Factory Methods
    
    /// 단일 (Record, Book) 페어를 생성해서 저장한 뒤 반환합니다.
    private func makeAndSaveRecordPair(
      recordIndex: Int,
      bookIndex: Int
    ) async throws -> (Record, Book) {
      let book = DummyData.dummyBooks[bookIndex]
      let record = DummyData.dummyRecords[recordIndex]
      
      try await libraryUseCase.saveRecord(record: record, book: book)
      return (record, book)
    }
      
    /// 여러 (Record, Book) 페어를 생성해서 저장한 뒤, 리스트로 반환합니다.
    private func makeAndSaveMultipleRecordPairs(
      indices: [(record: Int, book: Int)]
    ) async throws -> [(Record, Book)] {
      var pairs: [(Record, Book)] = []
      
      // 생성 순서대로 save 후 배열에 추가
      for idx in indices {
        let book = DummyData.dummyBooks[idx.book]
        let record = DummyData.dummyRecords[idx.record]
        try await libraryUseCase.saveRecord(record: record, book: book)
        pairs.append((record, book))
      }
      
      return pairs
    }
      
    // MARK: - Tests
      
    @Test("Save/Load Record Test")
    func loadRecordTest() async throws {
      // 1. 레코드와 책 생성 및 저장
      let (record, _) = try await makeAndSaveRecordPair(recordIndex: 0, bookIndex: 0)
      
      // 2. 저장된 레코드 패치
      let fetchedInfo = try await libraryUseCase.loadRecord(record.id)
      
      #expect(fetchedInfo.0.id == record.id)
      #expect(fetchedInfo.0.createdAt == record.createdAt)
    }
      
    @Test("loadRecentUpdatedReadingRecord Test")
    func loadRecentUpdatedReadingRecordTest() async throws {
      // 1. 레코드-책 페어 생성 (3개)
      let indexTuples: [(record: Int, book: Int)] = [ (0, 0), (1, 1), (2, 2) ]
      let sortedTuples = indexTuples.sorted { lhs, rhs in
        DummyData.dummyRecords[lhs.record].createdAt > DummyData.dummyRecords[rhs.record].createdAt
      }
      let infos = try await makeAndSaveMultipleRecordPairs(indices: sortedTuples)
      
      // 2. 최근 업데이트한 읽는 중 상태의 기록만 필터링
      let predictList = infos
        .filter { $0.0.state == .reading }
        .sorted { $0.0.updatedAt > $1.0.updatedAt }
        .prefix(3)
      
      // 3. 실제 로드 결과
      let fetchedList = try await libraryUseCase
        .loadRecentUpdatedReadingRecord(maxCount: 3)
      
      // 4. 첫 번째 요소만 비교
      if let expected = predictList.first {
        #expect(fetchedList[0] == expected)
      }
    }
    ```
    

## Naming

- 고정된 양식 🙅‍♂️: `public void Sum_TwoNumbers_ReturnsSum()`
- 단순한 자연어 문장(plain English)으로 작성한 이름: `public void Sum_of_two_numbers()`
- 테스트하고자 하는 동작(behavior)을 잘 반영한 네이밍이 좋다
- 테스트 이름에 SUT의 메서드명을 넣지 말자

## 매개변수화된 테스트로 리팩토링하기

- 여러 개의 비슷한 구조의 테스트 메서드 → 파라미터가 있는 하나의 메서드로 리팩토링
- 테스트 코드의 양과 코드 가독성 사이에는 균형을 맞춰야 하는 트레이드오프가 존재
    - 입력 파라미터만 보고 어떤 케이스가 긍정이고 부정인지 명확히 알 수 있을 때만, 긍정과 부정 테스트 케이스를 하나의 메서드에 함께 두는 것이 좋다

### Before Refactoring

```swift
struct DeliveryDateValidatorTests {
  
  private let validator = DeliveryDateValidator()
  
  @Test("Delivery for today is invalid")
  func deliveryForTodayIsInvalid() async throws {
    let today = Date()
    let isInvalid = !validator.isValidDeliveryDate(today)
    #expect(isInvalid == true)
  }
  
  @Test("Delivery for tomorrow is invalid")
  func deliveryForTomorrowIsInvalid() async throws {
    let tomorrow = Calendar.current.date(
      byAdding: .day,
      value: 1,
      to: Date()
    )!
    let isInvalid = !validator.isValidDeliveryDate(tomorrow)
    #expect(isInvalid == true)
  }
  
  @Test("The soonest delivery date is two days from now")
  func soonestDeliveryDateTwoDaysFromNowIsValid() async throws {
    let dayAfterTomorrow = Calendar.current.date(
      byAdding: .day,
      value: 2,
      to: Date()
    )!
    let isInvalid = !validator.isValidDeliveryDate(dayAfterTomorrow)
    #expect(isInvalid == false)
  }
}
```

### After Refactoring

```swift
struct DeliveryDateValidatorTests {

  private let validator = DeliveryDateValidator()

  @Test("Can detect invalid delivery dates")
  func canDetectInvalidDeliveryDate() async throws {
    // (daysFromNow, expectedIsInvalid)
    let cases: [(Int, Bool)] = [
      (0, true),   // 오늘: 무효
      (2, false)   // 모레: 유효
    ]

    for (days, expectedInvalid) in cases {
      let date = Calendar.current.date(
        byAdding: .day,
        value: days,
        to: Date()
      )!
      let isInvalid = !validator.isValidDeliveryDate(date)
      #expect(isInvalid == expectedInvalid)
    }
  }
}
```

## Assertion library

### XCTest

Swift에서 기본적인 `XCTAssert…` 계열 함수 제공

- `XCTAssertEqual(_:_:)`
- `XCTAssertTrue(_:)`
- `XCTAssertThrowsError(_:)`
- `XCTAssertNil(_:)`

### Fluent Assertions ?

→ third-party 라이브러리 사용 가능(ex. Nimble, Quick)

### Nimble

- Matcher 제공
- `expect(actual).to(equal(expected))`
- `expect(actual).toNot(equal(expected))`
- `expect(actual).notTo(equal(expected))`

### Quick

- B(ehavior)DD 스타일의 테스트 구조 제공
- `describe("...")` / `context("...")` / `it("...")`
