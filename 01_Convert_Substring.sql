
ALTER procedure [dbo].[spcr_operacao_corretora]
	@dt_carga smalldatetime  
as 
begin try

	declare @nm_arquivo  varchar(255);
	declare @qt_regi_ins int;
	declare @qt_regi_upd int;
	declare @cd_carga	 int;
	declare @dt_inicio	 smalldatetime;      
	declare @dt_termino	 smalldatetime;


	--Limpa tabela temporaria corretora
	delete from dbo.ttp_operacao_corretora;

   --Em 02/02/2023: Limpa tabela temporaria corretora benchmark

   delete from dbo.ttp_operacao_corretora_benchmark

   --Seta o nome do arquivo
	set @nm_arquivo = 'Operacao_Corretora' + upper(convert(varchar(8), @dt_carga,112)) + '.TXT';
	set @dt_inicio  = getdate();
	set @dt_termino = getdate();

   --Em 02/02/2023: Criar Variavel para capturar dia util anterior

   declare @dt_diaUtilAnterior smalldatetime;

   select @dt_diaUtilAnterior = (Select dbo.fncDia_Util_Anterior (@dt_carga, 1)) 

   --Obtem o codigo da carga
	exec @cd_carga = dbo.spgr_obter_cd_carga  10, @dt_carga, @nm_arquivo, 'spcr_operacao_corretora', @dt_inicio, @dt_termino, 0;

   --- Insere registros na tabela temporaria

   INSERT INTO [dbo].[ttp_operacao_corretora]
           ([cd_chave]      -- 1
           ,[dc_operacao]   -- 2 
           ,[dt_ordem]      -- 3
           ,[nm_cliente]    -- 4 
           ,[cd_bolsa]      -- 5 
           ,[dg_bolsa]      -- 6
           ,[tp_ordem]      -- 7
           ,[dt_validade]   -- 8 
           ,[dt_hr_ordem]   -- 9
           ,[dc_bolsa]      -- 10
           ,[dc_pesvinc]    -- 11
           ,[qt_espec]      -- 12
           ,[vl_preco_papel]-- 13 
           ,[dc_assessor]   -- 14 
           ,[dc_papel]      -- 15 
           ,[nr_negocio]    -- 16
           ,[qt_negocio]    -- 17
           ,[vl_negocio]    -- 18
           ,[cd_contraparte] -- 19
           ,[dg_negocio]     -- 20 
           ,[tp_neg]         -- 21
           ,[qt_executada]   -- 22 
           ,[dc_observ]      -- 23
           ,[dc_justif]      -- 24 
           ,[dc_emitente]    -- 25
           ,[dc_operador]    -- 26 
           ,[dc_cli_qualif]  -- 27
           ,[dt_pregao]      -- 28
           ,[dc_hr_neg]      -- 29
           ,[dc_obs]         -- 30
           ,[cd_mercado]     -- 31
           ,[dc_mercado]     -- 32
           ,[nm_empresa]     -- 33
           ,[dc_especie]     -- 34
           ,[pr_exerc]       -- 35
           ,[dt_venc]        -- 36 
           ,[cd_carga]       -- 37
           ,[vl_fator_cotacao] -- 38
           ,[id_daytrade])     -- 39
      Select DISTINCT CHAVE_ORDEM, -- 1        
             OPERACAO,    -- 2
             DT_ORDEM,    -- 3 
             CLIENTE,     -- 4
             CODBOLSA,    -- 5
             DIGBOLSA,    -- 6
             TIPO_ORDEM,  -- 7 
             case when cast(DT_VALID as date) > '2079-06-06' then DT_PREGAO else  DT_VALID end DT_VALID,    -- 8 --tratar limite do campo smalldatetime que e 2079-06-06
             DT_HR_ORDEM, -- 9
             BOLSA,       -- 10
             PESVINC,     -- 11
             QT_ESPEC,    -- 12
             PRECO_PAPEL, -- 13
             ASSESSOR,    -- 14
             PAPEL,       -- 15
             NR_NEGOCIO,  -- 16 
             QT_NEGOCIO,  -- 17 
             VL_NEGOCIO,  -- 18
             CONTRAPARTE, -- 19                                            
             DIG_NEGOCIO, -- 20        
             TIPO_NEG,    -- 21
             QT_EXECUTADA,-- 22       
             OBSERV,      -- 23      
             JUSTIF,      -- 24   
             EMITENTE,    -- 25
             OPERADOR,    -- 26
             CLI_QUALIF,  -- 27  
             DT_PREGAO,   -- 28  
             HR_NEG,      -- 29
             DS_OBS,      -- 30    
             COD_MERCADO, -- 31 
             MERCADO,     -- 32
             NOME_EMPRESA,-- 33 
             ESPECIE,     -- 34
             PR_EXERC,    -- 35
             DT_VENC,     -- 36
             @cd_carga,   -- 37 
             FAT_COT,     -- 38
             case when UPPER(id_daytrade) = 'Y' then 1 else 0 end as id_daytrade  -- 39                   
      from   OPENQUERY (SINACOR_LS,  
			' select * 
			FROM SIRCOIAPP.VW_ORD_NEGS' )
      where DT_PREGAO = @dt_carga

--- Em 2023-02-02: Insere registros na tabela temporaria benchmark 

   INSERT INTO [dbo].[ttp_operacao_corretora_benchmark]
           ([cd_chave]      -- 1
           ,[dc_operacao]   -- 2 
           ,[dt_ordem]      -- 3
           ,[nm_cliente]    -- 4 
           ,[cd_bolsa]      -- 5 
           ,[dg_bolsa]      -- 6
           ,[tp_ordem]      -- 7
           ,[dt_validade]   -- 8 
           ,[dt_hr_ordem]   -- 9
           ,[dc_bolsa]      -- 10
           ,[dc_pesvinc]    -- 11
           ,[qt_espec]      -- 12
           ,[vl_preco_papel]-- 13 
           ,[dc_assessor]   -- 14 
           ,[dc_papel]      -- 15 
           ,[nr_negocio]    -- 16
           ,[qt_negocio]    -- 17
           ,[vl_negocio]    -- 18
           ,[cd_contraparte] -- 19
           ,[dg_negocio]     -- 20 
           ,[tp_neg]         -- 21
           ,[qt_executada]   -- 22 
           ,[dc_observ]      -- 23
           ,[dc_justif]      -- 24 
           ,[dc_emitente]    -- 25
           ,[dc_operador]    -- 26 
           ,[dc_cli_qualif]  -- 27
           ,[dt_pregao]      -- 28
           ,[dc_hr_neg]      -- 29
           ,[dc_obs]         -- 30
           ,[cd_mercado]     -- 31
           ,[dc_mercado]     -- 32
           ,[nm_empresa]     -- 33
           ,[dc_especie]     -- 34
           ,[pr_exerc]       -- 35
           ,[dt_venc]        -- 36 
           ,[cd_carga]       -- 37
           ,[vl_fator_cotacao] -- 38
           ,[id_daytrade]      -- 39
           ,[vl_benchmark])    -- 40
      Select DISTINCT CHAVE_ORDEM, -- 1        
             OPERACAO,    -- 2
             DT_ORDEM,    -- 3 
             CLIENTE,     -- 4
             CODBOLSA,    -- 5
             DIGBOLSA,    -- 6
             TIPO_ORDEM,  -- 7 
             case when cast(DT_VALID as date) > '2079-06-06' then DT_PREGAO else  DT_VALID end DT_VALID,    -- 8 --tratar limite do campo smalldatetime que e 2079-06-06
             DT_HR_ORDEM, -- 9
             BOLSA,       -- 10
             PESVINC,     -- 11
             QT_ESPEC,    -- 12
             PRECO_PAPEL, -- 13
             ASSESSOR,    -- 14
             PAPEL,       -- 15
             NR_NEGOCIO,  -- 16 
             QT_NEGOCIO,  -- 17 
             VL_NEGOCIO,  -- 18
             CONTRAPARTE, -- 19                                            
             DIG_NEGOCIO, -- 20        
             TIPO_NEG,    -- 21
             QT_EXECUTADA,-- 22       
             OBSERV,      -- 23      
             JUSTIF,      -- 24   
             EMITENTE,    -- 25
             OPERADOR,    -- 26
             CLI_QUALIF,  -- 27  
             DT_PREGAO,   -- 28  
             HR_NEG,      -- 29
             DS_OBS,      -- 30    
             COD_MERCADO, -- 31 
             MERCADO,     -- 32
             NOME_EMPRESA,-- 33 
             ESPECIE,     -- 34
             PR_EXERC,    -- 35
             DT_VENC,     -- 36
             @cd_carga,   -- 37 
             FAT_COT,     -- 38
             case when UPPER(id_daytrade) = 'Y' then 1 else 0 end as id_daytrade,  -- 39,
             vl_benchmark -- 40                  
      from   OPENQUERY (SINACOR_LS,  
			' select * 
			FROM SIRCOIAPP.VW_ORD_NEGS' )
      where DT_PREGAO = @dt_diaUtilAnterior
 

-- Limpa tbl_operacao_corretora para o reprocessamento
delete tbl_operacao_corretora where dt_pregao = @dt_carga

-- Limpa tbl_operacao_corretora_ para o reprocessamento
delete tbl_operacao_corretora_benchmark where dt_pregao = @dt_diaUtilAnterior

--- Insert tbl_operacao_corretora

insert into tbl_operacao_corretora
      (cd_chave,    --01
       cd_cliente,  --02 
       dc_operacao, --03
       dt_ordem,    --04  
       cd_bolsa,    --05 
       dg_bolsa,    --06
       tp_ordem,    --07 
       dt_validade, --08
       dt_hr_ordem, --09 
       dc_bolsa,    --10 
       dc_pesvinc,  --11
       qt_espec,    --12
       vl_preco_papel, --13 
       dc_assessor,    --14 
       dc_papel,       --15 
       nr_negocio,     --16 
       qt_negocio,     --17
       vl_negocio,     --18
       cd_contraparte, --19
       dg_negocio,     --20 
       tp_neg,         --21
       qt_executada,   --22 
       dc_observ,      --23 
       dc_justif,      --24 
       dc_emitente,    --25
       dc_operador,    --26  
       dc_cli_qualif,  --27 
       dt_pregao,      --28 
       dc_hr_neg,      --29
       dc_obs,         --30 
       dc_mercado,     --31 
       nm_empresa,     --32 
       dc_especie,     --33
       pr_exerc,       --34 
       dt_venc,        --35
       cd_carga,       --36  
       cd_mercado,     --37 
       vl_fator_cotacao, --38 
       id_daytrade) --39
      select distinct
      substring(ttp.cd_chave,1,21) as cd_chave,                            -- 01. cd_chave,    --01       
      cl.cd_cliente,                                                       -- 02. cd_cliente,  --02    
      ttp.dc_operacao,                                                     -- 03. dc_operacao, --03
      convert(smalldatetime,substring(ttp.dt_ordem,1,4)
      + substring(ttp.dt_ordem,6,2) 
      + substring(ttp.dt_ordem,9,2))as dt_ordem,                           -- 04.dt_ordem,    --04
      ttp.cd_bolsa,                                                        -- 05.cd_bolsa,    --05 
      ttp.dg_bolsa,                                                        -- 06.dg_bolsa,    --06
      ttp.tp_ordem,                                                        -- 07.tp_ordem,    --07 
      case when convert(int,right(ttp.dt_validade,1))>= 2079               
      then CONVERT(smalldatetime,'2079-06-06') else 
      convert(smalldatetime,substring(ttp.dt_validade,1,4) 
      + substring(ttp.dt_validade,6,2) 
      + substring(ttp.dt_validade,9,2)) end as dt_validade,                -- 08.dt_validade, --08
      convert(smalldatetime,substring(ttp.dt_hr_ordem,1,4) 
      + substring(ttp.dt_hr_ordem,6,2) + substring(ttp.dt_hr_ordem,9,2) 
      + ' ' + substring(ttp.dt_hr_ordem,12,8)) as dt_hr_ordem,             -- 09.dt_hr_ordem, --09 
      ttp.dc_bolsa,                                                        -- 10.dc_bolsa,    --10 
      ttp.dc_pesvinc,                                                      -- 11.dc_pesvinc,  --11
      ttp.qt_espec,                                                        -- 12.qt_espec,    --12
      ttp.vl_preco_papel,                                                  -- 13.vl_preco_papel, --13 
      ttp.dc_assessor,                                                     -- 14.dc_assessor,    --14 
      ttp.dc_papel,                                                        -- 15.dc_papel,       --15 
      ttp.nr_negocio,                                                      -- 16.nr_negocio,     --16 
      ttp.qt_negocio,                                                      -- 17.qt_negocio,     --17 
      ttp.vl_negocio,                                                      -- 18.vl_negocio,     --18
      ttp.cd_contraparte,                                                  -- 19.cd_contraparte, --19
      ttp.dg_negocio,                                                      -- 20.dg_negocio,     --20 
      ttp.tp_neg,                                                          -- 21.tp_neg,         --21
      ttp.qt_executada,                                                    -- 22.qt_executada,   --22 
      ttp.dc_observ,                                                       -- 23.dc_observ,      --23
      ttp.dc_justif,                                                       -- 24.dc_justif,      --24 
      ttp.dc_emitente,                                                     -- 25.dc_emitente,    --25
      ttp.dc_operador,                                                     -- 26.dc_operador,    --26  
      ttp.dc_cli_qualif,                                                   -- 27.dc_cli_qualif,  --27 
      convert(smalldatetime,substring(ttp.dt_pregao,1,4) 
      + substring(ttp.dt_pregao,6,2) 
      + substring(ttp.dt_pregao,9,2)) as dt_pregao,                        -- 28.dt_pregao,      --28 
      ttp.dc_hr_neg,                                                       -- 29.dc_hr_neg,      --29
      ttp.dc_obs,                                                          -- 30.dc_obs,         --30  
      ttp.dc_mercado,                                                      -- 31.dc_mercado,     --31 
      ttp.nm_empresa,                                                      -- 32.nm_empresa,     --32 
      ttp.dc_especie,                                                      -- 33.dc_especie,     --33
      ttp.pr_exerc,                                                        -- 34.pr_exerc,       --34  
      case when convert(int,right(ttp.dt_venc,1))>= 2079 
      then CONVERT(smalldatetime,'2079-06-06') else 
      convert(smalldatetime,substring(ttp.dt_venc,1,4) 
      + substring(ttp.dt_venc,6,2) 
      + substring(ttp.dt_venc,9,2)) end as dt_venc,                       -- 35.dt_venc,        --35
      ttp.cd_carga,                                                       -- 36.cd_carga     --36  
      ttp.cd_mercado,                                                     -- 37.cd_mercado,     --37    
      ttp.vl_fator_cotacao,                                               -- 38.vl_fator_cotacao, --38                                                            
      ttp.id_daytrade                                                     -- 39.id_daytrade) --39                                                            
      from dbo.ttp_operacao_corretora ttp
      join dbo.tcl_cliente_detalhe_bolsa cdb
      on cdb.cd_cliente_bolsa = ttp.cd_bolsa
      join dbo.tcl_cliente cl
      on cl.cd_cliente = cdb.cd_cliente
      left join dbo.tbl_operacao_corretora op
      on ttp.cd_chave = op.cd_chave 
      and ttp.nr_negocio = op.nr_negocio
      and convert(smalldatetime,substring(ttp.dt_pregao,1,4) 
      + substring(ttp.dt_pregao,6,2) 
      + substring(ttp.dt_pregao,9,2)) = op.dt_pregao
      where ttp.nr_negocio is not null and (op.cd_chave is null 
      or op.nr_negocio is null
      or op.dt_pregao is null)

--- Insert tbl_operacao_corretora_beechmark

insert into tbl_operacao_corretora_benchmark
      (cd_chave,    --01
       cd_cliente,  --02 
       dc_operacao, --03
       dt_ordem,    --04  
       cd_bolsa,    --05 
       dg_bolsa,    --06
       tp_ordem,    --07 
       dt_validade, --08
       dt_hr_ordem, --09 
       dc_bolsa,    --10 
       dc_pesvinc,  --11
       qt_espec,    --12
       vl_preco_papel, --13 
       dc_assessor,    --14 
       dc_papel,       --15 
       nr_negocio,     --16 
       qt_negocio,     --17
       vl_negocio,     --18
       cd_contraparte, --19
       dg_negocio,     --20 
       tp_neg,         --21
       qt_executada,   --22 
       dc_observ,      --23 
       dc_justif,      --24 
       dc_emitente,    --25
       dc_operador,    --26  
       dc_cli_qualif,  --27 
       dt_pregao,      --28 
       dc_hr_neg,      --29
       dc_obs,         --30 
       dc_mercado,     --31 
       nm_empresa,     --32 
       dc_especie,     --33
       pr_exerc,       --34 
       dt_venc,        --35
       cd_carga,       --36  
       cd_mercado,     --37 
       vl_fator_cotacao, --38 
       id_daytrade,
       vl_benchmark) --39
      select distinct
      substring(ttp.cd_chave,1,21) as cd_chave,                            -- 01. cd_chave,    --01       
      cl.cd_cliente,                                                       -- 02. cd_cliente,  --02    
      ttp.dc_operacao,                                                     -- 03. dc_operacao, --03
      convert(smalldatetime,substring(ttp.dt_ordem,1,4)
      + substring(ttp.dt_ordem,6,2) 
      + substring(ttp.dt_ordem,9,2))as dt_ordem,                           -- 04.dt_ordem,    --04
      ttp.cd_bolsa,                                                        -- 05.cd_bolsa,    --05 
      ttp.dg_bolsa,                                                        -- 06.dg_bolsa,    --06
      ttp.tp_ordem,                                                        -- 07.tp_ordem,    --07 
      case when convert(int,right(ttp.dt_validade,1))>= 2079               
      then CONVERT(smalldatetime,'2079-06-06') else 
      convert(smalldatetime,substring(ttp.dt_validade,1,4) 
      + substring(ttp.dt_validade,6,2) 
      + substring(ttp.dt_validade,9,2)) end as dt_validade,                -- 08.dt_validade, --08
      convert(smalldatetime,substring(ttp.dt_hr_ordem,1,4) 
      + substring(ttp.dt_hr_ordem,6,2) + substring(ttp.dt_hr_ordem,9,2) 
      + ' ' + substring(ttp.dt_hr_ordem,12,8)) as dt_hr_ordem,             -- 09.dt_hr_ordem, --09 
      ttp.dc_bolsa,                                                        -- 10.dc_bolsa,    --10 
      ttp.dc_pesvinc,                                                      -- 11.dc_pesvinc,  --11
      ttp.qt_espec,                                                        -- 12.qt_espec,    --12
      ttp.vl_preco_papel,                                                  -- 13.vl_preco_papel, --13 
      ttp.dc_assessor,                                                     -- 14.dc_assessor,    --14 
      ttp.dc_papel,                                                        -- 15.dc_papel,       --15 
      ttp.nr_negocio,                                                      -- 16.nr_negocio,     --16 
      ttp.qt_negocio,                                                      -- 17.qt_negocio,     --17 
      ttp.vl_negocio,                                                      -- 18.vl_negocio,     --18
      ttp.cd_contraparte,                                                  -- 19.cd_contraparte, --19
      ttp.dg_negocio,                                                      -- 20.dg_negocio,     --20 
      ttp.tp_neg,                                                          -- 21.tp_neg,         --21
      ttp.qt_executada,                                                    -- 22.qt_executada,   --22 
      ttp.dc_observ,                                                       -- 23.dc_observ,      --23
      ttp.dc_justif,                                                       -- 24.dc_justif,      --24 
      ttp.dc_emitente,                                                     -- 25.dc_emitente,    --25
      ttp.dc_operador,                                                     -- 26.dc_operador,    --26  
      ttp.dc_cli_qualif,                                                   -- 27.dc_cli_qualif,  --27 
      convert(smalldatetime,substring(ttp.dt_pregao,1,4) 
      + substring(ttp.dt_pregao,6,2) 
      + substring(ttp.dt_pregao,9,2)) as dt_pregao,                        -- 28.dt_pregao,      --28 
      ttp.dc_hr_neg,                                                       -- 29.dc_hr_neg,      --29
      ttp.dc_obs,                                                          -- 30.dc_obs,         --30  
      ttp.dc_mercado,                                                      -- 31.dc_mercado,     --31 
      ttp.nm_empresa,                                                      -- 32.nm_empresa,     --32 
      ttp.dc_especie,                                                      -- 33.dc_especie,     --33
      ttp.pr_exerc,                                                        -- 34.pr_exerc,       --34  
      case when convert(int,right(ttp.dt_venc,1))>= 2079 
      then CONVERT(smalldatetime,'2079-06-06') else 
      convert(smalldatetime,substring(ttp.dt_venc,1,4) 
      + substring(ttp.dt_venc,6,2) 
      + substring(ttp.dt_venc,9,2)) end as dt_venc,                       -- 35.dt_venc,        --35
      ttp.cd_carga,                                                       -- 36.cd_carga     --36  
      ttp.cd_mercado,                                                     -- 37.cd_mercado,     --37    
      ttp.vl_fator_cotacao,                                               -- 38.vl_fator_cotacao, --38                                                            
      ttp.id_daytrade,                                                    -- 39.id_daytrade) --39                                                            
      ttp.vl_benchmark
      from dbo.ttp_operacao_corretora_benchmark ttp
      join dbo.tcl_cliente_detalhe_bolsa cdb
      on cdb.cd_cliente_bolsa = ttp.cd_bolsa
      join dbo.tcl_cliente cl
      on cl.cd_cliente = cdb.cd_cliente
      left join dbo.tbl_operacao_corretora_benchmark op
      on ttp.cd_chave = op.cd_chave 
      and ttp.nr_negocio = op.nr_negocio
      and convert(smalldatetime,substring(ttp.dt_pregao,1,4) 
      + substring(ttp.dt_pregao,6,2) 
      + substring(ttp.dt_pregao,9,2)) = op.dt_pregao
      where ttp.nr_negocio is not null and (op.cd_chave is null 
      or op.nr_negocio is null
      or op.dt_pregao is null)

     -- Recupera a qtde de registros inserido	
	  set @qt_regi_ins = @@rowcount;

       --Recupera a qtde de registros atualizado	
	   set @qt_regi_upd = 0;

      --Seta fim carga
	set @dt_termino = getdate();
   
   --Finaliza controle de carga
	exec dbo.spgr_grava_log_carga 10, @cd_carga, 'Carga Operacao Corretora', @dt_termino, @dt_carga, @qt_regi_ins, @qt_regi_upd;

end try
begin catch

	exec dbo.spgr_tratar_erro;

end catch
GO


