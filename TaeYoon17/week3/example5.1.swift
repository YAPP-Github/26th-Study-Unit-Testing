

protocol IEmailGateWay {
    func Sending_a_greetings_email(_ email: String);
}

class Mock<T> {

}

class Controller {
    private let _emailGateWay: IEmailGateWay;

    init(emailGateWay: IEmailGateWay) {
        _emailGateWay = emailGateWay;
    }
    public func greetUser(email: String) {
        _emailGateWay.Sending_a_greetings_email(email);
    }
}

func TestGreetUser() {
        // Arrange
        
    var mockEmailGateWay: Mock<any IEmailGateWay> =  Mock<IEmailGateWay>();
    var sut = Controller(mockEmailGateWay.Object);
        
    sut.GreetUser("user@email.com");
    mock.Verify(
        x -> x.Sending_a_greetings_email("user@email.com"),
        Times.Once
    );
}