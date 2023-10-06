USE db_uc_kami;

DROP FUNCTION IF EXISTS GetDiasAtraso;
DELIMITER //
CREATE FUNCTION GetDiasAtraso(cod_cliente INT) RETURNS INT
BEGIN
  RETURN (
    SELECT
      CASE
        WHEN (SUM(recebe.vl_total_titulo) - SUM(recebe.vl_total_baixa)) > 0
        THEN TIMESTAMPDIFF(DAY, recebe.dt_vencimento, CURRENT_DATE())
        ELSE 0
      END
    FROM fn_titulo_receber AS recebe
    WHERE recebe.dt_vencimento < SUBDATE(CURDATE(), INTERVAL 1 DAY)
    AND recebe.situacao < 30
    AND recebe.cod_cliente = cod_cliente
  );
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetValorDevido;
DELIMITER //
CREATE FUNCTION GetValorDevido(cod_cliente INT) RETURNS INT
BEGIN
  RETURN (
    SELECT
      CASE
        WHEN (SUM(recebe.vl_total_titulo) - SUM(recebe.vl_total_baixa)) > 0
        THEN (SUM(recebe.vl_total_titulo) - SUM(recebe.vl_total_baixa))
        ELSE 0
      END
    FROM fn_titulo_receber AS recebe
    WHERE recebe.dt_vencimento < SUBDATE(CURDATE(), INTERVAL 1 DAY)
    AND recebe.situacao < 30
    AND recebe.cod_cliente = cod_cliente
  );
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetDtPrimeiraCompra;
DELIMITER //
CREATE FUNCTION GetDtPrimeiraCompra(cod_cliente INT) RETURNS DATETIME
BEGIN
  RETURN (
    SELECT MIN(nota_fiscal.dt_emissao)
    FROM vw_sales_invoices AS nota_fiscal
    WHERE nota_fiscal.cod_cliente = cod_cliente
  );
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetDtUltimaCompra;
DELIMITER //
CREATE FUNCTION GetDtUltimaCompra(cod_cliente INT) RETURNS DATETIME
BEGIN
  RETURN (
    SELECT MAX(nota_fiscal.dt_emissao)
    FROM vw_sales_invoices AS nota_fiscal
    WHERE nota_fiscal.cod_cliente = cod_cliente
  );
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetDtPenultimaCompra;
DELIMITER //
CREATE FUNCTION GetDtPenultimaCompra(cod_cliente INT) RETURNS DATETIME
BEGIN
  RETURN (
    SELECT nota_fiscal.dt_emissao
    FROM vw_sales_invoices AS nota_fiscal
    WHERE nota_fiscal.cod_cliente = cod_cliente
    ORDER BY nota_fiscal.dt_emissao DESC
    LIMIT 1 OFFSET 1
  );
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetDiasUltimaCompra;
DELIMITER //
CREATE FUNCTION GetDiasUltimaCompra(cod_cliente INT) RETURNS INT
BEGIN
    RETURN TIMESTAMPDIFF(DAY, GetDtUltimaCompra(cod_cliente), CURRENT_DATE());
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetDiasPenultimaCompra;
DELIMITER //
CREATE FUNCTION GetDiasPenultimaCompra(cod_cliente INT) RETURNS INT
BEGIN
  RETURN TIMESTAMPDIFF(DAY, GetDtPenultimaCompra(cod_cliente), CURRENT_DATE());
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetQtdTotalCompras;
DELIMITER //
CREATE FUNCTION GetQtdTotalCompras(cod_cliente INT) RETURNS INT
BEGIN
  RETURN (
    SELECT COUNT(nota_fiscal.cod_nota_fiscal)
    FROM vw_sales_invoices AS nota_fiscal
    WHERE nota_fiscal.cod_cliente = cod_cliente
  );
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetQtdComprasSemestre;
DELIMITER //
CREATE FUNCTION GetQtdComprasSemestre(cod_cliente INT) RETURNS INT
BEGIN
  RETURN (
    SELECT COUNT(nota_fiscal.cod_nota_fiscal)
    FROM vw_sales_invoices AS nota_fiscal
    WHERE nota_fiscal.cod_cliente = cod_cliente
    AND (TIMESTAMPDIFF(DAY, nota_fiscal.dt_emissao, CURRENT_DATE()) <= 180)
  );
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetTotalComprasBimestre;
DELIMITER //
CREATE FUNCTION GetTotalComprasBimestre(cod_cliente INT) RETURNS DECIMAL(10, 2) 
BEGIN
  RETURN (
    SELECT SUM(nota_fiscal.vl_total_nota_fiscal)
    FROM vw_sales_invoices AS nota_fiscal
    WHERE nota_fiscal.cod_cliente = cod_cliente
    AND (TIMESTAMPDIFF(DAY, nota_fiscal.dt_emissao, CURRENT_DATE()) <= 60)
  );
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetTotalComprasTrimestre;
DELIMITER //
CREATE FUNCTION GetTotalComprasTrimestre(cod_cliente INT) RETURNS DECIMAL(10, 2)
BEGIN
  RETURN (
    SELECT SUM(nota_fiscal.vl_total_nota_fiscal)
    FROM vw_sales_invoices AS nota_fiscal
    WHERE nota_fiscal.cod_cliente = cod_cliente
    AND (TIMESTAMPDIFF(DAY, nota_fiscal.dt_emissao, CURRENT_DATE()) <= 90)
  );
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetTotalComprasSemestre;
DELIMITER //
CREATE FUNCTION GetTotalComprasSemestre(cod_cliente INT) RETURNS DECIMAL(10, 2) 
BEGIN
  RETURN (
    SELECT SUM(nota_fiscal.vl_total_nota_fiscal)
    FROM vw_sales_invoices AS nota_fiscal
    WHERE nota_fiscal.cod_cliente = cod_cliente
    AND (TIMESTAMPDIFF(DAY, nota_fiscal.dt_emissao, CURRENT_DATE()) <= 180)
  );
END //
DELIMITER ;

DROP FUNCTION IF EXISTS GetStatusCliente;

DELIMITER //
CREATE FUNCTION GetStatusCliente(cod_cliente INT) RETURNS CHAR(11)
BEGIN
  DECLARE dias_desde_ultima_compra INT;
  DECLARE dias_desde_penultima_compra INT;
  DECLARE diferenca_dias_ultimas_2_compras INT;
  DECLARE qtd_total_compras INT;
  
  SET dias_desde_ultima_compra = GetDiasUltimaCompra(cod_cliente);
  SET dias_desde_penultima_compra = GetDiasPenultimaCompra(cod_cliente);  
  SET diferenca_dias_ultimas_2_compras = (dias_desde_penultima_compra - dias_desde_ultima_compra);
  SET qtd_total_compras = GetQtdTotalCompras(cod_cliente);

  RETURN (
    CASE
      WHEN (qtd_total_compras = 1 AND dias_desde_ultima_compra <= 30)
      THEN 'NOVO'
      
      WHEN (qtd_total_compras > 1 AND dias_desde_ultima_compra <= 30)
      THEN 'ATIVO'
      
      WHEN (dias_desde_ultima_compra > 30 AND dias_desde_ultima_compra <= 60)      
      THEN 'PRÉ-INATIVO'
      
      WHEN (dias_desde_ultima_compra > 60 AND dias_desde_ultima_compra <= 180)
      THEN 'INATIVO'
   
      WHEN qtd_total_compras > 1
      AND dias_desde_ultima_compra <= 30      
      AND diferenca_dias_ultimas_2_compras <= 180
      THEN 'REATIVADO'
      
      WHEN qtd_total_compras > 1
      AND dias_desde_ultima_compra <= 30
      AND diferenca_dias_ultimas_2_compras > 180
      THEN 'RECUPERADO'
      
      ELSE 'PERDIDO'
    END
  );
END //
DELIMITER ;