

--- 01. Criação da Tabela para alimentar a view de simulação de 
--- Movimentacoes Conta Corrente - Matera

IF (EXISTS (select * from INFORMATION_SCHEMA.TABLES 
              where TABLE_SCHEMA = 'dbo'
              and TABLE_NAME = 'vw_tb_movimentacao_cc_matera'))

Begin

 drop table dbo.vw_tb_movimentacao_cc_matera

end

IF (Not EXISTS (select * from INFORMATION_SCHEMA.TABLES 
              where TABLE_SCHEMA = 'dbo'
              and TABLE_NAME = 'vw_tb_movimentacao_cc_matera'))

Begin

SET ANSI_NULLS ON

SET QUOTED_IDENTIFIER ON

CREATE TABLE [dbo].[vw_tb_movimentacao_cc_matera](
	[Cod_Movimentacao]  numeric NOT NULL,             -- 01 - Cod_Movimentacao
	[Especie] numeric NOT NULL,                       -- 02 - Especie
	[Cod_Agencia] numeric NOT NULL,                   -- 03 - Cod_Agencia
   [Nome_Agencia] varchar (200) NOT NULL,            -- 04 - Nome_Agencia
   [Num_Conta] numeric NOT NULL,                     -- 05 - Numero da Conta
   [Titular] numeric  NOT NULL,                      -- 06 - Indica se o Cliente é titular da Conta
   [Dt_Abertura] smalldatetime NULL,                 -- 07 - Data Abertura
   [Cod_Gerente] numeric NULL,                       -- 08 - Código do gerente da Conta
   [Dt_Movimentacao] smalldatetime NOT NULL,         -- 09 - Data da Movimentação
   [Vlr_Movimentacao] decimal (12,0) NOT NULL,       -- 10 - Valor da Movimentação
   [Natureza] varchar (1) NOT NULL,                  -- 11 - Natureza
   [Cod_Historico] numeric (4,0) NOT NULL,           -- 12 - Código do tipo de movimentação  
   [Desc_Historico] varchar (100) NOT NULL,          -- 13 - Descrição da movimentação
   [Cpf_Cnpj_Titular] numeric (14) NOT NULL          -- 14 - CNPJ_CPF Titular
   )          

End