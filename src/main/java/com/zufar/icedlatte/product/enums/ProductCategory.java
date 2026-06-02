package com.zufar.icedlatte.product.enums;

import java.util.Arrays;
import java.util.List;

public enum ProductCategory {
    COFFEE("Coffee"),
    TEA("Tea"),
    MATCHA("Matcha"),
    CHOCOLATE("Chocolate");

    private final String displayName;

    ProductCategory(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }

    public static boolean isValid(String category) {
        return Arrays.stream(values())
                .anyMatch(c -> c.displayName.equalsIgnoreCase(category));
    }

    public static List<String> getAllDisplayNames() {
        return Arrays.stream(values())
                .map(ProductCategory::getDisplayName)
                .toList();
    }
}
