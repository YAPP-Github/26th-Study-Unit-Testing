# 5 Mocks and test fragility
Chapter 4 introduced a frame of reference that you can use to analyze specific tests and unit testing approaches.

> 4장에서 특정 테스트와 단위 테스트 접근 방식을 분석할 때 활용할 수 있는 관점(프레임)을 소개했다.

In this chapter, you’ll see that frame of reference in action; we’ll use it to dissect the topic of mocks.

> 이번 5장에서는 그 관점을 실제로 적용해보며, 목(mock)에 대한 주제를 해부해볼 것이다.

The use of mocks in tests is a controversial subject.

> 테스트에서 목(mock)을 사용하는 것은 논란이 많은 주제다.

Some people argue that mocks are a great tool and apply them in most of their tests.

> 어떤 사람들은 목이 훌륭한 도구라고 주장하며, 대부분의 테스트에 이를 적용한다.

Others claim that mocks lead to test fragility and try not to use them at all.

> 반면, 다른 사람들은 목이 테스트를 취약하게 만들기 때문에 가능한 한 사용을 피하려고 한다.

As the saying goes, the truth lies somewhere in between.

> 흔히 말하듯, 진실은 그 중간쯤에 있다.

In this chapter, I’ll show that, indeed, mocks often result in fragile tests—tests that lack the metric of resistance to refactoring.

> 이번 장에서는 목이 실제로 테스트를 취약하게 만들 수 있다는 점—즉, 리팩토링에 대한 저항성을 갖추지 못한 테스트를 초래할 수 있다는 점—을 보여줄 것이다.

But there are still cases where mocking is applicable and even preferable.

> 하지만 여전히 목이 유용하며, 오히려 사용하는 것이 더 나은 경우도 존재한다.


This chapter draws heavily on the discussion about the London versus classical schools of unit testing from chapter 2.

> 이번 장은 2장에서 다뤘던 런던(London)과 고전(Classical) 두 단위 테스트 학파 간의 논의에 크게 의존한다.

In short, the disagreement between the schools stems from their views on the test isolation issue.

> 간단히 말해, 두 학파의 의견 충돌은 테스트 격리에 대한 관점 차이에서 비롯된다.

The London school advocates isolating pieces of code under test from each other and using test doubles for all but immutable dependencies to perform such isolation.

> 런던 학파는 테스트 대상 코드들을 서로 격리시키는 것을 주장하며, 이를 위해 불변(immutable) 의존성을 제외한 모든 의존성에 대해 테스트 대역(test double)을 사용하는 방식을 택한다.

The classical school stands for isolating unit tests themselves so that they can be run in parallel.

> 고전 학파는 테스트 자체를 서로 격리시켜 병렬 실행이 가능하도록 만드는 접근 방식을 지지한다.

This school uses test doubles only for dependencies that are shared between tests.

> 이 학파는 테스트 간에 공유되는 의존성에 대해서만 테스트 대역을 사용한다.

There’s a deep and almost inevitable connection between mocks and test fragility.

> 목(mock)과 테스트의 취약성 사이에는 깊고 거의 불가피한 연관이 있다.

In the next several sections, I will gradually lay down the foundation for you to see why that connection exists.

> 다음 몇 개 섹션에서는 왜 그런 연관성이 생기는지 이해할 수 있도록 점진적으로 기초를 다져나갈 것이다.

You will also learn how to use mocks so that they don’t compromise a test’s resistance to refactoring.

> 또한 목을 사용하더라도 테스트의 리팩토링 저항성을 해치지 않는 방법에 대해서도 배우게 될 것이다.


## 5.1 목(mock)과 스텁(stub)의 구분

In chapter 2, I briefly mentioned that a mock is a test double that allows you to examine interactions between the system under test (SUT) and its collaborators.

> 2장에서 나는 목(mock)은 테스트 대상 시스템(SUT)과 그 협력자 간의 상호작용을 검증할 수 있도록 해주는 테스트 대역(test double)이라고 간단히 언급한 바 있다.

There’s another type of test double: a stub.

> 테스트 대역에는 또 다른 종류가 있는데, 바로 스텁(stub)이다.

Let’s take a closer look at what a mock is and how it is different from a stub.

> 이제 목이 정확히 무엇인지, 그리고 스텁과 어떻게 다른지 자세히 살펴보자.

## 5.1.1 The types of test doubles

A test double is an overarching term that describes all kinds of non-production-ready, fake dependencies in tests.

> 테스트 대역(test double)은 테스트에서 사용되는 모든 종류의 비실제(fake) 의존성을 통칭하는 용어다.

The term comes from the notion of a stunt double in a movie.

> 이 용어는 영화에서 대역배우(stunt double) 개념에서 유래되었다.

The major use of test doubles is to facilitate testing; they are passed to the system under test instead of real dependencies, which could be hard to set up or maintain.

> 테스트 대역의 주요 목적은 테스트를 용이하게 만드는 것이다. 실제로 설정하거나 유지하기 어려운 의존성 대신, 테스트 대역을 SUT에 전달함으로써 테스트가 가능하게 된다.

According to Gerard Meszaros, there are five variations of test doubles: dummy, stub, spy, mock, and fake.

> Gerard Meszaros에 따르면, 테스트 대역에는 다섯 가지 변형이 있다: 더미(dummy), 스텁(stub), 스파이(spy), 목(mock), 그리고 페이크(fake)이다.

Such a variety can look intimidating, but in reality, they can all be grouped together into just two types: mocks and stubs (figure 5.1).

> 이렇게 다양한 종류가 혼란스러울 수 있지만, 실제로는 이들을 두 가지 유형—목(mock)과 스텁(stub)—으로 나눌 수 있다(그림 5.1 참조).

![스크린샷 2025-06-03 09.43.43](https://hackmd.io/_uploads/BJtBBpiGgx.png)

Figure 5.1 All variations of test doubles can be categorized into two types: mocks and stubs.

> 그림 5.1: 모든 테스트 대역의 변형은 두 가지 유형—목(mock)과 스텁(stub)—으로 분류할 수 있다.

The difference between these two types boils down to the following:

> 이 두 유형의 차이는 다음과 같이 요약된다:

Mocks help to emulate and examine outcoming interactions. These interactions are calls the SUT makes to its dependencies to change their state.

> 목(mock)은 외부로 향하는 상호작용(outgoing interaction) 을 흉내 내고 검증하는 데 사용된다. 이런 상호작용은 SUT가 의존성에 상태 변경을 유도하는 호출을 하는 경우다.

Stubs help to emulate incoming interactions. These interactions are calls the SUT makes to its dependencies to get input data (figure 5.2).

> 스텁(stub)은 내부로 향하는 상호작용(incoming interaction) 을 흉내 내는 데 사용된다. 이런 상호작용은 SUT가 의존성에서 입력 데이터를 받아오기 위해 호출하는 경우다(그림 5.2 참조).


![스크린샷 2025-06-03 09.44.00](https://hackmd.io/_uploads/SkjUHTszxe.png)

Figure 5.2 Sending an email is an outcoming interaction: an interaction that results in a side effect in the SMTP server.

> 그림 5.2: 이메일을 보내는 것은 외부로 향하는 상호작용(outgoing interaction) 으로, SMTP 서버에 사이드 이펙트(부작용) 를 일으키는 상호작용이다.

A test double emulating such an interaction is a mock.

> 이런 상호작용을 흉내 내는 테스트 대역은 목(mock) 이다.

Retrieving data from the database is an incoming interaction; it doesn’t result in a side effect.

> 데이터베이스에서 데이터를 조회하는 것은 내부로 향하는 상호작용(incoming interaction) 이며, 사이드 이펙트가 발생하지 않는다.

The corresponding test double is a stub.

> 이와 같은 상호작용에 해당하는 테스트 대역은 스텁(stub) 이다.

All other differences between the five variations are insignificant implementation details.

> 다섯 가지 변형 간의 다른 차이점들은 중요하지 않은 구현상의 세부사항들이다.

For example, spies serve the same role as mocks.

> 예를 들어, 스파이(spy)는 목(mock)과 같은 역할을 한다.

The distinction is that spies are written manually, whereas mocks are created with the help of a mocking framework.

> 차이점은 스파이는 수동으로 작성하는 반면, 목은 목킹 프레임워크를 통해 생성된다는 것이다.

Sometimes people refer to spies as handwritten mocks.

> 사람들은 스파이를 수작업으로 만든 목이라고 부르기도 한다.

On the other hand, the difference between a stub, a dummy, and a fake is in how intelligent they are.

> 반면, 스텁(stub), 더미(dummy), 페이크(fake)의 차이는 얼마나 "지능적"인지에 있다.

A dummy is a simple, hardcoded value such as a null value or a made-up string.

> 더미는 null 값이나 임의의 문자열처럼 단순한 하드코딩된 값이다.

It’s used to satisfy the SUT’s method signature and doesn’t participate in producing the final outcome.

> 이는 SUT의 메서드 시그니처를 만족시키기 위해 사용되며, 결과 생성에는 관여하지 않는다.

A stub is more sophisticated.

> 스텁은 이보다 더 정교하다.

It’s a fully fledged dependency that you configure to return different values for different scenarios.

> 스텁은 시나리오에 따라 다양한 값을 반환하도록 구성할 수 있는, 완전한 형태의 의존성이다.

Finally, a fake is the same as a stub for most purposes.

> 마지막으로, 페이크는 대부분의 목적에서 스텁과 같다.

The difference is in the rationale for its creation: a fake is usually implemented to replace a dependency that doesn’t yet exist.

> 차이점은 생성 목적에 있다. 페이크는 일반적으로 아직 존재하지 않는 의존성을 대체하기 위해 구현된다.

Notice the difference between mocks and stubs (aside from outcoming versus incoming interactions).

> 목과 스텁의 차이를 주목하자 (단순히 외부 vs 내부 상호작용의 차이 외에도).

Mocks help to emulate and examine interactions between the SUT and its dependencies, while stubs only help to emulate those interactions.

> 목은 SUT와 의존성 간의 상호작용을 흉내 내고 검증하는 데 도움을 주는 반면, 스텁은 단순히 그 상호작용을 흉내 내는 데 그친다.

This is an important distinction. You will see why shortly.

> 이는 중요한 차이점이며, 곧 그 이유를 알게 될 것이다.

## 5.1.2 Mock (the tool) vs. mock (the test double)

The term mock is overloaded and can mean different things in different circumstances.

> '목(mock)'이라는 용어는 문맥에 따라 다양한 의미로 사용된다.

I mentioned in chapter 2 that people often use this term to mean any test double, whereas mocks are only a subset of test doubles.

> 2장에서 언급했듯, 많은 사람들이 이 용어를 모든 테스트 대역을 지칭하는 데 사용하지만, 실제로 목은 그 하위 집합일 뿐이다.

But there’s another meaning for the term mock. You can refer to the classes from mocking libraries as mocks, too.

> '목(mock)'이라는 용어는 또 다른 의미로도 사용된다. 목킹(mocking) 라이브러리의 클래스 자체를 목이라고 부르기도 한다.

These classes help you create actual mocks, but they themselves are not mocks per se.

> 이런 클래스들은 실제 목(test double)을 생성하는 데 도움을 주지만, 그 자체가 목은 아니다.

The following listing shows an example.

> 다음 예제는 이를 보여주는 코드이다.

#### Listing 5.1 Using the Mock class from a mocking library to create a mock

```java

public void Sending_a_greetings_email()
{
var mock = new Mock<IEmailGateway>();
var sut = new Controller(mock.Object);
sut.GreetUser("user@email.com");
mock.Verify(
x => x.SendGreetingsEmail(
"user@email.com"),
Times.Once);
}

```

The test in listing 5.1 uses the Mock class from the mocking library of my choice (Moq).

> 예제 5.1의 테스트는 내가 선택한 목킹 라이브러리(Moq)의 Mock 클래스를 사용한다.

This class is a tool that enables you to create a test double—a mock.

> 이 클래스는 테스트 대역(mock)을 생성할 수 있게 해주는 도구다.

In other words, the class Mock (or Mock<IEmailGateway>) is a mock (the tool),

> 다시 말해 Mock 클래스 자체는 목(도구)이고,

while the instance of that class, mock, is a mock (the test double).

> 그 클래스의 인스턴스인 mock은 목(테스트 대역)이다.

It’s important not to conflate a mock (the tool) with a mock (the test double)

> 목(도구)과 목(테스트 대역)을 혼동하지 않는 것이 중요하다.

because you can use a mock (the tool) to create both types of test doubles: mocks and stubs.

> 왜냐하면 이 도구를 사용해 목과 스텁 두 가지 유형의 테스트 대역을 모두 만들 수 있기 때문이다.

#### Listing 5.2 Using the Mock class to create a stub
	

```
[Fact]
public void Creating_a_report()
{
	var stub = new Mock<IDatabase>();
	stub.Setup(x => x.GetNumberOfUsers())
	.Returns(10);
	var sut = new Controller(stub.Object);
	Report report = sut.CreateReport();
	Assert.Equal(10, report.NumberOfUsers);
}
```
	
This test double emulates an incoming interaction—a call that provides the SUT with input data.

> 이 테스트 대역은 SUT에 입력 데이터를 제공하는 내부로 향하는 상호작용을 흉내 낸다.

On the other hand, in the previous example (listing 5.1), the call to SendGreetingsEmail() is an outcoming interaction.

> 반면, 앞선 예제(5.1)에서 SendGreetingsEmail() 호출은 외부로 향하는 상호작용이다.

Its sole purpose is to incur a side effect—send an email.

> 그 목적은 사이드 이펙트를 발생시키는 것, 즉 이메일을 보내는 것이다.

## 5.1.3 Don’t assert interactions with stubs

As I mentioned in section 5.1.1, mocks help to emulate and examine outcoming interactions between the SUT and its dependencies, while stubs only help to emulate incoming interactions, not examine them.

> 5.1.1절에서 언급했듯, 목(mock)은 SUT와 의존성 간의 외부 상호작용을 흉내 내고 검증할 수 있도록 도와주는 반면, 스텁(stub)은 내부 상호작용만 흉내 낼 수 있고 이를 검증할 수는 없다.

The difference between the two stems from the guideline of never asserting interactions with stubs.

> 이 차이는 "스텁과의 상호작용을 검증하지 말라"는 원칙에서 비롯된다.

A call from the SUT to a stub is not part of the end result the SUT produces.

> SUT가 스텁을 호출하는 행위는 SUT가 만들어내는 최종 결과의 일부가 아니다.

Such a call is only a means to produce the end result: a stub provides input from which the SUT then generates the output.

> 이러한 호출은 단지 결과를 만들기 위한 수단일 뿐이다. 스텁은 단지 입력값을 제공하고, SUT는 그 입력을 바탕으로 결과를 생성한다.

**NOTE**

> 스텁과의 상호작용을 검증하는 것은 테스트를 취약하게 만드는 대표적인 안티 패턴이다.

Asserting interactions with stubs is a common anti-pattern that leads to fragile tests.

> 스텁과의 상호작용을 검증하는 것은 테스트를 취약하게 만드는 흔한 안티 패턴이다.

As you might remember from chapter 4, the only way to avoid false positives and thus improve resistance to refactoring in tests is to make those tests verify the end result (which, ideally, should be meaningful to a non-programmer), not implementation details.

> 4장에서 기억하겠지만, 테스트에서 거짓 양성(false positive)을 피하고 리팩토링에 대한 저항성을 높이는 유일한 방법은 구현 세부사항이 아닌 최종 결과를 검증하게 만드는 것이다. 이 최종 결과는 이상적으로 비개발자에게도 의미가 있어야 한다.

In listing 5.1, the check mock.Verify(x => x.SendGreetingsEmail("user@email.com")) corresponds to an actual outcome, and that outcome is meaningful to a domain expert: sending a greetings email is something business people would want the system to do.

> 예제 5.1에서 mock.Verify(x => x.SendGreetingsEmail("user@email.com"))는 실제 결과에 대한 검증이고, 이 결과는 도메인 전문가에게도 의미가 있다. 인사 이메일을 발송하는 것은 비즈니스 관점에서 시스템이 수행해야 하는 작업이다.

At the same time, the call to GetNumberOfUsers() in listing 5.2 is not an outcome at all. It’s an internal implementation detail regarding how the SUT gathers data necessary for the report creation.

> 반면, 예제 5.2의 GetNumberOfUsers() 호출은 결과가 아니다. 이것은 SUT가 보고서를 생성하기 위해 데이터를 수집하는 내부 구현 세부사항이다.

Therefore, asserting this call would lead to test fragility: it shouldn’t matter how the SUT generates the end result, as long as that result is correct.

> 따라서 이 호출을 검증하는 것은 테스트를 취약하게 만든다. 결과가 정확하기만 하다면, SUT가 그 결과를 어떻게 생성했는지는 중요하지 않다.

The following listing shows an example of such a brittle test.

> 아래 예제는 이처럼 취약한 테스트의 예를 보여준다.

#### Listing 5.3 Asserting an interaction with a stub
	
```
[Fact]
public void Creating_a_report()
{
	var stub = new Mock<IDatabase>();
	stub.Setup(x => x.GetNumberOfUsers()).Returns(10);
	var sut = new Controller(stub.Object);
	Report report = sut.CreateReport();
	Assert.Equal(10, report.NumberOfUsers);
	stub.Verify(
	x => x.GetNumberOfUsers(),
	Times.Once);
}	
```

This practice of verifying things that aren’t part of the end result is also called overspecification.

> 최종 결과와 관련 없는 부분을 검증하는 이러한 행위를 과도한 명세(overspecification)라고 부른다.

Most commonly, overspecification takes place when examining interactions.

> 일반적으로 과도한 명세는 상호작용(interaction)을 검증할 때 발생한다.

Checking for interactions with stubs is a flaw that’s quite easy to spot because tests shouldn’t check for any interactions with stubs.

> 스텁과의 상호작용을 검증하는 것은 테스트가 절대 해서는 안 되는 행위이므로 쉽게 발견할 수 있는 문제다.

Mocks are a more complicated subject: not all uses of mocks lead to test fragility, but a lot of them do.

> 목(mock)은 좀 더 복잡한 주제다. 모든 목 사용이 테스트를 취약하게 만들지는 않지만, 많은 경우 그렇다.

You’ll see why later in this chapter.

> 그 이유는 이 장의 뒷부분에서 살펴볼 것이다.

## 5.1.4 Using mocks and stubs together
	
Sometimes you need to create a test double that exhibits the properties of both a mock and a stub.

> 때때로 목과 스텁의 특성을 모두 가진 테스트 대역이 필요할 때가 있다.

For example, here’s a test from chapter 2 that I used to illustrate the London style of unit testing.

> 예를 들어, 2장에서 런던 스타일의 단위 테스트를 설명하기 위해 사용했던 테스트가 있다
	
#### Listing 5.4 storeMock: both a mock and a stub

```
public void Purchase_fails_when_not_enough_inventory()
{
	var storeMock = new Mock<IStore>();
	storeMock
		.Setup(x => x.HasEnoughInventory(
	Product.Shampoo, 5))
		.Returns(false);
	
	var sut = new Customer();
	bool success = sut.Purchase(
		storeMock.Object, Product.Shampoo, 5);
	Assert.False(success);
	storeMock.Verify(
	x => x.RemoveInventory(Product.Shampoo, 5),
	Times.Never);
}
```
This test uses storeMock for two purposes: it returns a canned answer and verifies a method call made by the SUT.

> 이 테스트는 storeMock을 두 가지 목적으로 사용한다: 하나는 고정된 값을 반환하고, 다른 하나는 SUT가 호출한 메서드를 검증하는 것이다.

Notice, though, that these are two different methods: the test sets up the answer from HasEnoughInventory() but then verifies the call to RemoveInventory().

> 그러나 주목할 점은 이 두 가지가 서로 다른 메서드라는 것이다. 테스트는 HasEnoughInventory()의 반환값을 설정하고, RemoveInventory() 호출 여부를 검증한다.

Thus, the rule of not asserting interactions with stubs is not violated here.

> 따라서 이 경우에는 "스텁과의 상호작용을 검증하지 말 것"이라는 원칙이 위반되지 않는다.

When a test double is both a mock and a stub, it’s still called a mock, not a stub.

> 테스트 대역이 목과 스텁의 특성을 동시에 가질 때에도, 그것은 스텁이 아닌 목이라고 부른다.

That’s mostly the case because we need to pick one name, but also because being a mock is a more important fact than being a stub.

> 이는 주로 하나의 명칭을 선택해야 하기 때문이기도 하지만, 목이라는 성격이 스텁보다 더 본질적으로 중요하기 때문이기도 하다.

## 5.15 How mocks and stubs relate to commands and queries
	
The notions of mocks and stubs tie to the command query separation (CQS) principle.

> 목과 스텁의 개념은 커맨드-쿼리 분리 원칙(CQS: Command Query Separation)과 연관되어 있다.

The CQS principle states that every method should be either a command or a query, but not both.

> CQS 원칙은 모든 메서드는 커맨드이거나 쿼리 중 하나여야 하며, 둘 다여서는 안 된다고 말한다.

As shown in figure 5.3, commands are methods that produce side effects and don’t return any value (return void).

> 그림 5.3에서 보이듯이, 커맨드는 사이드 이펙트를 발생시키고 값을 반환하지 않는 메서드이다 (예: void 반환).

Examples of side effects include mutating an object’s state, changing a file in the file system, and so on.

> 사이드 이펙트의 예로는 객체의 상태를 변경하거나 파일 시스템의 파일을 수정하는 것 등이 있다.

Queries are the opposite of that—they are side-effect free and return a value.

> 쿼리는 이와 반대이며, 사이드 이펙트가 없고 값을 반환한다.

To follow this principle, be sure that if a method produces a side effect, that method’s return type is void.

> 이 원칙을 따르기 위해서는, 메서드가 사이드 이펙트를 발생시킨다면 그 반환 타입은 void여야 한다.

And if the method returns a value, it must stay side-effect free.

> 반대로 메서드가 값을 반환한다면, 반드시 사이드 이펙트가 없어야 한다.
	
![스크린샷 2025-06-09 22.39.54](https://hackmd.io/_uploads/ByYNNvV7ex.png)

In other words, asking a question should not change the answer.

> 다시 말해, 질문을 던졌다고 해서 답이 바뀌어서는 안 된다.

Code that maintains such a clear separation becomes easier to read.

> 이러한 명확한 분리를 유지하는 코드는 읽기 쉬워진다.

You can tell what a method does just by looking at its signature, without diving into its implementation details.

> 구현 내용을 깊이 들여다보지 않아도, 시그니처만 보고 메서드가 무엇을 하는지 알 수 있게 된다.

Of course, it’s not always possible to follow the CQS principle.

> 물론 항상 CQS 원칙을 지킬 수 있는 것은 아니다.

There are always methods for which it makes sense to both incur a side effect and return a value.

> 때때로 사이드 이펙트를 발생시키면서 값을 반환하는 것이 타당한 메서드도 있다.

A classical example is stack.Pop().

> 대표적인 예는 stack.Pop()이다.

This method both removes a top element from the stack and returns it to the caller.

> 이 메서드는 스택에서 최상단 요소를 제거하고 그 값을 호출자에게 반환한다.

Still, it’s a good idea to adhere to the CQS principle whenever you can.

> 그래도 가능하다면 CQS 원칙을 따르는 것이 좋다.

Test doubles that substitute commands become mocks.

> 커맨드를 대체하는 테스트 대역은 목(mock)이 된다.

Similarly, test doubles that substitute queries are stubs.

> 마찬가지로 쿼리를 대체하는 테스트 대역은 스텁(stub)이다.

Look at the two tests from listings 5.1 and 5.2 again (I’m showing their relevant parts here):

> 예제 5.1과 5.2에 나왔던 두 테스트를 다시 보자 (관련 부분만 다시 보여준다):

```
	var mock = new Mock<IEmailGateway>();
	mock.Verify(x => x.SendGreetingsEmail("user@email.com"));
	var stub = new Mock<IDatabase>();
	stub.Setup(x => x.GetNumberOfUsers()).Returns(10);
```
	
SendGreetingsEmail() is a command whose side effect is sending an email.

> SendGreetingsEmail()은 이메일을 보내는 사이드 이펙트를 가진 커맨드이다.

The test double that substitutes this command is a mock.

> 이 커맨드를 대체하는 테스트 대역은 목(mock)이다.

On the other hand, GetNumberOfUsers() is a query that returns a value and doesn’t mutate the database state.

> 반면, GetNumberOfUsers()는 값을 반환하고 데이터베이스 상태를 변경하지 않는 쿼리이다.

The corresponding test double is a stub.

> 이에 해당하는 테스트 대역은 스텁(stub)이다.

## 5.2 Observable behavior vs. implementation details

Section 5.1 showed what a mock is. The next step on the way to explaining the connection between mocks and test fragility is diving into what causes such fragility.

5.1절에서는 목이 무엇인지 설명했다. 이제 목과 테스트 취약성 사이의 연관성을 설명하기 위해, 그런 취약성이 발생하는 원인을 파고들어보자.

As you might remember from chapter 4, test fragility corresponds to the second attribute of a good unit test: resistance to refactoring.

4장에서 언급했듯, 테스트의 취약성은 좋은 단위 테스트의 두 번째 속성인 '리팩토링에 대한 저항성'과 관련이 있다.

(As a reminder, the four attributes are protection against regressions, resistance to refactoring, fast feedback, and maintainability.)

(참고로, 좋은 테스트의 네 가지 속성은 회귀로부터의 보호, 리팩토링에 대한 저항성, 빠른 피드백, 유지보수 용이성이다.)

The metric of resistance to refactoring is the most important because whether a unit test possesses this metric is mostly a binary choice.

이 중에서도 리팩토링에 대한 저항성은 가장 중요한 기준인데, 단위 테스트가 이 속성을 가지는지는 대부분 이분법적인 판단이기 때문이다.

Thus, it’s good to max out this metric to the extent that the test still remains in the realm of unit testing and doesn’t transition to the category of end-to-end testing.

따라서 테스트가 단위 테스트의 범위를 벗어나지 않는 선에서 이 속성을 최대한 확보하는 것이 좋다.

The latter, despite being the best at resistance to refactoring, is generally much harder to maintain.

후자인 엔드 투 엔드 테스트는 리팩토링 저항성 면에서는 우수하지만, 유지보수는 훨씬 더 어렵다.

In chapter 4, you also saw that the main reason tests deliver false positives (and thus fail at resistance to refactoring) is because they couple to the code’s implementation details.

4장에서 살펴본 바와 같이, 테스트가 거짓 양성(false positive)을 발생시키고 리팩토링 저항성을 갖지 못하는 주요 원인은 코드의 구현 세부사항에 결합되어 있기 때문이다.

The only way to avoid such coupling is to verify the end result the code produces (its observable behavior) and distance tests from implementation details as much as possible.

이러한 결합을 피하는 유일한 방법은 코드가 만들어내는 최종 결과(즉, 관찰 가능한 동작)를 검증하고, 구현 세부사항으로부터 테스트를 최대한 멀리 떨어뜨리는 것이다.

In other words, tests must focus on the whats, not the hows.

다시 말해, 테스트는 "어떻게"가 아닌 "무엇을"에 집중해야 한다.

So, what exactly is an implementation detail, and how is it different from an observable behavior?

그렇다면 구현 세부사항이란 정확히 무엇이며, 그것은 관찰 가능한 동작과 어떻게 다른가?

## 5.2.1 Observable behavior is not the same as a public API
	
All production code can be categorized along two dimensions:  
> 모든 프로덕션 코드는 두 가지 차원으로 분류할 수 있다:  

 Public API vs. private API (where API means application programming interface)  
>  퍼블릭 API vs. 프라이빗 API (API는 Application Programming Interface의 약자다)  

 Observable behavior vs. implementation details  
>  관찰 가능한 동작 vs. 구현 세부사항  

The categories in these dimensions don’t overlap. A method can’t belong to both a public and a private API; it’s either one or the other.  
> 이 두 차원에서의 범주는 서로 겹치지 않는다. 어떤 메서드도 퍼블릭 API와 프라이빗 API에 동시에 속할 수 없다. 둘 중 하나에만 해당된다.  

Similarly, the code is either an internal implementation detail or part of the system’s observable behavior, but not both.  
> 마찬가지로, 코드는 내부 구현 세부사항이거나 시스템의 관찰 가능한 동작 중 하나이지, 둘 다일 수는 없다.  

Most programming languages provide a simple mechanism to differentiate between the code base’s public and private APIs.  
> 대부분의 프로그래밍 언어는 코드베이스의 퍼블릭 API와 프라이빗 API를 구분할 수 있는 간단한 메커니즘을 제공한다.  

For example, in C#, you can mark any member in a class with the private keyword, and that member will be hidden from the client code, becoming part of the class’s private API.  
> 예를 들어, C#에서는 클래스의 멤버에 `private` 키워드를 지정하면 해당 멤버는 클라이언트 코드에서 숨겨지고, 클래스의 프라이빗 API가 된다.  

The same is true for classes: you can easily make them private by using the private or internal keyword.  
> 클래스도 마찬가지다. `private` 또는 `internal` 키워드를 사용해 쉽게 프라이빗으로 만들 수 있다.  

The distinction between observable behavior and internal implementation details is more nuanced.  
> 관찰 가능한 동작과 내부 구현 세부사항의 구분은 더 미묘하다.  

For a piece of code to be part of the system’s observable behavior, it has to do one of the following things:  
> 어떤 코드가 시스템의 관찰 가능한 동작의 일부가 되기 위해서는 다음 중 하나를 수행해야 한다:  

 Expose an operation that helps the client achieve one of its goals. An operation is a method that performs a calculation or incurs a side effect or both.  
>  클라이언트가 목표를 달성하는 데 도움이 되는 연산(operation)을 제공해야 한다. 연산은 계산을 수행하거나 부작용을 유발하거나, 또는 둘 다 수행하는 메서드이다.  

 Expose a state that helps the client achieve one of its goals. State is the current condition of the system.  
>  클라이언트가 목표를 달성하는 데 도움이 되는 상태(state)를 제공해야 한다. 상태란 시스템의 현재 상태를 의미한다.  

Any code that does neither of these two things is an implementation detail.  
> 위 두 가지 중 어느 것도 하지 않는 코드는 구현 세부사항이다.  

Notice that whether the code is observable behavior depends on who its client is and what the goals of that client are.  
> 코드가 관찰 가능한 동작인지 여부는 해당 코드의 클라이언트가 누구이며, 그 클라이언트의 목표가 무엇인지에 따라 달라진다.  

In order to be a part of observable behavior, the code needs to have an immediate connection to at least one such goal.  
> 관찰 가능한 동작의 일부가 되기 위해서는, 해당 코드는 적어도 하나의 목표와 직접적으로 연결되어 있어야 한다.  

The word client can refer to different things depending on where the code resides.  
> 여기서 '클라이언트'라는 단어는 코드가 어디에 위치하느냐에 따라 다양한 대상을 의미할 수 있다.  

The common examples are client code from the same code base, an external application, or the user interface.  
> 일반적인 예로는 동일한 코드베이스 내의 클라이언트 코드, 외부 애플리케이션, 또는 사용자 인터페이스가 있다.  

Ideally, the system’s public API surface should coincide with its observable behavior, and all its implementation details should be hidden from the eyes of the clients.  
> 이상적으로는 시스템의 퍼블릭 API는 관찰 가능한 동작과 일치해야 하며, 구현 세부사항은 모두 클라이언트의 눈에 띄지 않도록 숨겨져야 한다.  

Such a system has a well-designed API (figure 5.4).  
> 이런 시스템은 잘 설계된 API를 갖추고 있는 것이다 (그림 5.4).  

Often, though, the system’s public API extends beyond its observable behavior and starts exposing implementation details.  
> 하지만 실제로는 시스템의 퍼블릭 API가 관찰 가능한 동작의 범위를 넘어서서 구현 세부사항을 드러내는 경우가 많다.  

Such a system’s implementation details leak to its public API surface (figure 5.5).  
> 이런 시스템에서는 구현 세부사항이 퍼블릭 API 영역으로 새어 나오는 것이다 (그림 5.5).  

## 5.2.2 Leaking implementation details: An example with an operation

Let’s take a look at examples of code whose implementation details leak to the public API.  
> 퍼블릭 API에 구현 세부사항이 노출된 코드 예제를 살펴보자.

Listing 5.5 shows a User class with a public API that consists of two members: a Name property and a NormalizeName() method.  
> 리스트 5.5는 `Name` 프로퍼티와 `NormalizeName()` 메서드 두 가지 퍼블릭 멤버를 갖는 `User` 클래스를 보여준다.

The class also has an invariant: users’ names must not exceed 50 characters and should be truncated otherwise.  
> 이 클래스에는 불변 조건도 하나 존재하는데, 사용자 이름은 50자를 초과할 수 없으며, 초과할 경우 잘라내야 한다.

#### Listing 5.5 User class with leaking implementation details

```
public class User
{
	public string Name { get; set; }
	
	public string NormalizeName(string name)
	{
		string result = (name ?? "").Trim();
		if (result.Length > 50)
			return result.Substring(0, 50);
		return result;
	}
	public class UserController
	{
		public void RenameUser(int userId, string newName)
		{
			User user = GetUserFromDatabase(userId);
			string normalizedName = user.NormalizeName(newName);
			user.Name = normalizedName;
			SaveUserToDatabase(user);
		}
	}
}	
```
	
UserController is client code. It uses the User class in its RenameUser method.  
> `UserController`는 클라이언트 코드다. 이 클래스는 `RenameUser` 메서드에서 `User` 클래스를 사용한다.

The goal of this method, as you have probably guessed, is to change a user’s name.  
> 이 메서드의 목적은 예상했듯이 사용자의 이름을 변경하는 것이다.

So, why isn’t User’s API well-designed?  
> 그렇다면 왜 `User`의 API는 잘 설계되지 않은 것일까?

Look at its members once again: the Name property and the NormalizeName method.  
> 그 멤버들을 다시 보자: `Name` 프로퍼티와 `NormalizeName` 메서드.

Both of them are public.  
> 이 둘 모두 퍼블릭이다.

Therefore, in order for the class’s API to be well-designed, these members should be part of the observable behavior.  
> 따라서 클래스의 API가 잘 설계되었다고 보기 위해서는 이 멤버들이 관찰 가능한 동작에 포함되어야 한다.

This, in turn, requires them to do one of the following two things (which I’m repeating here for convenience):  
> 이는 다시 말해, 다음 두 가지 중 하나를 충족해야 한다는 뜻이다 (편의를 위해 다시 적는다):

 Expose an operation that helps the client achieve one of its goals.  
>  클라이언트가 어떤 목표를 달성하도록 도와주는 연산을 노출할 것.

 Expose a state that helps the client achieve one of its goals.  
>  클라이언트가 어떤 목표를 달성하는 데 필요한 상태를 노출할 것.

Only the Name property meets this requirement.  
> 이 요건을 충족하는 건 `Name` 프로퍼티뿐이다.

It exposes a setter, which is an operation that allows UserController to achieve its goal of changing a user’s name.  
> 이 프로퍼티는 setter를 노출하며, 이는 `UserController`가 사용자 이름을 변경하는 목표를 달성할 수 있게 해주는 연산이다.

The NormalizeName method is also an operation, but it doesn’t have an immediate connection to the client’s goal.  
> `NormalizeName` 메서드 또한 연산이긴 하지만, 클라이언트의 목표와 직접적인 연결이 없다.

The only reason UserController calls this method is to satisfy the invariant of User.  
> `UserController`가 이 메서드를 호출하는 유일한 이유는 `User` 클래스의 불변 조건을 만족시키기 위해서다.

NormalizeName is therefore an implementation detail that leaks to the class’s public API (figure 5.6).  
> 따라서 `NormalizeName`은 클래스의 퍼블릭 API에 노출된 구현 세부사항인 것이다 (그림 5.6).

To fix the situation and make the class’s API well-designed, User needs to hide NormalizeName() and call it internally as part of the property’s setter without relying on the client code to do so.  
> 이 상황을 고치고 API를 잘 설계된 형태로 만들기 위해서는, `User` 클래스가 `NormalizeName()`을 숨기고, 해당 메서드를 프로퍼티의 setter 내부에서 호출하도록 해야 한다. 즉, 클라이언트 코드가 이 메서드를 직접 호출하지 않게 해야 한다.

Listing 5.6 shows this approach.  
> 리스트 5.6은 이러한 접근 방식을 보여준다.

![스크린샷 2025-06-10 07.38.09](https://hackmd.io/_uploads/HJTIzkr7xx.png)

#### Listing 5.6 A version of User with a well-designed API
	
![스크린샷 2025-06-10 07.39.33](https://hackmd.io/_uploads/rJlhMJHQll.png)
	
User’s API in listing 5.6 is well-designed: only the observable behavior (the Name prop-
erty) is made public, while the implementation details (the NormalizeName method)
are hidden behind the private API (figure 5.7).
	
![스크린샷 2025-06-10 07.39.50](https://hackmd.io/_uploads/rkQ6zyr7xg.png)

**NOTE**
	
Strictly speaking, Name’s getter should also be made private, because it’s not used by UserController.  
> 엄밀히 말하면 `Name`의 getter 역시 `UserController`에서 사용되지 않기 때문에 private으로 만드는 것이 맞다.

In reality, though, you almost always want to read back changes you make.  
> 하지만 실제로는, 변경한 내용을 다시 읽어오는 경우가 거의 항상 필요하다.

Therefore, in a real project, there will certainly be another use case that requires seeing users’ current names via Name’s getter.  
> 따라서 현실적인 프로젝트에서는 `Name`의 getter를 통해 사용자의 현재 이름을 확인해야 하는 또 다른 유스케이스가 반드시 존재하게 된다.

There’s a good rule of thumb that can help you determine whether a class leaks its implementation details.  
> 클래스가 구현 세부사항을 노출하는지를 판단하는 데 도움이 되는 좋은 경험칙이 있다.

If the number of operations the client has to invoke on the class to achieve a single goal is greater than one, then that class is likely leaking implementation details.  
> 클라이언트가 하나의 목표를 달성하기 위해 클래스에서 호출해야 하는 연산이 두 개 이상이라면, 그 클래스는 구현 세부사항을 노출하고 있을 가능성이 높다.

Ideally, any individual goal should be achieved with a single operation.  
> 이상적으로는, 어떤 개별적인 목표도 하나의 연산으로 달성될 수 있어야 한다.

In listing 5.5, for example, UserController has to use two operations from User:  
> 예를 들어 리스트 5.5에서 `UserController`는 `User`로부터 두 개의 연산을 사용해야 한다:

```
	string normalizedName = user.NormalizeName(newName);
	user.Name = normalizedName;
```
	
After the refactoring, the number of operations has been reduced to one:
	
```
	user.Name = newName;
```
In my experience, this rule of thumb holds true for the vast majority of cases where business logic is involved.  
> 내 경험상, 이 경험칙은 비즈니스 로직이 관련된 대부분의 경우에 적용된다.

There could very well be exceptions, though.  
> 물론 예외가 존재할 수는 있다.

Still, be sure to examine each situation where your code violates this rule for a potential leak of implementation details.  
> 그럼에도 불구하고, 이 규칙을 위반하는 상황이 발생할 때마다 구현 세부사항이 노출되고 있는 것은 아닌지 반드시 확인해야 한다.

## 5.2.3 Well-designed API and encapsulation
	
Maintaining a well-designed API relates to the notion of encapsulation.  
> 잘 설계된 API를 유지하는 것은 캡슐화(encapsulation) 개념과 관련이 있다.

As you might recall from chapter 3, encapsulation is the act of protecting your code against inconsistencies, also known as invariant violations.  
> 3장에서 언급했듯, 캡슐화란 코드가 불일치 상태에 빠지지 않도록 보호하는 행위이며, 이는 불변성(invariant) 위반을 방지하는 것을 의미한다.

An invariant is a condition that should be held true at all times.  
> 불변성이란 항상 참이어야 하는 조건이다.

The User class from the previous example had one such invariant: no user could have a name that exceeded 50 characters.  
> 이전 예제의 User 클래스에는 하나의 불변성이 존재했다. 사용자 이름은 50자를 초과해서는 안 된다는 것이다.

Exposing implementation details goes hand in hand with invariant violations—the former often leads to the latter.  
> 구현 세부사항을 외부에 노출하는 것은 불변성 위반과 밀접하게 연결되어 있으며, 전자가 후자를 유발하는 경우가 많다.

Not only did the original version of User leak its implementation details, but it also didn’t maintain proper encapsulation.  
> 기존 User 클래스는 구현 세부사항을 노출했을 뿐 아니라, 캡슐화도 제대로 유지하지 않았다.

It allowed the client to bypass the invariant and assign a new name to a user without normalizing that name first.  
> 클라이언트가 이름을 정규화하지 않고도 사용자 이름을 변경할 수 있도록 허용했기 때문에, 불변성을 우회할 수 있게 되었다.

Encapsulation is crucial for code base maintainability in the long run.  
> 캡슐화는 장기적인 코드베이스 유지보수에 있어서 핵심적인 요소다.

The reason why is complexity.  
> 그 이유는 바로 복잡성 때문이다.

Code complexity is one of the biggest challenges you’ll face in software development.  
> 코드의 복잡성은 소프트웨어 개발에서 마주하게 되는 가장 큰 도전 과제 중 하나다.

The more complex the code base becomes, the harder it is to work with, which, in turn, results in slowing down development speed and increasing the number of bugs.  
> 코드베이스가 복잡해질수록 작업이 어려워지고, 그로 인해 개발 속도는 느려지고 버그는 많아지게 된다.

Without encapsulation, you have no practical way to cope with ever-increasing code complexity.  
> 캡슐화 없이 점점 복잡해지는 코드를 실질적으로 다룰 방법이 없다.

When the code’s API doesn’t guide you through what is and what isn’t allowed to be done with that code, you have to keep a lot of information in mind to make sure you don’t introduce inconsistencies with new code changes.  
> API가 무엇을 할 수 있고 무엇을 하면 안 되는지를 명확히 안내하지 않으면, 새로운 코드 변경 시 불일치를 일으키지 않도록 많은 정보를 머릿속에 기억해둬야 한다.

This brings an additional mental burden to the process of programming.  
> 이는 프로그래밍 과정에 불필요한 정신적 부담을 더한다.

Remove as much of that burden from yourself as possible.  
> 이러한 부담을 최대한 줄이는 것이 중요하다.

You cannot trust yourself to do the right thing all the time—so, eliminate the very possibility of doing the wrong thing.  
> 항상 올바른 판단을 할 수 있다고 자신을 믿어서는 안 된다. 그러므로 잘못된 행동을 할 가능성 자체를 없애야 한다.

The best way to do so is to maintain proper encapsulation so that your code base doesn’t even provide an option for you to do anything incorrectly.  
> 이를 위한 최선의 방법은 캡슐화를 통해 코드베이스에서 잘못된 행동을 할 수 있는 여지를 아예 없애는 것이다.

Encapsulation ultimately serves the same goal as unit testing: it enables sustainable growth of your software project.  
> 캡슐화는 궁극적으로 단위 테스트와 동일한 목표를 가진다. 바로 소프트웨어 프로젝트의 지속 가능한 성장을 가능하게 한다는 점이다.

There’s a similar principle: tell-don’t-ask.  
> 이와 유사한 원칙으로 "Tell, Don’t Ask(말하고, 묻지 마라)"라는 개념이 있다.

It was coined by Martin Fowler and stands for bundling data with the functions that operate on that data.  
> 이는 마틴 파울러(Martin Fowler)가 만든 개념으로, 데이터를 다루는 함수와 데이터를 함께 묶는다는 의미다.

You can view this principle as a corollary to the practice of encapsulation.  
> 이 원칙은 캡슐화라는 실천 방식의 자연스러운 귀결로 볼 수 있다.

Code encapsulation is a goal, whereas bundling data and functions together, as well as hiding implementation details, are the means to achieve that goal:  
> 코드 캡슐화는 목표이고, 데이터를 함수와 함께 묶는 것과 구현 세부사항을 숨기는 것은 그 목표를 달성하기 위한 수단이다:

- Hiding implementation details helps you remove the class’s internals from the eyes of its clients, so there’s less risk of corrupting those internals.  
> 구현 세부사항을 숨기면 클래스의 내부 구조가 클라이언트로부터 감춰지므로, 내부 상태가 손상될 위험이 줄어든다.

- Bundling data and operations helps to make sure these operations don’t violate the class’s invariants.  
> 데이터와 연산을 함께 묶으면 그 연산이 클래스의 불변성을 위반하지 않도록 보장할 수 있다.

## 5.2.4 Leaking implementation details: An example with state

The example shown in listing 5.5 demonstrated an operation (the NormalizeName method) that was an implementation detail leaking to the public API.  
> 목록 5.5에 나온 예시는 구현 세부사항인 NormalizeName 메서드가 퍼블릭 API로 누출된 사례였다.

Let’s also look at an example with state. The following listing contains the MessageRenderer class you saw in chapter 4.  
> 이번에는 상태(state)와 관련된 예시를 살펴보자. 다음 목록은 4장에서 본 MessageRenderer 클래스를 포함하고 있다.

It uses a collection of sub-renderers to generate an HTML representation of a message containing a header, a body, and a footer.  
> 이 클래스는 메시지의 헤더, 본문, 푸터를 렌더링하기 위해 서브 렌더러(sub-renderer) 컬렉션을 사용해 HTML 형태로 표현을 생성한다.

```
	public class MessageRenderer : IRenderer
{
public IReadOnlyList<IRenderer> SubRenderers { get; }
public MessageRenderer()
{
SubRenderers = new List<IRenderer>
{
new HeaderRenderer(),
new BodyRenderer(),
	new FooterRenderer()

};
}
{
public string Render(Message message)
return SubRenderers
.Select(x => x.Render(message))
.Aggregate("", (str1, str2) => str1 + str2);
	}
	}
```
	
The sub-renderers collection is public. But is it part of observable behavior?  
> 서브 렌더러 컬렉션은 public이다. 하지만 이것이 관찰 가능한 동작에 해당할까?

Assuming that the client’s goal is to render an HTML message, the answer is no.  
> 클라이언트의 목표가 HTML 메시지를 렌더링하는 것이라고 가정한다면, 정답은 '아니다'.

The only class member such a client would need is the Render method itself.  
> 그런 클라이언트가 필요로 하는 유일한 클래스 멤버는 Render 메서드뿐이다.

Thus SubRenderers is also a leaking implementation detail.  
> 따라서 SubRenderers는 구현 세부사항이 외부로 새어나간 사례다.

I bring up this example again for a reason.  
> 이 예제를 다시 언급하는 데에는 이유가 있다.

As you may remember, I used it to illustrate a brittle test.  
> 기억하겠지만, 이 예제는 취약한 테스트(brittle test)를 설명하기 위해 사용되었다.

That test was brittle precisely because it was tied to this implementation detail—it checked to see the collection’s composition.  
> 그 테스트가 취약했던 이유는 이 구현 세부사항에 의존하고 있었기 때문이며, 구체적으로는 컬렉션의 구성을 검사했기 때문이다.

The brittleness was fixed by re-targeting the test at the Render method.  
> 이 취약성은 테스트의 초점을 Render 메서드로 옮김으로써 해결되었다.

The new version of the test verified the resulting message—the only output the client code cared about, the observable behavior.  
> 새로운 테스트는 렌더링된 메시지를 검증했으며, 이는 클라이언트 코드가 관심을 갖는 유일한 출력, 즉 관찰 가능한 동작이었다.

As you can see, there’s an intrinsic connection between good unit tests and a well-designed API.  
> 이처럼 좋은 단위 테스트와 잘 설계된 API 사이에는 본질적인 연결이 존재한다.

By making all implementation details private, you leave your tests no choice other than to verify the code’s observable behavior, which automatically improves their resistance to refactoring.  
> 모든 구현 세부사항을 private으로 숨기면, 테스트는 자연스럽게 관찰 가능한 동작만을 검증하게 되며, 이는 리팩토링 저항성을 자동으로 향상시킨다.

**TIP**
	
Making the API well-designed automatically improves unit tests.  
> API를 잘 설계하면 자동으로 단위 테스트의 품질도 향상된다.
	
Another guideline flows from the definition of a well-designed API: you should expose the absolute minimum number of operations and state.  
> 잘 설계된 API의 정의에서 파생되는 또 하나의 지침은, 연산과 상태를 가능한 최소한으로 공개해야 한다는 것이다.

Only code that directly helps clients achieve their goals should be made public.  
> 오직 클라이언트가 목표를 달성하는 데 직접적으로 도움이 되는 코드만 public으로 공개해야 한다.

Everything else is implementation details and thus must be hidden behind the private API.  
> 그 외의 모든 코드는 구현 세부사항이며, 따라서 private API 뒤에 감춰져야 한다.

Note that there’s no such problem as leaking observable behavior, which would be symmetric to the problem of leaking implementation details.  
> 구현 세부사항이 노출되는 문제와 달리, 관찰 가능한 동작이 '노출되는' 문제는 존재하지 않는다는 점에 주목하자.

While you can expose an implementation detail (a method or a class that is not supposed to be used by the client), you can’t hide an observable behavior.  
> 구현 세부사항은 클라이언트가 사용하지 않아야 할 메서드나 클래스를 실수로 외부에 노출시킬 수 있지만, 관찰 가능한 동작은 숨길 수 없다.

Such a method or class would no longer have an immediate connection to the client goals, because the client wouldn’t be able to directly use it anymore.  
> 그렇게 되면 해당 메서드나 클래스는 더 이상 클라이언트의 목표와 직접적인 연결고리를 가지지 않게 된다. 왜냐하면 클라이언트가 그것을 직접 사용할 수 없기 때문이다.

Thus, by definition, this code would cease to be part of observable behavior.  
> 따라서 정의상, 이러한 코드는 더 이상 관찰 가능한 동작에 속하지 않게 된다.

Table 5.1 sums it all up.  
> 표 5.1은 이 내용을 요약하고 있다.

Table 5.1 details public. The relationship between the code’s publicity and purpose. Avoid making implementation
	

## 5.3 The relationship between mocks and test fragility
	
The previous sections defined a mock and showed the difference between observable behavior and an implementation detail.  
> 앞선 섹션에서는 목(mock)의 정의와 관찰 가능한 동작과 구현 세부사항의 차이를 설명했다.

In this section, you will learn about hexagonal architecture, the difference between internal and external communications, and (finally!) the relationship between mocks and test fragility.  
> 이번 섹션에서는 헥사고날 아키텍처(hexagonal architecture), 내부 통신과 외부 통신의 차이, 그리고 (마침내!) 목과 테스트 취약성 간의 관계에 대해 알아본다.
	
## 5.3.1 Defining hexagonal architecture
	
A typical application consists of two layers, domain and application services, as shown in figure 5.8.  
> 일반적인 애플리케이션은 도메인 계층과 애플리케이션 서비스 계층, 이렇게 두 개의 계층으로 구성된다 (그림 5.8 참고).

The domain layer resides in the middle of the diagram because it’s the central part of your application.  
> 도메인 계층은 애플리케이션의 핵심이기 때문에 다이어그램의 중앙에 위치한다.

It contains the business logic: the essential functionality your application is built for.  
> 이 계층에는 비즈니스 로직이 포함되어 있으며, 이는 애플리케이션이 존재하는 본질적인 기능이다.

The domain layer and its business logic differentiate this application from others and provide a competitive advantage for the organization.  
> 도메인 계층과 그에 포함된 비즈니스 로직은 애플리케이션을 다른 제품들과 차별화시키며, 조직에 경쟁 우위를 제공한다.

![스크린샷 2025-06-10 07.43.55](https://hackmd.io/_uploads/B1vh71BQgl.png)

The application services layer sits on top of the domain layer and orchestrates communication between that layer and the external world.  
> 애플리케이션 서비스 계층은 도메인 계층 위에 위치하며, 도메인 계층과 외부 세계 간의 통신을 조율하는 역할을 한다.

For example, if your application is a RESTful API, all requests to this API hit the application services layer first.  
> 예를 들어, 애플리케이션이 RESTful API라면, 모든 요청은 가장 먼저 애플리케이션 서비스 계층에 도달한다.

This layer then coordinates the work between domain classes and out-of-process dependencies.  
> 이 계층은 도메인 클래스들과 외부 프로세스 의존성들 간의 작업을 조정한다.

Here’s an example of such coordination for the application service. It does the following:  
> 애플리케이션 서비스가 수행하는 조정 작업의 예는 다음과 같다:

 Queries the database and uses the data to materialize a domain class instance  
>  데이터베이스를 쿼리하고, 데이터를 이용해 도메인 클래스 인스턴스를 생성한다.

 Invokes an operation on that instance  
>  해당 인스턴스에서 특정 연산을 호출한다.

 Saves the results back to the database  
>  결과를 다시 데이터베이스에 저장한다.

The combination of the application services layer and the domain layer forms a hexagon, which itself represents your application.  
> 애플리케이션 서비스 계층과 도메인 계층이 결합되어 하나의 육각형(hexagon)을 이루며, 이것이 애플리케이션 자체를 나타낸다.

It can interact with other applications, which are represented with their own hexagons (see figure 5.9).  
> 이 구조는 다른 애플리케이션들과 상호작용할 수 있으며, 각 애플리케이션도 고유한 육각형으로 표현된다 (그림 5.9 참고).

These other applications could be an SMTP service, a third-party system, a message bus, and so on.  
> 다른 애플리케이션은 SMTP 서비스, 서드파티 시스템, 메시지 버스 등일 수 있다.

A set of interacting hexagons makes up a hexagonal architecture.  
> 이러한 육각형들이 상호작용하여 헥사고날 아키텍처를 구성하게 된다.

![스크린샷 2025-06-10 07.44.15](https://hackmd.io/_uploads/HJj6QJSQxl.png)

The term hexagonal architecture was introduced by Alistair Cockburn.  
> 헥사고날 아키텍처(hexagonal architecture)라는 용어는 알리스테어 코번(Alistair Cockburn)에 의해 소개되었다.

Its purpose is to emphasize three important guidelines:  
> 이 아키텍처의 목적은 세 가지 중요한 지침을 강조하는 것이다:

 The separation of concerns between the domain and application services layers —  
>  도메인 계층과 애플리케이션 서비스 계층 간의 관심사 분리 —  

Business logic is the most important part of the application.  
> 비즈니스 로직은 애플리케이션에서 가장 중요한 부분이다.

Therefore, the domain layer should be accountable only for that business logic and exempted from all other responsibilities.  
> 따라서 도메인 계층은 비즈니스 로직에만 집중하고, 그 외의 모든 책임에서는 제외되어야 한다.

Those responsibilities, such as communicating with external applications and retrieving data from the database, must be attributed to application services.  
> 외부 애플리케이션과의 통신이나 데이터베이스에서의 데이터 조회와 같은 책임은 애플리케이션 서비스 계층에 귀속되어야 한다.

Conversely, the application services shouldn’t contain any business logic.  
> 반대로, 애플리케이션 서비스 계층은 어떠한 비즈니스 로직도 포함해서는 안 된다.

Their responsibility is to adapt the domain layer by translating the incoming requests into operations on domain classes and then persisting the results or returning them back to the caller.  
> 이 계층의 책임은 들어오는 요청을 도메인 클래스의 연산으로 변환하고, 결과를 저장하거나 호출자에게 반환하는 방식으로 도메인 계층을 조정하는 것이다.

You can view the domain layer as a collection of the application’s domain knowledge (how-to’s) and the application services layer as a set of business use cases (what-to’s).  
> 도메인 계층은 애플리케이션의 도메인 지식(how-to), 애플리케이션 서비스 계층은 비즈니스 유스케이스(what-to) 집합으로 볼 수 있다.

 Communications inside your application —  
>  애플리케이션 내부의 통신 —

Hexagonal architecture prescribes a one-way flow of dependencies: from the application services layer to the domain layer.  
> 헥사고날 아키텍처는 애플리케이션 서비스 계층에서 도메인 계층으로 향하는 단방향 의존성 흐름을 지시한다.

Classes inside the domain layer should only depend on each other; they should not depend on classes from the application services layer.  
> 도메인 계층의 클래스는 오직 도메인 내부의 다른 클래스에만 의존해야 하며, 애플리케이션 서비스 계층의 클래스에는 의존해서는 안 된다.

This guideline flows from the previous one.  
> 이 지침은 앞선 관심사 분리 원칙으로부터 자연스럽게 이어진다.

The separation of concerns between the application services layer and the domain layer means that the former knows about the latter, but the opposite is not true.  
> 애플리케이션 서비스 계층은 도메인 계층을 알고 있어야 하지만, 도메인 계층은 애플리케이션 서비스 계층을 알 필요가 없다.

The domain layer should be fully isolated from the external world.  
> 도메인 계층은 외부 세계로부터 완전히 격리되어야 한다.

 Communications between applications —  
>  애플리케이션 간의 통신 —

External applications connect to your application through a common interface maintained by the application services layer.  
> 외부 애플리케이션은 애플리케이션 서비스 계층이 유지하는 공통 인터페이스를 통해 내부 애플리케이션에 연결된다.

No one has a direct access to the domain layer.  
> 그 누구도 도메인 계층에 직접 접근할 수 없다.

Each side in a hexagon represents a connection into or out of the application.  
> 육각형의 각 면은 애플리케이션과 외부 간의 연결을 나타낸다.

Note that although a hexagon has six sides, it doesn’t mean your application can only connect to six other applications.  
> 육각형이 여섯 면을 가진다고 해서 애플리케이션이 여섯 개의 외부 애플리케이션에만 연결될 수 있다는 의미는 아니다.

The number of connections is arbitrary. The point is that there can be many such connections.  
> 연결의 수는 임의적이며, 요점은 다양한 연결이 존재할 수 있다는 것이다.

Each layer of your application exhibits observable behavior and contains its own set of implementation details.  
> 애플리케이션의 각 계층은 고유의 관찰 가능한 동작을 가지며, 그 안에 구현 세부사항도 포함되어 있다.

For example, observable behavior of the domain layer is the sum of this layer’s operations and state that helps the application service layer achieve at least one of its goals.  
> 예를 들어, 도메인 계층의 관찰 가능한 동작은 이 계층의 연산과 상태 중 애플리케이션 서비스 계층이 목표를 달성하는 데 도움이 되는 것들의 합이다.

The principles of a well-designed API have a fractal nature: they apply equally to as much as a whole layer or as little as a single class.  
> 잘 설계된 API의 원칙은 프랙탈 성질을 가지고 있어서, 전체 계층에도, 단일 클래스에도 동일하게 적용된다.

When you make each layer’s API well-designed (that is, hide its implementation details), your tests also start to have a fractal structure;  
> 각 계층의 API를 잘 설계하게 되면(즉, 구현 세부사항을 숨기게 되면), 테스트도 프랙탈 구조를 갖게 된다.

they verify behavior that helps achieve the same goals but at different levels.  
> 이 테스트들은 동일한 목표를 검증하되, 서로 다른 레벨에서 이를 수행한다.

A test covering an application service checks to see how this service attains an overarching, coarse-grained goal posed by the external client.  
> 애플리케이션 서비스를 대상으로 하는 테스트는 외부 클라이언트가 제시한 상위 목표가 어떻게 달성되는지를 확인한다.

At the same time, a test working with a domain class verifies a subgoal that is part of that greater goal (figure 5.10).  
> 반면, 도메인 클래스를 테스트하는 경우에는 상위 목표의 일부인 하위 목표를 검증하게 된다 (그림 5.10).

	
![스크린샷 2025-06-10 07.44.43](https://hackmd.io/_uploads/S1OkNJSXgl.png)

You might remember from previous chapters how I mentioned that you should be able to trace any test back to a particular business requirement.  
> 앞선 장들에서 언급했듯이, 모든 테스트는 특정한 비즈니스 요구사항으로 거슬러 올라갈 수 있어야 한다.

Each test should tell a story that is meaningful to a domain expert, and if it doesn’t, that’s a strong indication that the test couples to implementation details and therefore is brittle.  
> 각각의 테스트는 도메인 전문가에게 의미 있는 "스토리"를 담고 있어야 하며, 그렇지 않다면 그 테스트는 구현 세부사항에 결합되어 있다는 강한 신호이며, 결국 깨지기 쉬운 테스트가 된다.

I hope now you can see why.  
> 이제 그 이유를 이해했기를 바란다.

Observable behavior flows inward from outer layers to the center.  
> 관찰 가능한 동작은 바깥 계층에서 중심으로 흐른다.

The overarching goal posed by the external client gets translated into subgoals achieved by individual domain classes.  
> 외부 클라이언트가 제시한 상위 목표는 개별 도메인 클래스가 달성해야 하는 하위 목표로 변환된다.

Each piece of observable behavior in the domain layer therefore preserves the connection to a particular business use case.  
> 따라서 도메인 계층의 각 관찰 가능한 동작은 특정 비즈니스 유스케이스와의 연결을 유지하게 된다.

You can trace this connection recursively from the innermost (domain) layer outward to the application services layer and then to the needs of the external client.  
> 이 연결성은 가장 안쪽인 도메인 계층에서부터 애플리케이션 서비스 계층, 그리고 외부 클라이언트의 요구로 재귀적으로 추적할 수 있다.

This traceability follows from the definition of observable behavior.  
> 이러한 추적 가능성은 관찰 가능한 동작의 정의에서 비롯된다.

For a piece of code to be part of observable behavior, it needs to help the client achieve one of its goals.  
> 코드가 관찰 가능한 동작의 일부가 되기 위해서는 클라이언트가 목표를 달성하도록 도와야 한다.

For a domain class, the client is an application service; for the application service, it’s the external client itself.  
> 도메인 클래스의 경우 클라이언트는 애플리케이션 서비스이고, 애플리케이션 서비스의 클라이언트는 외부 클라이언트다.

Tests that verify a code base with a well-designed API also have a connection to business requirements because those tests tie to the observable behavior only.  
> 잘 설계된 API를 검증하는 테스트는 오직 관찰 가능한 동작에만 결합되어 있기 때문에 비즈니스 요구사항과의 연결성을 가진다.

A good example is the User and UserController classes from listing 5.6 (I’m repeating the code here for convenience).  
> 좋은 예시는 5.6번 예제의 User 및 UserController 클래스이다 (편의를 위해 여기서 다시 코드가 반복된다).

	
#### Listing 5.8 A domain class with an application service
	
```
	public class User
{
private string _name;
public string Name
{
get => _name;
set => _name = NormalizeName(value);
private string NormalizeName(string name)
/* Trim name down to 50 characters */
}
{
}
}
{
public class UserController
public void RenameUser(int userId, string newName)
{
User user = GetUserFromDatabase(userId);
user.Name = newName;
SaveUserToDatabase(user);
}
}
```
	
UserController in this example is an application service.  
> 이 예제에서 UserController는 애플리케이션 서비스다.

Assuming that the external client doesn’t have a specific goal of normalizing user names, and all names are normalized solely due to restrictions from the application itself,  
> 외부 클라이언트가 사용자 이름을 정규화하는 구체적인 목표를 가지지 않고, 모든 이름 정규화가 애플리케이션 내부의 제약 조건 때문에 이루어진다고 가정한다면,

the NormalizeName method in the User class can’t be traced to the client’s needs.  
> User 클래스의 NormalizeName 메서드는 클라이언트의 요구와 연결 지을 수 없다.

Therefore, it’s an implementation detail and should be made private (we already did that earlier in this chapter).  
> 따라서 이는 구현 세부사항이며 private으로 감춰야 한다 (이전 절에서 이미 그렇게 했다).

Moreover, tests shouldn’t check this method directly.  
> 또한 테스트는 이 메서드를 직접 검증해서는 안 된다.

They should verify it only as part of the class’s observable behavior—the Name property’s setter in this example.  
> 대신, 이 동작은 클래스의 관찰 가능한 동작의 일부로서 검증되어야 하며, 이 예에서는 Name 프로퍼티의 setter가 그 예이다.

This guideline of always tracing the code base’s public API to business requirements  
> 코드베이스의 public API를 항상 비즈니스 요구사항에 연결하라는 이 가이드는

applies to the vast majority of domain classes and application services but less so to utility and infrastructure code.  
> 대부분의 도메인 클래스 및 애플리케이션 서비스에는 적용되지만, 유틸리티나 인프라스트럭처 코드에는 덜 적용된다.

The individual problems such code solves are often too low-level and fine-grained and can’t be traced to a specific business use case.  
> 유틸리티나 인프라 코드는 해결하는 문제가 너무 세세하고 저수준이기 때문에, 특정 비즈니스 유스케이스로 추적하기 어렵다.

	
## 5.3.2 Intra-system vs. inter-system communications
	
There are two types of communications in a typical application: intra-system and inter-system.  
> 일반적인 애플리케이션에는 두 가지 유형의 통신이 있다: 시스템 내부 통신(intra-system)과 시스템 간 통신(inter-system)이다.

Intra-system communications are communications between classes inside your application.  
> 시스템 내부 통신은 애플리케이션 내부의 클래스들 간의 통신을 의미한다.

Inter-system communications are when your application talks to other applications (figure 5.11).  
> 시스템 간 통신은 애플리케이션이 다른 애플리케이션과 통신할 때 발생하는 것이다 (그림 5.11 참고).
	
![스크린샷 2025-06-10 07.46.01](https://hackmd.io/_uploads/HkrVEyrmeg.png)

**NOTE**

Intra-system communications are implementation details; inter-system communications are not.  
> 시스템 내부 통신은 구현 세부사항에 해당하지만, 시스템 간 통신은 그렇지 않다.
	
Intra-system communications are implementation details because the collaborations your domain classes go through in order to perform an operation are not part of their observable behavior.  
> 시스템 내부 통신은 구현 세부사항이다. 왜냐하면 도메인 클래스들이 어떤 작업을 수행하기 위해 내부적으로 협력하는 방식은 관찰 가능한 동작에 포함되지 않기 때문이다.

These collaborations don’t have an immediate connection to the client’s goal.  
> 이러한 협력은 클라이언트의 목표와 직접적인 연관이 없다.

Thus, coupling to such collaborations leads to fragile tests.  
> 따라서 이런 협력 방식에 결합된 테스트는 쉽게 깨지는 테스트가 된다.

Inter-system communications are a different matter.  
> 반면, 시스템 간 통신은 다른 문제다.

Unlike collaborations between classes inside your application, the way your system talks to the external world forms the observable behavior of that system as a whole.  
> 애플리케이션 내부 클래스들 간의 협력과 달리, 시스템이 외부 세계와 통신하는 방식은 시스템 전체의 관찰 가능한 동작을 구성한다.

It’s part of the contract your application must hold at all times (figure 5.12).  
> 이것은 애플리케이션이 항상 유지해야 하는 계약의 일부다 (그림 5.12 참고).

This attribute of inter-system communications stems from the way separate applications evolve together.  
> 시스템 간 통신이 관찰 가능한 동작으로 간주되는 이유는, 서로 다른 애플리케이션들이 함께 진화하는 방식에 있다.

One of the main principles of such an evolution is maintaining backward compatibility.  
> 이러한 진화의 주요 원칙 중 하나는 하위 호환성을 유지하는 것이다.

Regardless of the refactorings you perform inside your system, the communication pattern it uses to talk to external applications should always stay in place, so that external applications can understand it.  
> 시스템 내부에서 어떤 리팩토링을 하더라도, 외부 애플리케이션과 통신하는 방식은 항상 유지되어야 외부 시스템이 이를 이해할 수 있다.

For example, messages your application emits on a bus should preserve their structure,  
> 예를 들어, 메시지 버스로 애플리케이션이 전송하는 메시지는 구조를 그대로 유지해야 하며,

the calls issued to an SMTP service should have the same number and type of parameters, and so on.  
> SMTP 서비스로 전송되는 호출은 동일한 개수와 타입의 파라미터를 유지해야 한다.

![스크린샷 2025-06-10 07.46.32](https://hackmd.io/_uploads/rJX8NyH7le.png)

The use of mocks is beneficial when verifying the communication pattern between your system and external applications.  
> 외부 애플리케이션과 시스템 간의 통신 패턴을 검증할 때는 목(mock)을 사용하는 것이 유익하다.

Conversely, using mocks to verify communications between classes inside your system results in tests that couple to implementation details and therefore fall short of the resistance-to-refactoring metric.  
> 반대로, 시스템 내부 클래스들 간의 통신을 검증하기 위해 목을 사용하면 구현 세부사항에 테스트가 결합되고, 그로 인해 리팩토링 저항성이라는 기준을 충족하지 못하게 된다.

## 5.3.3 Intra-system vs. inter-system communications: An example
	
To illustrate the difference between intra-system and inter-system communications, I’ll expand on the example with the Customer and Store classes that I used in chapter 2 and earlier in this chapter.  
> 시스템 내부 통신과 시스템 간 통신의 차이를 설명하기 위해, 2장과 이 장 초반에서 사용한 Customer 클래스와 Store 클래스 예제를 확장해보자.

Imagine the following business use case:  
> 다음과 같은 비즈니스 시나리오를 가정하자.

 A customer tries to purchase a product from a store.  
>  고객이 상점에서 상품을 구매하려고 한다.

 If the amount of the product in the store is sufficient, then  
>  상점에 해당 상품이 충분히 있다면,

– The inventory is removed from the store.  
> – 상점에서 재고가 차감된다.

– An email receipt is sent to the customer.  
> – 고객에게 이메일 영수증이 전송된다.

– A confirmation is returned.  
> – 구매 확인 응답이 반환된다.

Let’s also assume that the application is an API with no user interface.  
> 이 애플리케이션은 사용자 인터페이스 없이 API로만 구성되어 있다고 가정하자.

In the following listing, the CustomerController class is an application service that orchestrates the work between domain classes (Customer, Product, Store) and the external application (EmailGateway, which is a proxy to an SMTP service).  
> 아래 코드에서 CustomerController 클래스는 애플리케이션 서비스 역할을 하며, 도메인 클래스(Customer, Product, Store)와 외부 애플리케이션(EmailGateway, SMTP 서비스 프록시) 간의 작업을 조율한다.
	
#### Listing 5.9 Connecting the domain model with external applications

```
	public class CustomerController
{
public bool Purchase(int customerId, int productId, int quantity)
	{
Customer customer = _customerRepository.GetById(customerId);
Product product = _productRepository.GetById(productId);
bool isSuccess = customer.Purchase(
_mainStore, product, quantity);
if (isSuccess)
{
_emailGateway.SendReceipt(
customer.Email, product.Name, quantity);
}
return isSuccess;
}
}
```
Validation of input parameters is omitted for brevity.  
> 코드의 간결함을 위해 입력 파라미터 검증은 생략되어 있다.

In the Purchase method, the customer checks to see if there’s enough inventory in the store and, if so, decreases the product amount.  
> Purchase 메서드에서는 고객이 상점의 재고를 확인하고, 충분하다면 해당 상품 수량을 차감한다.

The act of making a purchase is a business use case with both intra-system and inter-system communications.  
> 구매 행위는 시스템 내부 통신과 시스템 간 통신이 모두 포함된 비즈니스 유스케이스다.

The inter-system communications are those between the CustomerController application service and the two external systems: the third-party application (which is also the client initiating the use case) and the email gateway.  
> 시스템 간 통신은 CustomerController 애플리케이션 서비스와 두 개의 외부 시스템 간의 통신이다: 유스케이스를 시작한 제3자 애플리케이션(클라이언트)과 이메일 게이트웨이.

The intra-system communication is between the Customer and the Store domain classes (figure 5.13).  
> 시스템 내부 통신은 Customer와 Store 도메인 클래스 간의 상호작용이다 (그림 5.13 참고).

In this example, the call to the SMTP service is a side effect that is visible to the external world and thus forms the observable behavior of the application as a whole.  
> 이 예시에서 SMTP 서비스에 대한 호출은 외부에서 관찰 가능한 사이드 이펙트이며, 따라서 애플리케이션 전체의 관찰 가능한 동작을 구성한다.

![스크린샷 2025-06-10 07.47.45](https://hackmd.io/_uploads/Hy29EyS7ee.png)
	
It also has a direct connection to the client’s goals.  
> 또한, 이 동작은 클라이언트의 목표와 직접적으로 연결되어 있다.

The client of the application is the third-party system.  
> 애플리케이션의 클라이언트는 제3자 시스템이다.

This system’s goal is to make a purchase, and it expects the customer to receive a confirmation email as part of the successful outcome.  
> 이 시스템의 목표는 구매를 완료하는 것이며, 성공적인 결과의 일부로 고객이 확인 이메일을 받는 것을 기대한다.

The call to the SMTP service is a legitimate reason to do mocking.  
> SMTP 서비스 호출은 목(mock)을 사용하는 정당한 이유가 된다.

It doesn’t lead to test fragility because you want to make sure this type of communication stays in place even after refactoring.  
> 이런 종류의 통신이 리팩토링 후에도 유지되는지를 확인하는 것이 목적이기 때문에, 이는 테스트 취약성을 유발하지 않는다.

The use of mocks helps you do exactly that.  
> 목의 사용은 바로 이런 목적을 달성하는 데 도움을 준다.

The next listing shows an example of a legitimate use of mocks  
> 다음 예시는 목을 올바르게 사용한 예를 보여준다.

	
#### Listing 5.10 Mocking that doesn’t lead to fragile tests
	
![스크린샷 2025-06-10 07.48.22](https://hackmd.io/_uploads/rkN641BQxx.png)
	
Note that the isSuccess flag is also observable by the external client and also needs verification.  
> isSuccess 플래그 또한 외부 클라이언트가 관찰할 수 있는 항목이며, 이에 대한 검증이 필요하다.

This flag doesn’t need mocking, though; a simple value comparison is enough.  
> 하지만 이 플래그는 목(mock)을 사용할 필요는 없으며, 단순한 값 비교로도 충분하다.

Let’s now look at a test that mocks the communication between Customer and Store.  
> 이제 Customer와 Store 간의 통신을 목으로 처리한 테스트 예제를 살펴보자.

#### Listing 5.11 Mocking that leads to fragile tests
	
![스크린샷 2025-06-10 07.48.55](https://hackmd.io/_uploads/SyQ1rJSmex.png)

Unlike the communication between CustomerController and the SMTP service, the RemoveInventory() method call from Customer to Store doesn’t cross the application boundary: both the caller and the recipient reside inside the application.  
> CustomerController와 SMTP 서비스 간의 통신과는 달리, Customer에서 Store로의 RemoveInventory() 호출은 애플리케이션 경계를 넘지 않는다. 호출자와 수신자가 모두 애플리케이션 내부에 존재한다.

Also, this method is neither an operation nor a state that helps the client achieve its goals.  
> 또한, 이 메서드는 클라이언트가 목표를 달성하는 데 직접적으로 도움이 되는 동작이나 상태도 아니다.

The client of these two domain classes is CustomerController with the goal of making a purchase.  
> 이 두 도메인 클래스의 클라이언트는 CustomerController이며, 그 목표는 구매를 수행하는 것이다.

The only two members that have an immediate connection to this goal are customer.Purchase() and store.GetInventory().  
> 이 목표와 즉각적으로 연결된 구성요소는 customer.Purchase()와 store.GetInventory()뿐이다.

The Purchase() method initiates the purchase, and GetInventory() shows the state of the system after the purchase is completed.  
> Purchase()는 구매를 시작하고, GetInventory()는 구매 완료 후 시스템의 상태를 보여준다.

The RemoveInventory() method call is an intermediate step on the way to the client’s goal—an implementation detail.  
> RemoveInventory() 호출은 클라이언트의 목표를 달성하기 위한 중간 단계일 뿐이며, 구현 세부사항에 해당한다.

## 5.4 The classical vs. London schools of unit testing,revisited
	
As a reminder from chapter 2 (table 2.1), table 5.2 sums up the differences between the classical and London schools of unit testing.  
> 2장의 표 2.1에서 언급했듯, 표 5.2는 전통(Classical) 학파와 런던(London) 학파의 단위 테스트 방식 간의 차이점을 요약한 것이다.
	
Table 5.2 The differences between the London and classical schools of unit testing
	
![스크린샷 2025-06-10 07.49.49](https://hackmd.io/_uploads/BkdzBkBQxg.png)

In chapter 2, I mentioned that I prefer the classical school of unit testing over the London school. I hope now you can see why.  
> 2장에서 말했듯 나는 런던 학파보다 전통 학파의 단위 테스트 방식을 선호한다고 했는데, 이제 그 이유가 보일 것이다.

The London school encourages the use of mocks for all but immutable dependencies and doesn’t differentiate between intra-system and inter-system communications.  
> 런던 학파는 변경 불가능한 의존성을 제외한 거의 모든 의존성에 대해 목(mock)의 사용을 권장하며, 시스템 내부 통신과 외부 통신을 구분하지 않는다.

As a result, tests check communications between classes just as much as they check communications between your application and external systems.  
> 그 결과 테스트는 클래스 간의 통신도 애플리케이션과 외부 시스템 간의 통신만큼이나 검증하게 된다.

This indiscriminate use of mocks is why following the London school often results in tests that couple to implementation details and thus lack resistance to refactoring.  
> 이러한 무분별한 목 사용 때문에 런던 학파를 따를 경우, 테스트가 구현 세부사항에 결합되고 리팩토링에 취약한 경우가 자주 발생한다.

As you may remember from chapter 4, the metric of resistance to refactoring (unlike the other three) is mostly a binary choice: a test either has resistance to refactoring or it doesn’t.  
> 4장에서 기억하겠지만, 리팩토링에 대한 저항성이라는 기준은 다른 세 가지와 달리 대부분 이분법적이다. 테스트는 리팩토링에 강하든지, 아니면 그렇지 않든지 둘 중 하나다.

Compromising on this metric renders the test nearly worthless.  
> 이 기준을 희생하게 되면 테스트는 거의 무의미해진다.

The classical school is much better at this issue because it advocates for substituting only dependencies that are shared between tests, which almost always translates into out-of-process dependencies such as an SMTP service, a message bus, and so on.  
> 전통 학파는 테스트 간에 공유되는 의존성만 대체하라고 권장하기 때문에 이 문제에 훨씬 더 잘 대처할 수 있다. 이러한 의존성은 거의 항상 SMTP 서비스, 메시지 버스 등과 같은 외부 프로세스 의존성이다.

But the classical school is not ideal in its treatment of inter-system communications, either.  
> 하지만 전통 학파도 외부 시스템 간 통신을 다루는 데 있어 완벽하진 않다.

This school also encourages excessive use of mocks, albeit not as much as the London school.  
> 이 학파 또한 목의 과도한 사용을 조장하긴 하지만, 런던 학파만큼 심하진 않다.

## 5.4.1 Not all out-of-process dependencies should be mocked out
	
Before we discuss out-of-process dependencies and mocking, let me give you a quick refresher on types of dependencies (refer to chapter 2 for more details):  
> 외부 프로세스 의존성과 목(mocking)에 대해 논의하기 전에, 의존성의 유형에 대해 간단히 복습해보자 (자세한 내용은 2장을 참고하라):

 Shared dependency—A dependency shared by tests (not production code)  
>  공유 의존성(Shared dependency) — 테스트들 간에 공유되는 의존성 (프로덕션 코드가 아닌)

 Out-of-process dependency—A dependency hosted by a process other than the program’s execution process (for example, a database, a message bus, or an SMTP service)  
>  외부 프로세스 의존성(Out-of-process dependency) — 애플리케이션 실행 프로세스 외부에서 호스팅되는 의존성 (예: 데이터베이스, 메시지 버스, SMTP 서비스)

 Private dependency—Any dependency that is not shared  
>  프라이빗 의존성(Private dependency) — 공유되지 않는 모든 의존성

The classical school recommends avoiding shared dependencies because they provide the means for tests to interfere with each other’s execution context and thus prevent those tests from running in parallel.  
> 전통 학파는 테스트 간 실행 컨텍스트를 간섭하게 되어 병렬 실행을 방해할 수 있으므로, 공유 의존성은 피하라고 권장한다.

The ability for tests to run in parallel, sequentially, and in any order is called test isolation.  
> 테스트가 병렬, 순차, 임의 순서로 실행될 수 있는 능력을 테스트 격리성(test isolation)이라고 한다.

If a shared dependency is not out-of-process, then it’s easy to avoid reusing it in tests by providing a new instance of it on each test run.  
> 공유 의존성이 외부 프로세스 기반이 아니라면, 테스트마다 새 인스턴스를 제공함으로써 쉽게 재사용을 피할 수 있다.

In cases where the shared dependency is out-of-process, testing becomes more complicated.  
> 하지만 공유 의존성이 외부 프로세스 기반이라면, 테스트는 훨씬 복잡해진다.

You can’t instantiate a new database or provision a new message bus before each test execution; that would drastically slow down the test suite.  
> 매 테스트 실행 전에 새로운 데이터베이스나 메시지 버스를 준비하는 것은 현실적으로 어렵고, 테스트 속도를 급격히 느려지게 만든다.

The usual approach is to replace such dependencies with test doubles—mocks and stubs.  
> 일반적인 접근 방식은 이런 의존성을 테스트 대역(test double)—목(mock)이나 스텁(stub)—으로 대체하는 것이다.

Not all out-of-process dependencies should be mocked out, though.  
> 그러나 모든 외부 프로세스 의존성을 목으로 대체해야 하는 것은 아니다.

If an out-of-process dependency is only accessible through your application, then communications with such a dependency are not part of your system’s observable behavior.  
> 외부 프로세스 의존성이 오직 애플리케이션을 통해서만 접근 가능하다면, 그와의 통신은 시스템의 관찰 가능한 동작에 해당하지 않는다.

An out-of-process dependency that can’t be observed externally, in effect, acts as part of your application (figure 5.14).  
> 외부에서 관찰할 수 없는 외부 프로세스 의존성은 사실상 애플리케이션의 일부처럼 동작한다 (도표 5.14 참고).

Remember, the requirement to always preserve the communication pattern between your application and external systems stems from the necessity to maintain backward compatibility.  
> 애플리케이션과 외부 시스템 간의 통신 패턴을 항상 유지해야 한다는 요구사항은, 하위 호환성(backward compatibility)을 유지해야 하기 때문이다.

You have to maintain the way your application talks to external systems.  
> 애플리케이션이 외부 시스템과 통신하는 방식은 보존되어야 한다.

That’s because you can’t change those external systems simultaneously with your application; they may follow a different deployment cycle, or you might simply not have control over them.  
> 이는 외부 시스템이 애플리케이션과 동시에 변경될 수 없기 때문이다. 배포 주기가 다르거나, 통제할 수 없는 경우가 대부분이다.

But when your application acts as a proxy to an external system, and no client can access it directly, the backward-compatibility requirement vanishes.  
> 하지만 애플리케이션이 외부 시스템에 대한 프록시 역할을 하며, 어떤 클라이언트도 그 외부 시스템에 직접 접근하지 못한다면, 하위 호환성 요구는 사라진다.

Now you can deploy your application together with this external system, and it won’t affect the clients.  
> 이제 애플리케이션과 해당 외부 시스템을 함께 배포해도, 클라이언트에는 영향을 주지 않는다.

The communication pattern with such a system becomes an implementation detail.  
> 이런 시스템과의 통신 방식은 구현 세부사항이 된다.

A good example here is an application database: a database that is used only by your application.  
> 좋은 예로, 애플리케이션 전용 데이터베이스가 있다. 이는 애플리케이션만 사용하는 데이터베이스다.

No external system has access to this database.  
> 어떤 외부 시스템도 이 데이터베이스에 접근할 수 없다.

Therefore, you can modify the communication pattern between your system and the application database in any way you like, as long as it doesn’t break existing functionality.  
> 따라서 기존 기능을 깨뜨리지 않는 한, 이 데이터베이스와의 통신 방식은 자유롭게 수정할 수 있다.

Because that database is completely hidden from the eyes of the clients, you can even replace it with an entirely different storage mechanism, and no one will notice.  
> 해당 데이터베이스는 클라이언트에게 완전히 숨겨져 있으므로, 전혀 다른 저장소 메커니즘으로 교체해도 누구도 알아차리지 못한다.

The use of mocks for out-of-process dependencies that you have a full control over also leads to brittle tests.  
> 이렇게 애플리케이션이 완전한 통제권을 가진 외부 프로세스 의존성에 대해 목을 사용하면, 테스트가 취약해진다.

You don’t want your tests to turn red every time you split a table in the database or modify the type of one of the parameters in a stored procedure.  
> 데이터베이스 테이블을 나누거나, 저장 프로시저의 파라미터 타입을 바꿀 때마다 테스트가 실패하는 상황은 피하고 싶을 것이다.

The database and your application must be treated as one system.  
> 데이터베이스와 애플리케이션은 하나의 시스템으로 간주되어야 한다.

This obviously poses an issue.  
> 물론 이것은 문제를 일으킬 수 있다.

How would you test the work with such a dependency without compromising the feedback speed, the third attribute of a good unit test?  
> 좋은 단위 테스트의 세 번째 속성인 빠른 피드백을 해치지 않으면서, 이런 의존성과의 작업을 어떻게 테스트할 수 있을까?

You’ll see this subject covered in depth in the following two chapters.  
> 이 주제는 다음 두 개의 장에서 깊이 있게 다룰 것이다.

![스크린샷 2025-06-10 07.50.32](https://hackmd.io/_uploads/HkHHBJH7ge.png)
	
## 5.4.2 Using mocks to verify behavior
	
Mocks are often said to verify behavior. In the vast majority of cases, they don’t.  
> 목(mock)은 종종 동작(behavior)을 검증한다고 말하지만, 대부분의 경우 그렇지 않다.

The way each individual class interacts with neighboring classes in order to achieve some goal has nothing to do with observable behavior; it’s an implementation detail.  
> 각 클래스가 어떤 목표를 달성하기 위해 이웃 클래스들과 상호작용하는 방식은 관찰 가능한 동작과는 무관하며, 구현 세부사항에 해당한다.

Verifying communications between classes is akin to trying to derive a person’s behavior by measuring the signals that neurons in the brain pass among each other.  
> 클래스 간의 통신을 검증하는 것은 마치 사람의 행동을 뇌의 뉴런 신호 흐름을 측정해 알아내려는 시도와 같다.

Such a level of detail is too granular.  
> 그런 수준의 디테일은 지나치게 세밀하다.

What matters is the behavior that can be traced back to the client goals.  
> 중요한 것은 클라이언트의 목표로 거슬러 올라갈 수 있는 동작이다.

The client doesn’t care what neurons in your brain light up when they ask you to help.  
> 클라이언트는 당신에게 도움을 요청했을 때 어떤 뉴런이 활성화되는지에 대해 관심이 없다.

The only thing that matters is the help itself—provided by you in a reliable and professional fashion, of course.  
> 중요한 것은 오직 그 요청에 대해 신뢰 가능하고 전문적인 방식으로 제공되는 "도움" 그 자체이다.

Mocks have something to do with behavior only when they verify interactions that cross the application boundary and only when the side effects of those interactions are visible to the external world.  
> 목(mock)은 오직 애플리케이션 경계를 넘는 상호작용을 검증하고, 그 상호작용의 부작용이 외부 세계에 관찰 가능할 때만 동작(behavior)과 관련이 있다.
	
#### Summary

- Test double is an overarching term that describes all kinds of non-production-ready, fake dependencies in tests. There are five variations of test doubles—dummy, stub, spy, mock, and fake—that can be grouped in just two types: mocks and stubs. Spies are functionally the same as mocks; dummies and fakes serve the same role as stubs.  
> 테스트 대역(test double)은 테스트에서 사용되는 비프로덕션용 가짜 의존성을 통칭하는 용어다. 테스트 대역에는 더미(dummy), 스텁(stub), 스파이(spy), 목(mock), 페이크(fake)의 다섯 가지 변형이 있으며, 이들은 두 가지 타입으로 묶을 수 있다: 목과 스텁. 스파이는 기능적으로 목과 동일하고, 더미와 페이크는 스텁과 동일한 역할을 수행한다.

- Mocks help emulate and examine outcoming interactions: calls from the SUT to its dependencies that change the state of those dependencies. Stubs help emulate incoming interactions: calls the SUT makes to its dependencies to get input data.  
> 목은 SUT(System Under Test)가 의존 객체의 상태를 변경하는 방향(outcoming)의 상호작용을 흉내내고 검증하는 데 사용된다. 반면 스텁은 SUT가 의존 객체로부터 데이터를 받아오는 방향(incoming)의 상호작용을 흉내낸다.

- A mock (the tool) is a class from a mocking library that you can use to create a mock (the test double) or a stub.  
> 목(도구)은 모킹 라이브러리의 클래스이며, 이를 사용해 테스트 대역인 목 또는 스텁을 생성할 수 있다.

- Asserting interactions with stubs leads to fragile tests. Such an interaction doesn’t correspond to the end result; it’s an intermediate step on the way to that result, an implementation detail.  
> 스텁과의 상호작용을 검증(assert)하면 테스트가 취약해진다. 이런 상호작용은 최종 결과와 직접적인 연관이 없고, 단지 중간 단계이며 구현 세부사항일 뿐이다.

- The command query separation (CQS) principle states that every method should be either a command or a query but not both. Test doubles that substitute commands are mocks. Test doubles that substitute queries are stubs.  
> CQS(Command Query Separation) 원칙에 따르면, 모든 메서드는 명령(command)이거나 질의(query) 중 하나여야 하며 둘 다일 수는 없다. 명령을 대체하는 테스트 대역은 목이고, 질의를 대체하는 테스트 대역은 스텁이다.

- All production code can be categorized along two dimensions: public API versus private API, and observable behavior versus implementation details.  
> 모든 프로덕션 코드는 두 가지 기준으로 나눌 수 있다: 퍼블릭 API와 프라이빗 API, 그리고 관찰 가능한 동작과 구현 세부사항.

- Code publicity is controlled by access modifiers, such as private, public, and internal keywords. Code is part of observable behavior when it meets one of the following requirements (any other code is an implementation detail):  
> 코드의 공개 여부는 `private`, `public`, `internal` 등의 접근 제어자로 결정된다. 다음 조건 중 하나를 만족하면 그 코드는 관찰 가능한 동작이다 (그 외는 모두 구현 세부사항이다):
  – It exposes an operation that helps the client achieve one of its goals. An operation is a method that performs a calculation or incurs a side effect.  
  > 클라이언트가 어떤 목표를 달성하는 데 도움이 되는 연산을 제공하는 경우. 연산은 계산을 수행하거나 부작용을 일으키는 메서드이다.  
  – It exposes a state that helps the client achieve one of its goals. State is the current condition of the system.  
  > 클라이언트가 목표를 달성하는 데 도움이 되는 상태를 제공하는 경우. 상태는 시스템의 현재 조건을 의미한다.

- Well-designed code is code whose observable behavior coincides with the public API and whose implementation details are hidden behind the private API. A code leaks implementation details when its public API extends beyond the observable behavior.  
> 잘 설계된 코드는 관찰 가능한 동작이 퍼블릭 API와 일치하고, 구현 세부사항이 프라이빗 API에 감춰진 코드다. 퍼블릭 API가 관찰 가능한 동작을 넘어서는 경우, 구현 세부사항이 노출된 것이다.

- Encapsulation is the act of protecting your code against invariant violations. Exposing implementation details often entails a breach in encapsulation because clients can use implementation details to bypass the code’s invariants.  
> 캡슐화(encapsulation)는 코드가 불변 조건(invariant)을 위반하지 않도록 보호하는 것이다. 구현 세부사항을 노출하면 클라이언트가 이를 통해 불변 조건을 우회할 수 있기 때문에, 이는 종종 캡슐화 위반으로 이어진다.

- Hexagonal architecture is a set of interacting applications represented as hexagons. Each hexagon consists of two layers: domain and application services.  
> 헥사고날 아키텍처는 육각형으로 표현된 상호작용하는 애플리케이션들의 집합이다. 각 육각형은 도메인 레이어와 애플리케이션 서비스 레이어의 두 계층으로 구성된다.

- Hexagonal architecture emphasizes three important aspects:  
> 헥사고날 아키텍처는 세 가지 중요한 측면을 강조한다:  
  – Separation of concerns between the domain and application services layers.  
  > 도메인과 애플리케이션 서비스 계층 간의 책임 분리.  
  – A one-way flow of dependencies from the application services layer to the domain layer.  
  > 애플리케이션 서비스에서 도메인 계층으로 향하는 단방향 의존성 흐름.  
  – External applications connect to your application through a common interface maintained by the application services layer.  
  > 외부 애플리케이션은 애플리케이션 서비스 계층이 유지하는 공통 인터페이스를 통해서만 연결된다.

- Each layer in a hexagon exhibits observable behavior and contains its own set of implementation details.  
> 육각형 내 각 계층은 고유한 구현 세부사항을 포함하면서도 관찰 가능한 동작을 나타낸다.

- There are two types of communications in an application: intra-system and inter-system.  
> 애플리케이션 내 통신은 두 가지 유형으로 나뉜다: 시스템 내부 통신(intra-system), 시스템 간 통신(inter-system).

- Intra-system communications are implementation details. Inter-system communications are part of observable behavior, with the exception of external systems that are accessible only through your application.  
> 시스템 내부 통신은 구현 세부사항이며, 시스템 간 통신은 (단, 애플리케이션을 통해서만 접근 가능한 외부 시스템은 제외하고) 관찰 가능한 동작의 일부이다.

- Using mocks to assert intra-system communications leads to fragile tests. Mocking is legitimate only when it’s used for inter-system communications—communications that cross the application boundary—and only when the side effects of those communications are visible to the external world.  
> 내부 통신을 목으로 검증하면 테스트가 취약해진다. 목 사용은 애플리케이션 경계를 넘는 시스템 간 통신을 검증할 때, 그리고 그 상호작용의 부작용이 외부 세계에 관찰될 수 있을 때만 정당하다.
