# 6. 단위 테스트의 스타일

> 📘 **단위 테스트의 스타일**
> - 단위 테스트 스타일 비교
> - 기능형 아키텍처와 헥사고날 아키텍처의 관계
> - 출력 기반 테스트 방식으로의 전환

<br>

4장에서 우리는 좋은 단위 테스트가 갖추어야 할 네 가지 속성—회귀로부터의 보호, 리팩터링에 대한 견고함, 빠른 피드백, 유지 보수성—을 살펴보았다.    
이 네 가지 속성은 특정 테스트나 단위 테스트 접근 방식을 분석할 때 사용할 수 있는 평가 기준이 된다.    
5장에서는 이러한 기준을 사용해 목(mock) 객체를 활용한 접근 방식을 분석했다.   

이번 장에서는 같은 평가 기준을 단위 테스트의 **스타일**이라는 주제에 적용해본다.    
단위 테스트에는 세 가지 스타일이 있다: **출력 기반(output-based)**, **상태 기반(state-based)**, **통신 기반(communication-based)** 테스트.       
이 중 가장 높은 품질의 테스트를 만들어내는 방식은 출력 기반 스타일이며, 그 다음으로 좋은 선택은 상태 기반 테스트다. 통신 기반 테스트는 특별한 경우에만 사용하는 것이 바람직하다.     

문제는, 출력 기반 테스트 스타일을 **모든 곳에 적용할 수는 없다**는 점이다.   
이 방식은 **순수 함수형**으로 작성된 코드에만 적용 가능하다. 하지만 걱정하지 않아도 된다.     
더 많은 테스트를 출력 기반 스타일로 바꿔나갈 수 있도록 도와주는 기법들이 있다. 이를 위해서는 함수형 프로그래밍의 원칙을 활용해 기존 코드를 함수형 아키텍처로 재구성해야 한다.

참고로, 이 장은 함수형 프로그래밍 자체를 깊이 있게 다루지는 않는다.     
그럼에도 이 장을 마치고 나면, 출력 기반 테스트와 함수형 프로그래밍의 관계에 대해 직관적인 이해를 얻게 될 것이다.    
또한 출력 기반 스타일로 더 많은 테스트를 작성하는 방법과, 함수형 프로그래밍 및 함수형 아키텍처가 갖는 한계에 대해서도 배우게 될 것이다.    


## 6.1 단위 테스트의 세 가지 스타일

앞서 장의 서문에서 언급했듯이, 단위 테스트에는 다음과 같은 세 가지 스타일이 있다:   
- **출력 기반 테스트 (Output-based testing)**
- **상태 기반 테스트 (State-based testing)**
- **통신 기반 테스트 (Communication-based testing)**

하나의 테스트 안에서 이 세 가지 스타일 중 하나만 사용할 수도 있고, 두 가지 혹은 세 가지를 조합해서 사용할 수도 있다.     
이번 절에서는 이 장 전체의 기초가 되는 내용을 다룬다. 각 테스트 스타일의 정의와 함께 예제를 통해 설명할 것이며, 이후 절에서는 이 스타일들이 서로 어떻게 비교되는지도 살펴볼 것이다.    

<br>

### 6.1.1 출력 기반 스타일 정의하기

첫 번째 단위 테스트 스타일은 **출력 기반 스타일**이다. 이 방식에서는 테스트 대상 시스템(SUT: System Under Test)에 입력값을 주고, 그 결과로 생성된 **출력값을 검증**한다 (그림 6.1 참조).   
이 스타일은 **글로벌 상태나 내부 상태를 변경하지 않는 코드**에만 적용 가능하다. 따라서 검증해야 할 유일한 요소는 **반환값**이다.


<img width="395" alt="figure 6 1" src="https://github.com/user-attachments/assets/abab142b-4fa5-4824-ae96-f3fdac87a32e" />

> 그림 6.1         
> 출력 기반 테스트에서는 시스템이 생성한 출력값을 검증한다. 이 테스트 스타일은 부작용이 전혀 없으며, 시스템이 수행한 작업의 유일한 결과가 호출자에게 반환되는 값이라고 가정한다.


다음 예제는 이 스타일에 해당하는 코드와 이를 검증하는 테스트를 보여준다.     
`PriceEngine` 클래스는 상품 배열을 입력으로 받아 **할인 금액**을 계산하는 역할을 한다.     

```C#
public class PriceEngine
{
    public decimal CalculateDiscount(params Product[] products)
    {
        decimal discount = products.Length * 0.01m;
        return Math.Min(discount, 0.2m);
     }
}
[Fact]
public void Discount_of_two_products()
{
    var product1 = new Product("Hand wash");
    var product2 = new Product("Shampoo");
    var sut = new PriceEngine();
    
    decimal discount = sut.CalculateDiscount(product1, product2);
    
    Assert.Equal(0.02m, discount);
}
```

`PriceEngine` 클래스는 상품의 개수에 1%를 곱한 값을 할인율로 계산하되, 최대 20%까지만 적용한다. 이 클래스는 그 외에 다른 일을 하지 않는다.       
상품들을 내부 컬렉션에 추가하지도 않고, 데이터베이스에 저장하지도 않는다.       
`CalculateDiscount()` 메서드의 **유일한 결과는 반환된 할인율**, 즉 **출력값**이다 (그림 6.2 참조).      


<img width="381" alt="figure 6 2" src="https://github.com/user-attachments/assets/e17c5b60-347f-42e0-a33e-4c51c6549abd" />

> 그림 6.2               
> 입력-출력 관점에서 본 PriceEngine. CalculateDiscount() 메서드는 상품 배열을 입력받아, 할인율을 계산해 반환한다.


출력 기반 단위 테스트 스타일은 함수형 스타일(functional style)이라고도 불린다.     
이 이름은 함수형 프로그래밍(functional programming)에서 비롯된 것으로, 부작용(side effect)이 없는 코드를 선호하는 프로그래밍 방식이다.        
함수형 프로그래밍과 함수형 아키텍처에 대해서는 이 장의 후반부에서 더 자세히 다룰 예정이다.        

<br>

### 6.1.2 상태 기반 스타일 정의하기

상태 기반 스타일(state-based style)은 어떤 작업이 완료된 **후에 시스템의 상태를 검증**하는 방식이다 (그림 6.3 참조).      
여기서 말하는 "상태(state)"는 테스트 대상 시스템(SUT) 자체의 상태일 수도 있고, 협력 객체 중 하나의 상태이거나, 데이터베이스나 파일 시스템처럼 **프로세스 외부의 의존성** 상태일 수도 있다.

<img width="349" alt="figure 6 3" src="https://github.com/user-attachments/assets/023b1a48-c65c-447c-8b86-3d4b7407e4b2" />

> 그림 6.3               
> 상태 기반 테스트는 작업이 완료된 후 시스템의 최종 상태를 검증한다. 점선 원은 그 최종 상태를 나타낸다.

다음은 상태 기반 테스트의 예시다. Order 클래스는 클라이언트가 새로운 상품을 추가할 수 있도록 한다.

```C#
public class Order
{
    private readonly List<Product> _products = new List<Product>();
    public IReadOnlyList<Product> Products => _products.ToList();
    
    public void AddProduct(Product product)
    {
        _products.Add(product);
    }
}
[Fact]
public void Adding_a_product_to_an_order()
{
    var product = new Product("Hand wash");
    var sut = new Order();
    
    sut.AddProduct(product);
    
    Assert.Equal(1, sut.Products.Count);
    Assert.Equal(product, sut.Products[0]);
}
```

이 테스트는 `AddProduct()` 호출이 끝난 후 **Products 컬렉션의 상태를 검증**한다.     
앞서 [리스트 6.1]의 출력 기반 테스트 예제와는 달리, 이 경우 `AddProduct()` 메서드의 결과는 **반환값이 아닌 주문 객체의 상태 변화**다.   

<br>

### 6.1.3 통신 기반 스타일 정의하기

마지막 세 번째 단위 테스트 스타일은 통신 기반 테스트(communication-based testing)이다.     
이 스타일은 모킹(mock)을 사용하여, 테스트 대상 시스템(SUT)과 그 **협력 객체 간의 통신이 올바르게 이루어졌는지를 검증**한다 (그림 6.4 참조).   


<img width="310" alt="figure 6 4" src="https://github.com/user-attachments/assets/d5211a52-8522-4367-ba59-1ec40e322a4d" />   

> 그림 6.4               
> 통신 기반 테스트에서는 SUT의 협력 객체를 모킹 객체로 대체하고, SUT가 이 협력 객체들을 **정상적으로 호출했는지를 검증**한다.

다음 예시는 통신 기반 테스트가 어떻게 이루어지는지를 보여준다.

```C#
[Fact]
public void Sending_a_greetings_email()
{
    var emailGatewayMock = new Mock<IEmailGateway>();
    var sut = new Controller(emailGatewayMock.Object);
    
    sut.GreetUser("user@email.com");
    
    emailGatewayMock.Verify(
        x => x.SendGreetingsEmail("user@email.com"),
        Times.Once);
}
```

	단위 테스트의 스타일과 학파      
	단위 테스트에는 서로 다른 철학을 가진 두 학파가 있다.
	클래식 학파(Classical school)는 상태 기반 스타일을 선호하는 반면, 런던 학파(London school)는 통신 기반 스타일을 선호한다.        
	두 학파 모두 출력 기반 테스트는 공통적으로 활용한다.

 <br>

 ## 6.2 단위 테스트의 세 가지 스타일 비교하기

출력 기반, 상태 기반, 통신 기반이라는 단위 테스트 스타일 자체는 새로운 개념이 아니다. 사실, 이 책의 앞선 장들에서 이미 이 세 가지 스타일 모두를 살펴본 바 있다.      
흥미로운 점은, 이 세 가지 스타일을 **좋은 단위 테스트의 네 가지 속성**을 기준으로 비교해볼 수 있다는 것이다.        
(이 속성들에 대한 자세한 내용은 4장을 참고하자.)        

다시 한 번 네 가지 속성을 정리하면 다음과 같다:       
- 회귀로부터의 보호(Protection against regressions)
- 리팩터링에 대한 저항력(Resistance to refactoring)
- 빠른 피드백(Fast feedback)
- 유지 보수성(Maintainability)

이 비교에서는 각 속성을 개별적으로 살펴보도록 하겠다.

<br>

### 6.2.1 회귀 방지 및 피드백 속도 관점에서의 스타일 비교 
먼저, **회귀 방지**와 **피드백 속도**라는 두 속성 기준으로 세 가지 테스트 스타일을 비교해보자.        
이 두 속성은 비교적 명확하고 측정이 쉬운 지표다. **회귀로부터의 보호**는 특정 테스트 스타일에 따라 달라지지 않는다.     
이 속성은 다음 세 가지 특성의 조합에 의해 결정된다:      
- 테스트 중 실행되는 코드의 양
- 코드의 복잡도
- 도메인 관점에서의 중요도

일반적으로, 테스트는 실행 범위를 넓게도 좁게도 작성할 수 있다.       
즉, **특정 스타일이 이 측면에서 뚜렷한 이점을 제공하지는 않는다**. 코드의 복잡도나 도메인 중요성도 마찬가지다.         
단, **통신 기반 스타일은 예외적인 상황을 만들 수 있다.**       

이를 과도하게 사용할 경우, **대부분의 코드를 목(mock) 처리하고 얕은 수준만 검증하는 테스트**가 되기 쉽다.       
이러한 피상성은 통신 기반 테스트 스타일 자체의 본질적 특징이라기보다는, **이 기법을 잘못 사용하는 극단적인 사례**에 가깝다.          
**피드백 속도**와 테스트 스타일 간의 상관관계 역시 거의 없다.

테스트가 외부 의존성(out-of-process dependency) — 예: DB, 네트워크 등 — 을 건드리지 않고 유닛 테스트의 영역 내에 머무르는 한, **세 가지 스타일 모두 대체로 비슷한 실행 속도**를 보인다.
물론 통신 기반 테스트는 런타임 시 모킹이 **약간의 지연(latency)** 을 유발할 수 있지만, 테스트 수가 수만 건에 이르지 않는 이상 **그 차이는 거의 무시할 수 있다.**    

<br>

### 6.2.2 리팩터링에 대한 저항력 관점에서의 스타일 비교

리팩터링 저항력은 상황이 다르다. 이 속성은 리팩터링 중 테스트가 얼마나 많은 "거짓 양성(false positive)"— 즉 잘못된 실패—을 발생시키는지를 나타낸다.       
이러한 거짓 양성은, 테스트가 **구현 세부사항(implementation detail)** 에 결합되어 있을 때 발생한다.       
즉, 테스트가 코드의 **외부 동작(behavior)** 이 아닌 **내부 구조**에 의존할수록 더 많은 거짓 양성이 발생한다.        


출력 기반 테스트는 구현 세부사항에 대한 결합도가 가장 낮기 때문에 거짓 양성을 유발할 가능성이 가장 적다.       
이 테스트는 오직 테스트 대상 메서드의 **반환값(output)** 에만 의존한다.     
단, 테스트 대상 메서드 자체가 구현 세부사항일 경우에는 이 제한이 무너질 수 있다.     


**상태 기반 테스트는 상대적으로 거짓 양성에 더 취약하다.**         
이 테스트는 메서드뿐 아니라 객체의 **상태(state)** 도 함께 다룬다. 통계적으로 볼 때, 테스트가 코드와 결합되는 범위가 넓어질수록, **구현 세부사항이 테스트에 노출될 가능성도 높아진다.**
상태 기반 테스트는 더 넓은 API 표면을 다루기에, 결과적으로 **구현 세부사항과 결합될 가능성도 더 크다.**


**통신 기반 테스트는 세 가지 스타일 중 가장 거짓 양성에 취약하다.**       
5장에서 설명했듯이, 대부분의 **더블(test double)과의 상호작용을 검증하는 테스트는 매우 깨지기 쉽다.**       
특히 **스텁(stub)** 과의 상호작용을 검증하는 것은 항상 피해야 한다. 반면, 목(mock) 은 어플리케이션 경계를 넘는 통신을 검증하고 그 결과가 외부 세계에 명확하게 드러나는 경우에만 사용해야 한다.      
결국, **통신 기반 테스트는 리팩터링 저항력을 유지하려면 훨씬 더 많은 주의와 설계적 배려가 필요하다.**    


하지만, 앞서의 얕음(shallowness)과 마찬가지로, 깨지기 쉬움(brittleness)도 통신 기반 스타일의 본질은 아니다.        
테스트가 오직 관찰 가능한 동작(observable behavior)에만 결합되도록 하고, 캡슐화(encapsulation)를 잘 유지한다면 거짓 양성을 최소화할 수 있다.            
다만, 어떤 스타일을 사용하느냐에 따라 이러한 설계적 배려의 수고(due diligence)의 정도는 다르다.

<br>

### 6.2.3 유지보수성(Maintainability) 측면에서의 테스트 스타일 비교

마지막으로, 유지보수성이라는 측정 기준은 유닛 테스트 스타일과 매우 높은 상관관계를 가지고 있다. 하지만 리팩터링 저항성과는 달리, 이를 완화할 수 있는 방법은 많지 않다.      
유지보수성은 유닛 테스트의 유지 관리 비용을 평가하며, 다음 두 가지 특성에 의해 정의된다:      
- 테스트를 이해하기 얼마나 어려운가 (이는 테스트 크기의 함수이다)
- 테스트를 실행하기 얼마나 어려운가 (이는 테스트가 직접 다루는 프로세스 외부 의존성의 수에 따라 결정된다)

테스트가 클수록 유지보수성이 낮아지는데, 이는 테스트를 이해하거나 필요할 때 변경하기가 더 어렵기 때문이다.    
마찬가지로, 하나 이상의 프로세스 외부 의존성(예: 데이터베이스)과 직접적으로 연동되는 테스트는 유지보수성이 낮다.      
왜냐하면, 그 테스트들을 유지하기 위해 데이터베이스 서버를 재시작하거나 네트워크 연결 문제를 해결하는 등의 시간과 노력이 필요하기 때문이다.       


**출력 기반 테스트의 유지보수성**      
다른 두 가지 테스트 방식과 비교했을 때, 출력 기반 테스트는 가장 유지보수성이 높다.         
이러한 테스트는 거의 항상 짧고 간결하며, 따라서 유지하기 더 쉽다.       
출력 기반 스타일의 이러한 장점은 이 스타일이 본질적으로 두 가지 작업으로만 구성되어 있기 때문이다:     
메서드에 입력을 제공하고, 그 출력 값을 검증하는 것이다.           

이는 종종 단 몇 줄의 코드로도 구현할 수 있다.      
출력 기반 테스트에서의 기반 코드는 전역 상태나 내부 상태를 변경하지 않아야 하므로, 이러한 테스트는 프로세스 외부 의존성과는 무관하다.       
따라서 출력 기반 테스트는 유지보수성과 관련된 두 가지 특성 모두에서 가장 우수하다.


**상태 기반 테스트의 유지보수성**        
상태 기반 테스트는 보통 출력 기반 테스트보다 유지보수성이 낮다.        
그 이유는 상태를 검증하는 작업이 출력 검증보다 더 많은 공간을 차지하는 경우가 많기 때문이다.        
다음은 상태 기반 테스트의 또 다른 예시이다:      

```C#
[Fact]
public void Adding_a_comment_to_an_article()
{
    var sut = new Article();
    var text = "Comment text";
    var author = "John Doe";
    var now = new DateTime(2019, 4, 1);
    
    sut.AddComment(text, author, now);
    
    // Verifies the state of the article
    Assert.Equal(1, sut.Comments.Count);
    Assert.Equal(text, sut.Comments[0].Text);
    Assert.Equal(author, sut.Comments[0].Author);
    Assert.Equal(now, sut.Comments[0].DateCreated);
}
```

이 테스트는 기사에 댓글을 추가한 뒤, 해당 댓글이 그 기사에 속한 댓글 리스트에 실제로 존재하는지를 확인한다.     
이 테스트는 단일 댓글만을 다루는 간단한 형태지만, 그 단정(assertion) 부분만 해도 이미 4줄에 걸쳐 있다.     
상태 기반 테스트는 보통 그보다 훨씬 많은 데이터를 검증해야 하므로, 크기가 훨씬 커질 수 있다.       

이 문제를 완화하는 방법 중 하나는 헬퍼 메서드를 도입하여 테스트 코드 대부분을 숨기고 테스트 자체를 짧게 만드는 것이다 (Listing 6.5 참조).    
하지만 이러한 메서드를 작성하고 유지하는 데는 상당한 노력이 필요하다.       
이러한 노력이 정당화되는 경우는 그 헬퍼 메서드가 여러 테스트에서 재사용될 때뿐이며, 실제로 그런 경우는 드물다.     
헬퍼 메서드에 대해서는 이 책의 Part 3에서 더 자세히 설명할 것이다.      

```C#
[Fact]
public void Adding_a_comment_to_an_article()
{
    var sut = new Article();
    var text = "Comment text";
    var author = "John Doe";
    var now = new DateTime(2019, 4, 1);
    
    sut.AddComment(text, author, now);
    
    // Helper methods
    sut.ShouldContainNumberOfComments(1)
        .WithComment(text, author, now);
}
```

상태 기반 테스트를 간략하게 만드는 또 다른 방법은, 단정 대상이 되는 클래스에 equality 멤버를 정의하는 것이다.      
Listing 6.6에서는 그 대상이 `Comment` 클래스이다.      
이 클래스를 값 객체(value object, 인스턴스가 참조가 아니라 값으로 비교되는 클래스)로 바꿀 수 있으며, 아래는 그 예시이다.        
이렇게 하면 테스트가 더 간단해질 수 있다. 특히, Fluent Assertions 같은 단정 라이브러리와 함께 사용하면 더욱 그렇다.        

```C#
[Fact]
public void Adding_a_comment_to_an_article()
{
    var sut = new Article();
    var comment = new Comment(
        "Comment text",
        "John Doe",
        new DateTime(2019, 4, 1));
		
		sut.AddComment(comment.Text, comment.Author, comment.DateCreated);
    
    sut.Comments.Should().BeEquivalentTo(comment);
}
```

이 테스트는 댓글들이 전체 값으로 비교될 수 있다는 점을 활용한다. 따라서 각 속성(property)을 일일이 단정하지 않아도 된다.      
또한, Fluent Assertions의 `BeEquivalentTo` 메서드를 사용하여 컬렉션 전체를 비교할 수 있어, 컬렉션 크기를 따로 확인할 필요도 없다.       
이 기술은 매우 강력하지만, 해당 클래스가 본질적으로 값(value)인 경우에만 적용 가능하며, 그런 경우에만 값 객체로의 변환이 타당하다.       
그렇지 않으면 코드 오염(code pollution)으로 이어지게 된다. (즉, 단지 테스트를 가능하게 하거나, 이 경우처럼 테스트를 단순화하기 위해 프로덕션 코드에 불필요한 코드가 들어가게 되는 것이다.)     

이와 같은 코드 오염 문제는 유닛 테스트 안티패턴들과 함께 11장에서 더 자세히 다룰 예정이다.     
보시다시피, 이러한 두 가지 기법—헬퍼 메서드 사용과 클래스의 값 객체화—는 경우에 따라 제한적으로만 적용 가능하다.      
그리고 이러한 기법들이 적용 가능하더라도, 상태 기반 테스트는 여전히 출력 기반 테스트보다 코드량이 많고, 그만큼 유지보수성이 떨어진다.      


**커뮤니케이션 기반 테스트의 유지보수성**        
커뮤니케이션 기반 테스트는 유지보수성 측면에서 출력 기반과 상태 기반 테스트보다 점수가 더 낮다.        
커뮤니케이션 기반 테스트는 테스트 대역(test double)을 설정하고, 상호작용 단정을 작성해야 하며, 이 과정에서 많은 코드가 필요하다.         
만약 mock chain(모의 객체나 스텁이 또 다른 모의 객체를 반환하고, 그것이 다시 또 다른 mock을 반환하는 식의 여러 계층 깊이를 가진 구조)을 사용하게 되면, 테스트는 더욱 커지고 유지보수성이 떨어지게 된다.       


<br>

### 6.2.4 스타일 비교: 결과
이제 좋은 단위 테스트의 속성을 사용하여 단위 테스트 스타일들을 비교해 보자.   
표 6.1은 비교 결과를 요약한 것이다. 6.2.1절에서 논의했듯이, 세 가지 스타일 모두 회귀로부터의 보호와 피드백 속도라는 측정 기준에서는 동일한 점수를 받는다.      
따라서 이 두 측정 기준은 비교에서 생략한다.

|  | output-based | state-based | communication-based |
| --- | --- | --- | --- |
| 리팩토링 저항성을 유지하기 위한 충분한 주의(또는 신중함) | 낮음 | 중간 | 중간 |
| 유지보수 비용 | 낮음 | 중간 | 높음 |

**출력 기반 테스트(output-based testing)** 가 가장 좋은 결과를 보여준다.    
이 스타일은 구현 세부사항에 거의 결합되지 않는 테스트를 만들어내기 때문에 리팩터링에 대한 저항성을 유지하기 위해 많은 주의가 필요하지 않다.     
또한, 이러한 테스트는 간결하고 외부 프로세스 의존성이 없기 때문에 유지보수 측면에서도 가장 뛰어나다.

**상태 기반 테스트(state-based testing)** 와 **통신 기반 테스트(communication-based testing)** 는 두 측정 기준 모두에서 더 나쁜 결과를 보인다.         
이 테스트들은 구현 세부사항이 누출될 가능성이 더 높고, 테스트 크기가 크기 때문에 유지 관리 비용이 더 많이 든다.    
 
항상 출력 기반 테스트를 가장 우선적으로 선택하라. 안타깝게도 말처럼 쉽지는 않다.     
이 단위 테스트 스타일은 순수 함수형 방식으로 작성된 코드에만 적용할 수 있는데, 이는 대부분의 객체지향 프로그래밍 언어에서는 드문 경우다.     
그럼에도 불구하고, 더 많은 테스트를 출력 기반 스타일로 전환할 수 있도록 도와주는 기술들이 있다.

이 장의 나머지 부분에서는 상태 기반 테스트나 협력 기반 테스트(communication-based)를 출력 기반 테스트로 전환하는 방법을 보여준다.        
이 전환은 코드를 더 순수하게 함수형으로 만들어야 하며, 그렇게 하면 상태 기반이나 통신 기반 테스트 대신 출력 기반 테스트를 사용할 수 있게 된다.    

<br>

## 6.3 함수형 아키텍처 이해하기
전환 방법을 보여주기 전에 약간의 기초 작업이 필요하다. 
이 절에서는 함수형 프로그래밍과 함수형 아키텍처가 무엇인지, 그리고 후자가 헥사고날 아키텍처(hexagonal architecture)와 어떻게 관련되어 있는지를 살펴본다.     
6.4절에서는 예제를 사용하여 그 전환 과정을 설명한다.

이것은 함수형 프로그래밍에 대한 깊은 탐구는 아니며, 그보다는 함수형 프로그래밍의 기본 원리를 설명하려는 것이다.    
이 기본 원리만으로도 함수형 프로그래밍과 출력 기반 테스트의 연결을 이해하는 데 충분할 것이다.    
함수형 프로그래밍을 더 깊이 알아보고 싶다면 [Scott Wlaschin의 웹사이트 및 책](https://fsharpforfunandprofit.com/books)을 참고하라.

<br>

### 6.3.1 함수형 프로그래밍이란?
6.1.1절에서 언급했듯이, 출력 기반 단위 테스트 스타일은 **함수형 스타일**이라고도 한다.     
이는 해당 테스트 스타일이 **순수 함수형 방식**으로 작성된 실제 코드에 의존하기 때문이다. 그렇다면 함수형 프로그래밍이란 무엇일까?

함수형 프로그래밍이란 **수학적 함수**(mathematical function)를 이용한 프로그래밍을 말한다.        
수학적 함수(순수 함수라고도 함)는 숨겨진 입력이나 출력이 없는 함수(또는 메서드)이다. 수학적 함수의 모든 입력과 출력은 메서드 시그니처(method signature)에 명시적으로 표현되어야 하며, 이 시그니처는 메서드의 이름, 인자, 반환 타입으로 구성된다. 수학적 함수는 같은 입력에 대해 항상 같은 출력을 반환한다.

예를 들어, listing 6.1에서의 `CalculateDiscount()` 메서드를 살펴보자.

```C#
public decimal CalculateDiscount(Product[] products)
{
    decimal discount = products.Length * 0.01m;
    return Math.Min(discount, 0.2m);
}
```

이 메서드는 하나의 입력(Product 배열)과 하나의 출력(할인값 decimal)을 가지고 있으며, 이 둘은 모두 메서드 시그니처에 명시적으로 표현되어 있다.    
숨겨진 입력이나 출력은 없다. 이 때문에 CalculateDiscount()는 수학적 함수이다.

<img width="385" alt="figure 6 5" src="https://github.com/user-attachments/assets/553cbe73-e9cf-41ac-9e36-8df7a42cd5de" />

> 그림 6.5       
> `CalculateDisCount()` 하나의 입력(제품 배열)과 하나의 출력(할인값)을 가진다. 이 입력과 출력은 모두 메서드 시그니처에 명시되어 있으므로, 이 메서드는 수학적 함수이다.

숨겨진 입력과 출력이 없는 메서드는 수학적 함수라고 불리며, 이는 수학에서 함수가 갖는 정의를 따르기 때문이다.   

> **정의**      
수학에서 함수란 두 집합 간의 관계로, 첫 번째 집합의 각 요소에 대해 두 번째 집합의 정확히 하나의 요소를 찾는 것이다.

<img width="240" alt="figure 6 6" src="https://github.com/user-attachments/assets/f73f31a9-60dc-49d6-b637-832e4385c9d8" />

> 그림 6.6       
> 수학에서 흔한 함수의 예는 f(x) = x + 1이다. 입력 집합 X의 각 x에 대해, 함수는 출력 집합 Y의 y를 찾는다.

<img width="388" alt="figure 6 7" src="https://github.com/user-attachments/assets/d3a7a114-2c3e-4ee4-bd07-03132f5a9a3a" />

> 그림 6.7       
> `CalculateDiscount()` 메서드를 f(x) = x + 1과 같은 표기법으로 표현한 것. 입력된 제품 배열마다, 해당하는 할인값을 출력한다.

명시적인 입력과 출력은 수학적 함수를 매우 테스트하기 좋게 만든다.    
그 결과, 테스트는 짧고 간단하며 이해하고 유지 관리하기 쉽다. 수학적 함수는 **출력 기반 테스트를 적용할 수 있는 유일한 종류의 메서드**이며, 유지보수성이 가장 높고, 잘못된 양성(false positive)이 발생할 확률이 가장 낮다.

반면, 숨겨진 입력과 출력은 코드를 덜 테스트 가능하게 만든다 (또한 가독성도 떨어진다). 이러한 숨겨진 입력과 출력의 예는 다음과 같다:    
- **사이드 이펙트(side effect)** — 메서드 시그니처에 표현되지 않은 출력이며, 따라서 숨겨진 것이다. 예를 들어 클래스 인스턴스의 상태를 변경하거나, 디스크의 파일을 업데이트하는 작업 등은 사이드 이펙트를 일으킨다.
- **예외(exception)** — 메서드가 예외를 던지면, 메서드 시그니처로 표현된 계약을 우회하는 실행 경로가 생긴다. 이 예외는 호출 스택 어디에서든 잡힐 수 있으므로, 시그니처에 명시되지 않은 출력이 추가된다.
- **내부 또는 외부 상태에 대한 참조** — 예를 들어, 메서드가 `DateTime.Now`와 같은 정적 속성을 사용해 현재 시간을 얻거나, 데이터베이스에서 데이터를 조회하거나, private 가변 필드에 접근하는 경우 등이 있다. 이들은 실행 흐름에 영향을 주는 입력이지만 시그니처에 나타나지 않으므로 숨겨진 입력이다.

메서드가 수학적 함수인지 판단하는 좋은 기준은, 그 메서드 호출을 반환 값으로 대체해도 프로그램의 동작이 변하지 않는지 여부를 보는 것이다. 이런 대체 가능성을 **참조 투명성(referential transparency)** 이라고 한다.     
다음 예제를 보자   
```C#
public int Increment(int x)
{
    return x + 1;
}
```

이 메서드는 수학적 함수이다. 다음 두 문장은 동일하다:
```C#
int y = Increment(4);
int y = 5;
```

반면, 다음 메서드는 수학적 함수가 아니다. 반환값으로 대체할 수 없기 때문이다. 반환값은 메서드의 모든 출력을 대표하지 않으며, 이 예에서는 x 필드의 변경이 숨겨진 출력이다:
```C#
int x = 0;
public int Increment()
{
    x++;
    return x;
}
```

사이드 이펙트는 가장 흔한 숨겨진 출력 형태이다.   
다음은 AddComment라는 메서드를 보여주는 예로, 겉보기에는 수학적 함수 같지만 실제로는 그렇지 않다. 그림 6.8이 메서드를 시각적으로 보여준다.

```C#
public Comment AddComment(string text)
{
    var comment = new Comment(text);
    _comments.Add(comment); // Side effect
     return comment;
}
```

<img width="237" alt="figure 6 8" src="https://github.com/user-attachments/assets/b054e68f-5a58-4d3a-912a-a88ff42eea0c" />

> 그림 6.8       
> AddComment 메서드(도식에서는 f로 표시됨)는 텍스트 입력값과 Comment 출력값을 가지며, 이 둘은 모두 메서드 시그니처에 명시되어 있다. 이 외에 부가적으로 숨겨진 출력값(부작용)이 존재한다.


<br>

### 6.3.2 함수형 아키텍처란 무엇인가?
물론, 어떤 종류의 부작용도 발생하지 않는 애플리케이션을 만드는 것은 불가능하다. 그런 애플리케이션은 현실적으로 무용지물일 것이다.      
결국, 부작용은 우리가 애플리케이션을 만드는 이유이기 때문이다 — 예를 들어 사용자의 정보를 업데이트하거나, 장바구니에 주문 항목을 추가하는 것 등이 모두 부작용이다.        

함수형 프로그래밍의 목적은 부작용을 완전히 제거하는 것이 아니라, 비즈니스 로직을 처리하는 코드와 부작용을 일으키는 코드를 분리하는 데 있다.     
이 두 책임은 그 자체로도 충분히 복잡하기 때문에, 이들을 섞어버리면 복잡성이 배가되고 장기적으로 유지보수가 어려워진다. 바로 이 지점에서 **함수형 아키텍처**가 등장한다.   
함수형 아키텍처는 부작용을 비즈니스 작업의 가장자리에 밀어냄으로써, 비즈니스 로직과 부작용을 분리한다.

> 정의       
> 함수형 아키텍처는 순수 함수형(불변) 방식으로 작성된 코드의 양을 최대화하고, 부작용을 다루는 코드의 양을 최소화하는 구조이다.
> 여기서 불변(immutable)이란 변경 불가능하다는 의미이다. 객체가 한 번 생성되면 그 상태는 더 이상 변경될 수 없다.
> 이는 생성 이후에도 상태 변경이 가능한 가변 객체(mutable object)와 대조된다.


비즈니스 로직과 부작용의 분리는 다음 두 가지 유형의 코드를 분리함으로써 이루어진다:  
- **결정을 내리는 코드** — 이 코드는 부작용을 필요로 하지 않으며, 따라서 수학적 함수로 작성할 수 있다.
- **그 결정을 실행에 옮기는 코드** — 이 코드는 수학적 함수가 내린 모든 결정을 외부에 드러나는 방식으로 바꾼다. 예를 들면 데이터베이스의 변화나 메시지 전송 등이 있다.

결정을 내리는 코드는 흔히 *함수형 코어(functional core)* 또는 불변 코어(immutable core)라고 불린다.    
이 결정들을 실행하는 코드는 가변 셸(mutable shell)이라 불린다. (그림 6.9 참고)

<img width="284" alt="figure 6 9" src="https://github.com/user-attachments/assets/e7d2cf85-4f01-4f4d-b272-bd2f5b77f643" />

> 그림 6.9       
> 함수형 아키텍처에서는, 함수형 코어가 수학적 함수를 기반으로 구현되어 애플리케이션 내의 모든 결정을 내린다. 가변 셸은 이 함수형 코어에 입력 데이터를 제공하고, 그 결정들을 외부 의존성(예: 데이터베이스)에 대한 부작용으로 해석하여 실행한다.

함수형 코어와 가변 셸은 다음과 같은 방식으로 협력한다:     
- 가변 셸이 모든 입력값을 수집한다.
- 함수형 코어가 그에 따른 결정을 생성한다.
- 셸이 그 결정을 부작용으로 전환한다.

이 두 계층 간의 올바른 분리를 유지하려면, **결정을 표현하는 클래스들이 가변 셸이 따로 판단을 내리지 않고도 실행할 수 있을 만큼 충분한 정보를 담고 있어야 한다.**    
다시 말해, 가변 셸은 가능한 한 "멍청하게(dumb)" 만들어야 한다. 이상적인 목표는 함수형 코어를 **출력 기반 테스트(output-based tests)** 로 폭넓게 테스트하고, 가변 셸은 **소수의 통합 테스트(integration tests)** 만으로 커버하는 것이다.


**캡슐화와 불변성**       
함수형 아키텍처(전반적으로)와 불변성(특히)은 단위 테스트와 마찬가지로 **소프트웨어 프로젝트의 지속 가능한 성장**을 위한 도구다.    
사실, *캡슐화(encapsulation)* 와 *불변성(immutability)* 은 깊은 연관이 있다.     
5장에서 다룬 내용을 기억한다면, 캡슐화는 코드가 일관성을 잃지 않도록 보호하는 행위였다.     
캡슐화는 클래스 내부 상태의 손상을 다음과 같은 방식으로 방지한다:      
- 데이터를 변경할 수 있는 API의 범위를 줄이고
- 남은 API들에 대해서는 엄격한 제약을 부여한다

반면, 불변성은 클래스의 불변 조건(invariant)을 보존하는 문제를 완전히 다른 각도에서 해결한다. 불변 객체에서는 애초에 상태를 변경할 수 없기 때문에, 상태가 손상될 가능성 자체가 없다.       
그 결과, 함수형 프로그래밍에서는 캡슐화 자체가 필요 없어지게 된다. 객체의 상태를 생성 시점에 한 번만 검증하면 이후에는 안심하고 아무 곳에나 전달할 수 있다.     
모든 데이터가 불변이라면, 캡슐화 부족으로 발생하는 문제들은 그 자체로 사라진다.       
이에 대해 마이클 페더스(Michael Feathers)의 명언이 있다:    
> 객체지향 프로그래밍은 '움직이는 부품(moving parts)'을 캡슐화함으로써 코드를 이해 가능하게 만든다.
> 함수형 프로그래밍은 '움직이는 부품'의 수를 최소화함으로써 코드를 이해 가능하게 만든다.


<br>

### 6.3.3 함수형 아키텍처와 육각형 아키텍처 비교하기
함수형 아키텍처와 육각형 아키텍처는 공통점이 많다. 두 아키텍처 모두 **관심사의 분리(separation of concerns)** 를 핵심 개념으로 삼는다.   
다만, 그 분리를 어떻게 실현하느냐의 방식에는 차이가 있다.

5장에서 다뤘듯, 육각형 아키텍처에서는 **도메인 계층(domain layer)** 과 **애플리케이션 서비스 계층(application services layer)** 을 분리한다. (그림 6.10 참고)

<img width="314" alt="figure 6 10" src="https://github.com/user-attachments/assets/c40ba96f-3eb9-4dad-af78-cb1e2caca375" />

> 그림 6.10       
> 육각형 아키텍처는 여러 애플리케이션(=육각형)의 상호작용으로 구성된다. 하나의 애플리케이션은 도메인 계층과 애플리케이션 서비스 계층으로 구성되며, 이는 함수형 아키텍처에서의 함수형 코어 와 가변 셸 에 해당한다.


도메인 계층은 비즈니스 로직을 책임지고, 서비스 계층은 데이터베이스나 SMTP 서비스처럼 외부 애플리케이션과의 통신을 담당한다.     
이 구조는 함수형 아키텍처에서 **결정(decision)** 과 **행동(action)** 을 나누는 방식과 매우 유사하다.      
또 다른 공통점은 **단방향 의존성(one-way dependency)** 이다.       

육각형 아키텍처에서는 도메인 계층 내의 클래스들만 서로 의존할 수 있으며, 서비스 계층의 클래스를 참조해서는 안 된다.      
마찬가지로 함수형 아키텍처에서도 **불변 코어는 가변 셸에 의존하지 않는다.**      
불변 코어는 외부 계층과 무관하게 독립적으로 작동할 수 있으며, 이는 곧 **테스트 용이성(testability)** 으로 이어진다.       

가변 셸 없이도 불변 코어를 테스트할 수 있고, 셸이 제공할 입력을 단순한 값으로 시뮬레이션하면 된다.      
하지만 두 아키텍처가 **부작용을 다루는 방식에는 차이점**이 있다.     
함수형 아키텍처는 모든 부작용을 비즈니스 작업의 가장자리로 밀어내어 **불변 코어에서 분리**한다.     

반면, 육각형 아키텍처에서는 **도메인 계층 안에서 발생하는 부작용을 허용**한다 — 단, 그 부작용이 도메인 계층을 벗어나지 않는 한에서만.    
예를 들어, 도메인 클래스의 인스턴스는 데이터베이스에 직접 저장할 수는 없지만, **자기 자신의 상태를 변경하는 것**은 가능하다.        
이후 애플리케이션 서비스 계층이 해당 변경 사항을 감지하고 데이터베이스에 반영하게 된다.      

> 참고      
> 함수형 아키텍처는 육각형 아키텍처의 하위 집합(subset) 으로 볼 수 있다.            
> 즉, 함수형 아키텍처는 육각형 아키텍처의 철학을 극단적으로 밀어붙인 형태다.


<br>


## 6.4 함수형 아키텍처로 전환하기와 출력 기반 테스트
이번 절에서는 예제 애플리케이션을 함수형 아키텍처로 리팩터링하는 과정을 살펴본다. 이 과정은 다음 두 단계로 나뉜다:    
- 외부 프로세스 의존성을 사용하던 코드를 **목(mock)** 으로 전환하기
- 목을 사용하던 테스트 코드를 **함수형 아키텍처 기반으로 리팩터링** 하기

이러한 전환은 **테스트 코드에도 영향을 준다!** 우리는 상태 기반 테스트(state-based test)나 통신 기반 테스트(communication-based test)를 **출력 기반 테스트(output-based test)** 스타일로 바꿔나갈 것이다.       
리팩터링을 시작하기에 앞서, 예제 프로젝트와 그것을 커버하는 테스트들을 간략히 살펴보자.

<br>

### 6.4.1 감사 시스템 소개
이 장에서는 조직 내의 모든 방문자를 기록하는 감사 시스템(audit system)을 예제로 사용합니다.       
해당 시스템은 그림 6.11에 나와 있는 구조처럼, 텍스트 파일을 기본 저장소로 사용합니다.      

시스템은 방문자의 이름과 방문 시간을 가장 최근 파일의 끝에 추가합니다. 그리고 파일당 최대 항목 수에 도달하면, 인덱스가 증가된 새 파일을 생성합니다.      

<img width="233" alt="figure 6 11" src="https://github.com/user-attachments/assets/220714ce-90fa-4e62-84f8-f9a506f66b3c" />

> 그림 6.11       
> 감사 시스템은 방문자 정보를 특정 형식의 텍스트 파일에 저장합니다. 한 파일에 들어갈 수 있는 최대 항목 수에 도달하면, 시스템은 새로운 파일을 생성합니다.


다음 코드는 감사 시스템의 초기 버전을 보여줍니다.   

```C#
public class AuditManager
{
    private readonly int _maxEntriesPerFile;
    private readonly string _directoryName;
    
    public AuditManager(int maxEntriesPerFile, string directoryName)
    {
        _maxEntriesPerFile = maxEntriesPerFile;
        _directoryName = directoryName;
    }
    
    public void AddRecord(string visitorName, DateTime timeOfVisit)
		{
		    string[] filePaths = Directory.GetFiles(_directoryName);
		    (int index, string path)[] sorted = SortByIndex(filePaths);
		    
		    string newRecord = visitorName + ';' + timeOfVisit;
		    
		    if (sorted.Length == 0)
		    {
		        string newFile = Path.Combine(_directoryName, "audit_1.txt");
		        File.WriteAllText(newFile, newRecord);
		        return;
				}
		    (int currentFileIndex, string currentFilePath) = sorted.Last();
		    List<string> lines = File.ReadAllLines(currentFilePath).ToList();
		    
		    if (lines.Count < _maxEntriesPerFile)
		    {
		        lines.Add(newRecord);
		        string newContent = string.Join("\r\n", lines);
		        File.WriteAllText(currentFilePath, newContent);
				} 
				else 
				{
						int newIndex = currentFileIndex + 1;
						string newName = $"audit_{newIndex}.txt";
						string newFile = Path.Combine(_directoryName, newName);
						File.WriteAllText(newFile, newRecord);
				} 
		}
}
```

코드가 다소 길어 보일 수 있지만, 구조 자체는 꽤 단순합니다. 이 시스템의 핵심 클래스는 `AuditManager`입니다. 이 클래스의 생성자는 파일당 최대 항목 수와 작업 디렉터리 경로를 설정 값으로 받습니다.     
클래스에는 `AddRecord`라는 **하나의 퍼블릭 메서드**만 존재하며, 이 메서드가 감사 시스템의 주요 동작을 모두 처리합니다.      

`AddRecord` 메서드의 작업 흐름은 다음과 같습니다:     
- 작업 디렉터리에서 **모든 파일 목록을 가져옵니다**.
- 파일 이름 패턴(`audit_{index}.txt` 예: `audit_1.txt`)을 기준으로 **파일을 인덱스 순서대로 정렬합니다**.
- **감사 파일이 존재하지 않으면**, 새 파일을 생성하고 **첫 기록을 작성합니다**.
- **감사 파일이 이미 존재하는 경우**, **가장 최근 파일을 가져온 뒤**, 해당 파일의 항목 수가 **최대치에 도달했는지 여부에 따라,** 기록을 **기존 파일에 추가하거나**, **새 파일을 생성합니다**.

하지만 `AuditManager` 클래스는 현재 구조상 **테스트하기가 어렵습니다**. 이유는 클래스가 **파일 시스템과 강하게 결합되어 있기 때문입니다**.       
테스트를 실행하기 전에는 **알맞은 위치에 테스트용 파일을 준비**해야 하고, 테스트가 끝난 후에는 **파일을 읽어 내용이 올바른지 확인한 뒤 정리**해야 합니다.

<img width="366" alt="figure 6 12" src="https://github.com/user-attachments/assets/8714c18f-830d-4449-94d1-155d449ab173" />

> 그림 6.12       
> 현재 감사 시스템 버전에 대한 테스트는 파일 시스템과 직접 상호작용해야만 합니다.


이러한 테스트는 병렬 실행이 불가능하거나, 가능하더라도 유지보수 비용이 상당히 증가하게 됩니다.      
그 이유는 파일 시스템이 공유 자원이기 때문입니다. 공유된 의존성으로 인해, 테스트들이 서로의 실행 흐름에 영향을 줄 수 있습니다.          
또한 파일 시스템을 사용하는 테스트는 속도가 느려질 수 있으며, 테스트 환경의 유지보수성도 떨어집니다.   
예를 들어, 작업 디렉터리가 존재하고, 테스트가 해당 디렉터리에 접근할 수 있도록 **로컬 개발 환경과 빌드 서버 모두에서 설정을 맞춰야** 합니다.      
아래 표는 **좋은 테스트의 네 가지 속성 중 두 가지**에서, 현재 감사 시스템의 초기 버전이 **낮은 점수를 받는다는 점을 요약**합니다.       

> 표 6.2    
> 감사 시스템의 초기 버전은 테스트 관점에서 아쉬운 점이 많습니다.

|  | 초기 버전 |
| --- | --- |
| 회귀(버그)로부터의 보호 | 좋음 |
| 리팩토링에 대한 저항력 | 좋음 |
| 빠른 피드백 | 나쁨 |
| 유지보수성 | 나쁨 |

참고로, **파일 시스템과 직접 상호작용하는 테스트**는 **단위 테스트**(unit test)의 정의에 부합하지 않습니다.      
이러한 테스트는 **단위 테스트의 두 번째와 세 번째 속성**을 만족하지 못하므로, 사실상 **통합 테스트**(integration test)로 분류되어야 합니다. (자세한 내용은 2장에서 다루었습니다.)      

단위 테스트란 다음과 같은 특성을 갖추어야 합니다:    
- **하나의 동작 단위를 검증**하고,
- **빠르게 실행되며**,
- **다른 테스트와 격리되어 독립적으로 실행**되어야 합니다.

<br>

### 6.4.2 목(mock)을 활용하여 테스트와 파일 시스템의 결합을 분리하기

테스트가 파일 시스템과 강하게 결합되어 있는 문제를 해결하는 일반적인 방법은, **파일 시스템을 목(mock) 객체로 대체하는 것**입니다.        
이 방법에서는 파일에 대한 모든 작업을 별도의 클래스로 추출하고, 예를 들어 `IFileSystem`이라는 인터페이스로 정의한 뒤, 이를 `AuditManager` 클래스에 **생성자를 통해 주입**합니다.      
테스트에서는 이 인터페이스를 **목(mock) 객체로 대체**하여, 감사 시스템이 파일에 어떤 데이터를 기록하는지를 캡처할 수 있습니다.      

<img width="314" alt="figure 6 13" src="https://github.com/user-attachments/assets/9fc19538-c470-4a86-8c61-06fc4c142dcc" />

> 그림 6.13       
> 테스트는 파일 시스템을 목(mock) 처리하여, 감사 시스템이 파일에 **기록하는 동작을 포착**할 수 있습니다.

다음 코드는 파일 시스템을 AuditManager에 주입하는 방식을 보여줍니다.

```C#
public class AuditManager
{
    private readonly int _maxEntriesPerFile;
    private readonly string _directoryName;
    private readonly IFileSystem _fileSystem;
    
    public AuditManager(
        int maxEntriesPerFile,
        string directoryName,
        IFileSystem fileSystem)
    {
        _maxEntriesPerFile = maxEntriesPerFile;
        _directoryName = directoryName;
        _fileSystem = fileSystem;
		} 
}
```

그리고 이어지는 코드는 AddRecord 메서드입니다.    

```C#
public void AddRecord(string visitorName, DateTime timeOfVisit)
{
    string[] filePaths = _fileSystem
        .GetFiles(_directoryName);
    (int index, string path)[] sorted = SortByIndex(filePaths);
    
    string newRecord = visitorName + ';' + timeOfVisit;
    
    if (sorted.Length == 0)
    {
        string newFile = Path.Combine(_directoryName, "audit_1.txt");
        _fileSystem.WriteAllText(
            newFile, newRecord);
        return;
		}
		
		(int currentFileIndex, string currentFilePath) = sorted.Last();
		List<string> lines = _fileSystem
		    .ReadAllLines(currentFilePath);
		
		if (lines.Count < _maxEntriesPerFile)
		{
				lines.Add(newRecord);
				string newContent = string.Join("\r\n", lines);
				_fileSystem.WriteAllText(
						currentFilePath, newContent);
		}
		else
		{
				int newIndex = currentFileIndex + 1;
				string newName = $"audit_{newIndex}.txt";
				string newFile = Path.Combine(_directoryName, newName);
				_fileSystem.WriteAllText(
				    newFile, newRecord);
		}
}
```

코드 목록 6.10에서는 `IFileSystem` 이라는 새로운 사용자 정의 인터페이스가 등장합니다.     
이 인터페이스는 파일 시스템과의 작업을 다음과 같이 캡슐화합니다:

```C#
public interface IFileSystem
{
		string[] GetFiles(string directoryName);
		void WriteAllText(string filePath, string content);
		List<string> ReadAllLines(string filePath);
}
```

이제 `AuditManager`는 더 이상 파일 시스템에 직접 의존하지 않기 때문에, 공유 의존성 문제가 사라졌고, 테스트들도 서로 완전히 독립적으로 실행될 수 있게 되었습니다.       
다음은 이를 검증하는 예시 테스트입니다:

```C#
[Fact]
public void A_new_file_is_created_when_the_current_file_overflows()
{
    var fileSystemMock = new Mock<IFileSystem>();
    fileSystemMock
        .Setup(x => x.GetFiles("audits"))
        .Returns(new string[]
        {
            @"audits\audit_1.txt",
            @"audits\audit_2.txt"
        });
    fileSystemMock
        .Setup(x => x.ReadAllLines(@"audits\audit_2.txt"))
        .Returns(new List<string>
        {
            "Peter; 2019-04-06T16:30:00",
            "Jane; 2019-04-06T16:40:00",
            "Jack; 2019-04-06T17:00:00"
        });
    var sut = new AuditManager(3, "audits", fileSystemMock.Object);
    
    sut.AddRecord("Alice", DateTime.Parse("2019-04-06T18:00:00"));
    
    fileSystemMock.Verify(x => x.WriteAllText(
        @"audits\audit_3.txt",
        "Alice;2019-04-06T18:00:00"));
}
```

이 테스트는 다음의 상황을 검증합니다:       
현재 파일의 항목 수가 최대치(예제에서는 3)에 도달했을 때, 새 파일이 생성되며 그 안에 하나의 감사 기록이 담긴다는 사실을 확인합니다.   
여기서 주목할 점은, 이 테스트는 정당한 목(mock)의 사용 예시라는 점입니다. 해당 애플리케이션은 실제로 사용자가 읽을 수 있는 파일을 생성합니다.       
(사용자는 전용 소프트웨어든, 단순한 메모장 프로그램이든 어떤 방식으로든 파일을 열어볼 수 있습니다.)      


즉, 파일 시스템과의 상호작용과 그로 인한 부작용(파일의 변화)은 애플리케이션의 외부에서 관찰 가능한 행동에 포함됩니다.      
5장에서 다룬 바와 같이, 이러한 경우가 목(mock)을 사용하는 유일하게 정당한 상황입니다.        
이번처럼 파일 시스템과의 의존성을 분리한 방식은, 초기 버전보다 확실히 개선된 구현 방식이라 할 수 있습니다.      
테스트는 더 이상 파일 시스템을 접근하지 않기 때문에, 실행 속도가 훨씬 빨라졌고, 파일 시스템을 신경 써야 할 필요도 없어서 유지보수 비용도 줄어들었습니다.     

또한 이 과정에서 회귀 테스트에 대한 보호력이나 리팩터링에 대한 저항력도 전혀 손상되지 않았습니다.    

> 표 6.3
> 목(mock)을 사용한 버전과 감사 시스템 초기 버전 간의 비교표

|  | 초기 버전 | 목(mock)을 사용할 때 |
| --- | --- | --- |
| 회귀로부터의 보호 | 좋음 | 좋음 |
| 리팩토링에 대한 저항력 | 좋음 | 좋음 |
| 빠른 피드백 | 나쁨 | 좋음 |
| 유지보수성 | 나쁨 | 보통 |

하지만 여전히 **개선의 여지**는 존재합니다.    
코드 목록 6.11에 나온 테스트를 보면, **설정 과정이 복잡하게 얽혀 있는 것**을 확인할 수 있습니다.      
이는 유지보수 측면에서 그다지 이상적이지 않습니다. 물론 모킹(mocking) 라이브러리들이 최대한 사용을 쉽게 도와주긴 하지만, 그럼에도 불구하고 **입력과 출력만으로 작성된 간단한 테스트에 비해 가독성이 떨어지는 것은 사실**입니다.      


<br>

### 6.4.3 함수형 아키텍처로의 리팩토링

파일 시스템에 대한 부작용을 인터페이스 뒤에 숨기고 `AuditManager`에 주입하는 대신, **그 부작용 자체를 아예 클래스 밖으로 옮기는 방식**도 있다.      
이렇게 하면 `AuditManager`는 **파일에 대해 어떤 작업을 해야 할지 결정만 하고**, 실제로 파일 시스템에 변화를 적용하는 역할은 새로운 클래스인 `Persister`가 담당하게 된다 (그림 6.14 참조).

<img width="291" alt="figure 6 14" src="https://github.com/user-attachments/assets/6c51c265-cfdd-433b-b244-62d1eb8d4a94" />

> 그림 6.14     
> `Persister`와 `AuditManager`는 함수형 아키텍처를 구성한다. `Persister`는 작업 디렉터리에서 파일과 그 내용을 수집해 `AuditManager`에 전달하고, 그로부터 반환된 명령을 실제 파일 시스템 변경으로 전환한다.


이 구조에서 Persister는 가변 셸(mutable shell) 역할을 하고, AuditManager는 함수형(불변) 코어(functional core) 역할을 한다. 아래는 리팩토링 이후의 AuditManager를 보여준다.

```C#
public class AuditManager
{
    private readonly int _maxEntriesPerFile;
    
    public AuditManager(int maxEntriesPerFile)
    {
        _maxEntriesPerFile = maxEntriesPerFile;
    }
    public FileUpdate AddRecord(
        FileContent[] files,
        string visitorName,
        DateTime timeOfVisit)
    {
        (int index, FileContent file)[] sorted = SortByIndex(files);
        
        string newRecord = visitorName + ';' + timeOfVisit;
        
        if (sorted.Length == 0)
        {
		        return new FileUpdate( 
				        "audit_1.txt", newRecord);
				}
        (int currentFileIndex, FileContent currentFile) = sorted.Last();
        List<string> lines = currentFile.Lines.ToList();
        
        if (lines.Count < _maxEntriesPerFile)
				{
				    lines.Add(newRecord);
				    string newContent = string.Join("\r\n", lines);
				    return new FileUpdate(
						    currentFile.FileName, newContent);
				} 
				else 
				{
						int newIndex = currentFileIndex + 1;
						string newName = $"audit_{newIndex}.txt";
						return new FileUpdate(
						    newName, newRecord);
				}
		}
}
```

이제 AuditManager는 작업 디렉터리 경로 대신, FileContent 객체의 배열을 받는다. 이 클래스는 AuditManager가 파일 시스템과 관련된 결정을 내리는 데 필요한 모든 정보를 담고 있다:    

```C#
public class FileContent
{
    public readonly string FileName;
    public readonly string[] Lines;
    
    public FileContent(string fileName, string[] lines)
    {
        FileName = fileName;
        Lines = lines;
    }
}
```

그리고 이전처럼 파일을 직접 수정하는 대신, 이제는 수행하고자 하는 부작용에 대한 명령을 반환한다:

```C#
public class FileUpdate
{
    public readonly string FileName;
    public readonly string NewContent;
    
    public FileUpdate(string fileName, string newContent)
    {
        FileName = fileName;
        NewContent = newContent;
    }
}
```

다음은 Persister 클래스의 코드이다:

```C#
public class Persister
{
    public FileContent[] ReadDirectory(string directoryName)
    {
        return Directory
            .GetFiles(directoryName)
            .Select(x => new FileContent(
						    Path.GetFileName(x),
						    File.ReadAllLines(x)))
						.ToArray();
		}
		
    public void ApplyUpdate(string directoryName, FileUpdate update)
    {
        string filePath = Path.Combine(directoryName, update.FileName);
        File.WriteAllText(filePath, update.NewContent);
    }
}
```

이 클래스는 매우 단순하다. 디렉터리에서 파일 내용을 읽고, `AuditManager`로부터 받은 업데이트 명령을 다시 디렉터리에 반영할 뿐이다.    
조건문(if 문)조차 없으며, 모든 복잡한 로직은 `AuditManager` 안에만 존재한다. 이것이 바로 **비즈니스 로직과 부작용의 분리**이다.    

이러한 분리를 유지하기 위해서는 `FileContent`와 `FileUpdate`의 인터페이스를 **프레임워크의 기본 파일 작업 API와 최대한 유사하게** 설계해야 한다.      
파싱과 준비 작업은 모두 함수형 코어에서 처리해야 하며, 외부 셸에서는 단순한 작업만 남도록 해야 한다. 예를 들어, .NET이 `File.ReadAllLines()`가 아닌 `File.ReadAllText()`만 제공한다고 가정하면, `FileContent`의 `Lines` 속성을 string으로 바꾸고, `AuditManager` 안에서 직접 파싱해야 할 것이다:    

```C#
public class FileContent
{
    public readonly string FileName;
    public readonly string Text; // previously, string[] Lines;
}
```

AuditManager와 Persister를 연결하려면 하나의 추가 클래스가 필요하다.    
이는 헥사고날 아키텍처 용어로 보면 애플리케이션 서비스(application service)에 해당하며, 아래 코드에서 확인할 수 있다:    

```C#
public class ApplicationService
{
    private readonly string _directoryName;
    private readonly AuditManager _auditManager;
    private readonly Persister _persister;
    
    public ApplicationService(
		    string directoryName, int maxEntriesPerFile)
		{
		    _directoryName = directoryName;
		    _auditManager = new AuditManager(maxEntriesPerFile);
		    _persister = new Persister();
		}
		
		public void AddRecord(string visitorName, DateTime timeOfVisit)
		{
				FileContent[] files = _persister.ReadDirectory(_directoryName);
				FileUpdate update = _auditManager.AddRecord(
				    files, visitorName, timeOfVisit);
				_persister.ApplyUpdate(_directoryName, update);
		}
}
```

이 애플리케이션 서비스는 함수형 코어(AuditManager)와 가변 셸(Persister)을 하나로 묶는 역할을 한다. 동시에 외부 클라이언트를 위한 진입점도 제공한다 (그림 6.15 참조).

<img width="390" alt="figure 6 15" src="https://github.com/user-attachments/assets/a263f411-00c6-497c-86b0-e9db6c17f0a6" />

> 그림 6.15         
> ApplicationService는 함수형 코어(AuditManager)와 가변 셸(Persister)을 연결하며, 외부 시스템을 위한 진입점 역할도 수행한다. 헥사고날 아키텍처에서 ApplicationService와 Persister는 애플리케이션 서비스 계층, AuditManager는 도메인 모델에 속한다.

```C#
[Fact]
public void A_new_file_is_created_when_the_current_file_overflows()
{
    var sut = new AuditManager(3);
    var files = new FileContent[]
    {
        new FileContent("audit_1.txt", new string[0]),
        new FileContent("audit_2.txt", new string[]
        {
            "Peter; 2019-04-06T16:30:00",
            "Jane; 2019-04-06T16:40:00",
            "Jack; 2019-04-06T17:00:00"
				}) 
		};
    
    FileUpdate update = sut.AddRecord(
        files, "Alice", DateTime.Parse("2019-04-06T18:00:00"));
    
    Assert.Equal("audit_3.txt", update.FileName);
    Assert.Equal("Alice;2019-04-06T18:00:00", update.NewContent);
}
```

이 테스트는 앞서 목(mock)을 사용한 버전의 장점(빠른 피드백)을 유지하면서, **유지보수성 측면에서도 더 큰 개선을 이룬다**.     
더 이상 복잡한 목 설정이 필요 없으며, 단순한 입력과 출력만으로 테스트가 가능해져 **가독성이 크게 향상된다**. 다음 표는 이 출력 기반 테스트와 앞선 두 가지 버전을 비교한 것이다:    

> 표 6.4      
> 출력 기반 테스트와 초기 버전 및 목 버전 비교     

|  | 초기 버전 | 목(mock)을 사용할 때 | Output-based |
| --- | --- | --- | --- |
| 회귀로부터의 보호 | 좋음 | 좋음 | 좋음 |
| 리팩토링에 대한 저항력 | 좋음 | 좋음 | 좋음 |
| 빠른 피드백 | 나쁨 | 좋음 | 좋음 |
| 유지보수성 | 나쁨 | 보통 | 좋음 |



또한, 함수형 코어가 생성하는 명령(instruction)은 항상 **값(value)** 또는 **값의 집합**이다.  
이런 값 객체는 내용만 같다면 서로 교환 가능하기 때문에, 테스트에서 값 기반 비교(value equality)를 활용해 가독성을 더 높일 수 있다.  
이를 위해 .NET에서는 클래스를 `struct`로 바꾸거나, 커스텀 `Equals()` 및 `GetHashCode()` 메서드를 정의해야 한다. 이렇게 하면 참조 비교가 아닌 **값 비교**가 가능하다.    

값 비교가 가능해지면, 다음과 같이 테스트 코드를 더 간결하게 작성할 수 있다:    

```C#
Assert.Equal(
    new FileUpdate("audit_3.txt", "Alice;2019-04-06T18:00:00"),
    update);
```

또는 Fluent Assertions를 사용할 경우:        

```C#
update.Should().Be(
    new FileUpdate("audit_3.txt", "Alice;2019-04-06T18:00:00"));
```

<br>

### 6.4.4 앞으로의 확장 가능성

이제 잠시 한 걸음 물러서서, 샘플 프로젝트를 어떻게 더 발전시킬 수 있을지 생각해 보자. 지금까지 보여준 감사 시스템은 매우 단순하며, 다음과 같은 세 가지 분기(branch)만 존재한다:
- 작업 디렉터리가 비어 있는 경우 새 파일 생성
- 기존 파일에 새 레코드 추가
- 현재 파일의 항목 수가 한도를 초과할 경우 새 파일 생성

그리고 단 하나의 유스케이스(방문자 기록 추가)만 존재한다. 하지만 만약 다음과 같은 요구사항이 추가된다면 어떻게 될까?     
- 특정 방문자의 기록을 **모두 삭제**하는 기능
- 방문자 이름의 최대 길이를 검사하는 **유효성 검사**

특정 방문자 기록 삭제는 여러 파일에 영향을 줄 수 있기 때문에, 새로운 메서드는 **여러 개의 파일 명령**을 반환해야 할 것이다:    

```C#
public FileUpdate[] DeleteAllMentions(
    FileContent[] files, string visitorName)
```

또한, 비즈니스 측에서는 **빈 파일은 디렉터리에 남기지 말라**는 요구를 할 수도 있다. 즉, 삭제된 항목이 해당 파일의 마지막 항목이었다면, 그 파일은 **삭제해야 한다**.     
이를 위해 `FileUpdate`를 `FileAction`으로 이름을 바꾸고, `ActionType`이라는 enum 필드를 추가할 수 있다. 이 필드는 변경(update)인지 삭제(delete)인지를 명시해 줄 것이다.      

에러 처리도 함수형 아키텍처에서는 **더 간결하고 명시적**으로 할 수 있다. 에러 정보를 `FileUpdate` 클래스 내부 또는 별도 구성요소로 함께 반환하도록 메서드 시그니처를 정의하면 된다:      

```C#
public (FileUpdate update, Error error) AddRecord(
    FileContent[] files,
    string visitorName,
    DateTime timeOfVisit)
```

이렇게 하면 애플리케이션 서비스는 이 에러 값을 검사해, 에러가 있을 경우 Persister에게 명령을 전달하지 않고, 사용자에게 에러 메시지를 반환할 수 있다.

<br>

## 6.5 함수형 아키텍처의 단점 이해하기
안타깝게도, 함수형 아키텍처는 항상 달성할 수 있는 것은 아니다.     
그리고 그것이 가능하더라도, 유지보수성의 이점은 종종 성능 저하와 코드베이스 크기 증가로 상쇄된다.      
이 절에서는 함수형 아키텍처에 따르는 비용과 트레이드오프를 살펴본다.     

<br>

### 6.5.1 함수형 아키텍처의 적용 가능성    
함수형 아키텍처는 우리의 감사 시스템에서 잘 작동했다. 왜냐하면 이 시스템은 결정을 내리기 전에 모든 입력을 사전에 수집할 수 있었기 때문이다. 하지만 실행 흐름이 항상 그렇게 단순하진 않다.
결정 과정을 거치는 중간 결과에 따라, 외부 프로세스 의존성에서 추가 데이터를 조회해야 할 수도 있다.        
예를 들어보자. 감사 시스템이 지난 24시간 동안 방문한 횟수가 어떤 임계값을 초과하는 경우 방문자의 접근 수준을 확인해야 한다고 해보자.      
그리고 모든 방문자의 접근 수준이 데이터베이스에 저장되어 있다고 가정하자. 이 경우 다음과 같이 `IDatabase` 인스턴스를 `AuditManager`에 전달할 수 없다:      

```C#
public FileUpdate AddRecord(
    FileContent[] files, string visitorName, DateTime timeOfVisit, IDatabase database
)
```

이러한 인스턴스는 AddRecord() 메서드에 숨겨진 입력을 도입하게 된다. 따라서 이 메서드는 더 이상 수학적인 함수가 아니게 된다 (그림 6.16 참고).    
즉, 더 이상 출력 기반 테스트를 적용할 수 없다.

<img width="384" alt="figure 6 16" src="https://github.com/user-attachments/assets/d2d1e1d4-267d-4dec-8e21-39d3513d0332" />

> 그림 6.16
> 데이터베이스에 대한 의존성은 AuditManager에 숨겨진 입력을 도입한다. 이러한 클래스는 더 이상 순수 함수형이 아니며, 전체 애플리케이션도 더 이상 함수형 아키텍처를 따르지 않게 된다.


이런 상황에서 가능한 해결책은 두 가지다:

- 디렉터리 내용과 함께 방문자의 접근 수준을 애플리케이션 서비스에서 미리 수집하는 방법
- AuditManager에 IsAccessLevelCheckRequired()와 같은 새 메서드를 도입하는 방법이다.
  애플리케이션 서비스는 AddRecord()를 호출하기 전에 이 메서드를 호출하고, true가 반환되면 서비스는 데이터베이스에서 접근 수준을 가져와 AddRecord()에 전달한다.
    
두 접근 방식 모두 단점이 있다.    
첫 번째는 성능을 포기한다 — 접근 수준이 필요하지 않은 경우에도 조건 없이 데이터베이스를 쿼리하게 된다.     
그러나 이 방식은 비즈니스 로직과 외부 시스템과의 통신 간 분리를 완전히 유지한다: 모든 의사결정은 이전처럼 AuditManager에 남는다.    
두 번째는 성능 향상을 위해 해당 분리의 일부를 포기한다: 데이터베이스를 호출할지 여부의 결정이 이제 AuditManager가 아니라 애플리케이션 서비스로 넘어간다.      
이 두 옵션과 달리, 도메인 모델(AuditManager)을 데이터베이스에 의존하게 만드는 것은 좋은 생각이 아니다.        
성능과 관심사의 분리 간 균형을 유지하는 방법에 대해서는 다음 두 장에서 더 자세히 설명하겠다.     


**협력자 vs. 값**     
AuditManager의 AddRecord() 메서드에 시그니처에 나타나지 않는 의존성이 하나 있다는 것을 눈치챘을지도 모른다: `_maxEntriesPerFile` 필드이다.      
AuditManager는 이 필드를 참조하여 기존 감사 파일에 추가할지 새 파일을 생성할지 결정한다.      
이 의존성은 메서드의 인자에는 없지만 숨겨진 것은 아니다. 클래스 생성자의 시그니처로부터 유추할 수 있다.      
그리고 `_maxEntriesPerFile` 필드는 불변이기 때문에 클래스 인스턴스화 이후 AddRecord() 호출 시점까지 값이 변하지 않는다. 즉, 이 필드는 하나의 값(value)이다.      
반면, IDatabase 의존성은 다르다.      
이것은 `_maxEntriesPerFile`과 같은 값이 아니라 협력자(collaborator)이다.      
2장에서 기억하듯이, 협력자는 다음 중 하나 이상에 해당하는 의존성이다:     
- 상태 변경이 가능한 경우 (mutable) 
- 아직 메모리에 존재하지 않는 데이터를 프록시하는 경우 (공유된 의존성) 

IDatabase 인스턴스는 두 번째 경우에 해당하며 따라서 협력자이다.     
이것은 외부 프로세스 의존성에 대한 추가 호출이 필요하며, 그 결과 출력 기반 테스트 사용을 방해한다.    

> 참고        
> 함수형 코어의 클래스는 협력자가 아닌, 그 협력자의 작업 결과인 값과 함께 작동해야 한다.

<br>

### 6.5.2 성능상의 단점

함수형 아키텍처가 시스템 전체에 미치는 성능 영향은 흔히 제기되는 반론이다. 여기서 성능이란 테스트의 성능이 아니다.   
우리가 작성한 출력 기반 테스트는 목(mock) 테스트와 동일하게 빠르게 작동한다. 성능이 떨어지는 것은 시스템 자체이다.   
이제 시스템은 외부 프로세스 의존성에 대한 호출을 더 많이 수행해야 하며, 그 결과 성능이 저하된다. 감사 시스템의 초기 버전은 작업 디렉터리의 모든 파일을 읽지 않았고, 목 버전도 마찬가지였다.   
하지만 최종 버전은 읽기-결정-행동(read-decide-act) 접근 방식을 따르기 위해 모든 파일을 읽는다.

함수형 아키텍처와 보다 전통적인 아키텍처 간 선택은 성능과 코드 유지보수성(프로덕션 및 테스트 코드 양쪽 모두) 간의 트레이드오프이다.     
일부 시스템에서는 성능 영향이 크지 않기 때문에 유지보수성을 위한 이점이 더 크므로 함수형 아키텍처가 낫다. 다른 시스템에서는 반대의 선택이 필요할 수도 있다. 보편적인 해답은 없다.        

<br>

### 6.5.3 코드베이스 크기의 증가
코드베이스 크기에 대해서도 마찬가지이다. 함수형 아키텍처는 함수형(불변의) 코어와 변경 가능한 셸 사이의 명확한 분리를 요구한다.    
이로 인해 초기에는 추가적인 코딩이 필요하지만, 궁극적으로는 코드 복잡도가 줄고 유지보수성이 향상된다.        

모든 프로젝트가 이러한 초기 투자를 정당화할 만큼 높은 복잡성을 가지는 것은 아니다. 일부 코드베이스는 비즈니스 관점에서 중요하지 않거나, 단순히 너무 간단하다.    
이러한 프로젝트에 함수형 아키텍처를 사용하는 것은 의미가 없으며, 초기 투자가 결실을 맺지 못할 것이다. 항상 시스템의 복잡성과 중요도를 고려하여 전략적으로 함수형 아키텍처를 적용하라.      

마지막으로, 함수형 접근 방식의 순수함이 너무 큰 대가를 요구한다면, 그 순수함을 고수하지 마라.     
대부분의 프로젝트에서는 도메인 모델을 완전히 불변하게 만들 수 없으며, 따라서 오직 출력 기반 테스트에만 의존할 수 없다.     
적어도 C#이나 Java와 같은 객체 지향 언어를 사용할 경우에는 그렇다.    

대부분의 경우, 출력 기반 테스트와 상태 기반 테스트를 조합해서 사용하며, 소량의 통신 기반 테스트가 섞이게 된다. 이것은 괜찮다.    
이 장의 목표는 모든 테스트를 출력 기반 스타일로 전환하라는 것이 아니다.    
목표는 가능한 많은 테스트를 합리적인 수준까지 출력 기반으로 전환하라는 것이다. 이 차이는 미묘하지만 중요하다.    

<br>

## Summary

- **Output-based testing is a style of testing where you feed an input to the SUT and check the output it produces.**
    
    출력 기반 테스트는 시스템(SUT)에 입력을 제공하고, 그것이 생성하는 출력을 확인하는 테스트 방식이다.
    
- **This style of testing assumes there are no hidden inputs or outputs, and the only result of the SUT’s work is the value it returns.**
    
    이 테스트 방식은 숨겨진 입력이나 출력이 없으며, 시스템의 작업 결과는 반환되는 값뿐이라고 가정한다.
    
- **State-based testing verifies the state of the system after an operation is completed.**
    
    상태 기반 테스트는 작업이 완료된 후 시스템의 상태를 검증한다.
    
- **In communication-based testing, you use mocks to verify communications between the system under test and its collaborators.**
    
    통신 기반 테스트에서는 시스템과 협력자 간의 통신을 검증하기 위해 목(mock)을 사용한다.
    
- **The classical school of unit testing prefers the state-based style over the communication-based one.**
    
    고전 학파의 단위 테스트는 통신 기반보다 상태 기반 스타일을 선호한다.
    
- **The London school has the opposite preference.**
    
    런던 학파는 그 반대를 선호한다.
    
- **Both schools use output-based testing.**
    
    두 학파 모두 출력 기반 테스트는 사용한다.
    
- **Output-based testing produces tests of the highest quality.**
    
    출력 기반 테스트는 가장 품질이 높은 테스트를 만들어낸다.
    
- **Such tests rarely couple to implementation details and thus are resistant to refactoring.**
    
    이러한 테스트는 구현 세부사항에 거의 결합되지 않기 때문에 리팩토링에 강하다.
    
- **They are also small and concise and thus are more maintainable.**
    
    또한 작고 간결하기 때문에 유지보수가 더 쉽다.
    
- **State-based testing requires extra prudence to avoid brittleness:**
    
    상태 기반 테스트는 테스트의 취약함을 피하기 위해 추가적인 주의가 필요하다:
    
- **you need to make sure you don’t expose a private state to enable unit testing.**
    
    단위 테스트를 가능하게 하려고 private 상태를 노출하지 않도록 주의해야 한다.
    
- **Because state-based tests tend to be larger than output-based tests, they are also less maintainable.**
    
    상태 기반 테스트는 출력 기반 테스트보다 크기 때문에 유지보수가 더 어렵다.
    
- **Maintainability issues can sometimes be mitigated (but not eliminated) with the use of helper methods and value objects.**
    
    유지보수 문제는 헬퍼 메서드와 값 객체의 사용을 통해 완화될 수는 있지만 완전히 제거되지는 않는다.
    
- **Communication-based testing also requires extra prudence to avoid brittleness.**
    
    통신 기반 테스트도 취약함을 피하기 위해 추가적인 주의가 필요하다.
    
- **You should only verify communications that cross the application boundary and whose side effects are visible to the external world.**
    
    애플리케이션 경계를 넘고 외부 세계에 영향을 주는 통신만을 검증해야 한다.
    
- **Maintainability of communication-based tests is worse compared to output-based and state-based tests.**
    
    통신 기반 테스트의 유지보수성은 출력 기반 및 상태 기반 테스트보다 더 나쁘다.
    
- **Mocks tend to occupy a lot of space, and that makes tests less readable.**
    
    목(mock)은 많은 공간을 차지하는 경향이 있어 테스트의 가독성이 떨어진다.
    
- **Functional programming is programming with mathematical functions.**
    
    함수형 프로그래밍은 수학적 함수를 사용하는 프로그래밍이다.
    
- **A mathematical function is a function (or method) that doesn’t have any hidden inputs or outputs.**
    
    수학적 함수란 숨겨진 입력이나 출력이 없는 함수(또는 메서드)이다.
    
- **Side effects and exceptions are hidden outputs.**
    
    부작용과 예외는 숨겨진 출력이다.
    
- **A reference to an internal or external state is a hidden input.**
    
    내부 또는 외부 상태에 대한 참조는 숨겨진 입력이다.
    
- **Mathematical functions are explicit, which makes them extremely testable.**
    
    수학적 함수는 명시적이기 때문에 매우 테스트하기 쉽다.
    
- **The goal of functional programming is to introduce a separation between business logic and side effects.**
    
    함수형 프로그래밍의 목표는 비즈니스 로직과 부작용 사이에 분리를 도입하는 것이다.
    
- **Functional architecture helps achieve that separation by pushing side effects to the edges of a business operation.**
    
    함수형 아키텍처는 비즈니스 작업의 가장자리로 부작용을 밀어냄으로써 이 분리를 달성하는 데 도움을 준다.
    
- **This approach maximizes the amount of code written in a purely functional way while minimizing code that deals with side effects.**
    
    이 접근 방식은 순수 함수형으로 작성된 코드의 양을 최대화하고, 부작용을 다루는 코드의 양을 최소화한다.
    
- **Functional architecture divides all code into two categories: functional core and mutable shell.**
    
    함수형 아키텍처는 모든 코드를 두 가지 범주로 나눈다: 함수형 코어와 변경 가능한 셸.
    
- **The functional core makes decisions.**

    함수형 코어는 결정을 내린다.
    
- **The mutable shell supplies input data to the functional core and converts decisions the core makes into side effects.**

    변경 가능한 셸은 함수형 코어에 입력 데이터를 제공하고, 코어가 내린 결정을 부작용으로 변환한다.
    
- **The difference between functional and hexagonal architectures is in their treatment of side effects.**

    함수형 아키텍처와 육각형 아키텍처의 차이는 부작용을 다루는 방식에 있다.
    
- **Functional architecture pushes all side effects out of the domain layer.**

    함수형 아키텍처는 모든 부작용을 도메인 계층 밖으로 밀어낸다.
    
- **Conversely, hexagonal architecture is fine with side effects made by the domain layer, as long as they are limited to that domain layer only.**

    반대로, 육각형 아키텍처는 도메인 계층에서 발생하는 부작용을 허용하지만, 그것이 도메인 계층 내부로 한정되어 있어야 한다.
    
- **Functional architecture is hexagonal architecture taken to an extreme.**

    함수형 아키텍처는 극단적으로 확장된 육각형 아키텍처이다.
    
- **The choice between a functional architecture and a more traditional one is a trade-off between performance and code maintainability.**

    함수형 아키텍처와 보다 전통적인 아키텍처 중 선택은 성능과 코드 유지보수성 간의 트레이드오프이다.
    
- **Functional architecture concedes performance for maintainability gains.**

    함수형 아키텍처는 유지보수성을 얻기 위해 성능을 일부 양보한다.
    
- **Not all code bases are worth converting into functional architecture.**

    모든 코드베이스가 함수형 아키텍처로 전환할 가치가 있는 것은 아니다.
    
- **Apply functional architecture strategically.**

    함수형 아키텍처는 전략적으로 적용하라.
    
- **Take into account the complexity and the importance of your system.**

    시스템의 복잡성과 중요도를 고려하라.
    
- **In code bases that are simple or not that important, the initial investment required for functional architecture won’t pay off.**

    단순하거나 중요하지 않은 코드베이스에서는 함수형 아키텍처에 필요한 초기 투자가 이득으로 돌아오지 않는다.
