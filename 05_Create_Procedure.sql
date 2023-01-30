
if exists(select name from sys.procedures where name = 'spcb_valores_elevados') 
drop procedure spcb_valores_elevados;
go

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[spcb_valores_elevados]  
@cd_execucao int,  
@cd_cliente dt_cd_cliente,  
@cd_produto smallint,  
@cd_enquadramento smallint,  
@cd_unico smallint,  
@ttp_varredura_mov_1 dtt_mov_varredura readonly,  
@ttp_varredura_mov_2 dtt_mov_varredura readonly,  
@ttp_varredura_mov_3 dtt_mov_varredura readonly,  
@dt_inicio smalldatetime,  
@dt_final  smalldatetime,  
@vl_parametro_1 float  = null,  
@vl_parametro_2 float  = null,  
@vl_parametro_3 float  = null,  
@vl_parametro_4 float  = null,  
@vl_parametro_5 float  = null,  
@vl_parametro_6 float  = null,  
@vl_parametro_7 float  = null,  
@vl_parametro_8 float  = null,  
@vl_parametro_9 float  = null,  
@vl_parametro_10 float  = null,  
@vl_parametro_11 float  = null,  
@vl_parametro_12 float  = null,  
@vl_parametro_13 float  = null,  
@vl_parametro_14 float  = null,  
@vl_parametro_15 float  = null,  
@vl_parametro_16 float  = null,  
@vl_parametro_17 float  = null,  
@vl_parametro_18 float  = null,  
@vl_parametro_19 float  = null,  
@vl_parametro_20 float  = null,  
@vl_parametro_21 float  = null,  
@vl_parametro_22 float  = null,  
@vl_parametro_23 float  = null,  
@vl_parametro_24 float  = null,  
@vl_parametro_25 float  = null,  
@vl_parametro_26 float  = null,  
@vl_parametro_27 float  = null,  
@vl_parametro_28 float  = null,  
@vl_parametro_29 float  = null,  
@vl_parametro_30 float  = null  
as  
begin try;  

--- 01. Declara as variaveis necessárias para a varredura
  
 declare @qtde_transacoes int  
 declare @vl_movimentacao money   
 declare @tp_pessoa varchar (1)
 declare @vl_cap_finan_anual float
 declare @vl_percentual float;
 declare @vl_percentual_acima float;
  
 --- 02. Capturar tipo pessoa através do Código do Cliente.

 select @tp_pessoa = tp_pessoa from dbo.tcl_cliente where cd_cliente = @cd_cliente

 --- 03. Capturando a tabela temporaria para verificar as movimentações

  declare @ttp_transacao_cliente as table  
 (cd_transacao  varchar(20),  
  tp_transacao varchar(1) null,  
  nm_contraparte varchar(200) null,  
  cd_natureza_operacao varchar(20) null,  
  vl_valor_real money null,  
  cd_boleto int null);  

 --- 04. Insert das movimentações do Cliente na Tabela Temporaria 

 insert into @ttp_transacao_cliente  
   (cd_transacao,  
    tp_transacao,  
    nm_contraparte,  
    cd_natureza_operacao,  
    vl_valor_real,  
    cd_boleto)  
 select distinct dc_registro  as cd_transacao,  
    dc_registro1 as tp_transacao,   
    dc_registro2 as nm_contraparte,  
    dc_registro5 as cd_natureza_operacao,  
    vl_registro  as vl_valor_real,  
    dc_registro6 as cd_boleto  
 from @ttp_varredura_mov_1  
 where cd_cliente = @cd_cliente  

--- 05. Verifica a quantidade de Transação, Valor Total Movimentado

 set @qtde_transacoes =  (select isnull(count(distinct cd_transacao),0) from @ttp_transacao_cliente)  
 set @vl_movimentacao =  (select isnull(sum(vl_valor_real),0) from @ttp_transacao_cliente) 

 --- 06. Se pessoal fisica e Valor Total Movimentado superior ao 'Parametro 1', 
 --- então o alerta é gerado 
  if (@tp_pessoa = 'F')
  Begin 

   if (@vl_movimentacao >= @vl_parametro_1)  
    begin  
  
     if not exists(  
     select 1   
     from dbo.tpr_varredura_alertas tva with(nolock)  
     where @qtde_transacoes = tva.dc_alerta  
     and @vl_movimentacao = vl_alerta  
     and tva.cd_enquadramento = @cd_enquadramento  
     and tva.cd_produto = @cd_produto  
     and tva.cd_cliente = @cd_cliente  
     and tva.dt_movimentacao = @dt_inicio) 
  
  begin  
   
   insert into dbo.tpr_varredura_alertas  
   (cd_produto,  
    cd_execucao,  
    cd_enquadramento,  
    cd_cliente,  
    dt_movimentacao,  
    cd_unico,      
    dc_alerta,    
    vl_alerta)    
   select distinct  
     @cd_produto,  
     @cd_execucao,  
     @cd_enquadramento,  
     @cd_cliente,     
     @dt_inicio,  
     @cd_unico,  
     @qtde_transacoes,  
     @vl_movimentacao;  
   
   insert into dbo.tpr_varredura_alertas_movimentacao  
   (cd_produto,  
    cd_execucao,  
    cd_alerta_varr,  
    cd_movimentacao  
   )  
    select   
    @cd_produto,  
    @cd_execucao,  
    cd_alerta_varr,  
    cd_transacao    
   from dbo.tpr_varredura_alertas tva with(nolock)  
   join @ttp_transacao_cliente ttp on  
   @qtde_transacoes = tva.dc_alerta  
   and @vl_movimentacao = vl_alerta  
   and  tva.cd_enquadramento = @cd_enquadramento  
   and  tva.cd_produto = @cd_produto  
   and  tva.cd_cliente = @cd_cliente  
   and  tva.dt_movimentacao = @dt_inicio 
  
   end  
  end  
 end
 -- 07. Se Pessoa Juridica,e valor total movimentado superior ao parametro2, 
 -- então é verificada a capacidade Financeira 
 else
 if (@tp_pessoa = 'J')
 Begin
 if (@vl_movimentacao >= @vl_parametro_2)   
 begin  
--- Verificando a capacidade financeira do Cliente apenas se Pessoa Jurídica e valor Maior que Parametro2

  select @vl_cap_finan_anual = case when isnull (vl_cap_finan_anual,0) = 0 
  then 75000.00 else vl_cap_finan_anual end
  from dbo.tcl_cliente_detalhe_generico
  where cd_cliente = @cd_cliente

--- 08. Verifica percentual da Capacidade Financeira
   Set @vl_percentual = ((@vl_cap_finan_anual * @vl_parametro_3) / 100)

--- 09. Se valor Movimentado for maior ou igual a 10% 'Parametro3', então o alerta é gerado. 

   If (@vl_movimentacao >= @vl_percentual)
  Begin
  if not exists(  
  select 1   
  from dbo.tpr_varredura_alertas tva with(nolock)  
  where @qtde_transacoes = tva.dc_alerta  
  and @vl_movimentacao = vl_alerta  
  and tva.cd_enquadramento = @cd_enquadramento  
  and tva.cd_produto = @cd_produto  
  and tva.cd_cliente = @cd_cliente  
  and tva.dt_movimentacao = @dt_inicio) 

  begin  
   
   insert into dbo.tpr_varredura_alertas  
   (cd_produto,  
    cd_execucao,  
    cd_enquadramento,  
    cd_cliente,  
    dt_movimentacao,  
    cd_unico,      
    dc_alerta,    
    vl_alerta)    
   select distinct  
     @cd_produto,  
     @cd_execucao,  
     @cd_enquadramento,  
     @cd_cliente,     
     @dt_inicio,  
     @cd_unico,  
     @qtde_transacoes,  
     @vl_movimentacao;  
   
   insert into dbo.tpr_varredura_alertas_movimentacao  
   (cd_produto,  
    cd_execucao,  
    cd_alerta_varr,  
    cd_movimentacao  
   )  
    select   
    @cd_produto,  
    @cd_execucao,  
    cd_alerta_varr,  
    cd_transacao    
   from dbo.tpr_varredura_alertas tva with(nolock)  
   join @ttp_transacao_cliente ttp on  
   @qtde_transacoes = tva.dc_alerta  
   and @vl_movimentacao = vl_alerta  
   and  tva.cd_enquadramento = @cd_enquadramento  
   and  tva.cd_produto = @cd_produto  
   and  tva.cd_cliente = @cd_cliente  
   and  tva.dt_movimentacao = @dt_inicio 
  
 end

 end

 end

 end

end try  
begin catch  
  exec dbo.spgr_tratar_erro;  
end catch
