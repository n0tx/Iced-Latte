--
-- PostgreSQL database dump
--

\restrict hnaMpsCNfeJdfG1MMxGNnS93Be27ZIOjUup41dp9mtCz7ZCD5N2IH7msfIF2XAF

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.address (
    id uuid NOT NULL,
    line character varying(55) NOT NULL,
    city character varying(55) NOT NULL,
    country character varying(55) NOT NULL,
    postcode character varying(55) NOT NULL
);


ALTER TABLE public.address OWNER TO postgres;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    entity_type character varying(100) NOT NULL,
    entity_id character varying(100) NOT NULL,
    operation character varying(20) NOT NULL,
    user_id uuid,
    old_values text,
    new_values text,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ip_address character varying(45),
    user_agent text
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: auth_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    refresh_token_hash character varying(128) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    last_used_at timestamp with time zone,
    revoked_at timestamp with time zone,
    user_agent character varying(256),
    ip_address character varying(64),
    compromised boolean DEFAULT false NOT NULL,
    previous_token_hash character varying(128)
);


ALTER TABLE public.auth_sessions OWNER TO postgres;

--
-- Name: databasechangelog; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databasechangelog (
    id character varying(255) NOT NULL,
    author character varying(255) NOT NULL,
    filename character varying(255) NOT NULL,
    dateexecuted timestamp without time zone NOT NULL,
    orderexecuted integer NOT NULL,
    exectype character varying(10) NOT NULL,
    md5sum character varying(35),
    description character varying(255),
    comments character varying(255),
    tag character varying(255),
    liquibase character varying(20),
    contexts character varying(255),
    labels character varying(255),
    deployment_id character varying(10)
);


ALTER TABLE public.databasechangelog OWNER TO postgres;

--
-- Name: databasechangeloglock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.databasechangeloglock (
    id integer NOT NULL,
    locked boolean NOT NULL,
    lockgranted timestamp without time zone,
    lockedby character varying(255)
);


ALTER TABLE public.databasechangeloglock OWNER TO postgres;

--
-- Name: delivery_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delivery_address (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    label character varying(64) NOT NULL,
    line character varying(256) NOT NULL,
    city character varying(128) NOT NULL,
    country character varying(128) NOT NULL,
    postcode character varying(16) NOT NULL,
    is_default boolean DEFAULT false NOT NULL
);


ALTER TABLE public.delivery_address OWNER TO postgres;

--
-- Name: favorite_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favorite_item (
    id uuid NOT NULL,
    favorite_id uuid NOT NULL,
    product_id uuid NOT NULL,
    version integer
);


ALTER TABLE public.favorite_item OWNER TO postgres;

--
-- Name: favorite_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favorite_list (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.favorite_list OWNER TO postgres;

--
-- Name: file_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.file_metadata (
    id uuid NOT NULL,
    related_object_id uuid NOT NULL,
    bucket_name character varying(255),
    file_name character varying(255),
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.file_metadata OWNER TO postgres;

--
-- Name: login_attempts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.login_attempts (
    id uuid NOT NULL,
    user_email character varying(55) NOT NULL,
    attempts integer NOT NULL,
    is_user_locked boolean NOT NULL,
    expiration_datetime timestamp with time zone,
    last_modified timestamp with time zone NOT NULL,
    CONSTRAINT login_attempts_attempts_check CHECK ((attempts >= 0))
);


ALTER TABLE public.login_attempts OWNER TO postgres;

--
-- Name: order_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item (
    id uuid NOT NULL,
    order_id uuid NOT NULL,
    product_id uuid NOT NULL,
    product_price numeric NOT NULL,
    product_name character varying(64) NOT NULL,
    products_quantity integer NOT NULL,
    CONSTRAINT order_item_product_price_check CHECK ((product_price > (0)::numeric)),
    CONSTRAINT order_item_products_quantity_check CHECK ((products_quantity >= 0))
);


ALTER TABLE public.order_item OWNER TO postgres;

--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    session_id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(55) NOT NULL,
    items_quantity integer NOT NULL,
    address_id uuid NOT NULL,
    items_total_price numeric NOT NULL,
    recipient_name character varying(128) DEFAULT ''::character varying NOT NULL,
    recipient_surname character varying(128) DEFAULT ''::character varying NOT NULL,
    recipient_phone character varying(32),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid,
    CONSTRAINT orders_items_quantity_check CHECK ((items_quantity >= 0)),
    CONSTRAINT orders_items_total_price_check CHECK ((items_total_price > (0)::numeric))
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    id uuid NOT NULL,
    name character varying(64) NOT NULL,
    description text,
    price numeric NOT NULL,
    quantity integer NOT NULL,
    active boolean NOT NULL,
    average_rating numeric DEFAULT 0,
    reviews_count integer DEFAULT 0,
    brand_name character varying(64) NOT NULL,
    seller_name character varying(64) NOT NULL,
    origin_country character varying(128) NOT NULL,
    weight integer NOT NULL,
    size_length integer NOT NULL,
    size_width integer NOT NULL,
    size_height integer NOT NULL,
    sold_products_count integer NOT NULL,
    discount integer NOT NULL,
    date_added timestamp with time zone NOT NULL,
    popularity_score integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid,
    version bigint DEFAULT 0 NOT NULL,
    ai_summary text,
    is_decaf boolean DEFAULT false NOT NULL,
    CONSTRAINT product_average_rating_check CHECK (((average_rating >= (0)::numeric) AND (average_rating < (6)::numeric))),
    CONSTRAINT product_date_added_check CHECK ((date_added <= CURRENT_TIMESTAMP)),
    CONSTRAINT product_discount_check CHECK ((discount >= 0)),
    CONSTRAINT product_popularity_score_check CHECK ((popularity_score > 0)),
    CONSTRAINT product_price_check CHECK ((price > (0)::numeric)),
    CONSTRAINT product_quantity_check CHECK ((quantity >= 0)),
    CONSTRAINT product_reviews_count_check CHECK ((reviews_count >= 0)),
    CONSTRAINT product_size_height_check CHECK ((size_height > 0)),
    CONSTRAINT product_size_length_check CHECK ((size_length > 0)),
    CONSTRAINT product_size_width_check CHECK ((size_width > 0)),
    CONSTRAINT product_sold_products_count_check CHECK ((sold_products_count > 0)),
    CONSTRAINT product_weight_check CHECK ((weight > 0))
);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: product_image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_image (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    product_id uuid NOT NULL,
    url character varying(2048) NOT NULL,
    "position" smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.product_image OWNER TO postgres;

--
-- Name: product_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_reviews (
    id uuid NOT NULL,
    product_id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    text character varying(1500) NOT NULL,
    rating integer NOT NULL,
    likes_count integer NOT NULL,
    dislikes_count integer NOT NULL,
    ai_summary text,
    CONSTRAINT product_reviews_dislikes_count_check CHECK ((dislikes_count >= 0)),
    CONSTRAINT product_reviews_likes_count_check CHECK ((likes_count >= 0)),
    CONSTRAINT product_reviews_rating_check CHECK (((rating > 0) AND (rating < 6)))
);


ALTER TABLE public.product_reviews OWNER TO postgres;

--
-- Name: product_reviews_likes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_reviews_likes (
    id uuid NOT NULL,
    review_id uuid NOT NULL,
    product_id uuid NOT NULL,
    user_id uuid NOT NULL,
    is_like boolean NOT NULL
);


ALTER TABLE public.product_reviews_likes OWNER TO postgres;

--
-- Name: shopping_cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shopping_cart (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    closed_at timestamp with time zone,
    CONSTRAINT shopping_cart_check CHECK ((created_at < closed_at))
);


ALTER TABLE public.shopping_cart OWNER TO postgres;

--
-- Name: shopping_cart_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shopping_cart_item (
    id uuid NOT NULL,
    shopping_cart_id uuid NOT NULL,
    product_id uuid NOT NULL,
    products_quantity integer NOT NULL,
    version integer,
    CONSTRAINT shopping_cart_item_products_quantity_check CHECK ((products_quantity >= 0))
);


ALTER TABLE public.shopping_cart_item OWNER TO postgres;

--
-- Name: user_details; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_details (
    id uuid NOT NULL,
    first_name character varying(128) NOT NULL,
    last_name character varying(128) NOT NULL,
    birth_date date,
    phone_number character varying(25),
    stripe_customer_token character varying(64),
    email character varying(55) NOT NULL,
    password character varying(255) NOT NULL,
    address_id uuid,
    account_non_expired boolean NOT NULL,
    account_non_locked boolean NOT NULL,
    credentials_non_expired boolean NOT NULL,
    enabled boolean NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_by uuid,
    oauth_user boolean DEFAULT false NOT NULL
);


ALTER TABLE public.user_details OWNER TO postgres;

--
-- Name: user_granted_authority; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_granted_authority (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    authority character varying(32) NOT NULL
);


ALTER TABLE public.user_granted_authority OWNER TO postgres;

--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (id);


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: auth_sessions auth_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_pkey PRIMARY KEY (id);


--
-- Name: auth_sessions auth_sessions_refresh_token_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_refresh_token_hash_key UNIQUE (refresh_token_hash);


--
-- Name: databasechangeloglock databasechangeloglock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.databasechangeloglock
    ADD CONSTRAINT databasechangeloglock_pkey PRIMARY KEY (id);


--
-- Name: delivery_address delivery_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_address
    ADD CONSTRAINT delivery_address_pkey PRIMARY KEY (id);


--
-- Name: favorite_item favorite_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite_item
    ADD CONSTRAINT favorite_item_pkey PRIMARY KEY (id);


--
-- Name: favorite_list favorite_list_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite_list
    ADD CONSTRAINT favorite_list_pkey PRIMARY KEY (id);


--
-- Name: file_metadata file_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.file_metadata
    ADD CONSTRAINT file_metadata_pkey PRIMARY KEY (id);


--
-- Name: login_attempts login_attempts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_attempts
    ADD CONSTRAINT login_attempts_pkey PRIMARY KEY (id);


--
-- Name: login_attempts login_attempts_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_attempts
    ADD CONSTRAINT login_attempts_user_email_key UNIQUE (user_email);


--
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: product_image product_image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_image
    ADD CONSTRAINT product_image_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product_reviews_likes product_reviews_likes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews_likes
    ADD CONSTRAINT product_reviews_likes_pkey PRIMARY KEY (id);


--
-- Name: product_reviews product_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT product_reviews_pkey PRIMARY KEY (id);


--
-- Name: shopping_cart_item shopping_cart_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_cart_item
    ADD CONSTRAINT shopping_cart_item_pkey PRIMARY KEY (id);


--
-- Name: shopping_cart shopping_cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_cart
    ADD CONSTRAINT shopping_cart_pkey PRIMARY KEY (id);


--
-- Name: product_reviews uk_product_reviews_user_product; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT uk_product_reviews_user_product UNIQUE (user_id, product_id);


--
-- Name: favorite_item uq_favorite_item_list_product; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite_item
    ADD CONSTRAINT uq_favorite_item_list_product UNIQUE (favorite_id, product_id);


--
-- Name: favorite_list uq_favorite_list_user_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite_list
    ADD CONSTRAINT uq_favorite_list_user_id UNIQUE (user_id);


--
-- Name: product_reviews_likes uq_product_reviews_likes_user_review; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews_likes
    ADD CONSTRAINT uq_product_reviews_likes_user_review UNIQUE (user_id, review_id);


--
-- Name: shopping_cart_item uq_shopping_cart_item_cart_product; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_cart_item
    ADD CONSTRAINT uq_shopping_cart_item_cart_product UNIQUE (shopping_cart_id, product_id);


--
-- Name: shopping_cart uq_shopping_cart_user_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shopping_cart
    ADD CONSTRAINT uq_shopping_cart_user_id UNIQUE (user_id);


--
-- Name: user_details user_details_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_details
    ADD CONSTRAINT user_details_email_key UNIQUE (email);


--
-- Name: user_details user_details_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_details
    ADD CONSTRAINT user_details_pkey PRIMARY KEY (id);


--
-- Name: user_details user_details_stripe_customer_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_details
    ADD CONSTRAINT user_details_stripe_customer_token_key UNIQUE (stripe_customer_token);


--
-- Name: user_granted_authority user_granted_authority_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_granted_authority
    ADD CONSTRAINT user_granted_authority_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_logs_entity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_logs_entity ON public.audit_logs USING btree (entity_type, entity_id);


--
-- Name: idx_audit_logs_operation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_logs_operation ON public.audit_logs USING btree (operation);


--
-- Name: idx_audit_logs_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_logs_timestamp ON public.audit_logs USING btree ("timestamp");


--
-- Name: idx_audit_logs_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_audit_logs_user_id ON public.audit_logs USING btree (user_id);


--
-- Name: idx_auth_sessions_previous_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_auth_sessions_previous_token_hash ON public.auth_sessions USING btree (previous_token_hash) WHERE (previous_token_hash IS NOT NULL);


--
-- Name: idx_auth_sessions_refresh_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_auth_sessions_refresh_token_hash ON public.auth_sessions USING btree (refresh_token_hash);


--
-- Name: idx_auth_sessions_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_auth_sessions_user_id ON public.auth_sessions USING btree (user_id);


--
-- Name: idx_delivery_address_one_default_per_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_delivery_address_one_default_per_user ON public.delivery_address USING btree (user_id) WHERE (is_default = true);


--
-- Name: idx_delivery_address_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_delivery_address_user_id ON public.delivery_address USING btree (user_id);


--
-- Name: idx_favorite_list_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_favorite_list_user_id ON public.favorite_list USING btree (user_id);


--
-- Name: idx_file_metadata_related_object_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_file_metadata_related_object_id ON public.file_metadata USING btree (related_object_id);


--
-- Name: idx_product_image_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_image_product_id ON public.product_image USING btree (product_id);


--
-- Name: idx_product_reviews_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_reviews_product_id ON public.product_reviews USING btree (product_id);


--
-- Name: idx_product_reviews_product_id_rating; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_reviews_product_id_rating ON public.product_reviews USING btree (product_id, rating);


--
-- Name: auth_sessions auth_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_sessions
    ADD CONSTRAINT auth_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_details(id) ON DELETE CASCADE;


--
-- Name: delivery_address delivery_address_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_address
    ADD CONSTRAINT delivery_address_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user_details(id) ON DELETE CASCADE;


--
-- Name: orders fk_address; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_address FOREIGN KEY (address_id) REFERENCES public.address(id) ON DELETE CASCADE;


--
-- Name: user_details fk_address; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_details
    ADD CONSTRAINT fk_address FOREIGN KEY (address_id) REFERENCES public.address(id) ON DELETE CASCADE;


--
-- Name: favorite_item fk_favorite; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite_item
    ADD CONSTRAINT fk_favorite FOREIGN KEY (favorite_id) REFERENCES public.favorite_list(id) ON DELETE CASCADE;


--
-- Name: favorite_list fk_favorite_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite_list
    ADD CONSTRAINT fk_favorite_user FOREIGN KEY (user_id) REFERENCES public.user_details(id) ON DELETE CASCADE;


--
-- Name: order_item fk_order; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES public.orders(id) ON DELETE CASCADE;


--
-- Name: favorite_item fk_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorite_item
    ADD CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: product_reviews fk_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: product_reviews_likes fk_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews_likes
    ADD CONSTRAINT fk_product FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- Name: product_reviews_likes fk_review; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews_likes
    ADD CONSTRAINT fk_review FOREIGN KEY (review_id) REFERENCES public.product_reviews(id) ON DELETE CASCADE;


--
-- Name: product_reviews fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.user_details(id) ON DELETE CASCADE;


--
-- Name: product_reviews_likes fk_user; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_reviews_likes
    ADD CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES public.user_details(id) ON DELETE CASCADE;


--
-- Name: login_attempts fk_user_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.login_attempts
    ADD CONSTRAINT fk_user_id FOREIGN KEY (user_email) REFERENCES public.user_details(email) ON DELETE CASCADE;


--
-- Name: product_image product_image_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_image
    ADD CONSTRAINT product_image_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.product(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict hnaMpsCNfeJdfG1MMxGNnS93Be27ZIOjUup41dp9mtCz7ZCD5N2IH7msfIF2XAF

