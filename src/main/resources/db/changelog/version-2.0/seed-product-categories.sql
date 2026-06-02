--liquibase formatted sql
--changeset n0tx:seed-product-categories

-- Tea
UPDATE product SET category = 'Tea' WHERE id IN (
    'b5faee5d-6e6d-4319-ba9f-8d1bf7ee3f63',
    'd1a2b3c4-0001-4000-8000-000000000006',
    '123f7a2d-cb34-4e5f-9a1d-4e4b456a03a7'
);

-- Matcha
UPDATE product SET category = 'Matcha' WHERE id IN (
    '25a8e8c1-37ba-4a8b-927f-5f1b4b5b5c3c',
    'd1a2b3c4-0001-4000-8000-000000000004',
    'd1a2b3c4-0001-4000-8000-000000000010'
);

-- Chocolate
UPDATE product SET category = 'Chocolate' WHERE id = '4e9a7d28-5e40-4b14-bc72-a5d1b547c3d0';
