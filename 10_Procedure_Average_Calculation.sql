
--- Criação da Procedure que verifica 9 (D) - Compra/Venda entre mesmas contrapartes (Master e Dependentes)
--- 'spcr_mesma_cp_master_dependente'

if exists(select name from sys.procedures where name = 'spcr_mesma_cp_master_dependente') 
drop procedure spcr_mesma_cp_master_dependente;
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create procedure [dbo].[spcr_mesma_cp_master_dependente]
@cd_cliente dt_cd_cliente,  
@cd_enquadramento smallint,  
@cd_produto smallint,  
@dt_inicio smalldatetime,  
@dt_final smalldatetime,  
@vl_total_mov float,  
@id_automatica bit,  
@id_resumir bit,  
@cd_usuario smallint = null  
as  

begin try

 set dateformat mdy;  

   --Variaveis
	declare @vl_parametro1      float;
	declare @vl_isencao         int;
	declare @cd_unico           int;
	declare @cd_status_suspeita int;
   declare @cd_alerta          int;
   declare @cd_cliente_master  int;   
   declare @dt_anterior        datetime;
   declare @qtd_dias           int = 3;

   if (@cd_produto = 9)  
      begin  
       if (@id_resumir = 1)  
          begin  
  
  delete dbo.tgr_alertas  
  where cd_cliente     = @cd_cliente  
  and dt_movimentacao  = @dt_inicio  
  and cd_produto       = @cd_produto  
  and cd_enquadramento = @cd_enquadramento; 

  end
   
  exec @vl_isencao = dbo.spgr_verificar_isencao @cd_cliente, @cd_produto, @cd_enquadramento, @dt_final;  

  exec dbo.spgr_achar_parametro @cd_produto, @cd_cliente, @cd_enquadramento, 
       @cd_usuario, @id_automatica, @vl_parametro1 output;

--- 01. Verificando todas as maters do cliente

    select cd_master
    into #tabl_Master
    from dbo.tcl_cliente_detalhe_bolsa a  
    where a.cd_cliente = @cd_cliente
    and cd_master is not null

--- 03. Realizar a verificação de compras realizadas pelo Cliente Master no periodo analisado

      if object_id('tempdb..#ttp_compra_master') is not null 	
		drop table #ttp_compra_master;

      create table #ttp_compra_master
	          (cd_cliente		 int			   null,
              cd_bolsa         int			   null,
              cd_master        int			   null,
	           nr_negocio		 numeric(12)   null, 
	           dc_operacao		 char(1)	      null,	--collate SQL_Latin1_General_CP1_CI_AS null,
	           dc_ativo		    varchar(20)	null, --collate SQL_Latin1_General_CP1_CI_AS null,
	           qt_negocio		 numeric(15)	null,
	           vl_negocio		 money		   null,
              dt_ordem         datetime      null,
              nr_movimentacao  bigint        null);

select @dt_anterior = (Select dbo.fncDia_Util_Anterior (@dt_inicio, @vl_parametro1)) 

   insert into #ttp_compra_master(cd_cliente, cd_bolsa, cd_master, nr_negocio, dc_operacao, dc_ativo, qt_negocio,
                                  vl_negocio, dt_ordem, nr_movimentacao)   
   select ope.cd_cliente, ope.cd_bolsa, @cd_cliente_master,ope.nr_negocio, ope.dc_operacao, ope.dc_papel, 
          ope.qt_negocio, ope.vl_negocio, ope.dt_ordem, ope.cd_movimentacao
   from dbo.tbl_operacao_corretora ope
   where cd_bolsa in (select cd_master from #tabl_Master) 
         and dc_operacao = 'C'
         and ope.dt_ordem between @dt_anterior and @dt_inicio  

--- 04. Realizar a verificação de vendas realizadas pelos Dependentes Master no periodo analisado

     if object_id('tempdb..#ttp_venda_dependentes') is not null 	
	  drop table #ttp_venda_dependentes; 

     create table #ttp_venda_dependentes
	          (cd_cliente		 int			   null,
              cd_bolsa         int			   null,
              cd_master        int			   null,
	           nr_negocio		 numeric(12)   null, 
	           dc_operacao		 char(1)	      null,	--collate SQL_Latin1_General_CP1_CI_AS null,
	           dc_ativo		    varchar(20)	null, --collate SQL_Latin1_General_CP1_CI_AS null,
	           qt_negocio		 numeric(15)	null,
	           vl_negocio		 money		   null,
              dt_ordem         datetime      null,
              nr_movimentacao  bigint        null);

   insert into #ttp_venda_dependentes (cd_cliente, cd_bolsa, cd_master, nr_negocio, dc_operacao, dc_ativo, qt_negocio,
                                  vl_negocio, dt_ordem, nr_movimentacao)   
   select ope.cd_cliente, ope.cd_bolsa, @cd_cliente_master,ope.nr_negocio, ope.dc_operacao, ope.dc_papel, 
          ope.qt_negocio, ope.vl_negocio, ope.dt_ordem, ope.cd_movimentacao
     from dbo.tbl_operacao_corretora ope
     where cd_cliente = @cd_cliente 
           and dc_operacao = 'V'
           and ope.dt_ordem between @dt_anterior and @dt_inicio

--- 05. Juntando as operações de compra e venda em que seja mesmo ativo, mesma quantidade e valor negocios diferentes

     if object_id('tempdb..#ttp_alerta_parte1') is not null 	
	  drop table #ttp_alerta_parte1; 

     create table #ttp_alerta_parte1
	          (cd_cliente_compra	     int			    null,
              cd_bolsa_compra         int			    null,
              cd_master_compra        int			    null,
	           nr_negocio_compra	     numeric(12)   null, 
	           dc_operacao_compra	     char(1)	    null, --collate SQL_Latin1_General_CP1_CI_AS null,
	           dc_ativo_compra		     varchar(20)	 null, --collate SQL_Latin1_General_CP1_CI_AS null,
	           qt_negocio_compra	     numeric(15)	 null,
	           vl_negocio_compra	     money		    null,
              dt_ordem_compra         datetime      null,
              nr_movimentacao_compra  bigint        null,
              cd_cliente_venda	     int			    null,
              cd_bolsa_venda          int			    null,
              cd_master_venda         int			    null,
              nr_negocio_venda	     numeric(12)   null,
              dc_operacao_venda	     char(1)	    null,
              dc_ativo_venda		     varchar(20)	 null, --collate SQL_Latin1_General_CP1_CI_AS null,
	           qt_negocio_venda	     numeric(15)	 null,
	           vl_negocio_venda	     money		    null,
              dt_ordem_venda          datetime      null,
              nr_movimentacao_venda   bigint        null);

      insert into #ttp_alerta_parte1 (cd_cliente_compra,cd_bolsa_compra,cd_master_compra,nr_negocio_compra, 
	           dc_operacao_compra, dc_ativo_compra, qt_negocio_compra, vl_negocio_compra, dt_ordem_compra,
              nr_movimentacao_compra, cd_cliente_venda, cd_bolsa_venda, cd_master_venda,nr_negocio_venda,
              dc_operacao_venda, dc_ativo_venda, qt_negocio_venda, vl_negocio_venda,dt_ordem_venda,
              nr_movimentacao_venda)

     select cm.cd_cliente,cm.cd_bolsa,cm.cd_master,cm.nr_negocio, 
	           cm.dc_operacao, cm.dc_ativo, cm.qt_negocio, cm.vl_negocio, cm.dt_ordem,
              cm.nr_movimentacao, vd.cd_cliente, vd.cd_bolsa, vd.cd_master, vd.nr_negocio,
              vd.dc_operacao, vd.dc_ativo, vd.qt_negocio, vd.vl_negocio, vd.dt_ordem,
              vd.nr_movimentacao  from #ttp_compra_master cm
     join #ttp_venda_dependentes vd on cm.dc_ativo = vd.dc_ativo
     and cm.qt_negocio =  vd.qt_negocio
     and cm.vl_negocio <> vd.vl_negocio

     if exists (select top 1 * from #ttp_alerta_parte1)

     Begin

--- 06. Caso a condição do alerta parte 1 seja verdadeira, verificar se teve outra incidencia no periodo de 30 dias

         declare @30dias int = 30
         declare @dt_anterior_mes datetime

         select @dt_anterior_mes = (Select dbo.fncDia_Util_Anterior (@dt_inicio, @30dias)) 

--- 07. Criar a tabela temporaria para verificar as compras realizadas pela Master nos ultimos 30 dias

        if object_id('tempdb..#ttp_compra_master_30dias') is not null 	
		  drop table #ttp_compra_master_30dias;

        create table #ttp_compra_master_30dias
	          (cd_cliente		 int			   null,
              cd_bolsa         int			   null,
              cd_master        int			   null,
	           nr_negocio		 numeric(12)   null, 
	           dc_operacao		 char(1)	      null,	--collate SQL_Latin1_General_CP1_CI_AS null,
	           dc_ativo		    varchar(20)	null, --collate SQL_Latin1_General_CP1_CI_AS null,
	           qt_negocio		 numeric(15)	null,
	           vl_negocio		 money		   null,
              dt_ordem         datetime      null,
              nr_movimentacao  bigint        null);

       insert into #ttp_compra_master_30dias(cd_cliente, cd_bolsa, cd_master, nr_negocio, dc_operacao, dc_ativo, 
                                         qt_negocio, vl_negocio, dt_ordem, nr_movimentacao)   
       select ope.cd_cliente, ope.cd_bolsa, @cd_cliente_master,ope.nr_negocio, ope.dc_operacao, ope.dc_papel, 
              ope.qt_negocio, ope.vl_negocio, ope.dt_ordem, ope.cd_movimentacao
         from dbo.tbl_operacao_corretora ope
          where cd_bolsa in (select cd_bolsa from #ttp_compra_master) 
                and dc_operacao = 'C'
                and ope.dt_ordem between @dt_anterior_mes and @dt_inicio

--- 08. Criar a tabela temporaria para verificar as vendas realizadas pelas Dependentes nos ultimos 30 dias

     if object_id('tempdb..#ttp_venda_dependentes_30dias') is not null 	
	  drop table #ttp_venda_dependentes_30dias; 

     create table #ttp_venda_dependentes_30dias
	          (cd_cliente		 int			   null,
              cd_bolsa         int			   null,
              cd_master        int			   null,
	           nr_negocio		 numeric(12)   null, 
	           dc_operacao		 char(1)	      null,	--collate SQL_Latin1_General_CP1_CI_AS null,
	           dc_ativo		    varchar(20)	null, --collate SQL_Latin1_General_CP1_CI_AS null,
	           qt_negocio		 numeric(15)	null,
	           vl_negocio		 money		   null,
              dt_ordem         datetime      null,
              nr_movimentacao  bigint        null);

       insert into #ttp_venda_dependentes_30dias (cd_cliente, cd_bolsa, cd_master, nr_negocio, dc_operacao, dc_ativo, qt_negocio,
                                                  vl_negocio, dt_ordem, nr_movimentacao)   
       select ope.cd_cliente, ope.cd_bolsa, @cd_cliente_master,ope.nr_negocio, ope.dc_operacao, ope.dc_papel, 
              ope.qt_negocio, ope.vl_negocio, ope.dt_ordem, ope.cd_movimentacao
         from dbo.tbl_operacao_corretora ope
         where cd_cliente = @cd_cliente
               and dc_operacao = 'V'
               and ope.dt_ordem between @dt_anterior_mes and @dt_inicio 

 ---- 08. Verificar a segunda condição do alerta

      if object_id('tempdb..#ttp_alerta_parte2') is not null 	
	      drop table #ttp_alerta_parte2; 

       create table #ttp_alerta_parte2
	                 (cd_cliente_compra	      int			    null,
                     cd_bolsa_compra         int			    null,
                     cd_master_compra        int			    null,
	                  nr_negocio_compra	      numeric(12)     null, 
	                  dc_operacao_compra	   char(1)	       null, --collate SQL_Latin1_General_CP1_CI_AS null,
	                  dc_ativo_compra		   varchar(20)	    null, --collate SQL_Latin1_General_CP1_CI_AS null,
	                  qt_negocio_compra	      numeric(15)	    null,
	                  vl_negocio_compra	      money		       null,
                     dt_ordem_compra         datetime        null,
                     nr_movimentacao_compra  bigint          null,
                     cd_cliente_venda	      int			    null,
                     cd_bolsa_venda          int			    null,
                     cd_master_venda         int			    null,
                     nr_negocio_venda	      numeric(12)     null,
                     dc_operacao_venda	      char(1)	       null,
                     dc_ativo_venda		      varchar(20)	    null, --collate SQL_Latin1_General_CP1_CI_AS null,
	                  qt_negocio_venda	      numeric(15)	    null,
	                  vl_negocio_venda	      money		       null,
                     dt_ordem_venda          datetime        null,
                     nr_movimentacao_venda   bigint          null);
          
        insert into #ttp_alerta_parte2 (cd_cliente_compra,cd_bolsa_compra,cd_master_compra,nr_negocio_compra, 
	           dc_operacao_compra, dc_ativo_compra, qt_negocio_compra, vl_negocio_compra, dt_ordem_compra,
              nr_movimentacao_compra, cd_cliente_venda, cd_bolsa_venda, cd_master_venda,nr_negocio_venda,
              dc_operacao_venda, dc_ativo_venda, qt_negocio_venda, vl_negocio_venda,dt_ordem_venda,
              nr_movimentacao_venda)

     select cm.cd_cliente,cm.cd_bolsa,cm.cd_master,cm.nr_negocio, 
	           cm.dc_operacao, cm.dc_ativo, cm.qt_negocio, cm.vl_negocio, cm.dt_ordem,
              cm.nr_movimentacao, vd.cd_cliente, vd.cd_bolsa, vd.cd_master, vd.nr_negocio,
              vd.dc_operacao, vd.dc_ativo, vd.qt_negocio, vd.vl_negocio, vd.dt_ordem,
              vd.nr_movimentacao  from #ttp_compra_master_30dias cm
     join #ttp_venda_dependentes_30dias vd on cm.dc_ativo = vd.dc_ativo
     and cm.qt_negocio =  vd.qt_negocio
     and cm.vl_negocio <> vd.vl_negocio

---- 09. Verifica se entra na condição da geração do alerta 

        exec @cd_unico = dbo.spgr_inserir_relac_produto_unico @cd_produto,
        @cd_enquadramento, @vl_parametro1;

        select	@cd_status_suspeita = cd_status_suspeita  from	dbo.tgr_status_suspeita  
		  where	tp_status_suspeita = 0;

     if exists (select top 1 * from #ttp_alerta_parte2)

        Begin

        if not exists(select top 1 *  
                       from dbo.tgr_alertas al with (nolock)
                       join #ttp_alerta_parte2 alp2 on al.dc_alerta = alp2.dc_ativo_compra
                       where al.cd_cliente     = @cd_cliente  
                       and al.dt_movimentacao  = @dt_inicio  
                       and al.cd_produto       = @cd_produto  
                       and al.cd_enquadramento = @cd_enquadramento
                       and al.nm_alerta        = alp2.cd_cliente_compra -- 01. cd_cliente_compra   -- 01. nm_alerta
                       and al.nm_alerta1       = alp2.cd_bolsa_compra   -- 02. nm_alerta1          -- 02. cd_bolsa_compra
                       )
 
 	         
        Begin
         
--- 10. Inserir Alerta caso não exista na tabela de alertas

         insert into dbo.tgr_alertas  
         (cd_cliente,       -- 01. cd_cliente          -- 01. @cd_cliente
          cd_produto,       -- 02. cd_produto          -- 02. @cd_produto      
          cd_enquadramento, -- 03. cd_enquadramento    -- 03. @cd_enquadramento
          id_selecionado,   -- 04. id_selecionado      -- 04. 0   
          id_automatica,    -- 05. id_automatico       -- 05. @id_automatica 
          cd_usuario,       -- 06. cd_usuário          -- 06. @cd_usuario   
          cd_status_atual,  -- 07. cd_status_suspeita  -- 07. @cd_status_suspeita    
          dt_alteracao,     -- 08. dt_alteracao        -- 08. getdate()  
          dt_movimentacao,  -- 09. dt_movimentacao     -- 09. dt_movimentacao
          vl_alerta,        -- 10. vl_alerta           -- 10. vl_negocio_compra  
          vl_alerta1,       -- 11. vl_alerta1          -- 11. vl_negocio_venda
          nm_alerta,        -- 12. cd_cliente_compra   -- 12. nm_alerta
          nm_alerta1,       -- 13. cd_bolsa_compra     -- 13. nm_alerta1
          nm_alerta2,       -- 14. cd_master_compra	 -- 14. nm_alerta2
          dc_alerta,        -- 15. dc_alerta           -- 15. dc_ativo	
          dc_alerta1,       -- 16. dc_alerta1          -- 16. qt_negocio	        
          dt_alerta,        -- 17. dt_alerta           -- 17. dt_ordem_compra 
          dc_alerta2,       -- 18. dc_alerta2          -- 18. cd_cliente_venda	
          dc_alerta3,       -- 19. dc_alerta3          -- 19. cd_bolsa_venda 
          dc_alerta4,       -- 20. dc_alerta4          -- 20. cd_master_venda
          dc_alerta5,       -- 21. dc_alerta5          -- 21. dc_ativo_venda
          dc_alerta6,       -- 22. dc_alerta6          -- 22. qt_negocio_venda
          dt_alerta1,       -- 23. dt_alerta1          -- 23. dt_ordem_venda
          cd_unico,         -- 24. cd_unico            -- 24. @cd_unico 
          dt_varredura,     -- 25. dt_varredura        -- 25. GETDATE()
          id_alerta)        -- 26. vl_isencao          -- 26. @vl_isencao
      select  
         @cd_cliente,            -- 01. cd_cliente          -- 01. @cd_cliente
         @cd_produto,            -- 02. cd_produto          -- 02. @cd_produto   
         @cd_enquadramento,      -- 03. cd_enquadramento    -- 03. @cd_enquadramento
         0,                      -- 04. id_selecionado      -- 04. 0
         @id_automatica,         -- 05. id_automatico       -- 05. @id_automatica 
         @cd_usuario,            -- 06. cd_usuário          -- 06. @cd_usuario  
         @cd_status_suspeita,    -- 07. cd_status_suspeita  -- 07. @cd_status_suspeita   
         getdate(),              -- 08. dt_alteracao        -- 08. getdate() 
         @dt_inicio,             -- 09. dt_movimentacao     -- 09. dt_movimentacao
         alp2.vl_negocio_compra, -- 10. vl_alerta           -- 10. vl_negocio_compra     
         alp2.vl_negocio_venda,  -- 11. vl_alerta1          -- 11. vl_negocio_venda           
         alp2.cd_cliente_compra, -- 12. cd_cliente_compra   -- 12. nm_alerta
         alp2.cd_bolsa_compra,   -- 13. cd_bolsa_compra     -- 13. nm_alerta1
         alp2.cd_master_compra,  -- 14. cd_master_compra	   -- 14. nm_alerta2
         alp2.dc_ativo_compra,   -- 15. dc_alerta           -- 15. dc_ativo	
         alp2.qt_negocio_compra, -- 16. dc_alerta1          -- 16. qt_negocio	   
         alp2.dt_ordem_compra,   -- 17. dt_alerta           -- 17. dt_ordem_compra 
         alp2.cd_cliente_venda,  -- 18. dc_alerta2          -- 18. cd_cliente_venda	  
         alp2.cd_bolsa_venda,    -- 19. dc_alerta3          -- 19. cd_bolsa_venda 
         alp2.cd_master_venda,   -- 20. dc_alerta4          -- 20. cd_master_venda
         alp2.dc_ativo_venda,    -- 21. dc_alerta5          -- 21. dc_ativo_venda
         alp2.qt_negocio_venda,  -- 22. dc_alerta6          -- 22. qt_negocio_venda   
         alp2.dt_ordem_venda,    -- 23. dt_alerta1          -- 23. dt_ordem_venda
         @cd_unico,              -- 24. cd_unico            -- 24. @cd_unico
         GETDATE(),              -- 25. dt_varredura        -- 25. GETDATE() 
         @vl_isencao             -- 26. vl_isencao          -- 26. @vl_isencao 
         from #ttp_alerta_parte2 alp2

--- 11. Incluindo as movimentações do alerta Primeira Parte

					set @cd_alerta = scope_identity()
					
					insert into dbo.tgr_alertas_movimentacao 
					     (cd_alerta, 
							cd_produto, 
							cd_movimentacao)
					select   @cd_alerta, 
							   @cd_produto, 
							   nr_movimentacao_compra	
					from	 #ttp_alerta_parte1;

               insert into dbo.tgr_alertas_movimentacao 
					     (cd_alerta, 
							cd_produto, 
							cd_movimentacao)
					select  @cd_alerta, 
							  @cd_produto, 
							  nr_movimentacao_venda	
					from #ttp_alerta_parte1;

              insert into dbo.tgr_alertas_movimentacao 
					     (cd_alerta, 
							cd_produto, 
							cd_movimentacao)
					select   @cd_alerta, 
							   @cd_produto, 
							   nr_movimentacao_compra	
					from	 #ttp_alerta_parte2;

             insert into dbo.tgr_alertas_movimentacao 
					     (cd_alerta, 
							cd_produto, 
							cd_movimentacao)
					select  @cd_alerta, 
							  @cd_produto, 
							  nr_movimentacao_venda	
					from #ttp_alerta_parte2;

               


               End
               
        End

     End

---- dropar as tabelastemporarias utilizadas

end
  
end try  
begin catch  
  
 exec dbo.spgr_tratar_erro  
   
end catch  
