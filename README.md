# GEAR

GEAR é um sistema web de gestão para oficinas mecânicas. O projeto será
desenvolvido com Django, Django REST Framework e MySQL, com administração do
banco pelo MySQL Workbench.

## Etapa atual

A etapa 1 define o escopo da primeira versão, o fluxo de atendimento, os
perfis de acesso e os critérios de aceite. O schema inicial do banco está em
[`database/schema.sql`](database/schema.sql).

## Fluxo principal

```text
Cliente e veículo
       ↓
Ordem de serviço aberta
       ↓
Orçamento enviado e aprovado
       ↓
Execução e consumo de peças
       ↓
Ordem de serviço concluída
       ↓
Pagamento registrado
```

## Documentação

- [Escopo e requisitos da etapa 1](docs/01-escopo-e-requisitos.md)
- [Instruções do banco de dados](database/README.md)

## Tecnologias planejadas

- Python 3.14
- Django 5.2 LTS
- Django REST Framework
- MySQL 8.0 ou superior
- MySQL Workbench
- Bootstrap e Chart.js

## Convenções do repositório

- Commits escritos em português.
- Valores monetários armazenados com `DECIMAL`, sem ponto flutuante.
- Datas e horas persistidas em UTC e exibidas no fuso da oficina.
- Regras de negócio compartilhadas pelas telas e pela API.
- Alterações de estoque e operações financeiras mantêm histórico.

