

SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE DATABASE IF NOT EXISTS gear
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE gear;


CREATE TABLE IF NOT EXISTS perfil (
    id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    nome VARCHAR(60) NOT NULL,
    descricao VARCHAR(255) NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_perfil_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS permissao (
    id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(80) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    descricao VARCHAR(255) NULL,
    PRIMARY KEY (id),
    CONSTRAINT uq_permissao_codigo UNIQUE (codigo)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS usuario (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(254) NOT NULL,
    senha VARCHAR(128) NOT NULL,
    telefone VARCHAR(20) NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    equipe BOOLEAN NOT NULL DEFAULT TRUE,
    administrador BOOLEAN NOT NULL DEFAULT FALSE,
    ultimo_login_em DATETIME(6) NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_usuario_email UNIQUE (email)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS perfil_permissao (
    perfil_id SMALLINT UNSIGNED NOT NULL,
    permissao_id SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (perfil_id, permissao_id),
    CONSTRAINT fk_perfil_permissao_perfil
        FOREIGN KEY (perfil_id) REFERENCES perfil (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_perfil_permissao_permissao
        FOREIGN KEY (permissao_id) REFERENCES permissao (id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS usuario_perfil (
    usuario_id BIGINT UNSIGNED NOT NULL,
    perfil_id SMALLINT UNSIGNED NOT NULL,
    PRIMARY KEY (usuario_id, perfil_id),
    CONSTRAINT fk_usuario_perfil_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_usuario_perfil_perfil
        FOREIGN KEY (perfil_id) REFERENCES perfil (id)
        ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- Clientes, veículos e catálogos
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS cliente (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    tipo_pessoa ENUM('FISICA', 'JURIDICA') NOT NULL DEFAULT 'FISICA',
    nome VARCHAR(150) NOT NULL,
    documento VARCHAR(18) NULL,
    telefone VARCHAR(20) NOT NULL,
    telefone_secundario VARCHAR(20) NULL,
    email VARCHAR(254) NULL,
    cep VARCHAR(9) NULL,
    logradouro VARCHAR(150) NULL,
    numero VARCHAR(20) NULL,
    complemento VARCHAR(80) NULL,
    bairro VARCHAR(80) NULL,
    cidade VARCHAR(80) NULL,
    uf CHAR(2) NULL,
    observacoes TEXT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_cliente_documento UNIQUE (documento),
    INDEX idx_cliente_nome (nome),
    INDEX idx_cliente_telefone (telefone)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS veiculo (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    proprietario_id BIGINT UNSIGNED NOT NULL,
    placa VARCHAR(8) NOT NULL,
    marca VARCHAR(60) NOT NULL,
    modelo VARCHAR(80) NOT NULL,
    versao VARCHAR(80) NULL,
    ano_fabricacao SMALLINT UNSIGNED NULL,
    ano_modelo SMALLINT UNSIGNED NULL,
    cor VARCHAR(40) NULL,
    chassi VARCHAR(17) NULL,
    renavam VARCHAR(11) NULL,
    combustivel ENUM(
        'FLEX', 'GASOLINA', 'ETANOL', 'DIESEL', 'GNV', 'ELETRICO', 'HIBRIDO',
        'OUTRO'
    ) NULL,
    observacoes TEXT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_veiculo_placa UNIQUE (placa),
    CONSTRAINT uq_veiculo_chassi UNIQUE (chassi),
    CONSTRAINT uq_veiculo_renavam UNIQUE (renavam),
    CONSTRAINT fk_veiculo_proprietario
        FOREIGN KEY (proprietario_id) REFERENCES cliente (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_veiculo_ano_fabricacao
        CHECK (ano_fabricacao IS NULL OR ano_fabricacao BETWEEN 1886 AND 2200),
    CONSTRAINT ck_veiculo_ano_modelo
        CHECK (ano_modelo IS NULL OR ano_modelo BETWEEN 1886 AND 2200),
    INDEX idx_veiculo_proprietario (proprietario_id),
    INDEX idx_veiculo_modelo (marca, modelo)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS servico_catalogo (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(30) NOT NULL,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT NULL,
    valor_referencia DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    duracao_estimada_minutos SMALLINT UNSIGNED NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_servico_codigo UNIQUE (codigo),
    CONSTRAINT ck_servico_valor CHECK (valor_referencia >= 0),
    INDEX idx_servico_nome (nome)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS peca (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    codigo VARCHAR(40) NOT NULL,
    codigo_barras VARCHAR(50) NULL,
    nome VARCHAR(120) NOT NULL,
    descricao TEXT NULL,
    unidade_medida VARCHAR(10) NOT NULL DEFAULT 'UN',
    valor_custo DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    valor_venda DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    estoque_atual DECIMAL(12, 3) NOT NULL DEFAULT 0.000,
    estoque_minimo DECIMAL(12, 3) NOT NULL DEFAULT 0.000,
    localizacao VARCHAR(80) NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_peca_codigo UNIQUE (codigo),
    CONSTRAINT uq_peca_codigo_barras UNIQUE (codigo_barras),
    CONSTRAINT ck_peca_valores
        CHECK (valor_custo >= 0 AND valor_venda >= 0),
    CONSTRAINT ck_peca_estoque
        CHECK (estoque_atual >= 0 AND estoque_minimo >= 0),
    INDEX idx_peca_nome (nome),
    INDEX idx_peca_estoque (ativo, estoque_atual, estoque_minimo)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- Ordens de serviço e histórico de estados
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ordem_servico (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    numero VARCHAR(24) NOT NULL,
    cliente_id BIGINT UNSIGNED NOT NULL,
    veiculo_id BIGINT UNSIGNED NOT NULL,
    atendente_id BIGINT UNSIGNED NOT NULL,
    mecanico_responsavel_id BIGINT UNSIGNED NULL,
    status ENUM('ABERTA', 'EM_EXECUCAO', 'CONCLUIDA', 'CANCELADA')
        NOT NULL DEFAULT 'ABERTA',
    quilometragem_entrada INT UNSIGNED NULL,
    nivel_combustivel TINYINT UNSIGNED NULL,
    relato_cliente TEXT NOT NULL,
    diagnostico TEXT NULL,
    trabalho_realizado TEXT NULL,
    observacoes TEXT NULL,
    desconto_geral DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    aberta_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    iniciada_em DATETIME(6) NULL,
    concluida_em DATETIME(6) NULL,
    cancelada_em DATETIME(6) NULL,
    previsao_conclusao_em DATETIME(6) NULL,
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_ordem_servico_numero UNIQUE (numero),
    CONSTRAINT fk_os_cliente
        FOREIGN KEY (cliente_id) REFERENCES cliente (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_os_veiculo
        FOREIGN KEY (veiculo_id) REFERENCES veiculo (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_os_atendente
        FOREIGN KEY (atendente_id) REFERENCES usuario (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_os_mecanico
        FOREIGN KEY (mecanico_responsavel_id) REFERENCES usuario (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_os_nivel_combustivel
        CHECK (nivel_combustivel IS NULL OR nivel_combustivel BETWEEN 0 AND 100),
    CONSTRAINT ck_os_desconto CHECK (desconto_geral >= 0),
    INDEX idx_os_cliente (cliente_id),
    INDEX idx_os_veiculo (veiculo_id),
    INDEX idx_os_status_data (status, aberta_em),
    INDEX idx_os_mecanico (mecanico_responsavel_id, status)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS ordem_servico_status_historico (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ordem_servico_id BIGINT UNSIGNED NOT NULL,
    status_anterior ENUM('ABERTA', 'EM_EXECUCAO', 'CONCLUIDA', 'CANCELADA') NULL,
    status_novo ENUM('ABERTA', 'EM_EXECUCAO', 'CONCLUIDA', 'CANCELADA') NOT NULL,
    alterado_por_id BIGINT UNSIGNED NOT NULL,
    motivo VARCHAR(255) NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_historico_status_os
        FOREIGN KEY (ordem_servico_id) REFERENCES ordem_servico (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_historico_status_usuario
        FOREIGN KEY (alterado_por_id) REFERENCES usuario (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_historico_status_alterado
        CHECK (status_anterior IS NULL OR status_anterior <> status_novo),
    INDEX idx_historico_status_os_data (ordem_servico_id, criado_em)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- Orçamentos versionados
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS orcamento (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ordem_servico_id BIGINT UNSIGNED NOT NULL,
    versao SMALLINT UNSIGNED NOT NULL,
    status ENUM('RASCUNHO', 'ENVIADO', 'APROVADO', 'RECUSADO')
        NOT NULL DEFAULT 'RASCUNHO',
    subtotal DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    desconto DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    total DECIMAL(14, 2) NOT NULL DEFAULT 0.00,
    validade_em DATE NULL,
    observacoes TEXT NULL,
    criado_por_id BIGINT UNSIGNED NOT NULL,
    enviado_em DATETIME(6) NULL,
    respondido_em DATETIME(6) NULL,
    resposta_registrada_por_id BIGINT UNSIGNED NULL,
    nome_aprovador VARCHAR(150) NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_orcamento_os_versao UNIQUE (ordem_servico_id, versao),
    CONSTRAINT fk_orcamento_os
        FOREIGN KEY (ordem_servico_id) REFERENCES ordem_servico (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orcamento_criador
        FOREIGN KEY (criado_por_id) REFERENCES usuario (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orcamento_resposta_usuario
        FOREIGN KEY (resposta_registrada_por_id) REFERENCES usuario (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_orcamento_valores
        CHECK (
            subtotal >= 0
            AND desconto >= 0
            AND desconto <= subtotal
            AND total = subtotal - desconto
        ),
    INDEX idx_orcamento_status (status, criado_em)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS orcamento_item (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    orcamento_id BIGINT UNSIGNED NOT NULL,
    tipo ENUM('SERVICO', 'PECA', 'OUTRO') NOT NULL,
    servico_id BIGINT UNSIGNED NULL,
    peca_id BIGINT UNSIGNED NULL,
    descricao VARCHAR(255) NOT NULL,
    quantidade DECIMAL(12, 3) NOT NULL,
    valor_unitario DECIMAL(12, 2) NOT NULL,
    desconto DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total DECIMAL(14, 2)
        GENERATED ALWAYS AS (
            ROUND((quantidade * valor_unitario) - desconto, 2)
        ) STORED,
    ordem SMALLINT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (id),
    CONSTRAINT fk_orcamento_item_orcamento
        FOREIGN KEY (orcamento_id) REFERENCES orcamento (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_orcamento_item_servico
        FOREIGN KEY (servico_id) REFERENCES servico_catalogo (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_orcamento_item_peca
        FOREIGN KEY (peca_id) REFERENCES peca (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_orcamento_item_referencia
        CHECK (
            (tipo = 'SERVICO' AND servico_id IS NOT NULL AND peca_id IS NULL)
            OR (tipo = 'PECA' AND peca_id IS NOT NULL AND servico_id IS NULL)
            OR (tipo = 'OUTRO' AND servico_id IS NULL AND peca_id IS NULL)
        ),
    CONSTRAINT ck_orcamento_item_valores
        CHECK (
            quantidade > 0
            AND valor_unitario >= 0
            AND desconto >= 0
            AND desconto <= quantidade * valor_unitario
        ),
    INDEX idx_orcamento_item_orcamento (orcamento_id, ordem)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- Itens efetivamente realizados na ordem de serviço
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ordem_servico_servico (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ordem_servico_id BIGINT UNSIGNED NOT NULL,
    servico_id BIGINT UNSIGNED NULL,
    mecanico_id BIGINT UNSIGNED NULL,
    descricao VARCHAR(255) NOT NULL,
    quantidade DECIMAL(12, 3) NOT NULL DEFAULT 1.000,
    valor_unitario DECIMAL(12, 2) NOT NULL,
    desconto DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total DECIMAL(14, 2)
        GENERATED ALWAYS AS (
            ROUND((quantidade * valor_unitario) - desconto, 2)
        ) STORED,
    status ENUM('PENDENTE', 'EM_EXECUCAO', 'CONCLUIDO', 'CANCELADO')
        NOT NULL DEFAULT 'PENDENTE',
    iniciado_em DATETIME(6) NULL,
    concluido_em DATETIME(6) NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_os_servico_os
        FOREIGN KEY (ordem_servico_id) REFERENCES ordem_servico (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_os_servico_catalogo
        FOREIGN KEY (servico_id) REFERENCES servico_catalogo (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_os_servico_mecanico
        FOREIGN KEY (mecanico_id) REFERENCES usuario (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_os_servico_valores
        CHECK (
            quantidade > 0
            AND valor_unitario >= 0
            AND desconto >= 0
            AND desconto <= quantidade * valor_unitario
        ),
    INDEX idx_os_servico_os (ordem_servico_id),
    INDEX idx_os_servico_mecanico (mecanico_id, status)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS ordem_servico_peca (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ordem_servico_id BIGINT UNSIGNED NOT NULL,
    peca_id BIGINT UNSIGNED NOT NULL,
    descricao VARCHAR(255) NOT NULL,
    quantidade_prevista DECIMAL(12, 3) NOT NULL,
    quantidade_utilizada DECIMAL(12, 3) NOT NULL DEFAULT 0.000,
    valor_unitario DECIMAL(12, 2) NOT NULL,
    desconto DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total DECIMAL(14, 2)
        GENERATED ALWAYS AS (
            ROUND((quantidade_utilizada * valor_unitario) - desconto, 2)
        ) STORED,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    atualizado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
        ON UPDATE CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_os_peca_os
        FOREIGN KEY (ordem_servico_id) REFERENCES ordem_servico (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_os_peca_catalogo
        FOREIGN KEY (peca_id) REFERENCES peca (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_os_peca_quantidades
        CHECK (
            quantidade_prevista > 0
            AND quantidade_utilizada >= 0
            AND quantidade_utilizada <= quantidade_prevista
        ),
    CONSTRAINT ck_os_peca_valores
        CHECK (
            valor_unitario >= 0
            AND desconto >= 0
            AND desconto <= quantidade_utilizada * valor_unitario
        ),
    INDEX idx_os_peca_os (ordem_servico_id),
    INDEX idx_os_peca_peca (peca_id)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- Estoque
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS movimentacao_estoque (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    peca_id BIGINT UNSIGNED NOT NULL,
    ordem_servico_id BIGINT UNSIGNED NULL,
    ordem_servico_peca_id BIGINT UNSIGNED NULL,
    usuario_id BIGINT UNSIGNED NOT NULL,
    tipo ENUM(
        'ENTRADA', 'SAIDA', 'DEVOLUCAO', 'AJUSTE_POSITIVO', 'AJUSTE_NEGATIVO'
    ) NOT NULL,
    quantidade DECIMAL(12, 3) NOT NULL,
    motivo VARCHAR(255) NOT NULL,
    documento_referencia VARCHAR(80) NULL,
    chave_idempotencia VARCHAR(64) NOT NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_movimentacao_chave UNIQUE (chave_idempotencia),
    CONSTRAINT fk_movimentacao_peca
        FOREIGN KEY (peca_id) REFERENCES peca (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimentacao_os
        FOREIGN KEY (ordem_servico_id) REFERENCES ordem_servico (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimentacao_os_peca
        FOREIGN KEY (ordem_servico_peca_id) REFERENCES ordem_servico_peca (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_movimentacao_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_movimentacao_quantidade CHECK (quantidade > 0),
    CONSTRAINT ck_movimentacao_vinculo_os
        CHECK (
            ordem_servico_peca_id IS NULL
            OR ordem_servico_id IS NOT NULL
        ),
    INDEX idx_movimentacao_peca_data (peca_id, criado_em),
    INDEX idx_movimentacao_os (ordem_servico_id)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- Financeiro
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS pagamento (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    ordem_servico_id BIGINT UNSIGNED NOT NULL,
    tipo ENUM('RECEBIMENTO', 'ESTORNO') NOT NULL DEFAULT 'RECEBIMENTO',
    pagamento_original_id BIGINT UNSIGNED NULL,
    forma ENUM(
        'DINHEIRO', 'PIX', 'CARTAO_CREDITO', 'CARTAO_DEBITO', 'BOLETO',
        'TRANSFERENCIA', 'OUTRO'
    ) NOT NULL,
    valor DECIMAL(14, 2) NOT NULL,
    referencia_externa VARCHAR(100) NULL,
    observacoes VARCHAR(255) NULL,
    chave_idempotencia VARCHAR(64) NOT NULL,
    registrado_por_id BIGINT UNSIGNED NOT NULL,
    pago_em DATETIME(6) NOT NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT uq_pagamento_chave UNIQUE (chave_idempotencia),
    CONSTRAINT fk_pagamento_os
        FOREIGN KEY (ordem_servico_id) REFERENCES ordem_servico (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_pagamento_original
        FOREIGN KEY (pagamento_original_id) REFERENCES pagamento (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_pagamento_usuario
        FOREIGN KEY (registrado_por_id) REFERENCES usuario (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT ck_pagamento_valor CHECK (valor > 0),
    CONSTRAINT ck_pagamento_estorno
        CHECK (
            (tipo = 'RECEBIMENTO' AND pagamento_original_id IS NULL)
            OR (tipo = 'ESTORNO' AND pagamento_original_id IS NOT NULL)
        ),
    CONSTRAINT ck_pagamento_nao_auto_referencia
        CHECK (pagamento_original_id IS NULL OR pagamento_original_id <> id),
    INDEX idx_pagamento_os_data (ordem_servico_id, pago_em),
    INDEX idx_pagamento_original (pagamento_original_id)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- Auditoria genérica
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS registro_auditoria (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    usuario_id BIGINT UNSIGNED NULL,
    entidade VARCHAR(80) NOT NULL,
    registro_id VARCHAR(64) NOT NULL,
    acao ENUM('CRIACAO', 'ALTERACAO', 'DESATIVACAO', 'ACAO') NOT NULL,
    dados_anteriores JSON NULL,
    dados_novos JSON NULL,
    endereco_ip VARBINARY(16) NULL,
    criado_em DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
    PRIMARY KEY (id),
    CONSTRAINT fk_auditoria_usuario
        FOREIGN KEY (usuario_id) REFERENCES usuario (id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_auditoria_entidade_registro (entidade, registro_id),
    INDEX idx_auditoria_data (criado_em)
) ENGINE = InnoDB;

-- ---------------------------------------------------------------------------
-- Dados iniciais de autorização
-- ---------------------------------------------------------------------------

INSERT IGNORE INTO perfil (codigo, nome, descricao) VALUES
    ('ADMINISTRADOR', 'Administrador', 'Acesso completo ao sistema'),
    ('ATENDENTE', 'Atendente', 'Atendimento, cadastros, OS e orçamentos'),
    ('MECANICO', 'Mecânico', 'Diagnóstico e execução dos serviços'),
    ('FINANCEIRO', 'Financeiro', 'Pagamentos e relatórios financeiros');

INSERT IGNORE INTO permissao (codigo, nome) VALUES
    ('clientes.visualizar', 'Visualizar clientes'),
    ('clientes.gerenciar', 'Gerenciar clientes'),
    ('veiculos.visualizar', 'Visualizar veículos'),
    ('veiculos.gerenciar', 'Gerenciar veículos'),
    ('catalogos.visualizar', 'Visualizar peças e serviços'),
    ('catalogos.gerenciar', 'Gerenciar peças e serviços'),
    ('estoque.visualizar', 'Visualizar estoque'),
    ('estoque.movimentar', 'Movimentar estoque'),
    ('ordens.visualizar', 'Visualizar ordens de serviço'),
    ('ordens.gerenciar', 'Gerenciar ordens de serviço'),
    ('ordens.executar', 'Executar serviços da ordem'),
    ('orcamentos.gerenciar', 'Gerenciar orçamentos'),
    ('financeiro.visualizar', 'Visualizar dados financeiros'),
    ('financeiro.gerenciar', 'Registrar pagamentos e estornos'),
    ('dashboard.visualizar', 'Visualizar dashboard'),
    ('usuarios.gerenciar', 'Gerenciar usuários e permissões');

INSERT IGNORE INTO perfil_permissao (perfil_id, permissao_id)
SELECT perfil.id, permissao.id
FROM perfil
CROSS JOIN permissao
WHERE perfil.codigo = 'ADMINISTRADOR';

INSERT IGNORE INTO perfil_permissao (perfil_id, permissao_id)
SELECT perfil.id, permissao.id
FROM perfil
JOIN permissao ON permissao.codigo IN (
    'clientes.visualizar', 'clientes.gerenciar',
    'veiculos.visualizar', 'veiculos.gerenciar',
    'catalogos.visualizar', 'estoque.visualizar',
    'ordens.visualizar', 'ordens.gerenciar',
    'orcamentos.gerenciar', 'dashboard.visualizar'
)
WHERE perfil.codigo = 'ATENDENTE';

INSERT IGNORE INTO perfil_permissao (perfil_id, permissao_id)
SELECT perfil.id, permissao.id
FROM perfil
JOIN permissao ON permissao.codigo IN (
    'clientes.visualizar', 'veiculos.visualizar', 'catalogos.visualizar',
    'estoque.visualizar', 'estoque.movimentar',
    'ordens.visualizar', 'ordens.executar'
)
WHERE perfil.codigo = 'MECANICO';

INSERT IGNORE INTO perfil_permissao (perfil_id, permissao_id)
SELECT perfil.id, permissao.id
FROM perfil
JOIN permissao ON permissao.codigo IN (
    'clientes.visualizar', 'veiculos.visualizar', 'ordens.visualizar',
    'financeiro.visualizar', 'financeiro.gerenciar', 'dashboard.visualizar'
)
WHERE perfil.codigo = 'FINANCEIRO';

-- ---------------------------------------------------------------------------
-- Gatilhos de integridade do estoque e financeiro
-- ---------------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_movimentacao_estoque_bi;
DROP TRIGGER IF EXISTS trg_movimentacao_estoque_bu;
DROP TRIGGER IF EXISTS trg_movimentacao_estoque_bd;
DROP TRIGGER IF EXISTS trg_pagamento_bu;
DROP TRIGGER IF EXISTS trg_pagamento_bd;

DELIMITER $$

CREATE TRIGGER trg_movimentacao_estoque_bi
BEFORE INSERT ON movimentacao_estoque
FOR EACH ROW
BEGIN
    IF NEW.quantidade <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A quantidade da movimentação deve ser positiva';
    END IF;

    IF NEW.tipo IN ('SAIDA', 'AJUSTE_NEGATIVO') THEN
        UPDATE peca
        SET estoque_atual = estoque_atual - NEW.quantidade
        WHERE id = NEW.peca_id
          AND estoque_atual >= NEW.quantidade;

        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Saldo insuficiente ou peça inexistente';
        END IF;
    ELSE
        UPDATE peca
        SET estoque_atual = estoque_atual + NEW.quantidade
        WHERE id = NEW.peca_id;

        IF ROW_COUNT() = 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Peça inexistente';
        END IF;
    END IF;
END$$

CREATE TRIGGER trg_movimentacao_estoque_bu
BEFORE UPDATE ON movimentacao_estoque
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Movimentações de estoque não podem ser alteradas';
END$$

CREATE TRIGGER trg_movimentacao_estoque_bd
BEFORE DELETE ON movimentacao_estoque
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Movimentações de estoque não podem ser apagadas';
END$$

CREATE TRIGGER trg_pagamento_bu
BEFORE UPDATE ON pagamento
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pagamentos não podem ser alterados; registre um estorno';
END$$

CREATE TRIGGER trg_pagamento_bd
BEFORE DELETE ON pagamento
FOR EACH ROW
BEGIN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pagamentos não podem ser apagados; registre um estorno';
END$$

DELIMITER ;

-- ---------------------------------------------------------------------------
-- Views para operação e dashboard
-- ---------------------------------------------------------------------------

CREATE OR REPLACE VIEW vw_estoque_baixo AS
SELECT
    peca.id,
    peca.codigo,
    peca.nome,
    peca.unidade_medida,
    peca.estoque_atual,
    peca.estoque_minimo,
    peca.estoque_minimo - peca.estoque_atual AS quantidade_para_repor
FROM peca
WHERE peca.ativo = TRUE
  AND peca.estoque_atual <= peca.estoque_minimo;

CREATE OR REPLACE VIEW vw_resumo_ordem_servico AS
SELECT
    os.id,
    os.numero,
    os.cliente_id,
    os.veiculo_id,
    os.status,
    os.aberta_em,
    os.concluida_em,
    COALESCE(servicos.total, 0.00) AS total_servicos,
    COALESCE(pecas.total, 0.00) AS total_pecas,
    os.desconto_geral,
    GREATEST(
        COALESCE(servicos.total, 0.00)
        + COALESCE(pecas.total, 0.00)
        - os.desconto_geral,
        0.00
    ) AS total_ordem,
    COALESCE(pagamentos.total, 0.00) AS total_recebido,
    GREATEST(
        COALESCE(servicos.total, 0.00)
        + COALESCE(pecas.total, 0.00)
        - os.desconto_geral
        - COALESCE(pagamentos.total, 0.00),
        0.00
    ) AS saldo_a_receber
FROM ordem_servico AS os
LEFT JOIN (
    SELECT ordem_servico_id, SUM(total) AS total
    FROM ordem_servico_servico
    WHERE status <> 'CANCELADO'
    GROUP BY ordem_servico_id
) AS servicos ON servicos.ordem_servico_id = os.id
LEFT JOIN (
    SELECT ordem_servico_id, SUM(total) AS total
    FROM ordem_servico_peca
    GROUP BY ordem_servico_id
) AS pecas ON pecas.ordem_servico_id = os.id
LEFT JOIN (
    SELECT
        ordem_servico_id,
        SUM(
            CASE tipo
                WHEN 'RECEBIMENTO' THEN valor
                WHEN 'ESTORNO' THEN -valor
            END
        ) AS total
    FROM pagamento
    GROUP BY ordem_servico_id
) AS pagamentos ON pagamentos.ordem_servico_id = os.id;

