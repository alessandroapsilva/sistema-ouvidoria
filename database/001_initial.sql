-- Fundação multi-instituição: PostgreSQL 15+.
-- Executar apenas em ambiente de desenvolvimento isolado.
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE TABLE institutions (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 slug text NOT NULL UNIQUE CHECK (slug ~ '^[a-z0-9]+(-[a-z0-9]+)*$'),
 name text NOT NULL,
 status text NOT NULL DEFAULT 'active' CHECK (status IN ('active','suspended')),
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE institution_members (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 institution_id uuid NOT NULL REFERENCES institutions(id),
 identity_subject text NOT NULL,
 role text NOT NULL CHECK (role IN ('owner','admin','ombudsman','analyst','viewer')),
 active boolean NOT NULL DEFAULT true,
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE (institution_id, identity_subject),
 UNIQUE (id,institution_id)
);
CREATE TABLE departments (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 institution_id uuid NOT NULL REFERENCES institutions(id),
 name text NOT NULL,
 active boolean NOT NULL DEFAULT true,
 UNIQUE(id,institution_id),
 UNIQUE(institution_id,name)
);
CREATE TABLE manifestations (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 institution_id uuid NOT NULL REFERENCES institutions(id),
 protocol text NOT NULL,
 kind text NOT NULL CHECK (kind IN ('complaint','report','suggestion','compliment','request')),
 subject text NOT NULL,
 description text NOT NULL,
 anonymous boolean NOT NULL DEFAULT false,
 confidentiality text NOT NULL DEFAULT 'restricted' CHECK (confidentiality IN ('restricted','highly_restricted')),
 status text NOT NULL DEFAULT 'received' CHECK (status IN ('received','triage','in_progress','awaiting_information','answered','closed')),
 department_id uuid,
 assigned_member_id uuid,
 due_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 updated_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(institution_id,protocol),
 UNIQUE(id,institution_id),
 FOREIGN KEY(department_id,institution_id) REFERENCES departments(id,institution_id),
 FOREIGN KEY(assigned_member_id,institution_id) REFERENCES institution_members(id,institution_id)
);
CREATE TABLE manifestation_events (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 institution_id uuid NOT NULL REFERENCES institutions(id),
 manifestation_id uuid NOT NULL,
 actor_member_id uuid,
 event_type text NOT NULL,
 metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
 created_at timestamptz NOT NULL DEFAULT now(),
 FOREIGN KEY(manifestation_id,institution_id) REFERENCES manifestations(id,institution_id),
 FOREIGN KEY(actor_member_id,institution_id) REFERENCES institution_members(id,institution_id)
);
CREATE INDEX idx_manifestations_tenant_status ON manifestations(institution_id,status,created_at DESC);
CREATE INDEX idx_events_tenant_manifestation ON manifestation_events(institution_id,manifestation_id,created_at DESC);
-- Sem políticas de acesso liberadas: fail closed até integrar autenticação verificada.
ALTER TABLE institutions ENABLE ROW LEVEL SECURITY;
ALTER TABLE institution_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE manifestations ENABLE ROW LEVEL SECURITY;
ALTER TABLE manifestation_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE institutions FORCE ROW LEVEL SECURITY;
ALTER TABLE institution_members FORCE ROW LEVEL SECURITY;
ALTER TABLE departments FORCE ROW LEVEL SECURITY;
ALTER TABLE manifestations FORCE ROW LEVEL SECURITY;
ALTER TABLE manifestation_events FORCE ROW LEVEL SECURITY;
-- Não criar políticas permissivas nem expor chaves privilegiadas no navegador.
-- A implementação futura deve estabelecer identidade confiável e testar isolamento por tenant.
