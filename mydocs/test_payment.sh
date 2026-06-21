#!/bin/bash

BASE_URL="http://localhost:8083/api/v1"
EMAIL="testmidtrans@example.com"
PASSWORD="Password123!"

# Register
echo "Registering..."
curl -s -X POST "$BASE_URL/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"firstName\":\"Test\",\"lastName\":\"User\",\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" > /dev/null

# Login
echo "Logging in..."
TOKEN=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\",\"password\":\"$PASSWORD\"}" | grep -o '"token":"[^"]*' | grep -o '[^"]*$')

echo "Token: $TOKEN"

if [ -z "$TOKEN" ]; then
  echo "Login failed!"
  exit 1
fi

# Add item to cart
echo "Adding to cart..."
curl -s -X POST "$BASE_URL/cart/items" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"productId":"d1a2b3c4-0001-4000-8000-000000000001","quantity":1}' > /dev/null

# Hit Midtrans endpoint
echo "Hitting Midtrans..."
curl -v -X POST "$BASE_URL/payment/midtrans/checkout" \
  -H "Authorization: Bearer $TOKEN"

