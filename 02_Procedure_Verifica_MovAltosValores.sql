
Create procedure [dbo].[spcc_mov_alto_val]
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
	declare @vl_parametro1 float;
	declare @vl_isencao int;
	declare @cd_unico int;
	declare @cd_status_atual int;

	exec @vl_isencao = dbo.spgr_verificar_isencao @cd_cliente, @cd_produto, @cd_enquadramento, @dt_final;
		
	if (@vl_isencao = 0)
	begin

		if (@cd_produto = 2)  
		begin  
	
			if (@id_resumir = 1)  
			begin  
		
				delete dbo.tgr_alertas
				from   dbo.tgr_alertas gra
				join   dbo.tgr_cargas  grc on gra.cd_carga = grc.cd_carga  	
				and    grc.cd_produto       = @cd_produto
				and    grc.dt_referencia    = @dt_final
				and	   grc.id_termino = 1	
				and	   left(rtrim(ltrim(grc.nm_arquivo)), 9) = 'CONTA_MOV'
				where  gra.cd_produto       = @cd_produto		
				and    gra.cd_enquadramento = @cd_enquadramento
				and    gra.cd_cliente       = @cd_cliente;

			end  

			exec dbo.spgr_achar_parametro @cd_produto, @cd_cliente, @cd_enquadramento, @cd_usuario, @id_automatica, @vl_parametro1 output;

			--cria tabelas temp	
			create table #ttp_alertas(
					cd_movimentacao int,
					cd_agencia varchar(5),
					nm_conta_corr varchar(15),
					dt_movimentacao date,
					vl_movimentacao money,
					cd_historico int,
					dc_historico varchar(40),
					tp_historico varchar(1) 	
			);

			create table #ttp_alertas_movimentacao(
					cd_alerta int,
					cd_movimentacao int
			);

			insert into #ttp_alertas
			(
					cd_movimentacao,
					cd_agencia,
					nm_conta_corr,
					dt_movimentacao,
					vl_movimentacao,
					cd_historico,
					dc_historico,
					tp_historico
			)		
			select  distinct 
					mcc.cd_movimentacao,
					mcc.cd_agencia,
					mcc.nm_conta_corr,
					mcc.dt_movimentacao,
					mcc.vl_movimentacao,
					hcc.cd_historico,
					hcc.dc_historico,
					hcc.tp_historico
			from	dbo.tcc_mov_conta_corr	     mcc with (nolock)
			join	dbo.tcc_cliente_conta_corr   ccc with (nolock) on mcc.cd_agencia   = ccc.cd_agencia
			and		mcc.nm_conta_corr = ccc.nm_conta_corr
			and		mcc.vl_movimentacao >= @vl_parametro1
			join	dbo.tcc_historico_conta_corr hcc with (nolock) on mcc.cd_historico = hcc.cd_historico
			and		hcc.id_varr_2_1 = 1
			join	dbo.tgr_cargas			     grc with (nolock) on mcc.cd_carga = grc.cd_carga
			and		grc.cd_produto = 2
			and		grc.id_termino = 1	
			and		left(rtrim(ltrim(grc.nm_arquivo)), 9) = 'CONTA_MOV'
			where	ccc.cd_cliente	= @cd_cliente
			and		grc.dt_referencia between @dt_inicio and @dt_final

			if exists(select top 1 1 from #ttp_alertas)
			begin
		
				exec @cd_unico = dbo.spgr_inserir_relac_produto_unico @cd_produto, @cd_enquadramento, @vl_parametro1;

				select @cd_status_atual = dbo.fcn_retorna_status_alertas(1)

				insert into dbo.tgr_alertas
				(
						cd_cliente,
						cd_produto, 
						cd_enquadramento, 
						id_selecionado, 
						id_automatica, 
						cd_usuario, 
						cd_status_atual, 
						dt_movimentacao,
						nm_alerta,
						dc_alerta,
						dc_alerta1,
						vl_alerta,
						nm_alerta1,
						dc_alerta2,
						dc_alerta3,
						cd_unico,
						dt_alteracao,
						dt_varredura
				) output inserted.cd_alerta, inserted.nm_alerta into #ttp_alertas_movimentacao (cd_alerta, cd_movimentacao)
				select
						@cd_cliente			as cd_cliente,
						@cd_produto			as cd_produto,
						@cd_enquadramento	as cd_enquadramento, 
						0					as id_selecionado,
						@id_automatica		as id_automatica, 
						@cd_usuario			as cd_usuario, 
						@cd_status_atual	as cd_status_atual,    		
						ori.dt_movimentacao,
						ori.cd_movimentacao as nm_alerta,
						ori.cd_agencia		as dc_alerta,
						ori.nm_conta_corr	as dc_alerta1,
						ori.vl_movimentacao as vl_alerta,
						ori.cd_historico	as nm_alerta1,
						ori.dc_historico	as dc_alerta2,
						ori.tp_historico	as dc_alerta3,  
						@cd_unico			as cd_unico,
						getdate()			as dt_alteracao,
						getdate()			as dt_varredura
				from	#ttp_alertas	  ori with (nolock)
				left join dbo.tgr_alertas des with (nolock) on ori.cd_movimentacao = des.nm_alerta
				and		ori.cd_agencia       = des.dc_alerta
				and		ori.nm_conta_corr    = des.dc_alerta1
				and		ori.vl_movimentacao  = des.vl_alerta
				and		ori.cd_historico     = des.nm_alerta1
				and		ori.dc_historico	 = des.dc_alerta2
				and		ori.tp_historico	 = des.dc_alerta3
				and		ori.dt_movimentacao  = des.dt_movimentacao
				and		des.cd_cliente		 = @cd_cliente
				and		des.cd_produto		 = @cd_produto
				and		des.cd_enquadramento = @cd_enquadramento
				where   des.cd_alerta is null;

				--Insere as movimentações 
				insert into dbo.tgr_alertas_movimentacao
				(
						cd_alerta,
						cd_produto,
						cd_movimentacao	
				)
				select  cd_alerta,
						@cd_produto,
						cd_movimentacao
				from	#ttp_alertas_movimentacao

			end 

			drop table #ttp_alertas;
			drop table #ttp_alertas_movimentacao;
				
		end	 	 
		  
	end 
	
end try
begin catch

    exec dbo.spgr_tratar_erro;

end catch
