USE db_uc_kami;
CREATE INDEX idx_nota_fiscal ON vd_nota_fiscal (cod_cliente, situacao, dt_emissao);