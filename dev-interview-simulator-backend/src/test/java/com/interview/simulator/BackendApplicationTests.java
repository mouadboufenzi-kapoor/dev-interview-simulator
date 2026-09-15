package com.interview.simulator;

import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
@Disabled("Disabled until Docker/Postgres container is fully configured in CI/test runner")
class BackendApplicationTests {

	@Test
	void contextLoads() {
	}

}
