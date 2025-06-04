# ch3 The anatomy of a unit test

#### This chapter covers
- The structure of a unit test
- Unit test naming best practices
- Working with parameterized tests
- Working with fluent assertions

1부의 이 남은 장에서는 몇 가지 기본적인 주제들을 다시 짚고 넘어가겠습니다.
일반적으로 배치(Arrange), 실행(Act), 검증(Assert) 패턴으로 표현되는 단위 테스트의 구조를 먼저 살펴보겠습니다.
그리고 제가 선택한 단위 테스트 프레임워크인 xUnit을 소개하고, 왜 경쟁 프레임워크가 아닌 xUnit을 사용하는지도 설명하겠습니다.

이 과정에서 단위 테스트의 이름을 짓는 방식에 대해서도 이야기할 텐데요.
이 주제에는 여러 가지 조언들이 존재하지만, 안타깝게도 대부분은 단위 테스트의 품질을 충분히 개선하지 못합니다.
이 장에서는 그런 덜 유용한 이름 짓기 관행들을 설명하고, 왜 그것들이 최선이 아닌지를 보여드리겠습니다.
그리고 그 대신, 문제 도메인을 잘 아는 사람이라면 누구든지 쉽게 이해할 수 있도록 테스트 이름을 읽기 쉽게 만드는 간단하고 따라 하기 쉬운 가이드라인을 제시하겠습니다.

마지막으로, 단위 테스트 작업을 더 효율적으로 만들어주는 프레임워크의 기능들도 다룰 예정입니다.
이 정보들이 C#이나 .NET에만 국한된 내용일까 걱정하지 않으셔도 됩니다.
대부분의 단위 테스트 프레임워크는 프로그래밍 언어가 달라도 비슷한 기능을 제공하므로, 하나만 익혀도 다른 프레임워크를 사용하는 데 큰 어려움이 없을 것입니다.

## 3.1 단위 테스트를 어떻게 구성할 것인가
이 절에서는 Arrange, Act, Assert 패턴을 사용한 단위 테스트 구조와 피해야 할 실수, 그리고 테스트를 최대한 읽기 쉽게 만드는 방법을 설명합니다.

#### 3.1.1 AAA 패턴 사용하기
AAA 패턴은 테스트를 세 부분으로 나누는 것을 권장합니다: Arrange (준비), Act (실행) 그리고 Assert (검증). (이 패턴은 때때로 3A 패턴이라고도 합니다.) 
예제로는 두 숫자의 합을 계산하는 메서드가 하나 있는 Calculator 클래스를 사용합니다:

```csharp
public class Calculator
{
    public double Sum(double first, double second)
    {
        return first + second;
    }
}
```

다음은 이 클래스의 동작을 검증하는 테스트로, AAA 패턴을 따릅니다:
```csharp
public class CalculatorTests // Class-container for a cohesive set of tests
{
    [Fact] // xUnit’s attribute indicating a test
    public void Sum_of_two_numbers() // Name of the unit test
    {
        // Arrange
        double first = 10;
        double second = 20;
        var calculator = new Calculator();

        // Act
        double result = calculator.Sum(first, second);

        // Assert
        Assert.Equal(30, result);
    }
}
```

AAA 패턴의 장점 중 하나는 모든 테스트가 일관된 구조를 가지므로, 익숙해지면 어떤 테스트든 쉽게 읽고 이해할 수 있다는 점입니다.
 이는 테스트 전체의 유지 비용을 줄이는 데 도움이 됩니다.
패턴의 구성:
- Arrange: 테스트 대상(SUT)과 그 의존성을 원하는 상태로 준비합니다.
- Act: SUT에 메서드를 호출하고, 준비한 의존성을 전달하며, 출력값을 수집합니다.
- Assert: 결과를 검증합니다. 이 결과는 리턴 값, SUT의 최종 상태 또는 SUT가 호출한 메서드 등이 될 수 있습니다.

> Given-When-Then 패턴

Given-When-Then 패턴은 AAA 패턴과 비슷하지만, 비개발자에게 더 읽기 쉬운 방식입니다.
- Given: AAA의 Arrange와 동일
- When: AAA의 Act와 동일
- Then: AAA의 Assert와 동일

실제로 테스트 구성은 동일하며, 차이는 단지 표현 방식입니다. 먼저 Assert로 시작하는 것도 가능하다

자연스럽게 사람들은 테스트를 Arrange부터 작성하려고 합니다. 하지만 TDD(테스트 주도 개발)를 할 때는, 기능이 아직 존재하지 않기 때문에 무엇을 기대할지부터 생각하고 Assert를 먼저 작성하는 것도 좋은 전략입니다.
이 방법은 처음엔 직관에 어긋나지만, 문제를 해결하는 방식과 유사합니다:
 우리는 먼저 "무엇을 달성하고 싶은지"를 생각하고, 그 후에 해결 방식을 고민합니다.
하지만 이미 프로덕션 코드를 작성한 후 테스트를 작성한다면, 이미 기대 동작을 알고 있으므로 Arrange부터 시작하는 것이 더 자연스럽습니다.

#### 3.1.2 Arrange, Act, Assert 섹션을 여러 번 사용하는 것은 피하라
가끔 하나의 테스트 안에 여러 개의 Arrange, Act, Assert가 존재하는 경우가 있습니다.
 이런 경우는 여러 동작을 동시에 검증하고 있는 것으로, 더 이상 단위 테스트라기보다는 통합 테스트에 가깝습니다.
예외는 느린 통합 테스트를 병합해 빠르게 만들고자 할 때뿐입니다. 이 경우, 상태가 자연스럽게 이어지는 여러 단계를 하나의 테스트에 포함시키는 것이 속도 측면에서 이점이 있을 수 있습니다.
 하지만 단위 테스트나 충분히 빠른 통합 테스트에서는 이와 같은 최적화는 필요 없습니다. 각 행동을 별도의 테스트로 분리하는 것이 더 낫습니다.

#### 3.1.3 테스트 안에 if 문 사용은 피하라
테스트 코드에 if 문이 있다면, 이 테스트는 너무 많은 것을 검증하려는 안티패턴입니다.
 이 경우에도 테스트를 분리하는 것이 좋습니다.
 그리고 이 규칙은 통합 테스트에도 예외가 없습니다. 테스트 내 분기문은 단지 유지 비용을 늘리고 읽기 어렵게 만들 뿐입니다.

#### 3.1.4 각 섹션의 적정 크기는?
Arrange 섹션이 가장 클 수 있다
보통 Arrange가 가장 큰 섹션입니다. Act와 Assert를 합친 것보다 클 수 있습니다.
 그러나 지나치게 길어지면, private 메서드나 팩토리 클래스로 분리하는 것이 좋습니다.
 재사용을 위해서는 Object Mother 패턴이나 Test Data Builder 패턴이 도움이 됩니다.
Act 섹션은 한 줄이 이상적이다
Act는 보통 한 줄이어야 합니다.
 두 줄 이상이라면, 이는 SUT의 API에 문제가 있음을 암시합니다.
예를 들어:

```csharp
public void Purchase_succeeds_when_enough_inventory()
{
    // Arrange
    var store = new Store();
    store.AddInventory(Product.Shampoo, 10);
    var customer = new Customer();

    // Act
    bool success = customer.Purchase(store, Product.Shampoo, 5);

    // Assert
    Assert.True(success);
    Assert.Equal(5, store.GetInventory(Product.Shampoo));
}
```

이처럼 Act 섹션이 한 줄이면, 클래스의 API가 잘 설계되었다는 신호입니다.
그러나 아래 예시는 Act가 두 줄입니다:
```csharp
public void Purchase_succeeds_when_enough_inventory()
{
    // Arrange
    var store = new Store();
    store.AddInventory(Product.Shampoo, 10);
    var customer = new Customer();

    // Act
    bool success = customer.Purchase(store, Product.Shampoo, 5);
    store.RemoveInventory(success, Product.Shampoo, 5);

    // Assert
    Assert.True(success);
    Assert.Equal(5, store.GetInventory(Product.Shampoo));
}
```

이 예시에서는 구매 완료 후 직접 인벤토리를 제거해야 하기 때문에, 고객이 두 개의 메서드를 호출해야 합니다.
 이런 설계는 캡슐화가 부족하다는 증거입니다. 클라이언트 코드가 실수로 두 번째 메서드를 호출하지 않으면, 데이터 불일치가 발생할 수 있습니다. 이는 **불변 조건(invariant)**이 깨진 상태입니다.
이런 불일치는 데이터베이스까지 침투할 수 있으며, 재시작으로는 복구할 수 없는 심각한 문제가 될 수 있습니다. 예: 고객에게 제품이 확보되었다고 알렸지만 실제로는 재고가 남지 않은 경우.
이러한 문제를 방지하기 위해, 캡슐화를 철저히 지켜야 합니다. 구매라는 행위는 제품 획득과 재고 차감이 동시에 이루어져야 하므로, 단일 public 메서드로 처리하는 것이 바람직합니다.
이 규칙은 비즈니스 로직에는 매우 중요하지만, 유틸리티 또는 인프라 코드에는 덜 적용될 수 있습니다.
 하지만 항상 캡슐화 위반 여부를 점검해야 합니다.


#### 3.1.5 Assert 섹션에는 몇 개의 검증문이 있어야 하나?
많은 사람들은 테스트에 단 하나의 Assert만 사용하라고 배웁니다. 이는 테스트 대상의 최소 단위 코드만을 검증해야 한다는 오해에서 비롯된 것입니다.
하지만 단위 테스트의 단위는 **"행동 단위(unit of behavior)"**이며, 하나의 행동이 여러 결과를 만들어내는 것은 자연스러운 일입니다. 따라서 여러 개의 assert를 사용하는 것도 문제 없습니다.
너무 커지는 Assert 섹션을 조심해야 합니다
이는 프로덕션 코드에서 추상화가 빠졌다는 신호일 수 있습니다. 예를 들어, SUT(테스트 대상 시스템)가 반환하는 객체의 모든 속성을 개별적으로 검증하는 대신, 해당 객체 클래스에 적절한 동등성(equality) 멤버를 정의하는 것이 더 나을 수 있습니다. 그러면 단일 어설션을 통해 기대값과 객체를 비교할 수 있습니다.

#### 3.1.6 Teardown 단계에 대해
일부 사람들은 AAA 패턴(Arrange, Act, Assert)에 이어 네 번째 단계인 teardown(정리)을 구분하기도 합니다. 예를 들어, 테스트에서 생성된 파일을 삭제하거나 데이터베이스 연결을 닫는 작업이 이에 해당합니다. Teardown은 일반적으로 클래스의 모든 테스트에서 재사용되는 별도의 메서드로 구현됩니다. 따라서 저는 AAA 패턴에 teardown 단계를 포함시키지 않습니다.
대부분의 단위 테스트는 teardown이 필요 없습니다. 단위 테스트는 외부 프로세스 종속성과 상호작용하지 않기 때문에 정리해야 할 부작용이 남지 않습니다. 이런 정리는 통합 테스트의 영역이며, 이에 대해서는 3부에서 더 자세히 다룰 것입니다.

#### 3.1.7 테스트 대상 시스템(SUT) 구분하기
SUT는 테스트에서 중요한 역할을 합니다. 이는 애플리케이션에서 원하는 동작을 호출하는 진입점입니다. 앞서 다룬 것처럼 이 동작은 여러 클래스에 걸쳐 있을 수도 있고, 단일 메서드에만 해당할 수도 있습니다. 하지만 진입점은 오직 하나여야 합니다: 이 동작을 유발하는 클래스 하나입니다.
따라서 특히 많은 의존성이 존재할 경우, 테스트에서 SUT와 그 외 의존성을 구분하는 것이 중요합니다. 이를 위해 테스트에서 SUT는 항상 sut이라는 이름을 사용하세요. 아래는 CalculatorTests에서 Calculator 인스턴스를 sut로 이름을 바꾼 예시입니다:
```csharp
public class CalculatorTests
{
    [Fact]
    public void Sum_of_two_numbers()
    {
        // Arrange
        double first = 10;
        double second = 20;
        var sut = new Calculator();

        // Act
        double result = sut.Sum(first, second);

        // Assert
        Assert.Equal(30, result);
    }
}
```

#### 3.1.8 AAA 주석을 테스트에서 제거하기
SUT와 그 의존성을 구분하는 것만큼이나, 테스트의 세 섹션(Arrange, Act, Assert)을 구분하는 것도 중요합니다. 이를 위해 각 섹션 앞에 // Arrange, // Act, // Assert 주석을 넣을 수 있습니다. 혹은 다음 예시처럼 각 섹션 사이에 빈 줄을 넣어 구분할 수도 있습니다:
```csharp
public class CalculatorTests
{
    [Fact]
    public void Sum_of_two_numbers()
    {
        double first = 10;
        double second = 20;
        var sut = new Calculator();

        double result = sut.Sum(first, second);

        Assert.Equal(30, result);
    }
}
```
빈 줄을 사용하는 방식은 대부분의 단위 테스트에서 효과적입니다. 간결성과 가독성의 균형을 유지할 수 있습니다. 하지만 Arrange 섹션 안에 추가 빈 줄이 필요한 경우, 특히 복잡한 설정이 필요한 통합 테스트에서는 적절하지 않을 수 있습니다.
따라서:
AAA 패턴을 따르고 Arrange나 Assert 섹션 안에 추가 빈 줄이 필요 없는 경우에는 주석을 생략하세요.
그렇지 않다면 주석을 유지하세요.



## 3.2 xUnit 테스트 프레임워크 살펴보기
이 섹션에서는 .NET에서 사용할 수 있는 단위 테스트 도구와 그 기능에 대해 간단히 개요를 제공합니다. 저는 xUnit(https://github.com/xunit/xunit)을 단위 테스트 프레임워크로 사용합니다(xUnit 테스트를 Visual Studio에서 실행하려면 xunit.runner.visualstudio NuGet 패키지를 설치해야 합니다).
이 프레임워크는 .NET 전용이지만, Java, C++, JavaScript 등 모든 객체 지향 언어에는 유사한 단위 테스트 프레임워크가 있습니다. 하나의 프레임워크에 익숙하다면, 다른 것도 쉽게 사용할 수 있습니다.
.NET에는 xUnit 외에도 NUnit(https://github.com/nunit/nunit)과 Microsoft MSTest가 있습니다. 개인적으로는 xUnit을 선호하지만, NUnit도 기능적으로 거의 동일합니다. MSTest는 xUnit이나 NUnit만큼 유연하지 않기 때문에 권장하지 않습니다. 실제로 Microsoft 내부에서도 MSTest를 잘 사용하지 않습니다. 예를 들어, ASP.NET Core 팀은 xUnit을 사용합니다.
xUnit을 선호하는 이유는 더 간결하고 깔끔하기 때문입니다. 예를 들어, 지금까지 살펴본 테스트에는 [Fact] 외에는 프레임워크 관련 속성이 없습니다. [TestFixture] 속성도 필요 없으며, 어떤 public 클래스든 테스트를 포함할 수 있습니다. [SetUp]이나 [TearDown]도 없습니다. 테스트 간에 설정 로직을 공유해야 한다면 생성자에 넣으면 되고, 정리 작업이 필요하다면 IDisposable 인터페이스를 구현하면 됩니다.

```csharp
public class CalculatorTests : IDisposable
{
    private readonly Calculator _sut;

    public CalculatorTests()
    {
        _sut = new Calculator();
    }

    [Fact]
    public void Sum_of_two_numbers()
    {
        // ...
    }

    public void Dispose()
    {
        _sut.CleanUp(); // 각 테스트 후 호출됨
    }
}
```

xUnit은 프레임워크를 간소화하기 위해 많은 노력을 기울였습니다. 예전에는 추가 설정이 필요했던 개념들이 이제는 규칙이나 언어 자체의 기능에 의존합니다.
특히 저는 [Fact]라는 이름이 좋습니다. 이것은 단순히 테스트(test)가 아닌 '사실(fact)'을 강조합니다. 앞 장에서 언급했듯이, 각 테스트는 하나의 이야기(story)를 전달해야 합니다. 이 이야기는 문제 영역에 대한 개별적이고 원자적인 시나리오나 사실이며, 테스트가 통과하면 이 사실이 유효함을 증명하는 것입니다. 테스트가 실패하면 이야기 자체를 고치거나 시스템을 수정해야 합니다.
이러한 사고방식을 테스트에 적용해 보세요. 테스트는 단순히 코드가 하는 일을 나열하는 것이 아니라, 애플리케이션의 동작을 더 높은 수준에서 설명해줘야 합니다. 가능하다면 이 설명은 프로그래머뿐 아니라 비즈니스 관계자에게도 의미 있어야 합니다.

## 3.3 테스트 간에 테스트 픽스처 재사용하기
테스트 간에 코드를 어떻게, 언제 재사용할지 아는 것은 매우 중요합니다.
Arrange(배치) 섹션에서 코드를 재사용하는 것은 테스트를 더 간결하고 단순하게 만드는 좋은 방법이며, 이 절에서는 그 재사용을 올바르게 수행하는 방법을 설명합니다.

앞서 언급했듯이, 픽스처(fixture) 설정 코드가 테스트에서 너무 많은 공간을 차지하는 경우가 많습니다.
이러한 설정 코드를 별도의 메서드나 클래스로 추출해놓고 여러 테스트에서 재사용하는 것은 자연스러운 선택입니다.
이러한 재사용 방식에는 두 가지가 있지만, 이 중 하나만이 유익하며, 다른 하나는 오히려 유지보수 비용을 증가시킵니다.

> 테스트 픽스처 (Test Fixture)
테스트 픽스처라는 용어는 일반적으로 두 가지 의미로 사용됩니다:

1. 테스트 대상 객체:
테스트가 실행되는 대상 객체를 말합니다. 이 객체는 일반적인 의존성(Dependency)일 수 있으며, SUT(테스트 대상 시스템)에 전달되는 인자일 수도 있습니다.
데이터베이스에 들어 있는 데이터나 하드디스크에 있는 파일처럼 외부 리소스일 수도 있습니다.
이러한 객체는 테스트가 실행되기 전마다 항상 동일하고 예측 가능한 상태를 유지해야 하며,
그래야 테스트가 항상 같은 결과를 내기 때문에 'fixture'라는 용어가 붙습니다.

2. NUnit에서의 정의:
NUnit 테스트 프레임워크에서는 TestFixture라는 **어트리뷰트(attribute)**가 테스트를 포함하는 클래스를 표시할 때 사용됩니다.

이 책 전반에 걸쳐서는 첫 번째 정의—즉, 테스트 대상 객체로서의 의미로 이 용어를 사용합니다.

이제 잘못된 방식의 재사용 예시를 소개하겠습니다.
테스트 픽스처를 테스트 클래스의 생성자(constructor)에서 초기화하거나, NUnit을 사용하는 경우에는 [SetUp] 어트리뷰트가 붙은 메서드에서 초기화하는 방식입니다.
다음은 그 예입니다:

``` csharp
public class CustomerTests
{
    private readonly Store _store;
    private readonly Customer _sut;

    public CustomerTests()
    {
        _store = new Store();
        _store.AddInventory(Product.Shampoo, 10);
        _sut = new Customer();
    }

    [Fact]
    public void Purchase_succeeds_when_enough_inventory()
    {
        bool success = _sut.Purchase(_store, Product.Shampoo, 5);
        Assert.True(success);
        Assert.Equal(5, _store.GetInventory(Product.Shampoo));
    }

    [Fact]
    public void Purchase_fails_when_not_enough_inventory()
    {
        bool success = _sut.Purchase(_store, Product.Shampoo, 15);
        Assert.False(success);
        Assert.Equal(10, _store.GetInventory(Product.Shampoo));
    }
}
```

리스트 3.7에 나온 두 테스트는 공통된 설정 로직(configuration logic)을 가지고 있습니다.
실제로 두 테스트의 Arrange 섹션은 동일하며, 따라서 이를 CustomerTests 클래스의 생성자로 완전히 추출할 수 있습니다—그리고 실제로 여기서는 그렇게 했습니다.
그 결과, 테스트 본문에는 더 이상 별도의 설정 코드가 존재하지 않습니다.

이 방식은 테스트 코드의 양을 현저히 줄일 수 있는 장점이 있습니다.
대부분의, 혹은 모든 테스트 픽스처 설정 코드를 제거할 수 있게 되죠.
하지만 이 기법에는 두 가지 주요 단점이 존재합니다:

테스트 간 높은 결합도(high coupling)를 초래합니다.

테스트의 가독성(test readability)이 저하됩니다.

이제 이러한 단점들을 자세히 살펴보겠습니다.

#### 3.3.1 테스트 간 높은 결합도는 안티패턴이다
리스트 3.7에 제시된 새로운 방식에서는 모든 테스트가 서로 얽혀 있습니다.
즉, 한 테스트의 설정 로직을 수정하면 해당 클래스의 모든 테스트에 영향을 미치게 됩니다.

예를 들어, 아래 코드에서

```csharp
_store.AddInventory(Product.Shampoo, 10);
```
이 부분을

```csharp
_store.AddInventory(Product.Shampoo, 15);
```
로 바꾸면, 테스트들이 기대하는 스토어의 초기 상태에 대한 가정이 깨지게 되어,
불필요한 테스트 실패가 발생할 수 있습니다.

이것은 중요한 테스트 원칙 중 하나를 위반하는 것입니다:

"하나의 테스트를 수정해도 다른 테스트에 영향을 주어서는 안 된다."

이 원칙은 2장에서 설명한 **"테스트는 서로 독립적으로 실행되어야 한다"**는 개념과 유사하지만, 정확히 같지는 않습니다.
여기서 말하는 것은 **"실행의 독립성"이 아니라, "수정의 독립성"**입니다.
이 둘은 모두 좋은 테스트 설계의 핵심 요소입니다.

이 원칙을 지키려면, 테스트 클래스 내에 공유 상태(shared state)를 도입하지 않아야 합니다.
예를 들어, 아래의 두 private 필드는 그 자체로 공유 상태를 나타냅니다:

```csharp
private readonly Store _store;
private readonly Customer _sut;
```

#### 3.3.2 생성자에 설정 코드를 넣으면 테스트 가독성이 떨어진다
Arrange 코드를 생성자에 추출하는 또 다른 단점은 테스트 가독성이 저하된다는 점입니다.
이제는 테스트 메서드만 들여다봐서는 전체 테스트 흐름을 알 수 없습니다.
테스트가 어떤 동작을 하는지 이해하려면 클래스의 다른 부분(예: 생성자)을 함께 봐야 합니다.

비록 설정 코드가 그리 많지 않다 하더라도—예를 들어 단순히 픽스처를 인스턴스화하는 정도라 하더라도—
그 코드를 테스트 메서드 안에 두는 것이 더 낫습니다.
그렇지 않으면,

“이게 단순한 인스턴스 생성일까? 아니면 다른 설정도 포함되어 있을까?”
하는 의문이 생기기 때문입니다.

#### 3.3.3 더 나은 픽스처 재사용 방법
테스트 클래스 내에 private 팩토리 메서드를 도입하는 것이 더 나은 방법입니다:
```csharp
public class CustomerTests
{
    [Fact]
    public void Purchase_succeeds_when_enough_inventory()
    {
        Store store = CreateStoreWithInventory(Product.Shampoo, 10);
        Customer sut = CreateCustomer();
        bool success = sut.Purchase(store, Product.Shampoo, 5);

        Assert.True(success);
        Assert.Equal(5, store.GetInventory(Product.Shampoo));
    }

    [Fact]
    public void Purchase_fails_when_not_enough_inventory()
    {
        Store store = CreateStoreWithInventory(Product.Shampoo, 10);
        Customer sut = CreateCustomer();
        bool success = sut.Purchase(store, Product.Shampoo, 15);

        Assert.False(success);
        Assert.Equal(10, store.GetInventory(Product.Shampoo));
    }

    private Store CreateStoreWithInventory(Product product, int quantity)
    {
        Store store = new Store();
        store.AddInventory(product, quantity);
        return store;
    }

    private static Customer CreateCustomer()
    {
        return new Customer();
    }
}
```

팩토리 메서드를 사용하면 테스트의 문맥(context)을 유지하면서 코드도 간결하게 만들 수 있습니다. 테스트 간 공유 상태도 발생하지 않습니다.
예외적으로 모든 테스트에서 공통으로 사용하는 픽스처는 생성자에서 초기화할 수 있습니다. 주로 데이터베이스 연결 같은 통합 테스트가 이에 해당하며, 이 경우에도 공통 코드는 **기반 클래스(Base class)**에 넣는 것이 좋습니다:

```csharp
public class CustomerTests : IntegrationTests
{
    [Fact]
    public void Purchase_succeeds_when_enough_inventory()
    {
        // _database 사용
    }
}

public abstract class IntegrationTests : IDisposable
{
    protected readonly Database _database;

    protected IntegrationTests()
    {
        _database = new Database();
    }

    public void Dispose()
    {
        _database.Dispose();
    }
}
```

이 방식은 테스트 클래스에 생성자가 없으므로, 가독성과 유지보수성이 뛰어납니다.

## 3.4 단위 테스트에 이름 짓기
테스트에 표현력 있는 이름을 붙이는 것은 매우 중요합니다.
적절한 이름은 해당 테스트가 무엇을 검증하는지, 
그리고 시스템이 어떻게 동작하는지를 이해하는 데 큰 도움이 됩니다.

그렇다면, 단위 테스트에는 어떻게 이름을 지어야 할까요?
지난 10년 동안 다양한 이름 규칙을 보고, 시도해봤습니다.
그중 가장 잘 알려졌지만, 동시에 가장 도움이 되지 않는 방식 중 하나는 다음과 같은 패턴입니다:

```css
[MethodUnderTest]_[Scenario]_[ExpectedResult]
```
여기서 각 구성 요소는 다음과 같습니다:
- MethodUnderTest: 테스트 대상 메서드의 이름
- Scenario: 테스트가 수행되는 조건
- ExpectedResult: 현재 조건에서 메서드가 기대하는 결과

이 규칙이 도움이 되지 않는 이유는,
시스템의 동작(behavior)보다는 구현 세부 사항(implementation details)에 집중하도록 유도하기 때문입니다.

반면, 단순한 자연어 문장(plain English)으로 작성한 이름이 훨씬 더 효과적입니다.
이런 방식은 더 표현력이 뛰어나고, 고정된 구조에 얽매이지 않으며,
시스템의 동작을 고객이나 도메인 전문가가 이해할 수 있는 방식으로 설명할 수 있게 해줍니다.

예를 들어, 리스트 3.5에서 소개한 테스트의 제목을 자연어로 표현한 예시는 다음과 같습니다:

```csharp
public class CalculatorTests
{
    [Fact]
    public void Sum_of_two_numbers()
    {
        double first = 10;
        double second = 20;
        var sut = new Calculator();
        double result = sut.Sum(first, second);
        Assert.Equal(30, result);
    }
}
```

Sum_of_two_numbers라는 테스트 이름을 [MethodUnderTest][Scenario][ExpectedResult] 규칙에 따라 다시 작성한다면 어떻게 될까요?
아마도 다음과 같은 이름이 될 것입니다:

```csharp
public void Sum_TwoNumbers_ReturnsSum()
```
테스트 대상 메서드는 Sum이며,

시나리오는 "두 숫자를 더할 때"이고,

기대 결과는 "그 두 숫자의 합을 반환하는 것"입니다.

새로운 이름은 프로그래머의 눈에는 그럴듯하게 보일 수 있습니다.
하지만 정말로 테스트의 가독성을 높이는 데 도움이 될까요?
전혀 그렇지 않습니다.
프로그래밍을 모르는 사람에게는 그리스어처럼 어렵게 느껴질 뿐입니다.

곰곰이 생각해보세요:
테스트 이름에 왜 Sum이라는 단어가 두 번이나 등장해야 할까요?
그리고 Returns라는 표현은 도대체 무엇을 의미하나요?
결과가 어디로 반환된다는 말인가요?
이름만 봐서는 알 수 없습니다.

어떤 사람들은 이렇게 반박할 수 있습니다:

"테스트 이름이 비프로그래머에게 이해될 필요는 없다.
단위 테스트는 프로그래머가 작성하고, 프로그래머가 읽는 것이니까."
"프로그래머는 복잡한 이름을 해독하는 데 익숙하다—그게 그들의 일이니까!"

이 주장은 일부분은 맞습니다.
하지만 완전히 옳지는 않습니다.

애매하고 암호 같은 이름은 결국 모두에게 인지적 부담(cognitive tax)을 줍니다.
프로그래머든 아니든, 이런 이름은 "이 테스트가 정확히 무엇을 검증하는지"와
"그것이 비즈니스 요구사항과 어떤 관련이 있는지"를 이해하기 위해
추가적인 뇌의 노력을 필요로 하게 만듭니다.

처음엔 별것 아닌 것처럼 보여도,
이러한 정신적 피로는 쌓이기 마련이며,
결국에는 전체 테스트 코드의 유지보수 비용을 꾸준히 높이는 결과를 초래합니다.

이 문제는 특히 다음과 같은 경우에 두드러지게 나타납니다:

어떤 기능의 세부 내용을 잊은 상태에서 해당 테스트로 돌아왔을 때

동료가 작성한 테스트를 이해하려고 할 때

남이 작성한 코드를 읽는 것 자체가 이미 충분히 어렵기 때문에,
그 코드를 이해하는 데 도움이 되는 요소는 모두 매우 소중합니다.

다시 두 가지 버전을 비교해 봅시다:

```csharp
public void Sum_of_two_numbers()
public void Sum_TwoNumbers_ReturnsSum()
````
처음에 자연어로 작성된 Sum_of_two_numbers는 훨씬 더 간단하고 직관적으로 읽힙니다.
이는 테스트하고자 하는 동작(behavior)을 있는 그대로 담아낸, 현실적인 설명입니다.


#### 3.4.1 단위 테스트 이름 지정 지침
표현력 있고 읽기 쉬운 테스트 이름을 작성하려면 다음 가이드라인을 따르세요:

- 엄격한 네이밍 규칙을 따르지 마세요.
복잡한 동작에 대한 고수준의 설명을 딱딱한 규칙 안에 억지로 끼워 맞출 수는 없습니다.
표현의 자유를 허용하세요.

- 테스트 이름은 문제 도메인을 잘 아는 비프로그래머에게 시나리오를 설명하듯 지으세요.
예를 들어, 도메인 전문가나 비즈니스 분석가에게 이야기하듯이 작성하는 것이 좋습니다.

- 단어는 밑줄(_)로 구분하세요.
특히 테스트 이름이 길어질 경우, 가독성을 크게 향상시킬 수 있습니다.

예를 들어, 제가 테스트 클래스의 이름을 CalculatorTests라고 지을 때는 밑줄을 사용하지 않았습니다.
일반적으로 클래스 이름은 테스트 메서드 이름보다 훨씬 짧기 때문에,
밑줄 없이도 충분히 가독성이 확보됩니다.

또한, 테스트 클래스 이름에 [클래스명]Tests 패턴을 사용한다고 해서
그 테스트들이 반드시 해당 클래스만을 검증해야 한다는 의미는 아닙니다.

기억하세요:
단위 테스트(Unit Test)에서의 "단위(Unit)"는 클래스가 아니라 동작(behavior)의 단위입니다.
이 단위는 하나의 클래스일 수도 있고, 여러 클래스로 이루어져 있을 수도 있습니다.
정확한 범위는 중요하지 않습니다.

그렇지만, 어딘가에서는 시작해야 하기에
[클래스명]Tests의 클래스명은 진입점(entry point)으로 간주하세요.
즉, 그 API를 통해 어떤 동작 단위를 검증한다는 의미입니다.

#### 3.4.2 예시: 테스트 이름 변경하기
이제 테스트 하나를 예시로 삼아, 앞서 소개한 가이드라인을 바탕으로 이름을 점진적으로 개선해 보겠습니다.
다음 예시는 배송 날짜가 과거일 경우 유효하지 않다고 판단하는지 확인하는 테스트입니다. 
처음에는 테스트 가독성을 해치는 딱딱한 네이밍 규칙을 사용하고 있습니다.

```csharp
[Fact]
public void IsDeliveryValid_InvalidDate_ReturnsFalse()
{
    DeliveryService sut = new DeliveryService();
    DateTime pastDate = DateTime.Now.AddDays(-1);
    Delivery delivery = new Delivery { Date = pastDate };
    bool isValid = sut.IsDeliveryValid(delivery);
    Assert.False(isValid);
}
```

이 테스트는 DeliveryService가 잘못된 날짜를 가진 배송을 올바르게 무효 처리하는지 확인합니다.
이 테스트 이름을 자연스러운 영어 문장으로 다시 쓴다면 이렇게 시작할 수 있겠죠:

```csharp
public void Delivery_with_invalid_date_should_be_considered_invalid()
```

이 새 이름에서 눈여겨볼 두 가지가 있습니다:

비프로그래머도 이해할 수 있는 문장이 되었기 때문에,
프로그래머에게도 훨씬 더 직관적으로 다가옵니다.

SUT(Sut Under Test, 테스트 대상)의 메서드 이름인 IsDeliveryValid는
더 이상 테스트 이름에 포함되지 않습니다.

두 번째 포인트는 테스트 이름을 자연어로 바꾸다 보면 무심코 지나칠 수 있지만,
사실은 매우 중요한 결과이며 별도의 가이드라인으로 격상시킬 가치가 있습니다.

> 테스트 이름에 SUT의 메서드명을 넣지 마세요
테스트는 코드가 아니라 "행동(behavior)"을 검증하는 것입니다.
따라서 테스트 대상 메서드의 이름이 무엇인지는 중요하지 않습니다.

앞서 이야기했듯, **SUT는 단지 진입점(entry point)**일 뿐입니다.
어떤 행동을 수행하도록 호출하는 수단일 뿐이죠.

예를 들어, IsDeliveryValid라는 메서드 이름을
IsDeliveryCorrect로 바꾼다고 해도, 행동의 의미는 변하지 않습니다.
그런데 처음 사용했던 네이밍 규칙을 따르면 테스트 이름도 함께 변경해야 하므로,
결국 테스트가 구현 세부사항에 종속되고,
그 결과 유지보수성은 크게 떨어지게 됩니다.
이 문제는 5장에서 더 자세히 다룹니다.

예외는 유틸리티 코드에 한해서입니다.
이런 코드는 비즈니스 로직 없이 단순한 보조 기능만 수행하므로
도메인 전문가가 이해할 수준의 의미를 가지지 않습니다.
따라서 유틸리티 코드에서는 메서드 이름을 테스트 이름에 포함해도 괜찮습니다.

그럼 예시로 다시 돌아가 보겠습니다.
앞서 수정한 테스트 이름도 괜찮은 출발점이지만, 더 개선할 수 있습니다.

"배송 날짜가 유효하지 않다"는 것이 정확히 무슨 뜻일까요?

리스트 3.10의 테스트를 보면, 과거 날짜는 무효라는 의미입니다.
즉, 사용자는 미래 날짜만 선택할 수 있어야 하죠.

이 사실을 좀 더 구체적으로 테스트 이름에 반영해보겠습니다:

```csharp
public void Delivery_with_past_date_should_be_considered_invalid()
```
좋아졌지만 아직 너무 장황합니다.
의미 손실 없이 considered라는 단어는 생략할 수 있습니다:

```csharp
public void Delivery_with_past_date_should_be_invalid()
```

여기서 should be 구문도 자주 등장하는 안티 패턴입니다.
이 장 앞부분에서 말했듯, **테스트는 어떤 행동에 대한 "단일한 사실"**을 기술하는 것입니다.
~해야 한다(should) 같은 표현은 바람이나 기대를 담고 있어
사실을 기술하는 문장으로는 부적절합니다.
따라서 should be 대신 is로 바꿔야 합니다:

```csharp
public void Delivery_with_past_date_is_invalid()
```
마지막으로, 기본적인 영어 문법을 굳이 피할 필요는 없습니다.
a, the 같은 관사는 오히려 문장을 더 매끄럽고 정확하게 읽히게 해줍니다.
관사 a를 넣어 마무리하면 다음과 같습니다:

```csharp
public void Delivery_with_a_past_date_is_invalid()
```
바로 이 이름이 최종 버전입니다.
간결하고 명확하며,
테스트하려는 애플리케이션의 동작을 사실로서 정확히 서술하고 있습니다.
이 경우, 그 동작은 바로 배송 가능 여부를 판단하는 로직입니다.


## 3.5 매개변수화된 테스트로 리팩토링하기
보통 하나의 테스트만으로는 하나의 동작 단위를 완전히 설명하기에 부족합니다.
이러한 동작 단위는 보통 여러 구성 요소로 이루어져 있으며, 각 구성 요소는 개별 테스트로 캡처되어야 합니다.
동작이 충분히 복잡하다면, 이를 설명하는 테스트의 수가 크게 증가하여 관리하기 어려워질 수 있습니다.
다행히도 대부분의 단위 테스트 프레임워크는 비슷한 테스트들을 그룹화할 수 있는 기능인 파라미터화된 테스트(parameterized tests)를 제공합니다(그림 3.2 참조).

이 절에서는 먼저 각각의 동작 구성 요소를 별도의 테스트로 설명하고, 그런 다음 이 테스트들을 하나로 묶는 방법을 보여드리겠습니다.

예를 들어, 배송 기능이 ‘가장 빠른 배송 가능일이 오늘로부터 이틀 후’라는 조건으로 동작한다고 가정해 봅시다.
명백히 지금까지 작성한 하나의 테스트만으로는 충분하지 않습니다.
과거 날짜를 검사하는 테스트 외에도, ‘오늘 날짜’, ‘내일 날짜’, 그리고 ‘이틀 후 날짜’를 검사하는 테스트도 필요합니다.

기존 테스트는 Delivery_with_a_past_date_is_invalid 라는 이름이었습니다.
여기에 세 개의 테스트를 추가할 수 있습니다:

```csharp
public void Delivery_for_today_is_invalid()
public void Delivery_for_tomorrow_is_invalid()
public void The_soonest_delivery_date_is_two_days_from_now()
```
하지만 이렇게 하면 네 개의 테스트 메서드가 생기고, 이들 사이의 유일한 차이는 배송 날짜뿐입니다.
더 나은 방법은 이 테스트들을 하나로 묶어서 테스트 코드 양을 줄이는 것입니다.
xUnit(다른 대부분의 테스트 프레임워크도 마찬가지로)에는 바로 이 목적을 위한 ‘파라미터화된 테스트(parameterized tests)’라는 기능이 있습니다.
다음 예제는 이런 그룹화가 어떻게 이루어지는지를 보여줍니다.
각각의 [InlineData] 어트리뷰트는 시스템에 관한 독립적인 사실, 즉 각각 하나의 테스트 케이스를 나타냅니다.
```csharp
public class DeliveryServiceTests
{
    [InlineData(-1, false)]
    [InlineData(0, false)]
    [InlineData(1, false)]
    [InlineData(2, true)]
    [Theory]
    public void Can_detect_an_invalid_delivery_date(int daysFromNow, bool expected)
    {
        var sut = new DeliveryService();
        DateTime deliveryDate = DateTime.Now.AddDays(daysFromNow);
        var delivery = new Delivery { Date = deliveryDate };
        bool isValid = sut.IsDeliveryValid(delivery);
        Assert.Equal(expected, isValid);
    }
}
```
각 사실은 이제 별도의 테스트가 아니라 [InlineData] 한 줄로 표현됩니다.
또한, 테스트 메서드의 이름도 좀 더 일반적인 것으로 변경했는데, 이제는 어떤 날짜가 유효한지 또는 유효하지 않은지에 대해 직접 언급하지 않습니다.
파라미터화된 테스트를 사용하면 테스트 코드 양을 크게 줄일 수 있지만, 이 장점에는 대가가 따릅니다.
테스트 메서드가 어떤 사실들을 나타내는지 파악하기가 어려워지고, 파라미터가 많아질수록 그 어려움은 더 커집니다.
이를 절충하기 위해, 긍정적인 테스트 케이스(유효한 경우)는 별도의 테스트로 분리하여, 가장 중요한 부분—유효한 배송 날짜와 유효하지 않은 배송 날짜를 구분하는 점—에서 설명적인 이름의 이점을 누릴 수 있습니다.
다음 예제에서 그 방식을 확인할 수 있습니다.

```csharp
public class DeliveryServiceTests
{
  [InlineData(-1)]
  [InlineData(0)]
  [InlineData(1)]
  [Theory]
  public void Detects_an_invalid_delivery_date(int daysFromNow)
  {
    /* ... */
  }

  [Fact]
  public void The_soonest_delivery_date_is_two_days_from_now()
  {
    /* ... */
  }
}
```
이 방법은 부정적인 테스트 케이스도 단순화합니다.
테스트 메서드에서 예상 결과를 나타내는 Boolean 파라미터를 제거할 수 있기 때문입니다.
물론, 긍정적인 테스트 메서드도 여러 날짜를 테스트할 수 있도록 파라미터화된 테스트로 변환할 수 있습니다.

보시다시피, 테스트 코드의 양과 코드 가독성 사이에는 균형을 맞춰야 하는 트레이드오프가 존재합니다.
일반적인 경험 법칙으로, 입력 파라미터만 보고 어떤 케이스가 긍정이고 부정인지 명확히 알 수 있을 때만, 긍정과 부정 테스트 케이스를 하나의 메서드에 함께 두는 것이 좋습니다.
그렇지 않다면, 긍정 테스트 케이스는 별도로 분리하세요.
그리고 만약 동작이 너무 복잡하다면, 파라미터화된 테스트를 아예 사용하지 않는 것이 좋습니다.
부정적 케이스와 긍정적 케이스 각각을 독립적인 테스트 메서드로 표현하는 것이 바람직합니다.

#### 3.5.1 매개변수화 테스트에 복잡한 데이터 전달하기
파라미터화된 테스트를 사용할 때(적어도 .NET에서는) 몇 가지 주의할 점이 있습니다.
리스트 3.11에서 daysFromNow라는 파라미터를 테스트 메서드의 입력값으로 사용한 것을 주목하세요.
“왜 실제 날짜와 시간을 직접 사용하지 않았냐?”고 물을 수 있겠지만, 안타깝게도 다음과 같은 코드는 작동하지 않습니다:

```csharp
[InlineData(DateTime.Now.AddDays(-1), false)]
[InlineData(DateTime.Now, false)]
[InlineData(DateTime.Now.AddDays(1), false)]
[InlineData(DateTime.Now.AddDays(2), true)]
[Theory]
public void Can_detect_an_invalid_delivery_date(
  DateTime deliveryDate,
  bool expected)
{
  DeliveryService sut = new DeliveryService();
  Delivery delivery = new Delivery
  {
    Date = deliveryDate
  };
  bool isValid = sut.IsDeliveryValid(delivery);
  Assert.Equal(expected, isValid);
}
```
C#에서는 모든 어트리뷰트(Attributes)의 내용이 컴파일 시점에 평가됩니다.
따라서 컴파일러가 이해할 수 있는 값만 사용할 수 있는데, 그 값들은 다음과 같습니다:

- 상수(Constants)
- 리터럴(Literals)
- typeof() 표현식

DateTime.Now 호출은 .NET 런타임에 의존하기 때문에 어트리뷰트 내에서는 사용할 수 없습니다.

이 문제를 해결할 방법이 있습니다.
xUnit에는 테스트 메서드에 전달할 커스텀 데이터를 생성할 수 있는 [MemberData]라는 기능이 있습니다.
다음 리스트는 이 기능을 사용해 이전 테스트를 다시 작성한 예를 보여줍니다.

```csharp
[Theory]
[MemberData(nameof(Data))]
public void Can_detect_an_invalid_delivery_date(DateTime deliveryDate, bool expected)
{
    var sut = new DeliveryService();
    var delivery = new Delivery { Date = deliveryDate };
    bool isValid = sut.IsDeliveryValid(delivery);
    Assert.Equal(expected, isValid);
}

public static List<object[]> Data()
{
    return new List<object[]>
    {
        new object[] { DateTime.Now.AddDays(-1), false },
        new object[] { DateTime.Now, false },
        new object[] { DateTime.Now.AddDays(1), false },
        new object[] { DateTime.Now.AddDays(2), true }
    };
}
```
MemberData는 입력 데이터를 생성하는 정적 메서드의 이름을 받습니다 (nameof(Data)는 컴파일러에 의해 "Data"라는 리터럴로 변환됩니다).
이 컬렉션의 각 요소는 다시 두 개의 입력 매개변수인 deliveryDate와 expected에 매핑되는 컬렉션입니다.
이 기능을 사용하면 컴파일러의 제한을 극복할 수 있으며, 파라미터화된 테스트에서 어떤 타입의 매개변수도 사용할 수 있습니다.

## 3.6 테스트 가독성을 위한 어설션 라이브러리 사용하기
테스트의 가독성을 높이는 또 하나의 방법은 어설션 라이브러리(assertion library)를 사용하는 것입니다.
개인적으로는 Fluent Assertions를 선호하지만, .NET에는 이와 경쟁하는 다양한 라이브러리들이 존재합니다.

어설션 라이브러리를 사용할 때 가장 큰 장점은, 어설션 구문의 구조를 더 읽기 쉽게 만들 수 있다는 점입니다.
예를 들어, 다음은 우리가 앞에서 봤던 테스트 중 하나입니다:

```csharp
[Fact]
public void Sum_of_two_numbers()
{
    var sut = new Calculator();
    double result = sut.Sum(10, 20);
    Assert.Equal(30, result);
}
```
이제 아래 예제를 보세요. Fluent Assertions를 사용한 버전입니다:

```csharp
[Fact]
public void Sum_of_two_numbers()
{
    var sut = new Calculator();
    double result = sut.Sum(10, 20);
    result.Should().Be(30);
}
```
두 번째 테스트의 어설션은 마치 자연스러운 영어 문장처럼 읽힙니다.
이처럼 코드 전체가 이야기처럼 읽히는 것이 가장 이상적입니다.
왜냐하면 인간은 정보를 ‘이야기 형태’로 받아들이는 데 익숙하기 때문입니다.

모든 이야기는 아래와 같은 기본 구조를 따릅니다:
```
[주어] [동작] [목적어]
```
예: 
```
Bob opened the door.
```
이 문장에서 Bob은 주어, opened는 동작, the door는 목적어입니다. 코드도 마찬가지입니다. result.Should().Be(30)는 Assert.Equal(30, result)보다 더 잘 읽히는데,
그 이유는 이야기 패턴을 따르기 때문입니다. 즉, *result(주어)*가 should be(동작) *30(목적어)*이라는 단순한 이야기가 되는 것이죠.

💡 참고:
객체 지향 프로그래밍(OOP)이 성공하게 된 이유 중 하나도 바로 이러한 가독성 이점 덕분입니다.
OOP를 활용하면 코드 역시 이야기처럼 자연스럽게 구성할 수 있습니다.

Fluent Assertions는 숫자, 문자열, 컬렉션, 날짜 및 시간 등 다양한 타입에 대해 어설션을 도와주는 다양한 헬퍼 메서드도 제공합니다.
단점이라면, 이런 라이브러리를 도입하는 것은 결국 프로젝트에 추가적인 의존성을 발생시킨다는 점입니다.
하지만 이는 어디까지나 개발 환경에서만 사용하는 것이며, 실제 배포 시 프로덕션 코드에는 포함되지 않습니다.

## 요약
- 모든 단위 테스트는 AAA 패턴(Arrange, Act, Assert)을 따라야 합니다. 
하나의 테스트에 여러 개의 arrange, act, 또는 assert 구문이 있다면, 이는 테스트가 한 번에 여러 개의 동작을 검증하고 있다는 신호입니다. 
이 테스트가 단위 테스트를 목적으로 한다면, 각 동작별로 테스트를 분리하는 것이 좋습니다.

- Act 섹션에 두 줄 이상의 코드가 있다면, 이는 SUT(System Under Test)의 API에 문제가 있다는 신호입니다.
클라이언트가 항상 특정 동작들을 함께 수행해야 한다는 것을 기억해야 하므로, **불일치 또는 예외 상태(invariant violation)**가 발생할 수 있습니다.
이러한 문제로부터 코드를 보호하는 행위를 **캡슐화(encapsulation)**라고 합니다.

- 테스트 코드에서 SUT는 항상 sut라는 이름으로 구분하세요.
Arrange, Act, Assert 각 섹션은 주석을 사용하거나 빈 줄을 넣어 시각적으로 구분하는 것이 좋습니다.

- 테스트 픽스처 초기화 코드는 생성자에 넣지 말고, 팩토리 메서드(factory method)를 사용해 재사용하세요.
이러한 방식은 테스트 간의 결합도를 낮추고, 코드의 가독성도 향상시킵니다.

- 고정된 테스트 이름 규칙은 피하세요.
해당 테스트 시나리오를 문제 도메인을 아는 비개발자에게 설명한다는 느낌으로 테스트 이름을 지으세요.
테스트 이름에는 단어를 밑줄(_)로 구분하고, 테스트 대상 메서드의 이름은 포함하지 마세요.

- 매개변수화된 테스트(Parameterized Test)는 유사한 테스트들을 줄이는 데 유용합니다.
다만, 테스트 이름을 일반화할수록 가독성이 떨어지는 단점이 있습니다.

- 어설션(Assertion) 라이브러리는 테스트 가독성을 더욱 향상시킬 수 있습니다.
어설션 구문의 단어 순서를 자연어처럼 바꿔줌으로써, 일반 영어 문장처럼 읽히도록 해줍니다.
