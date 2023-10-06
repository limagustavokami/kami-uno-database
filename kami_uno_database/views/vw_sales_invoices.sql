USE db_uc_kami;
CREATE OR REPLACE ALGORITHM = UNDEFINED VIEW vw_sales_invoices AS
SELECT 
  nota_fiscal.cod_nota_fiscal,
  nota_fiscal.cod_empresa,
  nota_fiscal.cod_cliente,
  nota_fiscal.dt_emissao, 
  nota_fiscal.nop, 
  nota_fiscal.situacao, 
  nota_fiscal.vl_total_nota_fiscal
FROM 
  vd_nota_fiscal AS nota_fiscal
WHERE 
  nota_fiscal.nop IN (
    '6.102',
    '6.108',
    '6.404',
    'BLACKFRIDAY',
    'VENDA',
    'VENDA_S_ESTOQUE',
    'WORKSHOP',
    'VENDA DE MERCADORIA P/ NÃO CONTRIBUINTE',
    'VENDA MERCADORIA DENTRO DO ESTADO'
  )
AND nota_fiscal.situacao > 79
AND nota_fiscal.situacao < 86;
