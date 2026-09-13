package com.trt;

import com.trt.framework.GreetingController;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class GreetingControllerTest {

    @Test
    void greetingReturnsHelloWorld() {
        GreetingController controller = new GreetingController();
        String result = controller.greeting();
        assertEquals("Hello, World!", result);
    }

}

