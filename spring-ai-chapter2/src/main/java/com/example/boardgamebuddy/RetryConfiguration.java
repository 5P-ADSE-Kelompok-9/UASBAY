package com.example.boardgamebuddy;

import org.springframework.context.annotation.Configuration;
import org.springframework.retry.annotation.EnableRetry;

/** Enables Spring Retry proxies for methods annotated with @Retryable. */
@Configuration
@EnableRetry
public class RetryConfiguration {
}
