# CH5


### 1. Mocks와 Stubs의 구분

- Test double(가짜 객체)에는 dummy, stub, spy, mock, fake 등 다양한 종류가 있지만, 의미에 따라 두 개로 나뉜다.
    - Mocks: SUT가 외부 의존자에 사이드이펙트를 발생시키는 호출을 흉내 내고, 그런 호출이 이루어졌는지 검증한다.
    - Stubs: SUT가 내부 의존자에게 데이터를 요청하는 호출을 흉내 내는 것에 그친다. 호출 검증은 하지 않는다.
    
    예: 이메일 전송 → mock, 데이터 조회 → stub
    

### 2. Observable Behavior vs. Implementation Details

- 테스트는 비프로그래머가 밨을때도 의미 있는 “관찰 가능한 행위”를 검증해야 한다.
- 구현 세부사항(내부 로직 흐름, 특정 메서드 호출 등)을 검증하는 것은 fragility test(구현이 조금만 바뀌어도 실패하는 테스트)를 초래한다.

 

### 3. **The relationship between mocks and test fragility**

- Mocks는 외부 시스템과의 상호작용 (메일 전송, 데이터 제거 등)을 검증할 때 적합하다.
- 내부 시스템 간 상호작용 (도메인 모델 내 호출 흐름 등)에 대해 과도하게 사용하면, 코드 구조가 바뀔 때 테스트도 빈번히 깨지는 문제를 낳는다.
- 도메인 내부에서는 되도록이면 mock을 쓰지 말고, 최종 상태를 검사하는 방식의 테스트를 선택하자

### 4. **The classical vs. London schools of unit testing,revisited**

- Classical School: 테스트를 병렬 실행이 가능하도록 하기 위해, 공유되는 외부 의존성에 대해서만 대역 사용 권장.
- London School: 코드 간의 결합을 막기 위해, 모든 mutable 의존성에 대해 대역 사용 권장.
    
    → 하지만 과도한 mocking은 테스트를 fragile하게 만든다는 위험이 있다.
    
- 모든 외부 의존성에 대해서 목으로 대체할 필요는 없다. 애플리케이션에서만 접근이 가능한 경우는 사실상 외부 가 아닌 내부 구현 사항이라고 간주해야한다.
