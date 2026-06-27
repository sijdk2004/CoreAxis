--
-- PostgreSQL database dump
--

\restrict Jfs36tLkhSfd4gqHHlWkirz25m4QQHlE4AqYlz8DFTNvNaeBOJugocidcDyiDIL

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.audit_logs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    is_active boolean DEFAULT true,
    created_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    updated_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by text,
    remarks text,
    user_id text,
    action character varying(100) NOT NULL,
    entity_name character varying(100),
    entity_id character varying(100),
    details text,
    ip_address character varying(50),
    user_agent character varying(255)
);


ALTER TABLE public.audit_logs OWNER TO postgres;

--
-- Name: bom_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bom_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    bom_id uuid NOT NULL,
    component_id uuid NOT NULL,
    quantity numeric(10,2) NOT NULL,
    uom_id uuid NOT NULL,
    unit_cost numeric(12,2) DEFAULT 0,
    total_cost numeric(12,2) DEFAULT 0
);


ALTER TABLE public.bom_items OWNER TO postgres;

--
-- Name: boms; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.boms (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    remarks text,
    product_id uuid NOT NULL,
    version_number integer DEFAULT 1 NOT NULL,
    active_version boolean DEFAULT false,
    status character varying(50) DEFAULT 'Draft'::character varying NOT NULL,
    material_cost numeric(12,2) DEFAULT 0,
    labor_cost numeric(12,2) DEFAULT 0,
    overhead_cost numeric(12,2) DEFAULT 0,
    total_cost numeric(12,2) DEFAULT 0
);


ALTER TABLE public.boms OWNER TO postgres;

--
-- Name: cities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cities (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    state_id uuid NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by text,
    organization_id character varying(50),
    remarks text
);


ALTER TABLE public.cities OWNER TO postgres;

--
-- Name: countries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.countries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by text,
    organization_id character varying(50),
    remarks text
);


ALTER TABLE public.countries OWNER TO postgres;

--
-- Name: customer_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_types (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid
);


ALTER TABLE public.customer_types OWNER TO postgres;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    customer_type_id uuid,
    name character varying(200) NOT NULL,
    email character varying(100),
    phone character varying(50),
    address_line1 character varying(255),
    address_line2 character varying(255),
    country_id uuid,
    state_id uuid,
    city_id uuid,
    zip_code character varying(20),
    tax_id character varying(50),
    credit_limit numeric(15,2) DEFAULT 0.0,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by text,
    remarks text
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: deliveries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deliveries (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    remarks text,
    delivery_number character varying(50) NOT NULL,
    quotation_id character varying(50),
    sales_order_id character varying(50),
    production_order_id uuid NOT NULL,
    customer_id uuid NOT NULL,
    delivery_date timestamp without time zone,
    expected_delivery_date timestamp without time zone NOT NULL,
    status character varying(50) DEFAULT 'Scheduled'::character varying NOT NULL,
    assigned_vehicle character varying(100),
    assigned_driver character varying(100),
    delivery_notes text,
    customer_acknowledgement boolean DEFAULT false
);


ALTER TABLE public.deliveries OWNER TO postgres;

--
-- Name: delivery_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delivery_statuses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid
);


ALTER TABLE public.delivery_statuses OWNER TO postgres;

--
-- Name: delivery_timeline_histories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.delivery_timeline_histories (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    delivery_id uuid NOT NULL,
    stage character varying(50) NOT NULL,
    "timestamp" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    user_id uuid,
    remarks text
);


ALTER TABLE public.delivery_timeline_histories OWNER TO postgres;

--
-- Name: master_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.master_data (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    is_active boolean DEFAULT true,
    created_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    updated_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by text,
    remarks text,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    sort_order bigint DEFAULT 0,
    type character varying(50) NOT NULL
);


ALTER TABLE public.master_data OWNER TO postgres;

--
-- Name: menus; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.menus (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    menu_code character varying(50) NOT NULL,
    menu_name character varying(100) NOT NULL,
    module_code character varying(50),
    screen_code character varying(50),
    parent_menu_id uuid,
    icon_name character varying(50),
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    tenant_id character varying(50) DEFAULT 'SYSTEM_TENANT'::character varying NOT NULL
);


ALTER TABLE public.menus OWNER TO postgres;

--
-- Name: modules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.modules (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    module_code character varying(50) NOT NULL,
    module_name character varying(100) NOT NULL,
    module_type character varying(50) NOT NULL,
    industry_code character varying(50),
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    remarks text
);


ALTER TABLE public.modules OWNER TO postgres;

--
-- Name: order_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_statuses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid
);


ALTER TABLE public.order_statuses OWNER TO postgres;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    permission_code character varying(100) NOT NULL,
    module_code character varying(50) NOT NULL,
    screen_code character varying(50) NOT NULL,
    action_type character varying(50) NOT NULL,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by text,
    remarks text,
    tenant_id character varying(50) DEFAULT 'SYSTEM_TENANT'::character varying NOT NULL,
    organization_id character varying(50),
    display_name character varying(100),
    description text
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: product_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_categories (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid
);


ALTER TABLE public.product_categories OWNER TO postgres;

--
-- Name: production_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.production_orders (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    remarks text,
    sales_order_id character varying(50),
    product_id uuid NOT NULL,
    bom_id uuid NOT NULL,
    bom_version integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    planned_start_date timestamp without time zone,
    planned_end_date timestamp without time zone,
    status character varying(50) DEFAULT 'Draft'::character varying NOT NULL,
    material_cost numeric(12,2) DEFAULT 0,
    labor_cost numeric(12,2) DEFAULT 0,
    overhead_cost numeric(12,2) DEFAULT 0,
    total_cost numeric(12,2) DEFAULT 0
);


ALTER TABLE public.production_orders OWNER TO postgres;

--
-- Name: production_stage_histories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.production_stage_histories (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    remarks text,
    tracking_id uuid NOT NULL,
    stage character varying(100) NOT NULL,
    stage_entered_at timestamp without time zone NOT NULL,
    stage_started_at timestamp without time zone,
    stage_completed_at timestamp without time zone,
    duration_minutes integer,
    delay_reason character varying(255),
    completed_by_user_id uuid
);


ALTER TABLE public.production_stage_histories OWNER TO postgres;

--
-- Name: production_stages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.production_stages (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid
);


ALTER TABLE public.production_stages OWNER TO postgres;

--
-- Name: production_trackings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.production_trackings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    remarks text,
    production_order_id uuid NOT NULL,
    current_stage character varying(100) NOT NULL,
    assigned_team character varying(100),
    assigned_employee_id uuid,
    completion_percentage integer DEFAULT 0,
    stage_start_date timestamp without time zone,
    stage_end_date timestamp without time zone
);


ALTER TABLE public.production_trackings OWNER TO postgres;

--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    product_code character varying(50) NOT NULL,
    product_name character varying(200) NOT NULL,
    category_id uuid,
    wood_type_id uuid,
    uom_id uuid,
    base_price numeric(15,2) DEFAULT 0.0,
    description text,
    image_url character varying(500),
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by text,
    remarks text
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: quotation_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quotation_items (
    id character varying(50) NOT NULL,
    quotation_id character varying(50) NOT NULL,
    product_id uuid NOT NULL,
    quantity bigint DEFAULT 1 NOT NULL,
    unit_price numeric(15,2) NOT NULL,
    total_price numeric(15,2) NOT NULL
);


ALTER TABLE public.quotation_items OWNER TO postgres;

--
-- Name: quotation_statuses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quotation_statuses (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid
);


ALTER TABLE public.quotation_statuses OWNER TO postgres;

--
-- Name: quotations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.quotations (
    id character varying(50) NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    customer_id uuid NOT NULL,
    status character varying(50) DEFAULT 'Draft'::character varying NOT NULL,
    date_created timestamp with time zone NOT NULL,
    valid_until timestamp with time zone NOT NULL,
    subtotal numeric(15,2) DEFAULT 0 NOT NULL,
    discount numeric(15,2) DEFAULT 0 NOT NULL,
    tax numeric(15,2) DEFAULT 0 NOT NULL,
    total numeric(15,2) DEFAULT 0 NOT NULL,
    notes text,
    created_by character varying(50),
    created_on timestamp with time zone,
    updated_by character varying(50),
    updated_on timestamp with time zone,
    is_active boolean DEFAULT true
);


ALTER TABLE public.quotations OWNER TO postgres;

--
-- Name: revoked_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.revoked_tokens (
    token character varying(512) NOT NULL,
    revoked_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL
);


ALTER TABLE public.revoked_tokens OWNER TO postgres;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_permissions (
    role_id uuid NOT NULL,
    permission_id uuid NOT NULL,
    tenant_id character varying(50) NOT NULL,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid
);


ALTER TABLE public.role_permissions OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    role_code character varying(50) NOT NULL,
    role_name character varying(100) NOT NULL,
    is_system_role boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    remarks text
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: sales_order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_order_items (
    id character varying(50) NOT NULL,
    sales_order_id character varying(50) NOT NULL,
    product_id uuid NOT NULL,
    quantity bigint DEFAULT 1 NOT NULL,
    unit_price numeric(15,2) NOT NULL,
    total_price numeric(15,2) NOT NULL
);


ALTER TABLE public.sales_order_items OWNER TO postgres;

--
-- Name: sales_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_orders (
    id character varying(50) NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    customer_id uuid NOT NULL,
    quotation_id character varying(50),
    status character varying(50) DEFAULT 'Draft'::character varying NOT NULL,
    order_date timestamp with time zone NOT NULL,
    total_amount numeric(15,2) DEFAULT 0 NOT NULL,
    created_by character varying(50),
    created_on timestamp with time zone,
    updated_by character varying(50),
    updated_on timestamp with time zone,
    is_active boolean DEFAULT true,
    expected_delivery_date timestamp with time zone,
    subtotal numeric(15,2) DEFAULT 0 NOT NULL,
    discount numeric(15,2) DEFAULT 0 NOT NULL,
    tax numeric(15,2) DEFAULT 0 NOT NULL,
    remarks text
);


ALTER TABLE public.sales_orders OWNER TO postgres;

--
-- Name: screens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.screens (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    screen_code character varying(50) NOT NULL,
    screen_name character varying(100) NOT NULL,
    module_code character varying(50) NOT NULL,
    route_path character varying(200) NOT NULL,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid,
    remarks text
);


ALTER TABLE public.screens OWNER TO postgres;

--
-- Name: states; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.states (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    country_id uuid NOT NULL,
    code character varying(10) NOT NULL,
    name character varying(100) NOT NULL,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by text,
    organization_id character varying(50),
    remarks text
);


ALTER TABLE public.states OWNER TO postgres;

--
-- Name: units_of_measure; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.units_of_measure (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid
);


ALTER TABLE public.units_of_measure OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    user_id uuid NOT NULL,
    role_id uuid NOT NULL,
    tenant_id character varying(50) NOT NULL,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    organization_id character varying(50),
    branch_id character varying(50),
    department_id character varying(50),
    username character varying(100) NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    first_name character varying(100) NOT NULL,
    last_name character varying(100),
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by text,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by text,
    remarks text,
    mobile character varying(20),
    designation character varying(100),
    department character varying(100)
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: wood_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wood_types (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    tenant_id character varying(50) NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true,
    created_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    created_by uuid,
    updated_on timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_by uuid
);


ALTER TABLE public.wood_types OWNER TO postgres;

--
-- Data for Name: audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.audit_logs (id, tenant_id, organization_id, is_active, created_on, created_by, updated_on, updated_by, remarks, user_id, action, entity_name, entity_id, details, ip_address, user_agent) FROM stdin;
a58c29f1-491a-4212-b717-81f7a77bcad2	SYSTEM_TENANT	\N	t	2026-06-21 12:12:21.891949+05:30	\N	2026-06-21 12:12:21.891949+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Dashboard Viewed	\N	\N	Executive Dashboard loaded with timeframe: YTD	\N	\N
81861be5-b0bb-4cd9-bfdf-e6999f2c7aca	SYSTEM_TENANT	\N	t	2026-06-21 12:32:33.659948+05:30	\N	2026-06-21 12:32:33.659948+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Dashboard Viewed	\N	\N	Executive Dashboard loaded with timeframe: YTD	\N	\N
885c86c6-e8b9-4666-b2a7-d4eee945faba	SYSTEM_TENANT	\N	t	2026-06-21 12:52:46.864959+05:30	\N	2026-06-21 12:52:46.864959+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Dashboard Viewed	\N	\N	Executive Dashboard loaded with timeframe: YTD	\N	\N
e693cfce-a321-4dee-9ec4-7f7774a31795	SYSTEM_TENANT	\N	t	2026-06-21 12:54:48.521012+05:30	\N	2026-06-21 12:54:48.521012+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Dashboard Viewed	\N	\N	Executive Dashboard loaded with timeframe: YTD	\N	\N
e74181e3-3dbc-47d8-b472-bd5b25f07fe1	SYSTEM_TENANT	\N	t	2026-06-21 13:22:26.656724+05:30	\N	2026-06-21 13:22:26.656724+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Dashboard Viewed	\N	\N	Executive Dashboard loaded with timeframe: YTD	\N	\N
b80b4a56-7a1f-4bb2-8b85-bcbdaa746a14	SYSTEM_TENANT	\N	t	2026-06-21 16:48:33.675387+05:30	\N	2026-06-21 16:48:33.675387+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Sales Dashboard Viewed	\N	\N	Sales Dashboard loaded with timeframe: YTD	\N	\N
29e4ca22-7c25-40d8-b347-22cee6f72176	SYSTEM_TENANT	\N	t	2026-06-21 16:48:47.327646+05:30	\N	2026-06-21 16:48:47.327646+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Manufacturing Dashboard Viewed	\N	\N	Manufacturing Dashboard loaded with timeframe: YTD	\N	\N
15846408-7928-4c46-8c42-e4e322b54b19	SYSTEM_TENANT	\N	t	2026-06-21 16:48:59.636888+05:30	\N	2026-06-21 16:48:59.636888+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Dashboard Viewed	\N	\N	Executive Dashboard loaded with timeframe: YTD	\N	\N
25f46bd9-cffd-4289-999d-92ff370401f0	SYSTEM_TENANT	\N	t	2026-06-21 18:52:08.909533+05:30	\N	2026-06-21 18:52:08.909533+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Dashboard Viewed	\N	\N	Executive Dashboard loaded with timeframe: YTD	\N	\N
8ca3389d-f1f3-4b96-9ea3-5abe7539f9e4	SYSTEM_TENANT	\N	t	2026-06-21 18:52:17.013573+05:30	\N	2026-06-21 18:52:17.013573+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Manufacturing Dashboard Viewed	\N	\N	Manufacturing Dashboard loaded with timeframe: YTD	\N	\N
b9329bd7-4d44-41fb-9eff-e42c106690f2	SYSTEM_TENANT	\N	t	2026-06-21 18:52:20.156307+05:30	\N	2026-06-21 18:52:20.156307+05:30	\N	\N	00000000-0000-0000-0000-000000000001	Sales Dashboard Viewed	\N	\N	Sales Dashboard loaded with timeframe: YTD	\N	\N
\.


--
-- Data for Name: bom_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bom_items (id, bom_id, component_id, quantity, uom_id, unit_cost, total_cost) FROM stdin;
70d0a204-2655-4dc3-ad58-078f5537f45b	d1a2b3c4-e5f6-4a5b-8c7d-9e0f1a2b3c4d	9c7b1c9b-aa54-4b43-85c0-a557df0c11cc	4.00	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	37.50	150.00
\.


--
-- Data for Name: boms; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.boms (id, tenant_id, organization_id, is_active, created_on, created_by, updated_on, updated_by, remarks, product_id, version_number, active_version, status, material_cost, labor_cost, overhead_cost, total_cost) FROM stdin;
d1a2b3c4-e5f6-4a5b-8c7d-9e0f1a2b3c4d	SYSTEM_TENANT	\N	t	2026-06-20 12:59:00.664225	\N	2026-06-20 12:59:00.664225	\N	\N	5f77154d-b199-4f9e-b207-73d43a39b2ce	1	t	Active	150.00	50.00	20.00	220.00
9d31ba8d-8572-487e-97aa-365f7e45b82f	SYSTEM_TENANT	\N	t	2026-06-20 10:06:50.654171	\N	2026-06-20 10:06:50.654171	\N	\N	23c55daa-c4e9-4320-a911-f5a47441998b	1	f	Approved	0.00	0.00	0.00	0.00
be2b12aa-ac1b-4ced-a3e0-94a47a8b0f18	SYSTEM_TENANT	\N	t	2026-06-21 09:37:55.048798	\N	2026-06-21 09:37:55.048798	\N	\N	9332670a-e9fb-472b-9b7f-f76b2cea5590	1	t	Active	0.00	0.00	0.00	621.20
9bd8ebd9-f724-4e3a-b92a-24dbf416c9c8	SYSTEM_TENANT	\N	t	2026-03-21 09:37:55.050144	\N	2026-03-21 09:37:55.050144	\N	\N	39285631-311c-4021-bf26-a6b22fd10818	1	t	Active	0.00	0.00	0.00	714.40
cb07e8b4-b4e2-4f46-9f8a-967352ef7bda	SYSTEM_TENANT	\N	t	2026-01-21 09:37:55.050934	\N	2026-01-21 09:37:55.050934	\N	\N	02e2b771-48ee-42ac-bfcd-66c9d91b93f0	1	t	Active	0.00	0.00	0.00	574.80
fcb200e9-9978-4a8f-b375-f335c8d7c943	SYSTEM_TENANT	\N	t	2026-02-21 09:37:55.051566	\N	2026-02-21 09:37:55.051566	\N	\N	09826aba-e956-4206-b76b-7ee17afb88e8	1	t	Active	0.00	0.00	0.00	257.20
c2cfd166-e575-4e3d-a235-74552088b88f	SYSTEM_TENANT	\N	t	2026-04-21 09:37:55.052125	\N	2026-04-21 09:37:55.052125	\N	\N	247e5569-01f7-4037-8acf-6e01631534e1	1	t	Active	0.00	0.00	0.00	208.80
16486ded-8a3a-41a4-bb74-c7b918df7985	SYSTEM_TENANT	\N	t	2026-03-21 09:37:55.052664	\N	2026-03-21 09:37:55.052664	\N	\N	588f5625-138a-4285-bfee-3e552ed4a1d2	1	t	Active	0.00	0.00	0.00	378.00
ceee9baf-3a1c-4420-87ef-222e73be9a13	SYSTEM_TENANT	\N	t	2026-04-21 09:37:55.053231	\N	2026-04-21 09:37:55.053231	\N	\N	9f463dc3-4053-48ed-a640-c7caa0cda2f4	1	t	Active	0.00	0.00	0.00	84.80
be8237b5-9ce8-4d07-8786-0ae07e4375d6	SYSTEM_TENANT	\N	t	2026-03-21 09:37:55.053811	\N	2026-03-21 09:37:55.053811	\N	\N	9918534a-b9c8-416d-abe1-8ae921aba300	1	t	Active	0.00	0.00	0.00	54.80
c720d908-0f3e-4bcf-927f-e3643daa5129	SYSTEM_TENANT	\N	t	2026-05-21 09:37:55.054385	\N	2026-05-21 09:37:55.054385	\N	\N	a378380a-6760-4808-8c54-81aa3a4a2cc3	1	t	Active	0.00	0.00	0.00	700.00
eb6854ed-cf50-4f50-a74c-3541dadd4cb3	SYSTEM_TENANT	\N	t	2026-02-21 09:37:55.054913	\N	2026-02-21 09:37:55.054913	\N	\N	89038509-4759-404b-bd35-baefcb799aac	1	t	Active	0.00	0.00	0.00	477.20
2c91e2c3-d70a-4699-ab29-6dce9701ec80	SYSTEM_TENANT	\N	t	2026-06-21 09:37:55.054913	\N	2026-06-21 09:37:55.054913	\N	\N	39285631-311c-4021-bf26-a6b22fd10818	1	t	Active	0.00	0.00	0.00	714.40
aafe5b39-0280-4ad9-83a5-ae4358a8e048	SYSTEM_TENANT	\N	t	2026-05-21 09:37:55.055649	\N	2026-05-21 09:37:55.055649	\N	\N	13bf25f5-0a28-46c1-9e1e-667fb40ab2e4	1	t	Active	0.00	0.00	0.00	174.00
b6a39e4d-ab8a-4612-ae78-cfc6694b3230	SYSTEM_TENANT	\N	t	2026-05-21 09:37:55.05617	\N	2026-05-21 09:37:55.05617	\N	\N	723c36f7-5bec-4037-8e94-6fd483fae9c3	1	t	Active	0.00	0.00	0.00	667.60
bf5fa587-08d3-4939-a660-8db653ff0dff	SYSTEM_TENANT	\N	t	2026-01-21 09:37:55.056712	\N	2026-01-21 09:37:55.056712	\N	\N	e1c83f92-5a08-4fa1-9fb7-a73a2f714d4e	1	t	Active	0.00	0.00	0.00	579.20
c626c7c2-672b-4604-911c-4cea928f3fc4	SYSTEM_TENANT	\N	t	2026-03-21 09:37:55.05726	\N	2026-03-21 09:37:55.05726	\N	\N	588f5625-138a-4285-bfee-3e552ed4a1d2	1	t	Active	0.00	0.00	0.00	378.00
\.


--
-- Data for Name: cities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cities (id, tenant_id, state_id, code, name, is_active, created_on, created_by, updated_on, updated_by, organization_id, remarks) FROM stdin;
55555555-5555-5555-5555-555555555555	SYSTEM_TENANT	33333333-3333-3333-3333-333333333333	SF	San Francisco	t	2026-06-19 21:56:31.519627	\N	2026-06-19 21:56:31.519627	\N	\N	\N
66666666-6666-6666-6666-666666666666	SYSTEM_TENANT	44444444-4444-4444-4444-444444444444	CHE	Chennai	t	2026-06-19 21:56:31.519627	\N	2026-06-19 21:56:31.519627	\N	\N	\N
\.


--
-- Data for Name: countries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.countries (id, tenant_id, code, name, is_active, created_on, created_by, updated_on, updated_by, organization_id, remarks) FROM stdin;
11111111-1111-1111-1111-111111111111	SYSTEM_TENANT	US	United States	t	2026-06-19 21:56:31.515349	\N	2026-06-19 21:56:31.515349	\N	\N	\N
22222222-2222-2222-2222-222222222222	SYSTEM_TENANT	IN	India	t	2026-06-19 21:56:31.515349	\N	2026-06-19 21:56:31.515349	\N	\N	\N
\.


--
-- Data for Name: customer_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_types (id, tenant_id, code, name, description, sort_order, is_active, created_on, created_by, updated_on, updated_by) FROM stdin;
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, tenant_id, organization_id, customer_type_id, name, email, phone, address_line1, address_line2, country_id, state_id, city_id, zip_code, tax_id, credit_limit, is_active, created_on, created_by, updated_on, updated_by, remarks) FROM stdin;
0c56601e-f6c8-4d97-8c4e-198d14f71890	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	John Doe	john.doe@example.com	+1 555-0100	123 Furniture St	\N	\N	\N	\N	\N	\N	5000.00	t	2026-06-20 12:01:35.17795	\N	2026-06-20 06:31:35.17811	\N	\N
f02a95ab-2246-4d53-9b68-7d5fce9c5f30	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	Acme Corp	contact@acme.com	+1 555-0200	456 Corporate Blvd	\N	\N	\N	\N	\N	\N	100000.00	t	2026-06-20 12:01:35.17795	\N	2026-06-20 06:31:35.17811	\N	\N
79a9ddfe-c94e-4bd3-81f6-8f8a66283177	SYSTEM_TENANT	\N	f4b8e4f9-2bb0-43ab-9ab0-9aa76d581d64	Global Tech Offices	contact_0@example.com	+1-555-1000	100 Main St, Suite 1	\N	\N	\N	\N	\N	\N	8781.00	t	2026-05-23 09:37:54.85008	\N	2026-05-23 09:37:54.85008	\N	\N
8509b93e-4358-48e3-bafe-e8feff13e134	SYSTEM_TENANT	\N	f4b8e4f9-2bb0-43ab-9ab0-9aa76d581d64	Grand Hotel Suites	contact_1@example.com	+1-555-1001	110 Main St, Suite 2	\N	\N	\N	\N	\N	\N	44661.00	t	2026-02-26 09:37:54.895408	\N	2026-02-26 09:37:54.895408	\N	\N
a59c60a2-991b-45a7-9461-09e9d73ea240	SYSTEM_TENANT	\N	f4b8e4f9-2bb0-43ab-9ab0-9aa76d581d64	Urban Dine Restaurant	contact_2@example.com	+1-555-1002	120 Main St, Suite 3	\N	\N	\N	\N	\N	\N	7078.00	t	2026-05-19 09:37:54.897123	\N	2026-05-19 09:37:54.897123	\N	\N
2997f6eb-091e-45e1-bb77-73bf6e86664b	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	Vertex Corp	contact_3@example.com	+1-555-1003	130 Main St, Suite 4	\N	\N	\N	\N	\N	\N	23932.00	t	2026-01-21 09:37:54.898955	\N	2026-01-21 09:37:54.898955	\N	\N
43212494-6c07-4116-a77f-b00e2a169ddc	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	Apex Interior Designs	contact_4@example.com	+1-555-1004	140 Main St, Suite 5	\N	\N	\N	\N	\N	\N	32960.00	t	2026-04-29 09:37:54.901494	\N	2026-04-29 09:37:54.901494	\N	\N
878c2485-51b1-4e63-a2f4-a70c411a42c3	SYSTEM_TENANT	\N	f4b8e4f9-2bb0-43ab-9ab0-9aa76d581d64	Starlight Cafe	contact_5@example.com	+1-555-1005	150 Main St, Suite 6	\N	\N	\N	\N	\N	\N	47670.00	t	2026-01-20 09:37:54.90355	\N	2026-01-20 09:37:54.90355	\N	\N
6bd243ca-d759-4f21-a0d3-2673e90da31c	SYSTEM_TENANT	\N	f4b8e4f9-2bb0-43ab-9ab0-9aa76d581d64	Oasis Resorts	contact_6@example.com	+1-555-1006	160 Main St, Suite 7	\N	\N	\N	\N	\N	\N	36298.00	t	2026-01-06 09:37:54.905406	\N	2026-01-06 09:37:54.905406	\N	\N
410e4938-562a-4994-b50e-f7b541ad1c73	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	Crestwood Designs	contact_7@example.com	+1-555-1007	170 Main St, Suite 8	\N	\N	\N	\N	\N	\N	39862.00	t	2026-03-01 09:37:54.907066	\N	2026-03-01 09:37:54.907066	\N	\N
24be5ae2-6af4-4c8b-a939-f478ed425d74	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	Lumina Spaces	contact_8@example.com	+1-555-1008	180 Main St, Suite 9	\N	\N	\N	\N	\N	\N	41354.00	t	2026-05-05 09:37:54.908975	\N	2026-05-05 09:37:54.908975	\N	\N
d6678617-b0f9-44f9-936a-54a4ec858ac7	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	John Smith	contact_9@example.com	+1-555-1009	190 Main St, Suite 10	\N	\N	\N	\N	\N	\N	23901.00	t	2026-06-13 09:37:54.910743	\N	2026-06-13 09:37:54.910743	\N	\N
c31a46d3-1215-47bc-bc70-651f90a88748	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	Emma Johnson	contact_10@example.com	+1-555-1010	200 Main St, Suite 11	\N	\N	\N	\N	\N	\N	34108.00	t	2026-03-06 09:37:54.912251	\N	2026-03-06 09:37:54.912251	\N	\N
d7822ded-bca0-4a08-8c97-14ba46bafd1f	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	Michael Williams	contact_11@example.com	+1-555-1011	210 Main St, Suite 12	\N	\N	\N	\N	\N	\N	27033.00	t	2026-03-07 09:37:54.913786	\N	2026-03-07 09:37:54.913786	\N	\N
c1958ad5-34f5-465a-bb27-5b1f6e5280e8	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	Sarah Brown	contact_12@example.com	+1-555-1012	220 Main St, Suite 13	\N	\N	\N	\N	\N	\N	5003.00	t	2026-04-22 09:37:54.915177	\N	2026-04-22 09:37:54.915177	\N	\N
9bcd51c3-12cc-44fb-b414-460ee8a74c44	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	David Jones	contact_13@example.com	+1-555-1013	230 Main St, Suite 14	\N	\N	\N	\N	\N	\N	5756.00	t	2026-04-08 09:37:54.916607	\N	2026-04-08 09:37:54.916607	\N	\N
81a62496-9b1d-4e7f-b821-c0b133ff79ec	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	Lisa Garcia	contact_14@example.com	+1-555-1014	240 Main St, Suite 15	\N	\N	\N	\N	\N	\N	6964.00	t	2026-01-03 09:37:54.918054	\N	2026-01-03 09:37:54.918054	\N	\N
9b2c4b86-4bcd-4641-a0ab-8b9b23a3d75d	SYSTEM_TENANT	\N	f4b8e4f9-2bb0-43ab-9ab0-9aa76d581d64	Robert Martinez	contact_15@example.com	+1-555-1015	250 Main St, Suite 16	\N	\N	\N	\N	\N	\N	31830.00	t	2026-01-07 09:37:54.919537	\N	2026-01-07 09:37:54.919537	\N	\N
8a717f51-2eaa-4a45-8e22-b20ccb59eae3	SYSTEM_TENANT	\N	f4b8e4f9-2bb0-43ab-9ab0-9aa76d581d64	Mary Rodriguez	contact_16@example.com	+1-555-1016	260 Main St, Suite 17	\N	\N	\N	\N	\N	\N	8205.00	t	2026-04-22 09:37:54.921071	\N	2026-04-22 09:37:54.921071	\N	\N
9607fbb9-eb6c-4a07-ba79-1c5dfd6a84cd	SYSTEM_TENANT	\N	c6e87cb7-d018-485e-91c5-ffa7e3468385	James Lee	contact_17@example.com	+1-555-1017	270 Main St, Suite 18	\N	\N	\N	\N	\N	\N	48101.00	t	2026-04-12 09:37:54.922586	\N	2026-04-12 09:37:54.922586	\N	\N
d121777d-10c5-4017-a05c-e5fb9436013b	SYSTEM_TENANT	\N	f4b8e4f9-2bb0-43ab-9ab0-9aa76d581d64	Patricia Walker	contact_18@example.com	+1-555-1018	280 Main St, Suite 19	\N	\N	\N	\N	\N	\N	5103.00	t	2026-05-04 09:37:54.924098	\N	2026-05-04 09:37:54.924098	\N	\N
4c289bb5-6aea-4e49-87df-54b8d9bcab9d	SYSTEM_TENANT	\N	f4b8e4f9-2bb0-43ab-9ab0-9aa76d581d64	Creative Hub Coworking	contact_19@example.com	+1-555-1019	290 Main St, Suite 20	\N	\N	\N	\N	\N	\N	35801.00	t	2026-04-11 09:37:54.926149	\N	2026-04-11 09:37:54.926149	\N	\N
\.


--
-- Data for Name: deliveries; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.deliveries (id, tenant_id, organization_id, is_active, created_on, created_by, updated_on, updated_by, remarks, delivery_number, quotation_id, sales_order_id, production_order_id, customer_id, delivery_date, expected_delivery_date, status, assigned_vehicle, assigned_driver, delivery_notes, customer_acknowledgement) FROM stdin;
e863a17e-14f3-40f7-b571-42acfc5ba333	SYSTEM_TENANT	\N	t	2026-06-20 21:12:29.263177	\N	2026-06-20 21:12:29.263177	\N	\N	DLV-001	\N	\N	9d67f243-bb40-48c5-a718-702ec243e106	0c56601e-f6c8-4d97-8c4e-198d14f71890	\N	2026-06-22 21:12:29.263177	Scheduled	Truck A-123	John Doe	Handle with care. Premium oak table.	f
1465581a-774d-4409-9755-d525421e1af9	SYSTEM_TENANT	\N	t	2026-06-20 21:12:29.271433	\N	2026-06-20 21:12:29.271433	\N	\N	DLV-002	\N	\N	9d67f243-bb40-48c5-a718-702ec243e106	0c56601e-f6c8-4d97-8c4e-198d14f71890	\N	2026-06-21 21:12:29.271433	In Transit	Van B-456	Jane Smith	Call customer before arrival.	f
\.


--
-- Data for Name: delivery_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delivery_statuses (id, tenant_id, code, name, description, sort_order, is_active, created_on, created_by, updated_on, updated_by) FROM stdin;
\.


--
-- Data for Name: delivery_timeline_histories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.delivery_timeline_histories (id, tenant_id, delivery_id, stage, "timestamp", user_id, remarks) FROM stdin;
\.


--
-- Data for Name: master_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.master_data (id, tenant_id, organization_id, is_active, created_on, created_by, updated_on, updated_by, remarks, code, name, description, sort_order, type) FROM stdin;
21066e13-98e6-4b2e-98e2-253a52440e17	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.761358+05:30	\N	2026-06-20 12:00:37.761748+05:30	\N	\N	OAK	Oak Wood	High quality oak wood	10	wood_types
e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.763473+05:30	\N	2026-06-20 12:00:37.763987+05:30	\N	\N	TEAK	Teak Wood	Premium teak wood	20	wood_types
4612582c-3902-4ecb-aad7-d3e568745756	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.764534+05:30	\N	2026-06-20 12:00:37.764783+05:30	\N	\N	PINE	Pine Wood	Standard pine wood	30	wood_types
6a01a95c-9fd6-40ff-a8ef-cec53636e45b	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.765053+05:30	\N	2026-06-20 12:00:37.765499+05:30	\N	\N	PCS	Pieces	Individual pieces	10	units_of_measure
7de436d2-9f55-49c4-8435-72305501bfeb	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.766105+05:30	\N	2026-06-20 12:00:37.766232+05:30	\N	\N	SET	Sets	Bundle of items	20	units_of_measure
871e5c36-60da-4836-a829-9003883b2a50	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.766629+05:30	\N	2026-06-20 12:00:37.766932+05:30	\N	\N	USD	US Dollar	$	10	currencies
a08d9312-95cd-4e26-b081-2cf80769e19b	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.767165+05:30	\N	2026-06-20 12:00:37.767648+05:30	\N	\N	EUR	Euro	€	20	currencies
c6e87cb7-d018-485e-91c5-ffa7e3468385	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.768206+05:30	\N	2026-06-20 12:00:37.768328+05:30	\N	\N	RETAIL	Retail Customer	Individual buyers	10	customer_types
f4b8e4f9-2bb0-43ab-9ab0-9aa76d581d64	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.768734+05:30	\N	2026-06-20 12:00:37.768903+05:30	\N	\N	WHOLESALE	Wholesale Customer	Bulk buyers	20	customer_types
350207a6-6b2e-4f88-a650-ad6b73d801b7	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.76926+05:30	\N	2026-06-20 12:00:37.769493+05:30	\N	\N	CHAIRS	Chairs & Seating	Chairs, Sofas, Stools	10	product_categories
5577d950-acbe-46af-8320-70957da028be	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.769785+05:30	\N	2026-06-20 12:00:37.770083+05:30	\N	\N	TABLES	Tables & Desks	Dining tables, Coffee tables, Desks	20	product_categories
f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	SYSTEM_TENANT	\N	t	2026-06-20 12:00:37.770315+05:30	\N	2026-06-20 12:00:37.770683+05:30	\N	\N	STORAGE	Storage	Cabinets, Wardrobes, Shelves	30	product_categories
7544816b-2ad8-445f-845d-6c7ee792aa0a	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.659591+05:30	\N	2026-06-20 12:08:34.65991+05:30	\N	\N	INV	Invoice	Standard Invoice	10	document_types
1124cbf8-a862-49b5-8085-4d58a75f85cf	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.660668+05:30	\N	2026-06-20 12:08:34.661116+05:30	\N	\N	PO	Purchase Order	Standard PO	20	document_types
690a9565-42d3-4f10-aac2-66d2be95a0a6	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.661708+05:30	\N	2026-06-20 12:08:34.661894+05:30	\N	\N	HQ	Headquarters	Main Branch	10	branches
fb07f7b7-5c7e-4853-b6cd-d1e4405be6eb	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.662263+05:30	\N	2026-06-20 12:08:34.662638+05:30	\N	\N	EAST	East Coast Branch	Eastern region operations	20	branches
fafb2fa7-64d3-4989-9487-7be17730ce54	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.663304+05:30	\N	2026-06-20 12:08:34.663412+05:30	\N	\N	SALES	Sales Dept	Sales and Marketing	10	departments
6784727c-5791-427a-8a2c-ae614e148438	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.663856+05:30	\N	2026-06-20 12:08:34.664272+05:30	\N	\N	PROD	Production Dept	Manufacturing	20	departments
cf41b4b8-3ebe-4bbc-88b2-74b79f82ae65	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.664909+05:30	\N	2026-06-20 12:08:34.665005+05:30	\N	\N	MGR	Manager	Department Manager	10	designations
4baa466a-8441-4e88-b448-eb889964a572	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.665435+05:30	\N	2026-06-20 12:08:34.665691+05:30	\N	\N	STAFF	Staff	Regular Staff	20	designations
e26ffa37-83e9-4e34-9a88-5e63ec7d5e8e	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.665956+05:30	\N	2026-06-20 12:08:34.66638+05:30	\N	\N	COLOR_RED	Red Polish	Red wood finish	10	product_variants
f9db24a3-bffe-4070-9db2-5f0daf203a81	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.66699+05:30	\N	2026-06-20 12:08:34.667339+05:30	\N	\N	COLOR_NATURAL	Natural Finish	Natural wood finish	20	product_variants
4c29ab29-d4f3-4816-a17e-bbee9dee6d78	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.667545+05:30	\N	2026-06-20 12:08:34.668049+05:30	\N	\N	CUTTING	Wood Cutting	Initial cutting phase	10	production_stages
cd3cb323-b877-4857-b97c-c44e01f9fd8e	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.668591+05:30	\N	2026-06-20 12:08:34.668665+05:30	\N	\N	ASSEMBLY	Assembly	Putting pieces together	20	production_stages
82d4219d-4734-426d-b44b-b90e46025089	SYSTEM_TENANT	\N	t	2026-06-20 12:08:34.669134+05:30	\N	2026-06-20 12:08:34.669243+05:30	\N	\N	FINISHING	Polishing & Finishing	Final touches	30	production_stages
425b63fd-ee19-4079-ba39-c55d2ef99849	SYSTEM_TENANT	\N	t	2026-06-20 15:35:16.324814+05:30	\N	2026-06-20 15:35:16.324814+05:30	\N	\N	CAT01	Seating		0	CATEGORY
9809a2dc-29dc-43ee-9902-b5ab877dbcc6	SYSTEM_TENANT	\N	t	2026-06-20 15:36:25.858452+05:30	\N	2026-06-20 15:36:25.858452+05:30	\N	\N	CAT01	Seating		0	CATEGORY
cfd8acf7-135b-45cc-98d0-8401a3ae37d4	SYSTEM_TENANT	\N	t	2026-06-20 15:36:50.643779+05:30	\N	2026-06-20 15:36:50.643779+05:30	\N	\N	CAT01	Seating		0	CATEGORY
\.


--
-- Data for Name: menus; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.menus (id, menu_code, menu_name, module_code, screen_code, parent_menu_id, icon_name, sort_order, is_active, created_on, created_by, updated_on, updated_by, tenant_id) FROM stdin;
c41960d1-614f-4cd0-b761-fc1aacd95794	MENU_DASHBOARD	Dashboard	DSH	DSH_HOME	\N	dashboard	10	t	2026-06-19 21:50:15.001134	\N	2026-06-19 21:50:15.001134	\N	SYSTEM_TENANT
64273e67-8c2a-4716-b239-663da2e802f5	MENU_CUSTOMERS	Customers	CUS	CUS_LIST	\N	users	20	t	2026-06-19 21:50:15.001134	\N	2026-06-19 21:50:15.001134	\N	SYSTEM_TENANT
e347b70d-2dcc-4965-917b-b11e5ed0d485	MENU_PRODUCTS	Catalog	PRD	PRD_LIST	\N	box	30	t	2026-06-19 21:50:15.001134	\N	2026-06-19 21:50:15.001134	\N	SYSTEM_TENANT
b7374ec0-5a7b-4994-a403-333ba3f50773	MENU_BOM	Bill of Materials	MFG	BOM_LIST	\N	box	35	t	2026-06-20 12:47:57.48096	\N	2026-06-20 12:47:57.48096	\N	SYSTEM_TENANT
472315eb-dc98-47c7-866d-c839ab11befa	MENU_PRD	Production	MFG	MFG_ORD_LIST	\N	factory	50	t	2026-06-20 13:12:23.567851	\N	2026-06-20 13:12:23.567851	\N	SYSTEM_TENANT
5257a0e1-b300-445e-a57f-e2a75b165981	MENU_TRK_BOARD	Production Board	MFG	TRK_BOARD	\N	layoutDashboard	55	t	2026-06-20 14:33:15.259746	\N	2026-06-20 14:33:15.259746	\N	SYSTEM_TENANT
c91b0554-2e21-46ac-ac3a-c91bcfa5718b	MENU_TRK_LIST	Production Tracking	MFG	TRK_LIST	\N	activity	60	t	2026-06-20 14:33:15.259746	\N	2026-06-20 14:33:15.259746	\N	SYSTEM_TENANT
c881cdbf-f8fd-48ec-88b2-f9ec23ba456b	MENU_DLV_LIST	Delivery Management	DLV	DLV_LIST	\N	truck	70	t	2026-06-20 21:02:42.717637	\N	2026-06-20 21:02:42.717637	\N	SYSTEM_TENANT
5a2174fa-55e5-40a3-81aa-a812c91bbb0c	MENU_USERS	Users	USR	USR_LIST	\N	\N	10	t	2026-06-19 21:50:15.006811	\N	2026-06-19 21:50:15.006811	\N	SYSTEM_TENANT
ec7bdcb4-0d1a-4ba8-b2d5-920ae9ca885b	MENU_ROLES	Roles	ROL	ROL_LIST	\N	\N	20	t	2026-06-19 21:50:15.014614	\N	2026-06-19 21:50:15.014614	\N	SYSTEM_TENANT
\.


--
-- Data for Name: modules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.modules (id, module_code, module_name, module_type, industry_code, is_active, created_on, created_by, updated_on, updated_by, remarks) FROM stdin;
e19c542b-e6d5-4434-8b9a-f8af03da6068	IAM	Identity Access Management	CORE	\N	t	2026-06-19 21:50:14.961495	\N	2026-06-19 21:50:14.961495	\N	\N
54d56ec0-a8b5-429d-928e-01caa1cf9316	USR	User Management	CORE	\N	t	2026-06-19 21:50:14.961495	\N	2026-06-19 21:50:14.961495	\N	\N
1a67360a-8290-409e-abf8-447c22bdc66c	ROL	Role Management	CORE	\N	t	2026-06-19 21:50:14.961495	\N	2026-06-19 21:50:14.961495	\N	\N
4f66f6b2-5435-4ebd-a633-f4fe6f1097d7	DSH	Dashboard	CORE	\N	t	2026-06-19 21:50:14.961495	\N	2026-06-19 21:50:14.961495	\N	\N
2964d474-10a4-4bc2-94a7-73d399671898	CUS	Customer Management	FOUNDATION	\N	t	2026-06-19 21:50:14.961495	\N	2026-06-19 21:50:14.961495	\N	\N
b5fa5db2-e5ad-4bfc-99ea-6150ba092f24	PRD	Product Catalog	FOUNDATION	\N	t	2026-06-19 21:50:14.961495	\N	2026-06-19 21:50:14.961495	\N	\N
380fb401-c9ed-4b74-bbc4-1b4b627533ac	SYS	System Admin	FOUNDATION	\N	t	2026-06-19 21:51:13.654637	\N	2026-06-19 21:51:13.654637	\N	\N
6827a6c6-e4cb-499f-8961-08b7fd40543a	CAT	Product Catalog	CORE	\N	t	2026-06-19 22:04:02.981533	\N	2026-06-19 22:04:02.981533	\N	\N
4d68e40f-a140-49bb-b88f-c908a0b70930	MFG	Manufacturing	CORE	\N	t	2026-06-20 12:47:57.469696	\N	2026-06-20 12:47:57.469696	\N	\N
5eeb31c0-91db-4fea-af10-12769dd55842	DLV	Delivery Management	CORE	\N	t	2026-06-20 20:52:54.28245	\N	2026-06-20 20:52:54.28245	\N	\N
\.


--
-- Data for Name: order_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_statuses (id, tenant_id, code, name, description, sort_order, is_active, created_on, created_by, updated_on, updated_by) FROM stdin;
71215d10-9834-4d16-b314-60ae4e8bc5a1	SYSTEM_TENANT	DRAFT	Draft	\N	10	t	2026-06-19 21:50:15.141963	\N	2026-06-19 21:50:15.141963	\N
f6d97968-e19b-4a98-ae3a-3724d115c095	SYSTEM_TENANT	CONFIRMED	Confirmed	\N	20	t	2026-06-19 21:50:15.141963	\N	2026-06-19 21:50:15.141963	\N
2b30f81e-086b-4365-b07c-13bf11939612	SYSTEM_TENANT	PROCESSING	Processing	\N	30	t	2026-06-19 21:50:15.141963	\N	2026-06-19 21:50:15.141963	\N
8b02bbca-a3b4-42f3-8639-652f8704f164	SYSTEM_TENANT	COMPLETED	Completed	\N	40	t	2026-06-19 21:50:15.141963	\N	2026-06-19 21:50:15.141963	\N
f61507a6-5ba3-4e59-ab8c-99f1ff9ffc9d	SYSTEM_TENANT	CANCELLED	Cancelled	\N	50	t	2026-06-19 21:50:15.141963	\N	2026-06-19 21:50:15.141963	\N
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, permission_code, module_code, screen_code, action_type, is_active, created_on, created_by, updated_on, updated_by, remarks, tenant_id, organization_id, display_name, description) FROM stdin;
5a23ed46-1a82-4eb6-9d67-7433aacbffe1	PRD.PRD_LIST.VIEW	PRD	PRD_LIST	VIEW	t	2026-06-19 21:50:14.990419	\N	2026-06-19 21:50:14.990419	\N	\N	SYSTEM_TENANT	\N	\N	\N
016902f1-65f6-4aca-823f-a266c62df5cc	CAT.CAT_CAT.VIEW	CAT	CAT_CAT	VIEW	t	2026-06-19 22:04:02.99055	\N	2026-06-19 22:04:02.99055	\N	\N	SYSTEM_TENANT	\N	\N	\N
63d698a8-4a38-42bd-81a5-0e2fa58349dc	CAT.CAT_CAT.CREATE	CAT	CAT_CAT	CREATE	t	2026-06-19 22:04:02.99055	\N	2026-06-19 22:04:02.99055	\N	\N	SYSTEM_TENANT	\N	\N	\N
5aedaac4-f210-4d3c-a601-6eb49994fa45	CAT.CAT_CAT.UPDATE	CAT	CAT_CAT	UPDATE	t	2026-06-19 22:04:02.99055	\N	2026-06-19 22:04:02.99055	\N	\N	SYSTEM_TENANT	\N	\N	\N
6219d1d4-eb7c-4b22-af2e-baa90a2b4a53	CAT.CAT_CAT.DELETE	CAT	CAT_CAT	DELETE	t	2026-06-19 22:04:02.99055	\N	2026-06-19 22:04:02.99055	\N	\N	SYSTEM_TENANT	\N	\N	\N
306a364a-c0ce-4ccb-903f-1457a9012c1a	MFG.PRD.DELETE	MFG	MFG_ORD_LIST	DELETE	t	2026-06-20 13:12:23.573231	\N	2026-06-20 13:12:23.573231	\N	\N	SYSTEM_TENANT	\N	\N	\N
ee01df53-fb94-435f-b61d-a5b098e5d991	DSH.DSH_HOME.VIEW	DSH	DSH_HOME	VIEW	t	2026-06-19 21:50:14.990419	\N	2026-06-19 21:50:14.990419	\N	\N	SYSTEM_TENANT	\N	View Executive Dashboard	Allows user to view the executive dashboard.
16150db4-5765-4be8-a31a-57158f17b011	MFG.DSH.VIEW	MFG	DSH	VIEW	t	2026-06-21 05:09:12.221094	\N	2026-06-21 05:09:12.221094	\N	\N	SYSTEM_TENANT	\N	View Manufacturing Dashboard	Allows user to view the manufacturing dashboard.
0b17858b-59a0-4eb1-8fcd-a438cb6524bc	USR.USR_LIST.VIEW	USR	USR_LIST	VIEW	t	2026-06-19 21:50:14.990419	\N	2026-06-19 21:50:14.990419	\N	\N	SYSTEM_TENANT	\N	View Users	Allows user to view user records.
925252b2-80d6-47ee-8099-c3e7956404e2	USR.USR_LIST.CREATE	USR	USR_LIST	CREATE	t	2026-06-19 21:50:14.990419	\N	2026-06-19 21:50:14.990419	\N	\N	SYSTEM_TENANT	\N	Create Users	Allows user to create user records.
3e8cfcd4-ffeb-459c-8d62-5e2f2b830fd7	USR.USR_LIST.UPDATE	USR	USR_LIST	UPDATE	t	2026-06-19 21:50:14.990419	\N	2026-06-19 21:50:14.990419	\N	\N	SYSTEM_TENANT	\N	Edit Users	Allows user to modify user records.
686c9091-9227-45db-b05b-89a8e9d8be06	USR.USR_LIST.DELETE	USR	USR_LIST	DELETE	t	2026-06-21 05:08:24.153374	\N	2026-06-21 05:08:24.153374	\N	\N	SYSTEM_TENANT	\N	Delete Users	Allows user to delete user records.
8a9c3185-a718-45de-b9e6-66838ce5db8d	ROL.ROL_LIST.VIEW	ROL	ROL_LIST	VIEW	t	2026-06-19 21:50:14.990419	\N	2026-06-19 21:50:14.990419	\N	\N	SYSTEM_TENANT	\N	View Roles	Allows user to view roles and permissions.
d7b3c8f9-1ab6-4ecc-84d0-b55f880ab3b2	ROL.ROL_LIST.CREATE	ROL	ROL_LIST	CREATE	t	2026-06-19 21:50:14.990419	\N	2026-06-19 21:50:14.990419	\N	\N	SYSTEM_TENANT	\N	Create Roles	Allows user to create new roles.
5d78adbe-8956-4cf7-9575-2da5f4f5ffc0	ROL.ROL_LIST.UPDATE	ROL	ROL_LIST	UPDATE	t	2026-06-19 21:50:14.990419	\N	2026-06-19 21:50:14.990419	\N	\N	SYSTEM_TENANT	\N	Edit Roles	Allows user to modify role permissions.
76adb14b-d791-4d3c-88f3-2f3b6b408fe9	ROL.ROL_LIST.DELETE	ROL	ROL_LIST	DELETE	t	2026-06-21 05:08:24.155587	\N	2026-06-21 05:08:24.155587	\N	\N	SYSTEM_TENANT	\N	Delete Roles	Allows user to delete roles.
296a7c9f-d96a-49ff-aadd-af007680d804	SYS.MASTER_DATA.VIEW	SYS	MASTER_DATA	VIEW	t	2026-06-19 21:51:25.246244	\N	2026-06-19 21:51:25.246244	\N	\N	SYSTEM_TENANT	\N	View Master Data	Allows user to view master data.
aa0844f7-6e54-4e07-866c-c33f173cb6c9	SYS.MASTER_DATA.CREATE	SYS	MASTER_DATA	CREATE	t	2026-06-19 21:51:25.246244	\N	2026-06-19 21:51:25.246244	\N	\N	SYSTEM_TENANT	\N	Create Master Data	Allows user to create master data.
750d3cc2-24da-47ab-aee2-5846fcd4e10d	SYS.MASTER_DATA.UPDATE	SYS	MASTER_DATA	UPDATE	t	2026-06-19 21:51:25.246244	\N	2026-06-19 21:51:25.246244	\N	\N	SYSTEM_TENANT	\N	Edit Master Data	Allows user to update master data.
458b5558-1c6e-4f54-8b43-853af82c29df	SYS.MASTER_DATA.DELETE	SYS	MASTER_DATA	DELETE	t	2026-06-19 21:51:25.246244	\N	2026-06-19 21:51:25.246244	\N	\N	SYSTEM_TENANT	\N	Delete Master Data	Allows user to delete master data.
0261c5bc-4727-45ae-8c51-efdd39970558	CUS.CUS_LIST.VIEW	CUS	CUS_LIST	VIEW	t	2026-06-19 21:50:14.990419	\N	2026-06-19 21:50:14.990419	\N	\N	SYSTEM_TENANT	\N	View Customers	Allows user to view customer records.
311874f8-1f61-4e83-b054-f06a4609cdca	CUS.CUS_LIST.CREATE	CUS	CUS_LIST	CREATE	t	2026-06-19 21:56:31.526418	\N	2026-06-19 21:56:31.526418	\N	\N	SYSTEM_TENANT	\N	Create Customers	Allows user to create customer records.
ecc482dc-9906-473f-9d76-566850444cc4	CUS.CUS_LIST.UPDATE	CUS	CUS_LIST	UPDATE	t	2026-06-19 21:56:31.526418	\N	2026-06-19 21:56:31.526418	\N	\N	SYSTEM_TENANT	\N	Edit Customers	Allows user to modify customer records.
3496a56f-86fa-442c-ae98-72140383dc7b	CUS.CUS_LIST.DELETE	CUS	CUS_LIST	DELETE	t	2026-06-19 21:56:31.526418	\N	2026-06-19 21:56:31.526418	\N	\N	SYSTEM_TENANT	\N	Delete Customers	Allows user to delete customer records.
8eec09da-66f2-4255-8772-3581f8cb1d9f	CAT.CAT_PROD.VIEW	CAT	CAT_PROD	VIEW	t	2026-06-19 22:04:02.99055	\N	2026-06-19 22:04:02.99055	\N	\N	SYSTEM_TENANT	\N	View Catalog	Allows user to view product catalog.
ea23ff76-86f4-476b-bf23-4c0c9eaa6b5e	CAT.CAT_PROD.CREATE	CAT	CAT_PROD	CREATE	t	2026-06-19 22:04:02.99055	\N	2026-06-19 22:04:02.99055	\N	\N	SYSTEM_TENANT	\N	Create Products	Allows user to create products.
ffd35033-37c1-4968-b323-0369e2c0e266	CAT.CAT_PROD.UPDATE	CAT	CAT_PROD	UPDATE	t	2026-06-19 22:04:02.99055	\N	2026-06-19 22:04:02.99055	\N	\N	SYSTEM_TENANT	\N	Edit Products	Allows user to modify products.
e3fb56f8-5592-4adf-b514-4d3b1a886fec	CAT.CAT_PROD.DELETE	CAT	CAT_PROD	DELETE	t	2026-06-19 22:04:02.99055	\N	2026-06-19 22:04:02.99055	\N	\N	SYSTEM_TENANT	\N	Delete Products	Allows user to delete products.
f21e08b7-439f-49b0-807c-af189dcdf172	QTN.QTN_MGMT.VIEW	QTN	QTN_MGMT	VIEW	t	2026-06-21 05:09:12.270319	\N	2026-06-21 05:09:12.270319	\N	\N	SYSTEM_TENANT	\N	View Quotations	Allows user to view quotations.
90a66597-b089-4a0a-bcce-a71c75e1bf52	QTN.QTN_MGMT.CREATE	QTN	QTN_MGMT	CREATE	t	2026-06-21 05:09:12.270766	\N	2026-06-21 05:09:12.270766	\N	\N	SYSTEM_TENANT	\N	Create Quotations	Allows user to create quotations.
130ebc70-83b8-4145-aaa6-966197d64256	QTN.QTN_MGMT.UPDATE	QTN	QTN_MGMT	UPDATE	t	2026-06-21 05:09:12.271324	\N	2026-06-21 05:09:12.271324	\N	\N	SYSTEM_TENANT	\N	Edit Quotations	Allows user to modify quotations.
3d2f0048-5fa8-42e0-82cf-dc91621bf13b	QTN.QTN_MGMT.DELETE	QTN	QTN_MGMT	DELETE	t	2026-06-21 05:09:12.2719	\N	2026-06-21 05:09:12.2719	\N	\N	SYSTEM_TENANT	\N	Delete Quotations	Allows user to delete quotations.
1cb4c24e-8361-4ab4-a755-b93b6b360ef2	SO.SO_LIST.VIEW	SO	SO_LIST	VIEW	t	2026-06-21 05:09:12.272397	\N	2026-06-21 05:09:12.272397	\N	\N	SYSTEM_TENANT	\N	View Sales Orders	Allows user to view sales orders.
e13b990d-1223-450a-a2b7-d7a60179efa3	SO.SO_LIST.UPDATE	SO	SO_LIST	UPDATE	t	2026-06-21 05:09:12.272865	\N	2026-06-21 05:09:12.272865	\N	\N	SYSTEM_TENANT	\N	Edit Sales Orders	Allows user to modify sales orders.
b2884675-a0c3-48e0-9395-66be6b1f90d9	SO.SO_VIEW.VIEW	SO	SO_VIEW	VIEW	t	2026-06-21 05:09:12.273294	\N	2026-06-21 05:09:12.273294	\N	\N	SYSTEM_TENANT	\N	View Order Details	Allows user to view sales order details.
43bef081-6538-40c6-b9b0-21e949ab0e06	SO.SO_STATUS.UPDATE	SO	SO_STATUS	UPDATE	t	2026-06-21 05:09:12.273708	\N	2026-06-21 05:09:12.273708	\N	\N	SYSTEM_TENANT	\N	Update Order Status	Allows user to update sales order status.
05473ee7-5288-449a-8591-e792983a00ae	MFG.BOM.VIEW	MFG	BOM_LIST	VIEW	t	2026-06-20 12:47:57.483123	\N	2026-06-20 12:47:57.483123	\N	\N	SYSTEM_TENANT	\N	View BOM	Allows user to view Bill of Materials.
a60bbf4b-2b42-4e2b-9349-9954e6373cf2	MFG.BOM.CREATE	MFG	BOM_LIST	CREATE	t	2026-06-20 12:47:57.483123	\N	2026-06-20 12:47:57.483123	\N	\N	SYSTEM_TENANT	\N	Create BOM	Allows user to create Bill of Materials.
a227128f-1fc4-4dfc-a1a5-07479a25564e	MFG.BOM.UPDATE	MFG	BOM_LIST	UPDATE	t	2026-06-20 12:47:57.483123	\N	2026-06-20 12:47:57.483123	\N	\N	SYSTEM_TENANT	\N	Edit BOM	Allows user to modify Bill of Materials.
df4497f5-2b18-4729-ade1-77f88ed451ab	MFG.PRD.CREATE	MFG	MFG_ORD_LIST	CREATE	t	2026-06-20 13:12:23.573231	\N	2026-06-20 13:12:23.573231	\N	\N	SYSTEM_TENANT	\N	Create Production Orders	Allows user to create production orders.
3c90e790-47f8-4cce-a105-f3c4318c4617	MFG.PRD.UPDATE	MFG	MFG_ORD_LIST	UPDATE	t	2026-06-20 13:12:23.573231	\N	2026-06-20 13:12:23.573231	\N	\N	SYSTEM_TENANT	\N	Edit Production Orders	Allows user to update production orders.
2e091517-4c1c-42fc-a335-8c95849b1723	MFG.TRK.VIEW	MFG	TRK_LIST	VIEW	t	2026-06-20 14:33:15.263842	\N	2026-06-20 14:33:15.263842	\N	\N	SYSTEM_TENANT	\N	View Production Tracking	Allows user to view production tracking details.
3da2fa8a-662d-449a-b25d-871336ca2464	DLV.DLV_LIST.VIEW	DLV	DLV_LIST	VIEW	t	2026-06-20 20:52:54.28997	\N	2026-06-20 20:52:54.28997	\N	\N	SYSTEM_TENANT	\N	View Deliveries	Allows user to view delivery management.
d9c54e1b-8a65-4566-b501-853f89f5b9d8	DLV.DLV_LIST.CREATE	DLV	DLV_LIST	CREATE	t	2026-06-20 20:52:54.28997	\N	2026-06-20 20:52:54.28997	\N	\N	SYSTEM_TENANT	\N	Create Deliveries	Allows user to create delivery schedules.
4fe19912-82fd-4da0-bbc5-13aed9bf6b00	MFG.PRD.VIEW	MFG	MFG_ORD_LIST	VIEW	t	2026-06-20 13:12:23.573231	\N	2026-06-20 13:12:23.573231	\N	\N	SYSTEM_TENANT	\N	View Production Orders	Allows user to view production orders.
77eba898-47a1-4970-ad66-e6512486d053	MFG.TRK.VIEW_BOARD	MFG	TRK_BOARD	VIEW	t	2026-06-20 14:33:15.263842	\N	2026-06-20 14:33:15.263842	\N	\N	SYSTEM_TENANT	\N	View Production Board	Allows user to view the production Kanban board.
8887537e-a1fc-4243-a4dd-c93924b3d52f	MFG.TRK.UPDATE	MFG	TRK_LIST	UPDATE	t	2026-06-20 14:33:15.263842	\N	2026-06-20 14:33:15.263842	\N	\N	SYSTEM_TENANT	\N	Update Production Tracking	Allows user to start and complete production stages.
eaf3c0ce-3c78-4682-95f5-86f71c85c945	DLV.DLV_LIST.UPDATE	DLV	DLV_LIST	UPDATE	t	2026-06-20 20:52:54.28997	\N	2026-06-20 20:52:54.28997	\N	\N	SYSTEM_TENANT	\N	Update Delivery Status	Allows user to update delivery status.
\.


--
-- Data for Name: product_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_categories (id, tenant_id, code, name, description, sort_order, is_active, created_on, created_by, updated_on, updated_by) FROM stdin;
\.


--
-- Data for Name: production_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.production_orders (id, tenant_id, organization_id, is_active, created_on, created_by, updated_on, updated_by, remarks, sales_order_id, product_id, bom_id, bom_version, quantity, planned_start_date, planned_end_date, status, material_cost, labor_cost, overhead_cost, total_cost) FROM stdin;
9d67f243-bb40-48c5-a718-702ec243e106	SYSTEM_TENANT	\N	t	2026-06-20 14:23:00.950262	\N	2026-06-20 14:23:00.950262	\N	\N	\N	5f77154d-b199-4f9e-b207-73d43a39b2ce	d1a2b3c4-e5f6-4a5b-8c7d-9e0f1a2b3c4d	1	5	2026-06-20 00:00:00	2026-06-25 00:00:00	Draft	150.00	50.00	20.00	220.00
994cbe1d-547d-4463-9191-a33a05b46f3b	SYSTEM_TENANT	\N	t	2026-06-20 14:23:11.007656	\N	2026-06-20 14:23:11.007656	\N	\N	\N	5f77154d-b199-4f9e-b207-73d43a39b2ce	d1a2b3c4-e5f6-4a5b-8c7d-9e0f1a2b3c4d	1	15	2026-06-18 00:00:00	2026-06-22 00:00:00	In Progress	450.00	150.00	60.00	660.00
54d8a77d-b359-4b55-a838-7ad225c8a867	SYSTEM_TENANT	\N	t	2026-06-20 14:23:20.027337	\N	2026-06-20 14:23:20.027337	\N	\N	\N	5f77154d-b199-4f9e-b207-73d43a39b2ce	d1a2b3c4-e5f6-4a5b-8c7d-9e0f1a2b3c4d	1	50	2026-06-10 00:00:00	2026-06-18 00:00:00	Completed	1500.00	500.00	200.00	2200.00
02ee5502-1f0e-4f8b-8749-7118b58564dc	SYSTEM_TENANT	\N	t	2026-06-20 10:06:50.656485	\N	2026-06-20 10:06:50.656485	\N	\N	\N	23c55daa-c4e9-4320-a911-f5a47441998b	9d31ba8d-8572-487e-97aa-365f7e45b82f	1	50	\N	\N	In Progress	0.00	0.00	0.00	0.00
78ce39c3-2523-49e4-bdaf-dd6cd8f9fffd	SYSTEM_TENANT	\N	t	2026-06-20 10:06:50.658216	\N	2026-06-20 10:06:50.658216	\N	\N	\N	fb9874a8-7e62-4e25-92d2-617c32ebff04	9d31ba8d-8572-487e-97aa-365f7e45b82f	2	20	\N	\N	In Progress	0.00	0.00	0.00	0.00
\.


--
-- Data for Name: production_stage_histories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.production_stage_histories (id, tenant_id, organization_id, is_active, created_on, created_by, updated_on, updated_by, remarks, tracking_id, stage, stage_entered_at, stage_started_at, stage_completed_at, duration_minutes, delay_reason, completed_by_user_id) FROM stdin;
09c2be5e-1891-485b-bf47-1498b08c02d5	SYSTEM_TENANT	\N	t	2026-06-20 10:06:50.661797	\N	2026-06-20 10:06:50.661797	\N	\N	c590263a-8b8e-4042-9fd9-04a35370254f	Assembly	2026-06-18 15:36:50.661237	\N	\N	\N	\N	\N
b7d0fba6-6fe8-4305-b36b-30eced8f1ff3	SYSTEM_TENANT	\N	t	2026-06-20 10:06:50.66371	\N	2026-06-20 10:06:50.66371	\N	\N	dbeeb104-a2f0-41ea-bf9b-5a74eecc1f42	Cutting	2026-06-19 15:36:50.663341	2026-06-20 15:37:22.410363	2026-06-20 15:37:27.72346	-329	\N	00000000-0000-0000-0000-000000000001
6a935ac7-a741-49de-9bf2-71f6df9a8a2b	SYSTEM_TENANT	\N	t	2026-06-20 10:07:27.732022	\N	2026-06-20 10:07:27.732022	\N	\N	dbeeb104-a2f0-41ea-bf9b-5a74eecc1f42	Carpentry	2026-06-20 15:37:27.731432	2026-06-21 16:50:31.523655	\N	\N	\N	\N
\.


--
-- Data for Name: production_stages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.production_stages (id, tenant_id, code, name, description, sort_order, is_active, created_on, created_by, updated_on, updated_by) FROM stdin;
bb554caa-d6a2-40a6-9a13-05d96986fc00	SYSTEM_TENANT	CUTTING	Cutting	\N	10	t	2026-06-19 21:50:15.147508	\N	2026-06-19 21:50:15.147508	\N
ce80d782-4f3e-4b18-8810-469def8d437b	SYSTEM_TENANT	CARPENTRY	Carpentry	\N	20	t	2026-06-19 21:50:15.147508	\N	2026-06-19 21:50:15.147508	\N
8b2c04d6-3576-419f-b600-ceab9a836799	SYSTEM_TENANT	SANDING	Sanding	\N	30	t	2026-06-19 21:50:15.147508	\N	2026-06-19 21:50:15.147508	\N
a73f4789-a918-4f7a-a578-093c3baccfbe	SYSTEM_TENANT	POLISHING	Polishing	\N	40	t	2026-06-19 21:50:15.147508	\N	2026-06-19 21:50:15.147508	\N
e4033e2a-fabb-4a43-809c-53c6b266bc81	SYSTEM_TENANT	QC	Quality Control	\N	50	t	2026-06-19 21:50:15.147508	\N	2026-06-19 21:50:15.147508	\N
\.


--
-- Data for Name: production_trackings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.production_trackings (id, tenant_id, organization_id, is_active, created_on, created_by, updated_on, updated_by, remarks, production_order_id, current_stage, assigned_team, assigned_employee_id, completion_percentage, stage_start_date, stage_end_date) FROM stdin;
c590263a-8b8e-4042-9fd9-04a35370254f	SYSTEM_TENANT	\N	t	2026-06-20 10:06:50.659357	\N	2026-06-20 10:06:50.659357	\N	\N	02ee5502-1f0e-4f8b-8749-7118b58564dc	Assembly	Assembly Team A	\N	45	\N	\N
dbeeb104-a2f0-41ea-bf9b-5a74eecc1f42	SYSTEM_TENANT	\N	t	2026-06-20 10:06:50.66114	\N	2026-06-20 10:06:50.66114	\N	\N	78ce39c3-2523-49e4-bdaf-dd6cd8f9fffd	Carpentry	Woodwork Team B	\N	18	2026-06-20 15:37:22.410363	\N
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, tenant_id, organization_id, product_code, product_name, category_id, wood_type_id, uom_id, base_price, description, image_url, is_active, created_on, created_by, updated_on, updated_by, remarks) FROM stdin;
5f77154d-b199-4f9e-b207-73d43a39b2ce	SYSTEM_TENANT	\N	TBL-001	Premium Oak Dining Table	5577d950-acbe-46af-8320-70957da028be	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1299.99	A beautiful 6-seater dining table made of premium oak wood.	\N	t	2026-06-20 12:01:35.183449	\N	2026-06-20 06:31:35.184001	\N	\N
9c7b1c9b-aa54-4b43-85c0-a557df0c11cc	SYSTEM_TENANT	\N	CHR-001	Classic Oak Chair	5577d950-acbe-46af-8320-70957da028be	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	199.99	A classic, sturdy oak chair to match your dining table.	\N	t	2026-06-20 12:01:35.183449	\N	2026-06-20 06:31:35.184001	\N	\N
e477c2ec-41c8-454f-a149-67f9951ae939	SYSTEM_TENANT	\N	CHAIR-01	Ergonomic Office Chair	425b63fd-ee19-4079-ba39-c55d2ef99849	\N	\N	150.00	\N	\N	t	2026-06-20 10:05:16.329277	\N	2026-06-20 10:05:16.329277	\N	\N
d90c1995-2e1a-4a8d-8a32-db04f5cc7b94	SYSTEM_TENANT	\N	DESK-01	Standing Desk Pro	425b63fd-ee19-4079-ba39-c55d2ef99849	\N	\N	350.00	\N	\N	t	2026-06-20 10:05:16.333183	\N	2026-06-20 10:05:16.333183	\N	\N
23c55daa-c4e9-4320-a911-f5a47441998b	SYSTEM_TENANT	\N	CHAIR-3f49	Ergonomic Office Chair	cfd8acf7-135b-45cc-98d0-8401a3ae37d4	\N	\N	150.00	\N	\N	t	2026-06-20 10:06:50.6484	\N	2026-06-20 10:06:50.6484	\N	\N
fb9874a8-7e62-4e25-92d2-617c32ebff04	SYSTEM_TENANT	\N	DESK-d077	Standing Desk Pro	cfd8acf7-135b-45cc-98d0-8401a3ae37d4	\N	\N	350.00	\N	\N	t	2026-06-20 10:06:50.652647	\N	2026-06-20 10:06:50.652647	\N	\N
ae6a130b-4618-4018-b22b-a2a94f7a58c9	SYSTEM_TENANT	\N	PRD-1001	Modern TV Unit	5577d950-acbe-46af-8320-70957da028be	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1681.00	A high-quality TV Unit made for modern spaces.	\N	t	2025-12-21 09:37:54.927962	\N	2026-06-21 04:07:54.928757	\N	\N
84b14542-bbde-44d1-b33d-cb90cf053883	SYSTEM_TENANT	\N	PRD-1002	Luxury TV Unit	5577d950-acbe-46af-8320-70957da028be	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1637.00	A high-quality TV Unit made for modern spaces.	\N	t	2025-12-21 09:37:54.931149	\N	2026-06-21 04:07:54.931423	\N	\N
90c792e7-b147-434e-a7ef-329a217225bc	SYSTEM_TENANT	\N	PRD-1003	Classic TV Unit	5577d950-acbe-46af-8320-70957da028be	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	158.00	A high-quality TV Unit made for modern spaces.	\N	t	2025-12-21 09:37:54.932744	\N	2026-06-21 04:07:54.932997	\N	\N
5cce546d-6925-4282-a61f-43588b9260d1	SYSTEM_TENANT	\N	PRD-1004	Modern Study Table	350207a6-6b2e-4f88-a650-ad6b73d801b7	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1141.00	A high-quality Study Table made for modern spaces.	\N	t	2025-12-21 09:37:54.934833	\N	2026-06-21 04:07:54.934972	\N	\N
c8184503-6d74-4507-bcf0-e175a4820373	SYSTEM_TENANT	\N	PRD-1005	Classic Bed	350207a6-6b2e-4f88-a650-ad6b73d801b7	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	397.00	A high-quality Bed made for modern spaces.	\N	t	2025-12-21 09:37:54.935874	\N	2026-06-21 04:07:54.936406	\N	\N
7b8cf0c7-f733-4214-955b-153dccdcda27	SYSTEM_TENANT	\N	PRD-1006	Classic TV Unit	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	980.00	A high-quality TV Unit made for modern spaces.	\N	t	2025-12-21 09:37:54.937454	\N	2026-06-21 04:07:54.937815	\N	\N
c761fd59-b683-4b03-adb1-1b64f6e087ba	SYSTEM_TENANT	\N	PRD-1007	Modern Executive Chair	5577d950-acbe-46af-8320-70957da028be	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1371.00	A high-quality Executive Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.939009	\N	2026-06-21 04:07:54.939209	\N	\N
13bf25f5-0a28-46c1-9e1e-667fb40ab2e4	SYSTEM_TENANT	\N	PRD-1008	Classic Study Table	350207a6-6b2e-4f88-a650-ad6b73d801b7	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	435.00	A high-quality Study Table made for modern spaces.	\N	t	2025-12-21 09:37:54.940057	\N	2026-06-21 04:07:54.940507	\N	\N
3444a70f-24e1-4c98-8199-2af2aa1ab398	SYSTEM_TENANT	\N	PRD-1009	Rustic Bed	5577d950-acbe-46af-8320-70957da028be	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1349.00	A high-quality Bed made for modern spaces.	\N	t	2025-12-21 09:37:54.941471	\N	2026-06-21 04:07:54.941919	\N	\N
9918534a-b9c8-416d-abe1-8ae921aba300	SYSTEM_TENANT	\N	PRD-1010	Classic Office Chair	350207a6-6b2e-4f88-a650-ad6b73d801b7	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	137.00	A high-quality Office Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.944717	\N	2026-06-21 04:07:54.945004	\N	\N
9f463dc3-4053-48ed-a640-c7caa0cda2f4	SYSTEM_TENANT	\N	PRD-1011	Ergonomic TV Unit	5577d950-acbe-46af-8320-70957da028be	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	212.00	A high-quality TV Unit made for modern spaces.	\N	t	2025-12-21 09:37:54.94623	\N	2026-06-21 04:07:54.946497	\N	\N
d6a6bce2-e181-45fb-8be8-00092237864e	SYSTEM_TENANT	\N	PRD-1012	Classic Study Table	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1369.00	A high-quality Study Table made for modern spaces.	\N	t	2025-12-21 09:37:54.947547	\N	2026-06-21 04:07:54.947933	\N	\N
ed8eade0-20da-4729-b51c-f8004c34342d	SYSTEM_TENANT	\N	PRD-1013	Premium Cabinet	350207a6-6b2e-4f88-a650-ad6b73d801b7	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1604.00	A high-quality Cabinet made for modern spaces.	\N	t	2025-12-21 09:37:54.94897	\N	2026-06-21 04:07:54.94934	\N	\N
18b1bea8-74fc-4b2c-b6c4-d60088fea9dd	SYSTEM_TENANT	\N	PRD-1014	Modern Sofa	350207a6-6b2e-4f88-a650-ad6b73d801b7	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1547.00	A high-quality Sofa made for modern spaces.	\N	t	2025-12-21 09:37:54.95028	\N	2026-06-21 04:07:54.950617	\N	\N
41212331-46a7-444e-994b-01c13b226b67	SYSTEM_TENANT	\N	PRD-1015	Premium Executive Chair	5577d950-acbe-46af-8320-70957da028be	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	952.00	A high-quality Executive Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.951598	\N	2026-06-21 04:07:54.951961	\N	\N
93ed428d-ef06-4dc2-ad17-147eddd3c780	SYSTEM_TENANT	\N	PRD-1016	Modern TV Unit	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1553.00	A high-quality TV Unit made for modern spaces.	\N	t	2025-12-21 09:37:54.952898	\N	2026-06-21 04:07:54.953291	\N	\N
5862d12f-7da3-4480-9954-01c6c6f2cea2	SYSTEM_TENANT	\N	PRD-1017	Luxury Executive Chair	5577d950-acbe-46af-8320-70957da028be	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	612.00	A high-quality Executive Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.954216	\N	2026-06-21 04:07:54.954452	\N	\N
c4a8712a-c41a-4a08-ae45-77b9cb38b51b	SYSTEM_TENANT	\N	PRD-1018	Rustic Executive Chair	350207a6-6b2e-4f88-a650-ad6b73d801b7	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	774.00	A high-quality Executive Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.955367	\N	2026-06-21 04:07:54.955761	\N	\N
a378380a-6760-4808-8c54-81aa3a4a2cc3	SYSTEM_TENANT	\N	PRD-1019	Ergonomic Office Chair	350207a6-6b2e-4f88-a650-ad6b73d801b7	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1750.00	A high-quality Office Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.957025	\N	2026-06-21 04:07:54.957424	\N	\N
9c556839-fa4a-4ecb-93ed-896c4e27d983	SYSTEM_TENANT	\N	PRD-1020	Classic Office Chair	5577d950-acbe-46af-8320-70957da028be	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1499.00	A high-quality Office Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.958391	\N	2026-06-21 04:07:54.958865	\N	\N
0eb4e687-9063-4804-a569-04c0d3becf5a	SYSTEM_TENANT	\N	PRD-1021	Rustic Office Chair	350207a6-6b2e-4f88-a650-ad6b73d801b7	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1173.00	A high-quality Office Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.96038	\N	2026-06-21 04:07:54.960641	\N	\N
9473a0f8-697e-412b-8496-57a7390d73b3	SYSTEM_TENANT	\N	PRD-1022	Premium Dining Table	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1361.00	A high-quality Dining Table made for modern spaces.	\N	t	2025-12-21 09:37:54.961741	\N	2026-06-21 04:07:54.962115	\N	\N
723c36f7-5bec-4037-8e94-6fd483fae9c3	SYSTEM_TENANT	\N	PRD-1023	Rustic Study Table	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1669.00	A high-quality Study Table made for modern spaces.	\N	t	2025-12-21 09:37:54.963073	\N	2026-06-21 04:07:54.963415	\N	\N
588f5625-138a-4285-bfee-3e552ed4a1d2	SYSTEM_TENANT	\N	PRD-1024	Luxury Wardrobe	350207a6-6b2e-4f88-a650-ad6b73d801b7	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	945.00	A high-quality Wardrobe made for modern spaces.	\N	t	2025-12-21 09:37:54.964383	\N	2026-06-21 04:07:54.96471	\N	\N
ef1774ca-9cb1-4596-9ca4-b8dd1dbbbb0c	SYSTEM_TENANT	\N	PRD-1025	Premium Executive Chair	5577d950-acbe-46af-8320-70957da028be	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	995.00	A high-quality Executive Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.964888	\N	2026-06-21 04:07:54.965973	\N	\N
02e2b771-48ee-42ac-bfcd-66c9d91b93f0	SYSTEM_TENANT	\N	PRD-1026	Rustic Study Table	5577d950-acbe-46af-8320-70957da028be	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1437.00	A high-quality Study Table made for modern spaces.	\N	t	2025-12-21 09:37:54.96662	\N	2026-06-21 04:07:54.967228	\N	\N
51e3938c-19ce-4e8d-97ab-9d32b789bae4	SYSTEM_TENANT	\N	PRD-1027	Luxury Dining Table	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1582.00	A high-quality Dining Table made for modern spaces.	\N	t	2025-12-21 09:37:54.968168	\N	2026-06-21 04:07:54.968412	\N	\N
7c3e36ed-8003-488f-921a-8445ee2dd394	SYSTEM_TENANT	\N	PRD-1028	Ergonomic Office Table	350207a6-6b2e-4f88-a650-ad6b73d801b7	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	685.00	A high-quality Office Table made for modern spaces.	\N	t	2025-12-21 09:37:54.969343	\N	2026-06-21 04:07:54.969697	\N	\N
e1c83f92-5a08-4fa1-9fb7-a73a2f714d4e	SYSTEM_TENANT	\N	PRD-1029	Ergonomic Executive Chair	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1448.00	A high-quality Executive Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.970625	\N	2026-06-21 04:07:54.971026	\N	\N
8758b6f3-c0de-49c6-8e46-28c338f96c2e	SYSTEM_TENANT	\N	PRD-1030	Classic Wardrobe	350207a6-6b2e-4f88-a650-ad6b73d801b7	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1822.00	A high-quality Wardrobe made for modern spaces.	\N	t	2025-12-21 09:37:54.971791	\N	2026-06-21 04:07:54.972418	\N	\N
09826aba-e956-4206-b76b-7ee17afb88e8	SYSTEM_TENANT	\N	PRD-1031	Minimalist Dining Table	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	643.00	A high-quality Dining Table made for modern spaces.	\N	t	2025-12-21 09:37:54.976129	\N	2026-06-21 04:07:54.976678	\N	\N
12452504-2d94-4d58-ae3f-2aece99e2257	SYSTEM_TENANT	\N	PRD-1032	Premium TV Unit	5577d950-acbe-46af-8320-70957da028be	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1911.00	A high-quality TV Unit made for modern spaces.	\N	t	2025-12-21 09:37:54.977924	\N	2026-06-21 04:07:54.978358	\N	\N
8dddbcad-2564-4061-bcc9-c1791cb0e44c	SYSTEM_TENANT	\N	PRD-1033	Premium Office Chair	350207a6-6b2e-4f88-a650-ad6b73d801b7	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	574.00	A high-quality Office Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.97955	\N	2026-06-21 04:07:54.979986	\N	\N
983f004a-7c54-4a51-9161-275e139738c9	SYSTEM_TENANT	\N	PRD-1034	Ergonomic Office Chair	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	434.00	A high-quality Office Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.98116	\N	2026-06-21 04:07:54.981474	\N	\N
1e9f919a-699c-40f6-b376-41314c256e25	SYSTEM_TENANT	\N	PRD-1035	Modern TV Unit	5577d950-acbe-46af-8320-70957da028be	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1539.00	A high-quality TV Unit made for modern spaces.	\N	t	2025-12-21 09:37:54.982559	\N	2026-06-21 04:07:54.98299	\N	\N
ee133245-d255-43fb-9a17-64d902c4001a	SYSTEM_TENANT	\N	PRD-1036	Ergonomic Office Table	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	492.00	A high-quality Office Table made for modern spaces.	\N	t	2025-12-21 09:37:54.984016	\N	2026-06-21 04:07:54.984377	\N	\N
1709baa6-d4a1-4dc8-b91f-77f8a16f7645	SYSTEM_TENANT	\N	PRD-1037	Ergonomic Dining Table	5577d950-acbe-46af-8320-70957da028be	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	693.00	A high-quality Dining Table made for modern spaces.	\N	t	2025-12-21 09:37:54.985372	\N	2026-06-21 04:07:54.985639	\N	\N
247e5569-01f7-4037-8acf-6e01631534e1	SYSTEM_TENANT	\N	PRD-1038	Classic Cabinet	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	522.00	A high-quality Cabinet made for modern spaces.	\N	t	2025-12-21 09:37:54.986578	\N	2026-06-21 04:07:54.98699	\N	\N
64aaf62e-4050-4449-9807-9aba08352d32	SYSTEM_TENANT	\N	PRD-1039	Minimalist Office Table	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1488.00	A high-quality Office Table made for modern spaces.	\N	t	2025-12-21 09:37:54.98761	\N	2026-06-21 04:07:54.988255	\N	\N
cf6e4273-8a3d-4504-820c-86d0157758e4	SYSTEM_TENANT	\N	PRD-1040	Luxury TV Unit	350207a6-6b2e-4f88-a650-ad6b73d801b7	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	574.00	A high-quality TV Unit made for modern spaces.	\N	t	2025-12-21 09:37:54.98915	\N	2026-06-21 04:07:54.989637	\N	\N
3dac2ebf-c4c1-42de-b259-47fbac4e1cbb	SYSTEM_TENANT	\N	PRD-1041	Luxury Sofa	350207a6-6b2e-4f88-a650-ad6b73d801b7	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	775.00	A high-quality Sofa made for modern spaces.	\N	t	2025-12-21 09:37:54.990667	\N	2026-06-21 04:07:54.990937	\N	\N
171b4a0d-7993-46c3-ace1-4ae3b3f9a60e	SYSTEM_TENANT	\N	PRD-1042	Luxury Office Chair	5577d950-acbe-46af-8320-70957da028be	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	604.00	A high-quality Office Chair made for modern spaces.	\N	t	2025-12-21 09:37:54.992271	\N	2026-06-21 04:07:54.992348	\N	\N
39285631-311c-4021-bf26-a6b22fd10818	SYSTEM_TENANT	\N	PRD-1043	Modern Study Table	350207a6-6b2e-4f88-a650-ad6b73d801b7	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1786.00	A high-quality Study Table made for modern spaces.	\N	t	2025-12-21 09:37:54.993583	\N	2026-06-21 04:07:54.994028	\N	\N
23ead663-57ce-4943-8a1e-83d014426299	SYSTEM_TENANT	\N	PRD-1044	Premium Bed	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1687.00	A high-quality Bed made for modern spaces.	\N	t	2025-12-21 09:37:54.995115	\N	2026-06-21 04:07:54.995643	\N	\N
c6fc1cbd-7c1f-4f8e-a3da-b4e9c78144d6	SYSTEM_TENANT	\N	PRD-1045	Premium Office Table	350207a6-6b2e-4f88-a650-ad6b73d801b7	21066e13-98e6-4b2e-98e2-253a52440e17	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	471.00	A high-quality Office Table made for modern spaces.	\N	t	2025-12-21 09:37:54.996569	\N	2026-06-21 04:07:54.996918	\N	\N
6335c4e0-218d-47b7-be4e-001d96fc73a1	SYSTEM_TENANT	\N	PRD-1046	Rustic TV Unit	350207a6-6b2e-4f88-a650-ad6b73d801b7	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1339.00	A high-quality TV Unit made for modern spaces.	\N	t	2025-12-21 09:37:54.997928	\N	2026-06-21 04:07:54.998257	\N	\N
89038509-4759-404b-bd35-baefcb799aac	SYSTEM_TENANT	\N	PRD-1047	Modern Bed	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1193.00	A high-quality Bed made for modern spaces.	\N	t	2025-12-21 09:37:54.999608	\N	2026-06-21 04:07:55.000072	\N	\N
5240ed01-7f72-483d-a3d9-97e0bc62335d	SYSTEM_TENANT	\N	PRD-1048	Modern Sofa	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1760.00	A high-quality Sofa made for modern spaces.	\N	t	2025-12-21 09:37:55.001014	\N	2026-06-21 04:07:55.001373	\N	\N
c482c321-2815-464d-a94f-4a13bf0b977e	SYSTEM_TENANT	\N	PRD-1049	Modern Executive Chair	5577d950-acbe-46af-8320-70957da028be	e1d01752-17e9-43ff-92b5-4dbd3a13e9a8	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1927.00	A high-quality Executive Chair made for modern spaces.	\N	t	2025-12-21 09:37:55.00152	\N	2026-06-21 04:07:55.002479	\N	\N
9332670a-e9fb-472b-9b7f-f76b2cea5590	SYSTEM_TENANT	\N	PRD-1050	Ergonomic Bed	f2d95db8-e3e8-4ca5-8d83-6a5197594b8e	4612582c-3902-4ecb-aad7-d3e568745756	6a01a95c-9fd6-40ff-a8ef-cec53636e45b	1553.00	A high-quality Bed made for modern spaces.	\N	t	2025-12-21 09:37:55.003362	\N	2026-06-21 04:07:55.003717	\N	\N
\.


--
-- Data for Name: quotation_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quotation_items (id, quotation_id, product_id, quantity, unit_price, total_price) FROM stdin;
0f4483e7-5e16-405a-bdc9-30af7c2ba099	QT-1001	5f77154d-b199-4f9e-b207-73d43a39b2ce	1	1299.99	1299.99
\.


--
-- Data for Name: quotation_statuses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quotation_statuses (id, tenant_id, code, name, description, sort_order, is_active, created_on, created_by, updated_on, updated_by) FROM stdin;
\.


--
-- Data for Name: quotations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.quotations (id, tenant_id, organization_id, customer_id, status, date_created, valid_until, subtotal, discount, tax, total, notes, created_by, created_on, updated_by, updated_on, is_active) FROM stdin;
QT-1001	SYSTEM_TENANT		0c56601e-f6c8-4d97-8c4e-198d14f71890	Draft	2026-06-20 12:08:34.673312+05:30	2026-07-20 12:08:34.673312+05:30	1299.99	0.00	130.00	1429.99	Valid for 30 days		2026-06-20 12:08:34.673312+05:30		2026-06-20 12:08:34.673312+05:30	t
QT-20000	SYSTEM_TENANT		c1958ad5-34f5-465a-bb27-5b1f6e5280e8	Sent	2026-05-13 09:37:55.004583+05:30	2026-06-13 09:37:55.004583+05:30	21217.00	0.00	2121.70	23338.70	Demo Quote		2026-05-13 09:37:55.004583+05:30		2026-05-14 09:37:55.004583+05:30	t
QT-20001	SYSTEM_TENANT		79a9ddfe-c94e-4bd3-81f6-8f8a66283177	Approved	2026-05-07 09:37:55.015228+05:30	2026-06-07 09:37:55.015228+05:30	8618.00	0.00	861.80	9479.80	Demo Quote		2026-05-07 09:37:55.015228+05:30		2026-05-09 09:37:55.015228+05:30	t
QT-20002	SYSTEM_TENANT		4c289bb5-6aea-4e49-87df-54b8d9bcab9d	Rejected	2026-05-10 09:37:55.016806+05:30	2026-06-10 09:37:55.016806+05:30	15530.00	0.00	1553.00	17083.00	Demo Quote		2026-05-10 09:37:55.016806+05:30		2026-05-11 09:37:55.016806+05:30	t
QT-20003	SYSTEM_TENANT		24be5ae2-6af4-4c8b-a939-f478ed425d74	Approved	2026-02-02 09:37:55.017864+05:30	2026-03-02 09:37:55.017864+05:30	18888.00	0.00	1888.80	20776.80	Demo Quote		2026-02-02 09:37:55.017864+05:30		2026-02-05 09:37:55.017864+05:30	t
QT-20004	SYSTEM_TENANT		2997f6eb-091e-45e1-bb77-73bf6e86664b	Draft	2026-06-21 09:37:55.018923+05:30	2026-07-21 09:37:55.018923+05:30	12833.00	0.00	1283.30	14116.30	Demo Quote		2026-06-21 09:37:55.018923+05:30		2026-06-25 09:37:55.018923+05:30	t
QT-20005	SYSTEM_TENANT		878c2485-51b1-4e63-a2f4-a70c411a42c3	Approved	2026-02-17 09:37:55.020502+05:30	2026-03-17 09:37:55.020502+05:30	31737.00	0.00	3173.70	34910.70	Demo Quote		2026-02-17 09:37:55.020502+05:30		2026-02-18 09:37:55.020502+05:30	t
QT-20006	SYSTEM_TENANT		a59c60a2-991b-45a7-9461-09e9d73ea240	Approved	2026-05-17 09:37:55.022587+05:30	2026-06-17 09:37:55.022587+05:30	7470.00	0.00	747.00	8217.00	Demo Quote		2026-05-17 09:37:55.022587+05:30		2026-05-17 09:37:55.022587+05:30	t
QT-20007	SYSTEM_TENANT		d6678617-b0f9-44f9-936a-54a4ec858ac7	Rejected	2026-05-07 09:37:55.024182+05:30	2026-06-07 09:37:55.024182+05:30	10829.00	0.00	1082.90	11911.90	Demo Quote		2026-05-07 09:37:55.024182+05:30		2026-05-08 09:37:55.024182+05:30	t
QT-20008	SYSTEM_TENANT		9bcd51c3-12cc-44fb-b414-460ee8a74c44	Rejected	2026-04-14 09:37:55.025202+05:30	2026-05-14 09:37:55.025202+05:30	17763.00	0.00	1776.30	19539.30	Demo Quote		2026-04-14 09:37:55.025202+05:30		2026-04-15 09:37:55.025202+05:30	t
QT-20009	SYSTEM_TENANT		878c2485-51b1-4e63-a2f4-a70c411a42c3	Draft	2026-03-06 09:37:55.027144+05:30	2026-04-06 09:37:55.027144+05:30	397.00	0.00	39.70	436.70	Demo Quote		2026-03-06 09:37:55.027144+05:30		2026-03-07 09:37:55.027144+05:30	t
QT-20010	SYSTEM_TENANT		79a9ddfe-c94e-4bd3-81f6-8f8a66283177	Rejected	2026-02-16 09:37:55.027682+05:30	2026-03-16 09:37:55.027682+05:30	10936.00	0.00	1093.60	12029.60	Demo Quote		2026-02-16 09:37:55.027682+05:30		2026-02-19 09:37:55.027682+05:30	t
QT-20011	SYSTEM_TENANT		a59c60a2-991b-45a7-9461-09e9d73ea240	Sent	2026-06-02 09:37:55.029806+05:30	2026-07-02 09:37:55.029806+05:30	16932.00	0.00	1693.20	18625.20	Demo Quote		2026-06-02 09:37:55.029806+05:30		2026-06-02 09:37:55.029806+05:30	t
QT-20012	SYSTEM_TENANT		878c2485-51b1-4e63-a2f4-a70c411a42c3	Approved	2026-05-02 09:37:55.031407+05:30	2026-06-02 09:37:55.031407+05:30	18865.00	0.00	1886.50	20751.50	Demo Quote		2026-05-02 09:37:55.031407+05:30		2026-05-02 09:37:55.031407+05:30	t
QT-20013	SYSTEM_TENANT		a59c60a2-991b-45a7-9461-09e9d73ea240	Rejected	2026-05-07 09:37:55.033022+05:30	2026-06-07 09:37:55.033022+05:30	20576.00	0.00	2057.60	22633.60	Demo Quote		2026-05-07 09:37:55.033022+05:30		2026-05-11 09:37:55.033022+05:30	t
QT-20014	SYSTEM_TENANT		410e4938-562a-4994-b50e-f7b541ad1c73	Draft	2026-02-20 09:37:55.035202+05:30	2026-03-20 09:37:55.035202+05:30	20619.00	0.00	2061.90	22680.90	Demo Quote		2026-02-20 09:37:55.035202+05:30		2026-02-20 09:37:55.035202+05:30	t
QT-20015	SYSTEM_TENANT		878c2485-51b1-4e63-a2f4-a70c411a42c3	Rejected	2026-03-19 09:37:55.036246+05:30	2026-04-19 09:37:55.036246+05:30	3697.00	0.00	369.70	4066.70	Demo Quote		2026-03-19 09:37:55.036246+05:30		2026-03-22 09:37:55.036246+05:30	t
QT-20016	SYSTEM_TENANT		8a717f51-2eaa-4a45-8e22-b20ccb59eae3	Rejected	2026-04-08 09:37:55.037587+05:30	2026-05-08 09:37:55.037587+05:30	22750.00	0.00	2275.00	25025.00	Demo Quote		2026-04-08 09:37:55.037587+05:30		2026-04-10 09:37:55.037587+05:30	t
QT-20017	SYSTEM_TENANT		43212494-6c07-4116-a77f-b00e2a169ddc	Approved	2026-04-14 09:37:55.038673+05:30	2026-05-14 09:37:55.038673+05:30	1803.00	0.00	180.30	1983.30	Demo Quote		2026-04-14 09:37:55.038673+05:30		2026-04-14 09:37:55.038673+05:30	t
QT-20018	SYSTEM_TENANT		d6678617-b0f9-44f9-936a-54a4ec858ac7	Rejected	2026-06-12 09:37:55.040301+05:30	2026-07-12 09:37:55.040301+05:30	16900.00	0.00	1690.00	18590.00	Demo Quote		2026-06-12 09:37:55.040301+05:30		2026-06-16 09:37:55.040301+05:30	t
QT-20019	SYSTEM_TENANT		8509b93e-4358-48e3-bafe-e8feff13e134	Draft	2026-03-25 09:37:55.041846+05:30	2026-04-25 09:37:55.041846+05:30	22570.00	0.00	2257.00	24827.00	Demo Quote		2026-03-25 09:37:55.041846+05:30		2026-03-26 09:37:55.041846+05:30	t
\.


--
-- Data for Name: revoked_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.revoked_tokens (token, revoked_at, expires_at) FROM stdin;
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.role_permissions (role_id, permission_id, tenant_id, created_on, created_by) FROM stdin;
00000000-0000-0000-0000-000000000001	ee01df53-fb94-435f-b61d-a5b098e5d991	SYSTEM_TENANT	2026-06-19 21:50:15.018256	\N
00000000-0000-0000-0000-000000000001	0b17858b-59a0-4eb1-8fcd-a438cb6524bc	SYSTEM_TENANT	2026-06-19 21:50:15.018256	\N
00000000-0000-0000-0000-000000000001	925252b2-80d6-47ee-8099-c3e7956404e2	SYSTEM_TENANT	2026-06-19 21:50:15.018256	\N
00000000-0000-0000-0000-000000000001	3e8cfcd4-ffeb-459c-8d62-5e2f2b830fd7	SYSTEM_TENANT	2026-06-19 21:50:15.018256	\N
00000000-0000-0000-0000-000000000001	8a9c3185-a718-45de-b9e6-66838ce5db8d	SYSTEM_TENANT	2026-06-19 21:50:15.018256	\N
00000000-0000-0000-0000-000000000001	d7b3c8f9-1ab6-4ecc-84d0-b55f880ab3b2	SYSTEM_TENANT	2026-06-19 21:50:15.018256	\N
00000000-0000-0000-0000-000000000001	5d78adbe-8956-4cf7-9575-2da5f4f5ffc0	SYSTEM_TENANT	2026-06-19 21:50:15.018256	\N
00000000-0000-0000-0000-000000000001	0261c5bc-4727-45ae-8c51-efdd39970558	SYSTEM_TENANT	2026-06-19 21:50:15.018256	\N
00000000-0000-0000-0000-000000000001	5a23ed46-1a82-4eb6-9d67-7433aacbffe1	SYSTEM_TENANT	2026-06-19 21:50:15.018256	\N
00000000-0000-0000-0000-000000000001	05473ee7-5288-449a-8591-e792983a00ae	SYSTEM_TENANT	2026-06-20 12:47:57.4848	\N
00000000-0000-0000-0000-000000000001	a60bbf4b-2b42-4e2b-9349-9954e6373cf2	SYSTEM_TENANT	2026-06-20 12:47:57.4848	\N
00000000-0000-0000-0000-000000000001	a227128f-1fc4-4dfc-a1a5-07479a25564e	SYSTEM_TENANT	2026-06-20 12:47:57.4848	\N
00000000-0000-0000-0000-000000000002	2e091517-4c1c-42fc-a335-8c95849b1723	SYSTEM_TENANT	2026-06-20 14:33:44.217202	\N
00000000-0000-0000-0000-000000000002	8887537e-a1fc-4243-a4dd-c93924b3d52f	SYSTEM_TENANT	2026-06-20 14:33:44.217202	\N
00000000-0000-0000-0000-000000000002	77eba898-47a1-4970-ad66-e6512486d053	SYSTEM_TENANT	2026-06-20 14:33:44.217202	\N
00000000-0000-0000-0000-000000000002	3da2fa8a-662d-449a-b25d-871336ca2464	SYSTEM_TENANT	2026-06-20 20:52:54.294404	\N
00000000-0000-0000-0000-000000000002	d9c54e1b-8a65-4566-b501-853f89f5b9d8	SYSTEM_TENANT	2026-06-20 20:52:54.294404	\N
00000000-0000-0000-0000-000000000002	eaf3c0ce-3c78-4682-95f5-86f71c85c945	SYSTEM_TENANT	2026-06-20 20:52:54.294404	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	ee01df53-fb94-435f-b61d-a5b098e5d991	SYSTEM_TENANT	2026-06-21 05:07:36.615569	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	0261c5bc-4727-45ae-8c51-efdd39970558	SYSTEM_TENANT	2026-06-21 05:07:36.617472	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	311874f8-1f61-4e83-b054-f06a4609cdca	SYSTEM_TENANT	2026-06-21 05:07:36.61827	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	ecc482dc-9906-473f-9d76-566850444cc4	SYSTEM_TENANT	2026-06-21 05:07:36.618696	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	8eec09da-66f2-4255-8772-3581f8cb1d9f	SYSTEM_TENANT	2026-06-21 05:07:36.619133	\N
81279c76-e8ef-493d-8f6b-47de3976792f	8eec09da-66f2-4255-8772-3581f8cb1d9f	SYSTEM_TENANT	2026-06-21 05:07:36.620711	\N
81279c76-e8ef-493d-8f6b-47de3976792f	05473ee7-5288-449a-8591-e792983a00ae	SYSTEM_TENANT	2026-06-21 05:07:36.621192	\N
81279c76-e8ef-493d-8f6b-47de3976792f	a60bbf4b-2b42-4e2b-9349-9954e6373cf2	SYSTEM_TENANT	2026-06-21 05:07:36.62155	\N
81279c76-e8ef-493d-8f6b-47de3976792f	a227128f-1fc4-4dfc-a1a5-07479a25564e	SYSTEM_TENANT	2026-06-21 05:07:36.621906	\N
81279c76-e8ef-493d-8f6b-47de3976792f	4fe19912-82fd-4da0-bbc5-13aed9bf6b00	SYSTEM_TENANT	2026-06-21 05:07:36.622243	\N
81279c76-e8ef-493d-8f6b-47de3976792f	df4497f5-2b18-4729-ade1-77f88ed451ab	SYSTEM_TENANT	2026-06-21 05:07:36.622636	\N
81279c76-e8ef-493d-8f6b-47de3976792f	3c90e790-47f8-4cce-a105-f3c4318c4617	SYSTEM_TENANT	2026-06-21 05:07:36.622991	\N
81279c76-e8ef-493d-8f6b-47de3976792f	2e091517-4c1c-42fc-a335-8c95849b1723	SYSTEM_TENANT	2026-06-21 05:07:36.623333	\N
81279c76-e8ef-493d-8f6b-47de3976792f	8887537e-a1fc-4243-a4dd-c93924b3d52f	SYSTEM_TENANT	2026-06-21 05:07:36.623657	\N
81279c76-e8ef-493d-8f6b-47de3976792f	77eba898-47a1-4970-ad66-e6512486d053	SYSTEM_TENANT	2026-06-21 05:07:36.624005	\N
bfd6cbaf-2fcb-460c-b01c-b657162cfbd4	3da2fa8a-662d-449a-b25d-871336ca2464	SYSTEM_TENANT	2026-06-21 05:07:36.625304	\N
bfd6cbaf-2fcb-460c-b01c-b657162cfbd4	d9c54e1b-8a65-4566-b501-853f89f5b9d8	SYSTEM_TENANT	2026-06-21 05:07:36.625666	\N
bfd6cbaf-2fcb-460c-b01c-b657162cfbd4	eaf3c0ce-3c78-4682-95f5-86f71c85c945	SYSTEM_TENANT	2026-06-21 05:07:36.626062	\N
00000000-0000-0000-0000-000000000001	296a7c9f-d96a-49ff-aadd-af007680d804	SYSTEM_TENANT	2026-06-21 05:07:36.630069	\N
00000000-0000-0000-0000-000000000001	aa0844f7-6e54-4e07-866c-c33f173cb6c9	SYSTEM_TENANT	2026-06-21 05:07:36.630365	\N
00000000-0000-0000-0000-000000000001	750d3cc2-24da-47ab-aee2-5846fcd4e10d	SYSTEM_TENANT	2026-06-21 05:07:36.63074	\N
00000000-0000-0000-0000-000000000001	458b5558-1c6e-4f54-8b43-853af82c29df	SYSTEM_TENANT	2026-06-21 05:07:36.631087	\N
00000000-0000-0000-0000-000000000001	311874f8-1f61-4e83-b054-f06a4609cdca	SYSTEM_TENANT	2026-06-21 05:07:36.631472	\N
00000000-0000-0000-0000-000000000001	ecc482dc-9906-473f-9d76-566850444cc4	SYSTEM_TENANT	2026-06-21 05:07:36.63181	\N
00000000-0000-0000-0000-000000000001	3496a56f-86fa-442c-ae98-72140383dc7b	SYSTEM_TENANT	2026-06-21 05:07:36.632191	\N
00000000-0000-0000-0000-000000000001	8eec09da-66f2-4255-8772-3581f8cb1d9f	SYSTEM_TENANT	2026-06-21 05:07:36.632517	\N
00000000-0000-0000-0000-000000000001	ea23ff76-86f4-476b-bf23-4c0c9eaa6b5e	SYSTEM_TENANT	2026-06-21 05:07:36.632856	\N
00000000-0000-0000-0000-000000000001	ffd35033-37c1-4968-b323-0369e2c0e266	SYSTEM_TENANT	2026-06-21 05:07:36.633232	\N
00000000-0000-0000-0000-000000000001	e3fb56f8-5592-4adf-b514-4d3b1a886fec	SYSTEM_TENANT	2026-06-21 05:07:36.633648	\N
00000000-0000-0000-0000-000000000001	4fe19912-82fd-4da0-bbc5-13aed9bf6b00	SYSTEM_TENANT	2026-06-21 05:07:36.634292	\N
00000000-0000-0000-0000-000000000001	df4497f5-2b18-4729-ade1-77f88ed451ab	SYSTEM_TENANT	2026-06-21 05:07:36.63464	\N
00000000-0000-0000-0000-000000000001	3c90e790-47f8-4cce-a105-f3c4318c4617	SYSTEM_TENANT	2026-06-21 05:07:36.634969	\N
00000000-0000-0000-0000-000000000001	2e091517-4c1c-42fc-a335-8c95849b1723	SYSTEM_TENANT	2026-06-21 05:07:36.635301	\N
00000000-0000-0000-0000-000000000001	8887537e-a1fc-4243-a4dd-c93924b3d52f	SYSTEM_TENANT	2026-06-21 05:07:36.635629	\N
00000000-0000-0000-0000-000000000001	77eba898-47a1-4970-ad66-e6512486d053	SYSTEM_TENANT	2026-06-21 05:07:36.635955	\N
00000000-0000-0000-0000-000000000001	3da2fa8a-662d-449a-b25d-871336ca2464	SYSTEM_TENANT	2026-06-21 05:07:36.636283	\N
00000000-0000-0000-0000-000000000001	d9c54e1b-8a65-4566-b501-853f89f5b9d8	SYSTEM_TENANT	2026-06-21 05:07:36.636644	\N
00000000-0000-0000-0000-000000000001	eaf3c0ce-3c78-4682-95f5-86f71c85c945	SYSTEM_TENANT	2026-06-21 05:07:36.63702	\N
00000000-0000-0000-0000-000000000001	686c9091-9227-45db-b05b-89a8e9d8be06	SYSTEM_TENANT	2026-06-21 05:08:24.176948	\N
00000000-0000-0000-0000-000000000001	76adb14b-d791-4d3c-88f3-2f3b6b408fe9	SYSTEM_TENANT	2026-06-21 05:08:24.178222	\N
00000000-0000-0000-0000-000000000001	16150db4-5765-4be8-a31a-57158f17b011	SYSTEM_TENANT	2026-06-21 05:09:12.285924	\N
00000000-0000-0000-0000-000000000001	f21e08b7-439f-49b0-807c-af189dcdf172	SYSTEM_TENANT	2026-06-21 05:09:12.288968	\N
00000000-0000-0000-0000-000000000001	90a66597-b089-4a0a-bcce-a71c75e1bf52	SYSTEM_TENANT	2026-06-21 05:09:12.289513	\N
00000000-0000-0000-0000-000000000001	130ebc70-83b8-4145-aaa6-966197d64256	SYSTEM_TENANT	2026-06-21 05:09:12.290016	\N
00000000-0000-0000-0000-000000000001	3d2f0048-5fa8-42e0-82cf-dc91621bf13b	SYSTEM_TENANT	2026-06-21 05:09:12.290542	\N
00000000-0000-0000-0000-000000000001	1cb4c24e-8361-4ab4-a755-b93b6b360ef2	SYSTEM_TENANT	2026-06-21 05:09:12.291053	\N
00000000-0000-0000-0000-000000000001	e13b990d-1223-450a-a2b7-d7a60179efa3	SYSTEM_TENANT	2026-06-21 05:09:12.291564	\N
00000000-0000-0000-0000-000000000001	b2884675-a0c3-48e0-9395-66be6b1f90d9	SYSTEM_TENANT	2026-06-21 05:09:12.292009	\N
00000000-0000-0000-0000-000000000001	43bef081-6538-40c6-b9b0-21e949ab0e06	SYSTEM_TENANT	2026-06-21 05:09:12.292374	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	f21e08b7-439f-49b0-807c-af189dcdf172	SYSTEM_TENANT	2026-06-21 05:09:12.294042	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	90a66597-b089-4a0a-bcce-a71c75e1bf52	SYSTEM_TENANT	2026-06-21 05:09:12.294423	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	130ebc70-83b8-4145-aaa6-966197d64256	SYSTEM_TENANT	2026-06-21 05:09:12.294823	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	1cb4c24e-8361-4ab4-a755-b93b6b360ef2	SYSTEM_TENANT	2026-06-21 05:09:12.295211	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	e13b990d-1223-450a-a2b7-d7a60179efa3	SYSTEM_TENANT	2026-06-21 05:09:12.295688	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	b2884675-a0c3-48e0-9395-66be6b1f90d9	SYSTEM_TENANT	2026-06-21 05:09:12.296321	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	43bef081-6538-40c6-b9b0-21e949ab0e06	SYSTEM_TENANT	2026-06-21 05:09:12.296845	\N
81279c76-e8ef-493d-8f6b-47de3976792f	16150db4-5765-4be8-a31a-57158f17b011	SYSTEM_TENANT	2026-06-21 05:09:12.299341	\N
bfd6cbaf-2fcb-460c-b01c-b657162cfbd4	1cb4c24e-8361-4ab4-a755-b93b6b360ef2	SYSTEM_TENANT	2026-06-21 05:09:12.300649	\N
bfd6cbaf-2fcb-460c-b01c-b657162cfbd4	b2884675-a0c3-48e0-9395-66be6b1f90d9	SYSTEM_TENANT	2026-06-21 05:09:12.301026	\N
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, tenant_id, organization_id, role_code, role_name, is_system_role, is_active, created_on, created_by, updated_on, updated_by, remarks) FROM stdin;
00000000-0000-0000-0000-000000000001	SYSTEM_TENANT	\N	PLATFORM_ADMIN	Platform Administrator	t	t	2026-06-19 21:50:15.016304	\N	2026-06-19 21:50:15.016304	\N	\N
00000000-0000-0000-0000-000000000002	SYSTEM_TENANT	\N	SYS_ADMIN	System Administrator	t	t	2026-06-19 21:50:15.016304	\N	2026-06-19 21:50:15.016304	\N	\N
b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	SYSTEM_TENANT	\N	SALES_MANAGER	Sales Manager	f	t	2026-06-21 04:33:42.655245	\N	2026-06-21 04:33:42.655245	\N	\N
81279c76-e8ef-493d-8f6b-47de3976792f	SYSTEM_TENANT	\N	PRODUCTION_MANAGER	Production Manager	f	t	2026-06-21 04:33:42.657128	\N	2026-06-21 04:33:42.657128	\N	\N
bfd6cbaf-2fcb-460c-b01c-b657162cfbd4	SYSTEM_TENANT	\N	DELIVERY_MANAGER	Delivery Manager	f	t	2026-06-21 04:33:42.657978	\N	2026-06-21 04:33:42.657978	\N	\N
fa0ba4c8-7366-4916-8ce2-ceabb9e9754a	SYSTEM_TENANT	\N	test	test	f	t	2026-06-21 07:24:06.200967	\N	2026-06-21 07:24:06.200967	\N	\N
\.


--
-- Data for Name: sales_order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_order_items (id, sales_order_id, product_id, quantity, unit_price, total_price) FROM stdin;
f47f0517-c85a-4db5-a414-759d1321bb23	SO-2001	5f77154d-b199-4f9e-b207-73d43a39b2ce	1	1299.99	1299.99
\.


--
-- Data for Name: sales_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_orders (id, tenant_id, organization_id, customer_id, quotation_id, status, order_date, total_amount, created_by, created_on, updated_by, updated_on, is_active, expected_delivery_date, subtotal, discount, tax, remarks) FROM stdin;
SO-2001	SYSTEM_TENANT		0c56601e-f6c8-4d97-8c4e-198d14f71890	\N	Confirmed	2026-06-20 12:08:34.675402+05:30	1429.99		2026-06-20 12:08:34.675402+05:30		2026-06-20 12:08:34.675402+05:30	t	\N	1299.99	0.00	130.00	Please deliver by next week
SO-30000	SYSTEM_TENANT		24be5ae2-6af4-4c8b-a939-f478ed425d74	QT-20003	Confirmed	2026-02-06 09:37:55.017864+05:30	20776.80		2026-02-06 09:37:55.017864+05:30		2026-02-06 09:37:55.017864+05:30	t	\N	18888.00	0.00	1888.80	\N
SO-30001	SYSTEM_TENANT		878c2485-51b1-4e63-a2f4-a70c411a42c3	QT-20012	In Production	2026-05-03 09:37:55.031407+05:30	20751.50		2026-05-03 09:37:55.031407+05:30		2026-05-11 09:37:55.031407+05:30	t	\N	18865.00	0.00	1886.50	\N
SO-30002	SYSTEM_TENANT		43212494-6c07-4116-a77f-b00e2a169ddc	QT-20017	Confirmed	2026-04-17 09:37:55.038673+05:30	1983.30		2026-04-17 09:37:55.038673+05:30		2026-04-22 09:37:55.038673+05:30	t	\N	1803.00	0.00	180.30	\N
SO-30003	SYSTEM_TENANT		a59c60a2-991b-45a7-9461-09e9d73ea240	QT-20006	Ready for Delivery	2026-05-18 09:37:55.022587+05:30	8217.00		2026-05-18 09:37:55.022587+05:30		2026-05-22 09:37:55.022587+05:30	t	\N	7470.00	0.00	747.00	\N
SO-30004	SYSTEM_TENANT		79a9ddfe-c94e-4bd3-81f6-8f8a66283177	QT-20001	Ready for Delivery	2026-05-10 09:37:55.015228+05:30	9479.80		2026-05-10 09:37:55.015228+05:30		2026-05-13 09:37:55.015228+05:30	t	\N	8618.00	0.00	861.80	\N
SO-30005	SYSTEM_TENANT		878c2485-51b1-4e63-a2f4-a70c411a42c3	QT-20005	Delivered	2026-02-20 09:37:55.020502+05:30	34910.70		2026-02-20 09:37:55.020502+05:30		2026-03-01 09:37:55.020502+05:30	t	\N	31737.00	0.00	3173.70	\N
\.


--
-- Data for Name: screens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.screens (id, screen_code, screen_name, module_code, route_path, is_active, created_on, created_by, updated_on, updated_by, remarks) FROM stdin;
75e246ea-69c1-4ae4-89b8-467d1b9f62d5	DSH_HOME	Dashboard Home	DSH	/dashboard	t	2026-06-19 21:50:14.97577	\N	2026-06-19 21:50:14.97577	\N	\N
c42f197f-b023-440f-907a-0ea9af9bd99d	USR_LIST	Users	USR	/users	t	2026-06-19 21:50:14.97577	\N	2026-06-19 21:50:14.97577	\N	\N
9c0917b3-4846-42e8-b477-0dc3c058be18	ROL_LIST	Roles	ROL	/roles	t	2026-06-19 21:50:14.97577	\N	2026-06-19 21:50:14.97577	\N	\N
a8855297-cf2b-4ca7-bca9-ae352be87cf0	CUS_LIST	Customers	CUS	/customers	t	2026-06-19 21:50:14.97577	\N	2026-06-19 21:50:14.97577	\N	\N
6ef42768-52bf-4550-9658-d105c6995b22	PRD_LIST	Products	PRD	/products	t	2026-06-19 21:50:14.97577	\N	2026-06-19 21:50:14.97577	\N	\N
d7057601-4ced-4e16-b8ce-ae09c27feb47	MASTER_DATA	Master Data	SYS	/master-data	t	2026-06-19 21:51:19.193714	\N	2026-06-19 21:51:19.193714	\N	\N
904370db-f766-469d-8fe0-0062ccbcbfc2	CAT_PROD	Products	CAT	/catalog	t	2026-06-19 22:04:02.986508	\N	2026-06-19 22:04:02.986508	\N	\N
d5a52729-33c6-457a-bc9e-13581406b461	CAT_CAT	Categories	CAT	/catalog/categories	t	2026-06-19 22:04:02.986508	\N	2026-06-19 22:04:02.986508	\N	\N
71a22a10-8d2d-44c5-ae1d-f67014f52bcc	BOM_LIST	Bill of Materials	MFG	/bom	t	2026-06-20 12:47:57.47771	\N	2026-06-20 12:47:57.47771	\N	\N
630f073c-4eb5-480a-8b59-a2d43de448ae	MFG_ORD_LIST	Production Orders	MFG	/production	t	2026-06-20 14:02:46.934894	\N	2026-06-20 14:02:46.934894	\N	\N
b821c516-ecef-4a32-8a79-e0b61106069a	TRK_BOARD	Production Board	MFG	/tracking/board	t	2026-06-20 14:33:15.253237	\N	2026-06-20 14:33:15.253237	\N	\N
ace57dce-a128-409a-b21b-3b26bdd2deed	TRK_LIST	Production Tracking	MFG	/tracking	t	2026-06-20 14:33:15.253237	\N	2026-06-20 14:33:15.253237	\N	\N
ee0e5f90-c39e-4ce0-bf06-948594aa69de	DLV_LIST	Delivery List	DLV	/delivery	t	2026-06-20 20:52:54.287199	\N	2026-06-20 20:52:54.287199	\N	\N
\.


--
-- Data for Name: states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.states (id, tenant_id, country_id, code, name, is_active, created_on, created_by, updated_on, updated_by, organization_id, remarks) FROM stdin;
33333333-3333-3333-3333-333333333333	SYSTEM_TENANT	11111111-1111-1111-1111-111111111111	CA	California	t	2026-06-19 21:56:31.51736	\N	2026-06-19 21:56:31.51736	\N	\N	\N
44444444-4444-4444-4444-444444444444	SYSTEM_TENANT	22222222-2222-2222-2222-222222222222	TN	Tamil Nadu	t	2026-06-19 21:56:31.51736	\N	2026-06-19 21:56:31.51736	\N	\N	\N
\.


--
-- Data for Name: units_of_measure; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.units_of_measure (id, tenant_id, code, name, description, sort_order, is_active, created_on, created_by, updated_on, updated_by) FROM stdin;
fb98f701-ba1e-447a-b10e-1ca639985324	SYSTEM_TENANT	PCS	Pieces	\N	10	t	2026-06-19 21:50:15.131945	\N	2026-06-19 21:50:15.131945	\N
c65365f0-0d98-42a3-beb3-54aa682b0d3c	SYSTEM_TENANT	KG	Kilograms	\N	20	t	2026-06-19 21:50:15.131945	\N	2026-06-19 21:50:15.131945	\N
41123c15-04f3-4639-889b-67a838ab7269	SYSTEM_TENANT	M	Meters	\N	30	t	2026-06-19 21:50:15.131945	\N	2026-06-19 21:50:15.131945	\N
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_roles (user_id, role_id, tenant_id, created_on, created_by) FROM stdin;
00000000-0000-0000-0000-000000000001	00000000-0000-0000-0000-000000000001	SYSTEM_TENANT	2026-06-19 21:50:15.022857	\N
9884cce7-be7e-4e90-b6d4-d9fd4f3405ec	b46a60cd-2e58-48cc-a317-3ceb1ac5cb47	SYSTEM_TENANT	2026-06-21 11:05:57.606523	\N
8e7ec47b-d2be-4f46-b6b0-c9e568180ae7	81279c76-e8ef-493d-8f6b-47de3976792f	SYSTEM_TENANT	2026-06-21 11:06:03.533326	\N
ca8a4154-17e0-4b9c-badc-747b5ff1f282	bfd6cbaf-2fcb-460c-b01c-b657162cfbd4	SYSTEM_TENANT	2026-06-21 11:06:09.80535	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, tenant_id, organization_id, branch_id, department_id, username, email, password_hash, first_name, last_name, is_active, created_on, created_by, updated_on, updated_by, remarks, mobile, designation, department) FROM stdin;
9884cce7-be7e-4e90-b6d4-d9fd4f3405ec	SYSTEM_TENANT	\N	\N	\N	sales_manager	sales@furniflow.com	$2a$10$yGErQ9QUejjy1dOHoBjSGO47BI3EP00h9sWfZMviU/ZfgZzwXiUpO	Alice	Sales	t	2026-06-21 04:33:42.665684	\N	2026-06-21 04:33:42.665684	\N	\N	\N	\N	\N
8e7ec47b-d2be-4f46-b6b0-c9e568180ae7	SYSTEM_TENANT	\N	\N	\N	prod_manager	production@furniflow.com	$2a$10$yGErQ9QUejjy1dOHoBjSGO47BI3EP00h9sWfZMviU/ZfgZzwXiUpO	Bob	Production	t	2026-06-21 04:33:42.669393	\N	2026-06-21 04:33:42.669393	\N	\N	\N	\N	\N
ca8a4154-17e0-4b9c-badc-747b5ff1f282	SYSTEM_TENANT	\N	\N	\N	dlv_manager	delivery@furniflow.com	$2a$10$yGErQ9QUejjy1dOHoBjSGO47BI3EP00h9sWfZMviU/ZfgZzwXiUpO	Charlie	Delivery	t	2026-06-21 04:33:42.671061	\N	2026-06-21 04:33:42.671061	\N	\N	\N	\N	\N
00000000-0000-0000-0000-000000000001	SYSTEM_TENANT	\N	\N	\N	admin	admin@furniflow.com	$2a$10$tZSplwf.VkPjGQZ2FV7od.Av8ayW4KHZ7YFLGjTtJK0WJZFaTeOm6	Platform	Admin	t	2026-06-19 21:50:15.020435	\N	2026-06-19 21:50:15.020435	\N	\N	\N	\N	\N
\.


--
-- Data for Name: wood_types; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.wood_types (id, tenant_id, code, name, description, sort_order, is_active, created_on, created_by, updated_on, updated_by) FROM stdin;
657edb37-90a6-4bbb-b1a3-59c4328b49a1	SYSTEM_TENANT	TEAK	Teak Wood	\N	10	t	2026-06-19 21:50:15.138148	\N	2026-06-19 21:50:15.138148	\N
7aaa91c0-4f84-4136-8e58-280602593b14	SYSTEM_TENANT	MAHOGANY	Mahogany	\N	20	t	2026-06-19 21:50:15.138148	\N	2026-06-19 21:50:15.138148	\N
fb7545da-e109-4eda-9693-a0053d70fe0d	SYSTEM_TENANT	OAK	Oak Wood	\N	30	t	2026-06-19 21:50:15.138148	\N	2026-06-19 21:50:15.138148	\N
\.


--
-- Name: audit_logs audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);


--
-- Name: bom_items bom_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom_items
    ADD CONSTRAINT bom_items_pkey PRIMARY KEY (id);


--
-- Name: boms boms_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.boms
    ADD CONSTRAINT boms_pkey PRIMARY KEY (id);


--
-- Name: cities cities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (id);


--
-- Name: cities cities_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: countries countries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (id);


--
-- Name: countries countries_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.countries
    ADD CONSTRAINT countries_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: customer_types customer_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_types
    ADD CONSTRAINT customer_types_pkey PRIMARY KEY (id);


--
-- Name: customer_types customer_types_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_types
    ADD CONSTRAINT customer_types_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: deliveries deliveries_delivery_number_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_delivery_number_key UNIQUE (delivery_number);


--
-- Name: deliveries deliveries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT deliveries_pkey PRIMARY KEY (id);


--
-- Name: delivery_statuses delivery_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_statuses
    ADD CONSTRAINT delivery_statuses_pkey PRIMARY KEY (id);


--
-- Name: delivery_statuses delivery_statuses_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_statuses
    ADD CONSTRAINT delivery_statuses_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: delivery_timeline_histories delivery_timeline_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_timeline_histories
    ADD CONSTRAINT delivery_timeline_histories_pkey PRIMARY KEY (id);


--
-- Name: master_data master_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.master_data
    ADD CONSTRAINT master_data_pkey PRIMARY KEY (id);


--
-- Name: menus menus_menu_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_menu_code_key UNIQUE (menu_code);


--
-- Name: menus menus_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_pkey PRIMARY KEY (id);


--
-- Name: modules modules_module_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_module_code_key UNIQUE (module_code);


--
-- Name: modules modules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.modules
    ADD CONSTRAINT modules_pkey PRIMARY KEY (id);


--
-- Name: order_statuses order_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_statuses
    ADD CONSTRAINT order_statuses_pkey PRIMARY KEY (id);


--
-- Name: order_statuses order_statuses_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_statuses
    ADD CONSTRAINT order_statuses_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: permissions permissions_permission_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_permission_code_key UNIQUE (permission_code);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- Name: product_categories product_categories_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: production_orders production_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_orders
    ADD CONSTRAINT production_orders_pkey PRIMARY KEY (id);


--
-- Name: production_stage_histories production_stage_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_stage_histories
    ADD CONSTRAINT production_stage_histories_pkey PRIMARY KEY (id);


--
-- Name: production_stages production_stages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_stages
    ADD CONSTRAINT production_stages_pkey PRIMARY KEY (id);


--
-- Name: production_stages production_stages_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_stages
    ADD CONSTRAINT production_stages_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: production_trackings production_trackings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_trackings
    ADD CONSTRAINT production_trackings_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: products products_tenant_id_product_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_tenant_id_product_code_key UNIQUE (tenant_id, product_code);


--
-- Name: quotation_items quotation_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT quotation_items_pkey PRIMARY KEY (id);


--
-- Name: quotation_statuses quotation_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quotation_statuses
    ADD CONSTRAINT quotation_statuses_pkey PRIMARY KEY (id);


--
-- Name: quotation_statuses quotation_statuses_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quotation_statuses
    ADD CONSTRAINT quotation_statuses_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: quotations quotations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT quotations_pkey PRIMARY KEY (id);


--
-- Name: revoked_tokens revoked_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.revoked_tokens
    ADD CONSTRAINT revoked_tokens_pkey PRIMARY KEY (token);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: roles roles_tenant_id_role_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_tenant_id_role_code_key UNIQUE (tenant_id, role_code);


--
-- Name: sales_order_items sales_order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT sales_order_items_pkey PRIMARY KEY (id);


--
-- Name: sales_orders sales_orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT sales_orders_pkey PRIMARY KEY (id);


--
-- Name: screens screens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.screens
    ADD CONSTRAINT screens_pkey PRIMARY KEY (id);


--
-- Name: screens screens_screen_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.screens
    ADD CONSTRAINT screens_screen_code_key UNIQUE (screen_code);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (id);


--
-- Name: states states_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: units_of_measure units_of_measure_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units_of_measure
    ADD CONSTRAINT units_of_measure_pkey PRIMARY KEY (id);


--
-- Name: units_of_measure units_of_measure_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.units_of_measure
    ADD CONSTRAINT units_of_measure_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: production_trackings uq_tracking_order; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_trackings
    ADD CONSTRAINT uq_tracking_order UNIQUE (production_order_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: wood_types wood_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wood_types
    ADD CONSTRAINT wood_types_pkey PRIMARY KEY (id);


--
-- Name: wood_types wood_types_tenant_id_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wood_types
    ADD CONSTRAINT wood_types_tenant_id_code_key UNIQUE (tenant_id, code);


--
-- Name: idx_customers_name_trgm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_customers_name_trgm ON public.customers USING gin (name public.gin_trgm_ops);


--
-- Name: idx_deliveries_number_trgm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_deliveries_number_trgm ON public.deliveries USING gin (delivery_number public.gin_trgm_ops);


--
-- Name: idx_master_data_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_master_data_type ON public.master_data USING btree (type);


--
-- Name: idx_products_code_trgm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_code_trgm ON public.products USING gin (product_code public.gin_trgm_ops);


--
-- Name: idx_products_name_trgm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_products_name_trgm ON public.products USING gin (product_name public.gin_trgm_ops);


--
-- Name: idx_quotations_id_trgm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_quotations_id_trgm ON public.quotations USING gin (id public.gin_trgm_ops);


--
-- Name: idx_sales_orders_id_trgm; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_sales_orders_id_trgm ON public.sales_orders USING gin (id public.gin_trgm_ops);


--
-- Name: idx_tenant_city_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_tenant_city_code ON public.cities USING btree (code);


--
-- Name: idx_tenant_country_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_tenant_country_code ON public.countries USING btree (code);


--
-- Name: idx_tenant_state_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_tenant_state_code ON public.states USING btree (code);


--
-- Name: bom_items bom_items_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom_items
    ADD CONSTRAINT bom_items_bom_id_fkey FOREIGN KEY (bom_id) REFERENCES public.boms(id) ON DELETE CASCADE;


--
-- Name: bom_items bom_items_component_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom_items
    ADD CONSTRAINT bom_items_component_id_fkey FOREIGN KEY (component_id) REFERENCES public.products(id);


--
-- Name: bom_items bom_items_uom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bom_items
    ADD CONSTRAINT bom_items_uom_id_fkey FOREIGN KEY (uom_id) REFERENCES public.master_data(id);


--
-- Name: boms boms_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.boms
    ADD CONSTRAINT boms_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: cities cities_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT cities_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- Name: customers customers_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.cities(id);


--
-- Name: customers customers_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: customers customers_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- Name: cities fk_cities_state; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cities
    ADD CONSTRAINT fk_cities_state FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- Name: customers fk_customers_city; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_customers_city FOREIGN KEY (city_id) REFERENCES public.cities(id);


--
-- Name: customers fk_customers_country; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_customers_country FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: customers fk_customers_customer_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_customers_customer_type FOREIGN KEY (customer_type_id) REFERENCES public.master_data(id);


--
-- Name: customers fk_customers_state; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_customers_state FOREIGN KEY (state_id) REFERENCES public.states(id);


--
-- Name: deliveries fk_dlv_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT fk_dlv_customer FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: deliveries fk_dlv_prod_order; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deliveries
    ADD CONSTRAINT fk_dlv_prod_order FOREIGN KEY (production_order_id) REFERENCES public.production_orders(id);


--
-- Name: delivery_timeline_histories fk_dlv_timeline_delivery; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.delivery_timeline_histories
    ADD CONSTRAINT fk_dlv_timeline_delivery FOREIGN KEY (delivery_id) REFERENCES public.deliveries(id) ON DELETE CASCADE;


--
-- Name: products fk_products_category; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES public.master_data(id);


--
-- Name: products fk_products_uom; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_uom FOREIGN KEY (uom_id) REFERENCES public.master_data(id);


--
-- Name: products fk_products_wood_type; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT fk_products_wood_type FOREIGN KEY (wood_type_id) REFERENCES public.master_data(id);


--
-- Name: quotation_items fk_quotation_items_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT fk_quotation_items_product FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: quotations fk_quotations_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quotations
    ADD CONSTRAINT fk_quotations_customer FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: quotation_items fk_quotations_items; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.quotation_items
    ADD CONSTRAINT fk_quotations_items FOREIGN KEY (quotation_id) REFERENCES public.quotations(id);


--
-- Name: sales_order_items fk_sales_order_items_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT fk_sales_order_items_product FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: sales_orders fk_sales_orders_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_orders
    ADD CONSTRAINT fk_sales_orders_customer FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: sales_order_items fk_sales_orders_items; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_order_items
    ADD CONSTRAINT fk_sales_orders_items FOREIGN KEY (sales_order_id) REFERENCES public.sales_orders(id);


--
-- Name: states fk_states_country; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT fk_states_country FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: menus menus_module_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_module_code_fkey FOREIGN KEY (module_code) REFERENCES public.modules(module_code);


--
-- Name: menus menus_parent_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_parent_menu_id_fkey FOREIGN KEY (parent_menu_id) REFERENCES public.menus(id);


--
-- Name: menus menus_screen_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.menus
    ADD CONSTRAINT menus_screen_code_fkey FOREIGN KEY (screen_code) REFERENCES public.screens(screen_code);


--
-- Name: production_orders production_orders_bom_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_orders
    ADD CONSTRAINT production_orders_bom_id_fkey FOREIGN KEY (bom_id) REFERENCES public.boms(id);


--
-- Name: production_orders production_orders_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_orders
    ADD CONSTRAINT production_orders_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- Name: production_stage_histories production_stage_histories_completed_by_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_stage_histories
    ADD CONSTRAINT production_stage_histories_completed_by_user_id_fkey FOREIGN KEY (completed_by_user_id) REFERENCES public.users(id);


--
-- Name: production_stage_histories production_stage_histories_tracking_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_stage_histories
    ADD CONSTRAINT production_stage_histories_tracking_id_fkey FOREIGN KEY (tracking_id) REFERENCES public.production_trackings(id) ON DELETE CASCADE;


--
-- Name: production_trackings production_trackings_assigned_employee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_trackings
    ADD CONSTRAINT production_trackings_assigned_employee_id_fkey FOREIGN KEY (assigned_employee_id) REFERENCES public.users(id);


--
-- Name: production_trackings production_trackings_production_order_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.production_trackings
    ADD CONSTRAINT production_trackings_production_order_id_fkey FOREIGN KEY (production_order_id) REFERENCES public.production_orders(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;


--
-- Name: role_permissions role_permissions_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: screens screens_module_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.screens
    ADD CONSTRAINT screens_module_code_fkey FOREIGN KEY (module_code) REFERENCES public.modules(module_code);


--
-- Name: states states_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.countries(id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Jfs36tLkhSfd4gqHHlWkirz25m4QQHlE4AqYlz8DFTNvNaeBOJugocidcDyiDIL

