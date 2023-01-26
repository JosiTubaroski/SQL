

--- 01. Criação da Tabela Temporaria - dbo.ttp_riscos_baixados.

IF (NOT EXISTS (select * from INFORMATION_SCHEMA.TABLES 
              where TABLE_SCHEMA = 'dbo'
              and TABLE_NAME = 'ttp_riscos_baixados'))

Begin

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TABLE [dbo].[ttp_riscos_baixados](
   [cpf_cnpj] [varchar](20) not NULL,
   [tp_pessoa] [char](1) not NULL,
   [dt_risco] [varchar](50) not NULL,
   [vl_risco] [int] NULL,
   [dc_risco] [varchar](50) NULL,
   [id_descon_regra][int] Null, 
   [dt_cadastro] [smalldatetime] NULL) 

ALTER TABLE [dbo].[ttp_riscos_baixados] ADD  CONSTRAINT [ttp_riscos_baixados_dt_cadastro]  
DEFAULT (getdate()) FOR [dt_cadastro]

ALTER TABLE [dbo].[ttp_riscos_baixados] ADD  CONSTRAINT [ttp_riscos_baixados_id_descon_regra]  
DEFAULT (1) FOR [id_descon_regra]

End

Go

--- 02. Criação da Tabela Definitiva - dbo.tgr_riscos_baixados

IF (NOT EXISTS (select * from INFORMATION_SCHEMA.TABLES 
              where TABLE_SCHEMA = 'dbo'
              and TABLE_NAME = 'tgr_riscos_baixados'))


Begin

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TABLE [dbo].[tgr_riscos_baixados](
   [cpf_cnpj] [varchar](20) not NULL,
   [tp_pessoa] [char](1) not NULL,
   [dt_risco] [varchar](50) not NULL,
   [vl_risco] [int] NULL,
   [dc_risco] [varchar](50) NULL,
   [id_descon_regra][int] Null, 
   [dt_cadastro] [smalldatetime] NULL) 


ALTER TABLE [dbo].[tgr_riscos_baixados] ADD  CONSTRAINT [tgr_riscos_baixados_dt_cadastro]  
DEFAULT (getdate()) FOR [dt_cadastro]

ALTER TABLE [dbo].[tgr_riscos_baixados] ADD  CONSTRAINT [tgr_riscos_baixados_id_descon_regra]  
DEFAULT (1) FOR [id_descon_regra]

End

Go

IF (NOT EXISTS (select * from INFORMATION_SCHEMA.TABLES 
              where TABLE_SCHEMA = 'dbo'
              and TABLE_NAME = 'tgr_riscos_cpfs_nao_loc'))

Begin

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TABLE [dbo].[tgr_riscos_cpfs_nao_loc](
   [cpf_cnpj] [varchar](20) not NULL,
   [tp_pessoa] [char](1) not NULL,
   [dt_risco] [varchar](50) not NULL,
   [vl_risco] [int] NULL,
   [dc_risco] [varchar](50) NULL,
   [id_descon_regra][int] Null, 
   [dt_cadastro] [smalldatetime] NULL) 


ALTER TABLE [dbo].[tgr_riscos_cpfs_nao_loc] ADD  CONSTRAINT [tgr_riscos_cpfs_nao_loc_dt_cadastro]  
DEFAULT (getdate()) FOR [dt_cadastro]

ALTER TABLE [dbo].[tgr_riscos_cpfs_nao_loc] ADD  CONSTRAINT [tgr_riscos_cpfs_nao_loc_id_descon_regra]  
DEFAULT (1) FOR [id_descon_regra]

End

IF (NOT EXISTS (select * from INFORMATION_SCHEMA.TABLES 
              where TABLE_SCHEMA = 'dbo'
              and TABLE_NAME = 'ttp_clientes_item_risco_manual'))

Begin

SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON

CREATE TABLE [dbo].[ttp_clientes_item_risco_manual](
   [cd_cliente] int not null,
   [cpf_cnpj] [varchar](20) not NULL,
   [dt_cadastro] [smalldatetime] NULL)

ALTER TABLE [dbo].[ttp_clientes_item_risco_manual] ADD  CONSTRAINT [ttp_clientes_item_risco_manual_dt_cadastro]  
DEFAULT (getdate()) FOR [dt_cadastro]

End