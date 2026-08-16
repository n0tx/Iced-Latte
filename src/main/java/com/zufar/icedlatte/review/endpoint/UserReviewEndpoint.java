package com.zufar.icedlatte.review.endpoint;

import com.zufar.icedlatte.openapi.dto.ProductReviewsAndRatingsWithPagination;
import com.zufar.icedlatte.review.api.ProductReviewsProvider;
import com.zufar.icedlatte.security.api.SecurityPrincipalProvider;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping(value = "/api/v1/users")
@Tag(name = "Product Review", description = "User review operations")
public class UserReviewEndpoint {

    private final ProductReviewsProvider productReviewsProvider;
    private final SecurityPrincipalProvider securityPrincipalProvider;

    @Operation(
            summary = "Get all reviews written by the authenticated user",
            security = @SecurityRequirement(name = "bearerAuth")
    )
    @GetMapping(value = "/reviews")
    public ResponseEntity<ProductReviewsAndRatingsWithPagination> getUserReviews(
            @RequestParam(name = "page", required = false) final Integer pageNumber,
            @RequestParam(name = "size", required = false) final Integer pageSize,
            @RequestParam(name = "sort_attribute", required = false) final String sortAttribute,
            @RequestParam(name = "sort_direction", required = false) final String sortDirection) {
        return ResponseEntity.ok(productReviewsProvider.getUserReviews(
                securityPrincipalProvider.getUserId(), pageNumber, pageSize, sortAttribute, sortDirection));
    }
}
