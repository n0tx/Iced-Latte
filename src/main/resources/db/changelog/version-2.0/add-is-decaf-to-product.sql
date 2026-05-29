--liquibase formatted sql
--changeset n0tx:add-is-decaf-to-product
ALTER TABLE product ADD COLUMN is_decaf BOOLEAN NOT NULL DEFAULT false;
