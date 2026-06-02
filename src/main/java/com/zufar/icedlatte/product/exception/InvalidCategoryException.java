package com.zufar.icedlatte.product.exception;

import com.zufar.icedlatte.product.enums.ProductCategory;

public class InvalidCategoryException extends RuntimeException {
    public InvalidCategoryException(final String category) {
        super(String.format("Invalid category: '%s'. Allowed categories are: %s.", category, ProductCategory.getAllDisplayNames()));
    }
}
