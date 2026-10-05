# Banco de dados do GEAR

O MySQL Workbench é a ferramenta gráfica utilizada para administrar o banco.
O servidor de banco de dados do projeto é o MySQL 8.0 ou superior.

## Criar o banco pelo Workbench

1. Abra o MySQL Workbench e conecte-se ao servidor local.
2. Acesse **File > Open SQL Script**.
3. Selecione o arquivo `database/schema.sql`.
4. Execute o script completo pelo botão de raio.
5. Atualize o painel **Schemas** e abra o schema `gear`.

O script pode ser executado novamente sem apagar os dados existentes. Ele cria
o schema, as tabelas que ainda não existem, os perfis iniciais, as permissões,
as views e os gatilhos de integridade.

## Conferência rápida

Depois da importação, execute:

```sql
USE gear;

SHOW TABLES;

SELECT codigo, nome
FROM perfil
ORDER BY id;

SELECT *
FROM vw_estoque_baixo;
```

## Regras incorporadas no banco

- e-mail de usuário e placa normalizada são únicos;
- orçamento possui versões independentes;
- preços utilizados são preservados nos itens;
- saída de estoque não pode deixar saldo negativo;
- movimentações de estoque são imutáveis;
- pagamentos e estornos são lançamentos imutáveis;
- chaves de idempotência impedem lançamentos repetidos;
- views fornecem estoque baixo e resumo financeiro das ordens de serviço.

As validações de experiência de uso e de permissão também serão aplicadas no
Django. O banco permanece como última barreira para regras de integridade.

## Integração futura com Django

Na etapa 2, os modelos Django serão escritos para refletir este schema. As
migrações passarão a registrar evoluções da estrutura, e o arquivo SQL será
mantido como a referência de criação inicial para o Workbench.

