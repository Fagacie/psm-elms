package com.psm.elearning.exception;

import java.util.Collections;
import java.util.LinkedHashSet;
import java.util.Objects;
import java.util.Set;

/**
 * Aggregates validation messages for user-facing feedback.
 */
public class ValidationException extends RuntimeException {

    private final Set<String> messages;

    public ValidationException(String message) {
        super(message);
        this.messages = Collections.singleton(message);
    }

    public ValidationException(Set<String> messages) {
        super(String.join("; ", messages));
        this.messages = Collections.unmodifiableSet(new LinkedHashSet<>(Objects.requireNonNull(messages)));
    }

    public Set<String> getMessages() {
        return messages;
    }
}