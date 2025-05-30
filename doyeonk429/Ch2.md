# Ch2. What is a Unit Test?

## 단위 테스트의 정의
- 작은 Unit을 검증  
- 빠르게 실행  
- 격리된 방식으로 수행  

## Classical Style
> **실행 격리**  
- 격리 대상: Test  
- SUT는 하나의 클래스거나 shared dependency를 갖지 않는 클래스 집합  
- 테스트 간 **상호 간섭이 없어야 함** (즉, **테스트들끼리 격리**)  
- shared dependency만 Test Double로 대체 (SUT가 모든 Collaborator와 격리될 필요 없음)  
- 테스트하기 어려운 코드는 코드 자체에 문제가 있는 것이다.  

## London(Mockist) Style
> **구조 격리**  
- 격리 대상: SUT(Unit)  
- SUT는 하나의 class거나 method  
- SUT는 모든 Collaborator와 격리되어야 함  
- mutable dependency는 Test Double로 대체되어야 한다  
- 테스트 구조 단순 (복잡한 의존성 그래프 분리 가능)  
- test fail 시, SUT만 의심하면 된다 (범인 찾기 확실)  

### 문제점
- 테스트는 코드 단위가 아니라 **동작 단위**를 검증해야 한다.  
- **Over-specification**: 테스트가 SUT의 **구현 세부사항에 너무 밀접하게 결합됨**  
- 코드 리팩토링을 어렵게 하고, 테스트 유지보수 비용을 증가시킴  

## 통합 테스트
- 단위 테스트의 조건 중 하나라도 충족하지 못하는 테스트  
- 외부 시스템과 통신하거나 느리거나, 다른 테스트와 격리되지 않은 경우 등  

## End-to-End Test
- 시스템을 최종 사용자 관점에서 검증  
- 거의 모든 **외부 의존성에 직접 접근**  

## Shared vs Volatile
- **DB**: Shared & Volatile  
- **File System**: Shared 만 해당  
- **Random Generator**: Volatile 만 해당  
