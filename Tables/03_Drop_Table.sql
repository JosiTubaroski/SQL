

--- 01. Dropar Tabela caso exista na base
--- Movimentacoes Conta Corrente - Matera

IF (EXISTS (select * from INFORMATION_SCHEMA.TABLES 
              where TABLE_SCHEMA = 'dbo'
              and TABLE_NAME = 'tb_movimentacao_cc_matera'))

Begin

 drop table dbo.vw_tb_movimentacao_cc_matera

end
