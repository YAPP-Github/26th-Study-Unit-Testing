
import java.util.*;

interface IEmailGateWay {
    void Sending_a_greetings_email(String email);
}

class Controller {
    private IEmailGateWay _emailGateWay;

    public Controller(IEmailGateWay emailGateWay) {
        _emailGateWay = emailGateWay;
    }

    public void GreetUser(String email) {
        _emailGateWay.Sending_a_greetings_email(email);
    }
}

public class Hello {

    // Unit tests should be written in a separate test class using a Java testing framework like JUnit.
    // The main method remains as the entry point for the application.
    // [Fact]
    public void TestGreetUser() {
        // Arrange
        
        var mockEmailGateWay = new Mock<IEmailGateWay>();
        var sut = new Controller(mockEmailGateWay.Object);
        
        sut.GreetUser("user@email.com");
        mock.Verify(
            x -> x.Sending_a_greetings_email("user@email.com"),
             Times.Once
            );
    }
}