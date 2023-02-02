
-- Variáveis para execução da preparação de varredura
declare @cd_produto integer
declare @cd_varredura integer
declare @dt_inicio smalldatetime
declare @dt_final smalldatetime
declare @id_mensal bit
declare @id_todos_clientes bit

-- Variáveis utilizadas para disparo de cada item de execução da varredura
declare @cd_cursor_clientes integer
declare @cd_sessao integer
declare @cd_execucao integer
declare @cd_cont integer
declare @cd_total integer

set @id_mensal = 1
set @id_todos_clientes = 1
set @cd_produto = 2
set @dt_inicio = '2021-09-01'
set @dt_final  = '2021-09-30'

--- 1) Alimenta a variavel @cd_varredura

exec @cd_varredura = dbo.spgr_preparar_varredura @id_todos_clientes, 0, @cd_produto, @id_mensal, @dt_inicio, @dt_final, 0, null, 0

--- 2) Alimenta a tabela temporaria #ttp_itens_varredura, utilizando a variavel @cd_varredura

select row_number() over(order by cd_sessao) as cd_inc, cd_cursor_clientes, cd_sessao, cd_execucao 
into #ttp_itens_varredura from dbo.tpr_varredura_control where cd_varredura = @cd_varredura

set @cd_cont = 1
select @cd_total = MAX(cd_inc) from #ttp_itens_varredura

while (@cd_cont <= @cd_total)
begin
  select
    @cd_cursor_clientes = cd_cursor_clientes,
	@cd_sessao = cd_sessao,
	@cd_execucao = cd_execucao
  from #ttp_itens_varredura
  where
    cd_inc = @cd_cont

  exec dbo.spgr_varredura_avancado 1, 0, @cd_produto, @dt_inicio, @dt_final, @id_mensal, 0, 0, @cd_varredura, @cd_cursor_clientes, @cd_sessao, null, @cd_execucao
  
  set @cd_cont = @cd_cont + 1
end

drop table #ttp_itens_varredura

go

