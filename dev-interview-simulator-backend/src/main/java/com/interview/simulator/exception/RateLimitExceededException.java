package com.interview.simulator.exception;

import org.springframework.http.HttpStatus;

public class RateLimitExceededException extends ApiException {

    private final long retryAfterSeconds;

    public RateLimitExceededException(long retryAfterSeconds) {
        super(HttpStatus.TOO_MANY_REQUESTS, "Trop de tests lancés. Réessaie dans quelques minutes.");
        this.retryAfterSeconds = retryAfterSeconds;
    }

    public long getRetryAfterSeconds() {
        return retryAfterSeconds;
    }
}
