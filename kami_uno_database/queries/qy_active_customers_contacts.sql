SELECT
  DISTINCTROW IFNULL(
    CAST(`cliente`.`cod_cliente` AS CHAR charset utf8mb4),
    '0'
  ) AS `cod_cliente`,  
  IFNULL(
    CAST(`cliente`.`nome_cliente` AS CHAR charset utf8mb4),
    '0'
  ) AS `nome_cliente`,
  IFNULL(
    CAST(`cliente`.`razao_social` AS CHAR charset utf8mb4),
    '0'
  ) AS `razao_social`,
  IFNULL(
    CAST(`cliente`.`tp_cliente` AS CHAR charset utf8mb4),
    '0'
  ) AS `tp_cliente`,  
  IFNULL(
    CAST(
      `cliente_contato`.`cod_contato` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `cod_contato`,
  IFNULL(
    CAST(
      `cliente_contato`.`nome_contato` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `nome_contato`,
  IFNULL(
    CAST(
      `cliente_contato`.`sexo` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `sexo`,
  IFNULL(
    CAST(
      `cliente_contato`.`rg` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `rg`,
  IFNULL(
    CAST(
      `cliente_contato`.`cpf` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `cpf`,
  IFNULL(
    CAST(
      `cliente_contato`.`descricao` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `descricao`,IFNULL(
    CAST(
      `cliente_contato`.`obs_contato` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `obs_contato`,
  IFNULL(
    CAST(
      `cliente_contato`.`endereco` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `endereco`,
  IFNULL(
    CAST(
      `cliente_contato`.`numero` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `numero`,
  IFNULL(
    CAST(
      `cliente_contato`.`complemento_end` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `complemento_end`,
  IFNULL(
    CAST(
      `cliente_contato`.`bairro` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `bairro`,
  IFNULL(
    CAST(
      `cliente_contato`.`cidade` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `cidade`,
  IFNULL(
    CAST(
      `cliente_contato`.`sigla_uf` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `sigla_uf`,
  IFNULL(
    CAST(
      `cliente_contato`.`pais` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `pais`,
  IFNULL(
    CAST(
      `cliente_contato`.`referencia_end` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `referencia_end`,
  IFNULL(
    CAST(
      `cliente_contato`.`cep` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `cep`,
  IFNULL(
    CAST(
      `cliente_contato`.`dt_nascimento` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `dt_nascimento`,
  IFNULL(
    CAST(
      `cliente_contato`.`naturalidade` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `naturalidade`,
  IFNULL(
    CAST(
      `cliente_contato`.`nacionalidade` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `nacionalidade`,
  IFNULL(
    CAST(
      `cliente_contato`.`estado_civil` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `estado_civil`,
  IFNULL(
    CAST(
      `cliente_contato`.`email` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `email`,
  IFNULL(
    CAST(
      `cliente_telefone`.`ddi` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `ddi`,
  IFNULL(
    CAST(
      `cliente_telefone`.`ddd` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `ddd`,
  IFNULL(
    CAST(
      `cliente_telefone`.`telefone` AS CHAR charset utf8mb4
    ),
    '0'
  ) AS `telefone`
  
FROM
  (
    (
      (
        (
          `cd_cliente` AS `cliente`
          LEFT JOIN `cd_cliente_contato` AS `cliente_contato` ON (
            `cliente_contato`.`cod_cliente` = `cliente`.`cod_cliente`
          )
        )
        LEFT JOIN `cd_cliente_contato_telefone` AS `cliente_contato_telefone` ON (
          `cliente_contato_telefone`.`cod_cliente` = `cliente`.`cod_cliente`
        )
        LEFT JOIN `cd_cliente_telefone` AS `cliente_telefone` ON (
          `cliente_telefone`.`cod_contato` = `cliente_contato_telefone`.`cod_contato`
        )
      )      
    )
  )
WHERE
  (
    `cliente`.`cod_cliente` IN (
      SELECT
        DISTINCTROW `nota_fiscal`.`cod_cliente`
      FROM
        `vd_nota_fiscal` AS `nota_fiscal`
      WHERE (`nota_fiscal`.`dt_emissao` >= SUBDATE(CURDATE(), INTERVAL 365 DAY))
        AND (`nota_fiscal`.`cod_empresa` IN (1, 2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14, 15, 16))
        AND (`nota_fiscal`.`situacao` > 79)
        AND (`nota_fiscal`.`situacao` < 86))
 )
GROUP BY `cliente`.`cod_cliente`;