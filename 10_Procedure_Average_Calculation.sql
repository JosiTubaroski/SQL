
/****** Object:  StoredProcedure [dbo].[spcc_aumento_vol]    Script Date: 2023-01-31 13:30:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
ALTER procedure [dbo].[spcc_aumento_vol]
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
declare @vl_parametro1 float
declare @vl_parametro2 float
declare @vl_parametro3 float
declare @cd_suspeita int
declare @cd_status_suspeita int
declare @dt_ultimo_mes smalldatetime
declare @vl_dia char(2)
declare @vl_mes char(2)
declare @vl_ano char(4)
declare @vl_media_mensal float
declare @vl_percentual float
declare @vl_dia_convertido char(7)
declare @dt_limite smalldatetime
declare @cd_resultado int
declare @vl_isencao int
declare @cd_unico int

set dateformat mdy

begin try

	exec @vl_isencao = spgr_verificar_isencao @cd_cliente, @cd_produto, @cd_enquadramento, @dt_final
	
	if (@vl_isencao = 0)
	begin

		exec spgr_achar_parametro @cd_produto, @cd_cliente, @cd_enquadramento, @cd_usuario, @id_automatica, 1, @vl_parametro1 output
		exec spgr_achar_parametro @cd_produto, @cd_cliente, @cd_enquadramento, @cd_usuario, @id_automatica, 2, @vl_parametro2 output
		exec spgr_achar_parametro @cd_produto, @cd_cliente, @cd_enquadramento, @cd_usuario, @id_automatica, 3, @vl_parametro3 output
		
		set @vl_dia = '01'
		
		if month(@dt_final) < 10
			set @vl_mes = '0' + convert(char(1), month(@dt_final))
		else
		  	set @vl_mes = month(@dt_final)
		set @vl_ano = '%'
		set @vl_dia_convertido = convert(char, @vl_mes + '/' + @vl_dia + '/' + @vl_ano)
		set @vl_ano = year(@dt_final)
		set @dt_ultimo_mes = convert(smalldatetime, @vl_mes + '/' + @vl_dia + '/' + @vl_ano)
		set @vl_ano = year(@dt_final) - @vl_parametro1
		set @dt_limite = convert(smalldatetime, @vl_mes + '/' + @vl_dia + '/' + @vl_ano)
		
	   if (@cd_produto = 1)
	   begin

      	if (@id_resumir = 1)
		   begin

		      delete from dbo.tgr_alertas
		      where cd_cliente = @cd_cliente
		      and dt_movimentacao = @dt_ultimo_mes
		      and cd_enquadramento = @cd_enquadramento

		   end
		
		   select @vl_media_mensal = avg(vl_creditos)
		   from (select
		          (select sum(mhcc.vl_creditos)
		           from dbo.tcc_mov_hist_conta_corr mhcc, dbo.tcc_cliente_conta_corr ccc
		           where mb.dt_mes_ano = mhcc.dt_mes_ano
		           and ccc.cd_agencia = mhcc.cd_agencia
		           and ccc.nm_conta_corr = mhcc.nm_conta_corr
		           and mhcc.dt_mes_ano >= @dt_limite
		           and mhcc.dt_mes_ano < @dt_ultimo_mes
		           and ccc.cd_cliente = @cd_cliente) as vl_creditos
		           from dbo.tgr_mes_base mb) as vl_media_anual
		
		   if @vl_media_mensal <> 0
		   begin

		      if ((@vl_total_mov >= (@vl_media_mensal * ((@vl_parametro2 / 100) + 1))) and
		         (@vl_total_mov >= @vl_parametro3))
		      begin

		         set @vl_percentual = ((@vl_total_mov / @vl_media_mensal) * 100)
		
	        	   if not exists(select *
	              from dbo.tgr_alertas
	              where cd_cliente = @cd_cliente
	          	  and dt_movimentacao = @dt_ultimo_mes
	          	  and cd_enquadramento = @cd_enquadramento
	              and round(vl_alerta,0) = round(isnull(@vl_percentual, 0),0)
	          	  and round(vl_alerta1,0) = round(isnull(@vl_media_mensal, 0),0)
	              and round(vl_alerta2,0) = round(isnull(@vl_total_mov, 0),0)
	              and id_automatica = 1)
		         begin
		
	               select @cd_status_suspeita = cd_status_suspeita
	               from dbo.tgr_status_suspeita
	               where tp_status_suspeita = 0

						exec @cd_unico = dbo.spgr_inserir_relac_produto_unico @cd_cliente, @cd_produto, @cd_enquadramento

			         insert into dbo.tgr_alertas (cd_cliente, cd_enquadramento, id_selecionado, id_automatica, cd_usuario, 
	                                           cd_status_atual, dt_alteracao, cd_produto, dt_movimentacao, 
                                                   vl_alerta, vl_alerta1, vl_alerta2, dt_varredura, cd_unico
						   values(@cd_cliente, @cd_enquadramento, 0, @id_automatica, @cd_usuario, 
		                                    @cd_status_suspeita, getdate(), @cd_produto, @dt_ultimo_mes, 
	                                            isnull(@vl_percentual, 0), isnull(@vl_media_mensal, 0), isnull(@vl_total_mov, 0), getdate(), @cd_unico) 

			
		         end
		      end
		   end
	   end
   end
end try
begin catch

	exec dbo.spgr_tratar_erro

end catch
