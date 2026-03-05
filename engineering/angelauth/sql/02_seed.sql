-- Angelauth: datos iniciales de roles y permisos (design.md §2.8)
-- Ejecutar después de 01_tables.sql: psql -d prodaric_accounting -U prodaric_sys -f angelauth/sql/02_seed.sql

INSERT INTO angelauth.role (id, code, name) VALUES
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a31', 'admin', 'Administrator'),
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a32', 'accountant', 'Accountant'),
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a33', 'auditor', 'Auditor'),
  ('c1eebc99-9c0b-4ef8-bb6d-6bb9bd380a34', 'viewer', 'Viewer')
ON CONFLICT (code) DO NOTHING;

INSERT INTO angelauth.permission (id, code, name) VALUES
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a41', 'entity:read', 'View entities'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a42', 'entity:manage', 'Manage entities'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a43', 'period:read', 'View periods'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a44', 'period:manage', 'Manage periods'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a45', 'chart_of_accounts:read', 'View chart of accounts'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a46', 'chart_of_accounts:write', 'Edit chart of accounts'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a47', 'journal:write', 'Register entries'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a48', 'ledger:read', 'Read ledger'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a49', 'balance:read', 'Read balances'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a4a', 'report:read', 'Read reports'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a4b', 'configuration:read', 'View configuration'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a4c', 'configuration:write', 'Edit configuration'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a4d', 'sustainability:read', 'View sustainability'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a4e', 'sustainability:write', 'Edit sustainability'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a4f', 'user:read', 'View users'),
  ('d1eebc99-9c0b-4ef8-bb6d-6bb9bd380a50', 'user:manage', 'Manage users')
ON CONFLICT (code) DO NOTHING;

-- role_permission: admin = todos; accountant, auditor, viewer según design.md §2.8
INSERT INTO angelauth.role_permission (role_id, permission_id)
SELECT r.id, p.id FROM angelauth.role r, angelauth.permission p
WHERE r.code = 'admin'
ON CONFLICT DO NOTHING;

INSERT INTO angelauth.role_permission (role_id, permission_id)
SELECT r.id, p.id FROM angelauth.role r, angelauth.permission p
WHERE r.code = 'accountant' AND p.code IN (
  'entity:read','period:read','chart_of_accounts:read','chart_of_accounts:write','journal:write',
  'ledger:read','balance:read','report:read','configuration:read','sustainability:read','sustainability:write'
)
ON CONFLICT DO NOTHING;

INSERT INTO angelauth.role_permission (role_id, permission_id)
SELECT r.id, p.id FROM angelauth.role r, angelauth.permission p
WHERE r.code = 'auditor' AND p.code IN (
  'entity:read','period:read','chart_of_accounts:read','ledger:read','balance:read','report:read',
  'configuration:read','sustainability:read'
)
ON CONFLICT DO NOTHING;

INSERT INTO angelauth.role_permission (role_id, permission_id)
SELECT r.id, p.id FROM angelauth.role r, angelauth.permission p
WHERE r.code = 'viewer' AND p.code IN (
  'entity:read','period:read','chart_of_accounts:read','balance:read','report:read'
)
ON CONFLICT DO NOTHING;
