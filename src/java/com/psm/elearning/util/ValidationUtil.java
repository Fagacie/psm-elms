package com.psm.elearning.util;

import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;

/**
 * Provides a lazily initialised {@link Validator} for bean validation across the app.
 */
public final class ValidationUtil {

    private static final ValidatorFactory FACTORY = Validation.buildDefaultValidatorFactory();
    private static final Validator VALIDATOR = FACTORY.getValidator();

    private ValidationUtil() {
        // utility
    }

    public static Validator getValidator() {
        return VALIDATOR;
    }
}