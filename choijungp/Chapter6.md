# 6장. 단위 테스트의 스타일

- 출력 기반 테스트 (output-based)
    - 가장 높은 품질의 테스트를 만들어내지만 순수 함수형으로 작성된 코드에만 적용 가능하다.
- 상태 기반 테스트 (state-based)
- 통신 기반 테스트 (communication-based)

<br>

## 6.1 단위 테스트의 세 가지 스타일

### **출력 기반 스타일 (output-based)**   
- SUT에 입력값을 주고, 그 결과로 생성된 출력값을 검증한다.
- 글로벌 상태나 내부 상태를 변경하지 않는 코드에만 적용 가능하고 (= side effect가 없어야 하고), 검증해야 할 유일한 요소는 반환값이다.

### **상태 기반 스타일 (state-based)**   
- 어떤 작업이 완료된 후에 시스템의 상태를 검증한다.
- 여기서의 state는 SUT 자체의 상태일 수 있고, 의존성의 상태이거나 프로세스 외부의 의존성 상태일 수 있다.
- 클래식파 선호

### **통신 기반 스타일 (communication-based)**    
- mock을 사용하여 SUT와 의존성들 간의 통신이 올바르게 이루어졌는지를 검증한다.
- 여기서의 state는 SUT 자체의 상태일 수 있고, 의존성의 상태이거나 프로세스 외부의 의존성 상태일 수 있다.
- 런던파 선호

<br>

## 6.2 단위 테스트의 세 가지 스타일 비교하기

### **회귀 방지와 피드백 속도 관점에서의 비교**
**회귀로부터의 보호**    
- **테스트 중 실행되는 코드의 양, 코드 복잡도, 도메인 관점에서의 중요도**에 의해 결정된다.
- 특정 스타일이 해당 측면에서 뚜렷한 이점을 제공하진 않는다.
- 다만 통신 기반 스타일은 과도하게 사용할 경우 대부분 코드를 mock 처리하고 얕은 수준만 검증하는 테스트가 되기 쉽다.

**피드백 속도**   
- 이것또한 테스트 스타일 간의 상관관계가 거의 없다. (대체로 비슷한 실행 속도)

<br>

### **리팩토링 저항성 관점에서의 비교**
리팩터링 저항성은 테스트가 얼마나 많은 거짓 양성을 발생시키는지를 나타낸다.       
거짓 양성은 테스트가 구현 세부사항에 결합되어 있을 때 발생한다. (즉, 외부 동작이 아닌 내부 구조에 의존하는 경우)      

- **출력 기반 테스트**
    - 구현 세부사항에 대한 결합도가 가장 낮기 때문에 거짓 양성을 유발할 가능성이 가장 낮다.
    - 오직 반환값에만 의존
- **상태 기반 테스트**
    - 상대적으로 거짓 양성에 취약하다.
    - 메서드 뿐만 아니라 객체의 상태도 함께 다루기 때문에 테스트가 코드와 결합될 가능성이 더 크다.
- **통신 기반 테스트**
    - 세 가지 스타일 중 거짓 양성에 가장 취약하다.
    - 테스트 대역과의 상호작용을 검증하는 테스트는 매우 깨지기 쉽다.

그렇지만 캡슐화를 잘 유지한다면 거짓 양성을 최소화할 수 있다.

<br>

### 유지보수성 관점에서의 비교
리팩토링 저항성과 달리 완화할 수 있는 방법이 많지 않다.    
유지보수성은 **테스트를 얼마나 이해하기 어려운가, 실행하기 어려운가**에 의해 결정된다.     
테스트가 클수록, 하나 이상의 프로세스 외부 의존성과 직접 연관될수록 유지보수성이 낮다.      

   
- **출력 기반 테스트**
    - 다른 두 가지와 비교했을 때 가장 유지보수성이 높다.
    - 메서드에 입력을 제공하고, 출력값을 검증하는 두 가지 작업으로 구성되어 있다.
- **상태 기반 테스트**
    - 출력 기반 테스트보다 유지보수성이 낮다.
    - 상태를 검증하는 작업이 출력 검증보다 공간을 차지하는 경우가 많기 때문이다.
    - 헬퍼 메서드를 도입하여 문제를 완화할 수 있다.
- **통신 기반 테스트**
    - 유지보수성 측면에서 가장 낮은 점수를 갖고 있다.
    - 테스트 대역을 설정하고 상호작용을 작성하는 과정에서 많은 코드가 필요하다.

<br>

### 결과

|  | 출력 기반 테스트 | 상태 기반 테스트 | 통신 기반 테스트 |
| --- | --- | --- | --- |
| 리팩토링 저항성을 위한 신중함 | 낮음 | 중간 | 중간 |
| 유지보수 비용 | 낮음 | 중간 | 높음 |


<br>

## 6.3 함수형 아키텍처

### 함수형 프로그래밍   
- 수학적 함수(순수 함수)를 이용한 프로그래밍을 말한다.
- 수학적 함수는 같은 입력에 대해 항상 같은 출력을 반환한다.
- 숨겨진 입력과 출력이 없다.
    - side effect, exception, 내부 또는 외부 상태에 대한 참조
- 출력 기반 테스트를 적용할 수 있는 유일한 종류의 메서드이며 유지보수성이 높고, 거짓 양성이 발생할 확률이 가장 적다.

<br>

### 함수형 아키텍처    
- 부작용을 비즈니스 작업의 가장자리에 밀어냄으로써, 비즈니스 로직과 부작용을 분리한다.
- 순수 함수형 방식으로 작성된 코드의 양을 최대화하고, 부작용을 다루는 코드를 최소화 한다.

그렇다면 비즈니스 로직과 부작용 분리를 어떻게 할까 ?     
- 결정을 내리는 코드와 그 결정을 실행에 옮기는 코드로 분리한다.

<br>

## 6.4 함수형 아키텍처로 전환하기와 출력 기반 테스트

**초기버전**
- 파일 시스템 같은 공유 자원을 포함한 테스트는 유지보수성도 떨어지고, 속도가 느려질 수 있다.
    - 사실상 통합 테스트에 가까움


**mock 사용 시**
- 파일 시스템과 강하게 결합되어 있는 문제를 해결하는 일반적인 방법은 파일 시스템을 mock으로 대체하는 것이다.


**함수형 아키텍처로 리팩토링**  
- 부작용 자체를 아예 클래스 밖으로 옮기는 방식
- 비즈니스 로직과 부작용의 분리


|  | 초기 버전 | mock을 사용할 때 | 출력 기반  |
| --- | --- | --- | --- |
| 회귀로부터의 보호 | 좋음 | 좋음 | 좋음 |
| 리팩토링에 대한 저항력 | 좋음 | 좋음 | 좋음 |
| 빠른 피드백 | 나쁨 | 좋음 | 좋음 |
| 유지보수성 | 나쁨 | 보통 | 좋음 |


-----

## 느낀점

이번 장을 통해 다양한 단위 테스트 스타일을 알아봤다. (출력 기반, 상태 기반, 통신 기반)  
그동안 테스트 진행했을 때는 무분별하게 섞어 사용했던 것 같다.     

머리로는 출력 기반 테스트가 좋고 이점이 많다는 것을 알지만 .. 막상 테스트를 출력 기반으로만 구성하기는 어려울 수 있을 것 같다는 생각이 들었다.    
앞으로는 조금 더 의식적으로 생각하며 상황에 따라 적절한 스타일을 혼합해서 사용해야겠다. ..   

클린 아키텍처 스터디 당시 함수형 패러다임에 대한 얘기가 잠시 나왔는데 .. 테스트와 엮어 생각할 수 있지 않을까 ? 라는 생각도 들었다.
