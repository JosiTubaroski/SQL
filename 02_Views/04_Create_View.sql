
 if exists(select * from sys.all_objects where name = 'VW_TPINVESTIDOR')
 Drop view VW_TPINVESTIDOR
 GO

  CREATE VIEW [dbo].[VW_TPINVESTIDOR] ("TIPO_INVEST", "DES_INVEST") AS 
  SELECT cd_tipo_invest   AS TIPO_INVEST, 
       dc_tipo_invest   AS DES_INVEST
FROM dbo.tb_vw_corretora_tipo_investidor;




