# Arquitetura — plataforma universal de Ouvidoria

## Estado atual
O portal existente em `app/page.tsx` é um **protótipo visual**, sem persistência, autenticação ou geração real de protocolo. Não usar para dados reais.

## Domínios
- Instituição (tenant): configuração, marca, unidades e políticas.
- Equipe: associação de usuários a instituições, perfis e escopos.
- Manifestação: tipo, assunto, relato, sigilo, setor, situação e prazo.
- Tramitação: eventos imutáveis, responsáveis e respostas.
- Canal público: protocolo e credencial de acompanhamento, sem expor dados por enumeração.
- Relatórios: agregações por instituição, com regras de anonimização.

## Decisões de segurança
1. Toda entidade operacional possui `institution_id`.
2. Chaves estrangeiras compostas impedem vincular setores ou agentes de outra instituição.
3. RLS ativado e forçado, inicialmente sem políticas: acesso negado por padrão.
4. **RLS não substitui autorização**. A camada de serviço deve validar identidade, associação ativa, papel, escopo e confidencialidade.
5. Nunca confiar em `institution_id` enviado pelo navegador. Resolver tenant e identidade no servidor.
6. Evitar cliente de banco com privilégio de bypass RLS em rotas públicas.
7. Não armazenar identidade de denunciantes em logs, URLs ou eventos de auditoria genéricos.
8. Anexos devem ficar em bucket privado com varredura, limites e links temporários.
9. Consultas públicas exigem credencial aleatória forte, armazenada em hash, com rate limiting.
10. Migrações só devem ser aplicadas após escolha e configuração do provedor PostgreSQL.

## Próximas etapas
1. Conectar banco gerenciado e pipeline de migrações com rollback.
2. Integrar autenticação com sessões seguras e MFA para operadores.
3. Implementar políticas RLS vinculadas a claims verificadas e testes negativos de isolamento.
4. Criar endpoints com validação de entrada, transações, idempotência e logs de auditoria.
5. Implementar cadastro público com comprovante e acompanhamento seguro.
6. Implementar painel restrito, tramitação, prazos e relatórios.

## Critérios de aceite antes de produção
Testes de acesso cruzado entre tenants, vazamento por anexos, acesso anônimo, rate limiting, recuperação de backup, auditoria, LGPD e acessibilidade.
