CREATE EXTENSION pg_crypto;

CREATE TABLE public.users (
    id UUID PRIMARY KEY,
    created_at TIMESTAMP NOT NULL DEFAULT (now() WITH TIME ZONE 'utc'),
    username CHAR(32) UNIQUE NOT NULL CHECK ( length(name) > 2),
    password TEXT NOT NULL, -- TODO: figure out salting and whatnot
    token_salt TEXT NOT NULL
);
CREATE TABLE public.projects (
    project_id SERIAL PRIMARY KEY,
    owner_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    url TEXT NOT NULL
);
CREATE TABLE public.project_pages (
    page_id SERIAL PRIMARY KEY,
    project_id INTEGER NOT NULL REFERENCES public.projects(project_id) ON DELETE CASCADE,
    page_name CHAR(16) NOT NULL,
    page_language CHAR(5),
    active_build CHAR(32),
    custom_domain VARCHAR(64),
    path_prefix VARCHAR(64) NOT NULL,
    is_menu_item BOOLEAN NOT NULL DEFAULT TRUE,
    webhook_salt TEXT, -- TODO: figure out webhook authing
    UNIQUE (project_id, page_name, page_language)
);
CREATE TABLE public.builds (
    build_id UUID PRIMARY KEY,
    git_hash CHAR(40),
    page_id INTEGER NOT NULL REFERENCES public.project_pages(page_id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT (now() WITH TIME ZONE 'utc'),
    is_content_available BOOLEAN NOT NULL DEFAULT TRUE,
    build_cancelled BOOLEAN NOT NULL DEFAULT FALSE
);