# Etapa 1 — Escopo e requisitos do GEAR

## 1. Objetivo

O GEAR centraliza o atendimento de uma oficina mecânica, desde a entrada do
veículo até a conclusão do serviço e o recebimento. A primeira versão atende
uma oficina com vários funcionários e pode ser acessada pelo navegador.

## 2. Escopo da primeira versão

O sistema deve oferecer:

1. cadastro e consulta de clientes;
2. cadastro de veículos vinculados aos clientes;
3. catálogo de serviços;
4. cadastro de peças e controle de estoque;
5. abertura e acompanhamento de ordens de serviço;
6. elaboração, envio e aprovação de orçamentos;
7. registro de peças e serviços executados;
8. histórico completo de cada veículo;
9. registro de pagamentos e estornos;
10. usuários com permissões por perfil;
11. dashboard operacional e financeiro;
12. API REST autenticada e documentada.

Não fazem parte da primeira versão: emissão de nota fiscal, integração com
WhatsApp, agenda online do cliente, compra automática de peças, múltiplas
filiais e aplicativo móvel nativo.

## 3. Perfis de acesso

| Perfil | Responsabilidades iniciais |
|---|---|
| Administrador | Configurações, usuários, permissões e acesso completo |
| Atendente | Clientes, veículos, abertura de OS e orçamentos |
| Mecânico | Diagnóstico, execução e registro de peças e serviços |
| Financeiro | Pagamentos, estornos, faturamento e relatórios financeiros |

As permissões devem ser verificadas no servidor. A API deve aplicar as mesmas
restrições utilizadas pelas telas.

## 4. Fluxo de atendimento

1. O atendente localiza ou cadastra o cliente.
2. O atendente localiza ou cadastra o veículo.
3. Uma ordem de serviço é aberta com quilometragem e relato do cliente.
4. A oficina registra o diagnóstico e monta o orçamento.
5. O orçamento é enviado ao cliente.
6. A aprovação ou recusa é registrada com data e responsável.
7. Após a aprovação, a OS pode passar para `EM_EXECUCAO`.
8. Serviços realizados e peças efetivamente utilizadas são registrados.
9. Ao terminar o trabalho, a OS passa para `CONCLUIDA`.
10. O financeiro registra um ou mais pagamentos até a quitação.

## 5. Estados e transições

### Ordem de serviço

```text
ABERTA ──> EM_EXECUCAO ──> CONCLUIDA
   │             │
   └─────────────┴──────> CANCELADA
```

Regras:

- uma OS concluída não volta para execução;
- uma OS cancelada não pode receber novos serviços, peças ou pagamentos;
- iniciar uma OS exige um orçamento aprovado;
- concluir uma OS exige diagnóstico e descrição do trabalho realizado;
- toda mudança de estado registra usuário, data, estado anterior e novo estado.

### Orçamento

```text
RASCUNHO ──> ENVIADO ──> APROVADO
                     └─> RECUSADO
```

Um orçamento aprovado não é alterado. Mudanças posteriores geram uma nova
versão, preservando os valores e itens apresentados anteriormente.

## 6. Regras de negócio

### Clientes e veículos

- Um cliente pode possuir vários veículos.
- Um veículo possui um proprietário atual, mas cada OS preserva o cliente que
  contratou o atendimento naquela data.
- A placa normalizada deve ser única.
- Registros com histórico são desativados em vez de apagados.

### Valores

- Preços usam duas casas decimais e quantidades usam até três casas.
- Itens armazenam a descrição e o preço praticados no momento da operação.
- O total do orçamento é a soma dos itens menos o desconto geral.
- Serviço concluído e dinheiro recebido são indicadores diferentes.

### Estoque

- Toda alteração de saldo gera uma movimentação identificando usuário e motivo.
- A quantidade informada em uma movimentação é sempre positiva; o tipo define
  se ela soma ou subtrai do saldo.
- Não é permitida saída ou ajuste negativo superior ao saldo disponível.
- A baixa ocorre quando a peça é entregue para utilização na OS.
- Cancelamento ou sobra de peça exige uma movimentação de devolução.
- Uma chave de idempotência impede que a mesma operação seja lançada duas vezes.
- Movimentações não são editadas ou apagadas; correções usam nova movimentação.

### Financeiro

- Uma OS pode receber pagamentos parciais.
- Estornos são novos lançamentos vinculados ao pagamento original.
- O saldo a receber considera recebimentos válidos e seus estornos.
- Um orçamento aprovado ainda não conta como recebimento.

### Auditoria

- Operações relevantes devem registrar autor e data.
- Alterações de estado, movimentações de estoque e pagamentos mantêm histórico.
- Exclusões físicas de registros operacionais não serão oferecidas pela aplicação.

## 7. Indicadores do dashboard

| Indicador | Definição |
|---|---|
| OS em andamento | Quantidade de OS abertas ou em execução |
| Valor concluído | Total final das OS concluídas no período |
| Recebimentos | Pagamentos recebidos menos estornos no período |
| Valores a receber | Total devido menos pagamentos líquidos |
| Ticket médio | Valor concluído dividido pela quantidade de OS concluídas |
| Serviços mais realizados | Quantidade executada agrupada por serviço |
| Estoque baixo | Peças com saldo igual ou inferior ao estoque mínimo |

Todos os indicadores financeiros devem aceitar filtro por período.

## 8. Critérios de aceite da primeira versão

A primeira versão será considerada funcional quando for possível:

1. criar usuários e aplicar os quatro perfis de acesso;
2. cadastrar um cliente e seu veículo;
3. abrir uma OS e gerar um orçamento versionado;
4. registrar a aprovação e iniciar a execução;
5. consumir uma peça sem permitir saldo negativo ou lançamento duplicado;
6. registrar serviços, concluir a OS e consultar o histórico do veículo;
7. registrar pagamento parcial, quitação e estorno;
8. consultar os indicadores e conferir seus valores nos registros de origem;
9. executar o mesmo fluxo pelas telas e pela API conforme as permissões;
10. impedir transições, acessos e operações inválidas com mensagens claras.

## 9. Próxima etapa

A etapa 2 criará a base Django, a conexão com MySQL e o modelo de usuário
personalizado. Em seguida serão implementados clientes e veículos.

