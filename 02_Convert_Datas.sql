
select getdate() as datanormal, Convert(varchar(10),getdate(),103) as dataformatada103,
Convert(varchar(25),getdate(),113) as dataformatada113,
Convert(varchar(25),getdate(),22) as dataformatada22,
Convert(varchar(25),getdate(),111) as dataformatada111,
Convert(varchar(25),getdate(),130) as dataformatada130,
Convert(varchar(25),getdate(),109) as dataformatada109,
Convert(varchar(25),getdate(),120) as dataformatada120

--- Teste passar de 103 para varchar
--- E de varchar para 120

select getdate() as datanormal,Convert(varchar(25),getdate(),103) as dataformatada103

create table tb_teste_date
(dt_teste varchar (15))

INSERT INTO [dbo].[tb_teste_date]
           ([dt_teste])
     VALUES
           ('14/04/2021')
GO

update [dbo].[tb_teste_date]
set dt_teste = '14/04/2021'

--- Converte o formato de 14/04/2021 para 2021-04-14 00:00:00

select 
convert(smalldatetime,substring(dt_teste,7,4)+ substring(dt_teste,4,2) 
      + substring(dt_teste,1,2))as dt_ordem
from tb_teste_date

--- Converte o formato de 14042021 para 2021-04-14 00:00:00

select 
convert(smalldatetime,substring(dt_teste,5,4)+ substring(dt_teste,3,2) 
      + substring(dt_teste,1,2))as dt_ordem
from tb_teste_date

--- Converte o formato de 20210414 para 2021-04-14 00:00:00

select 
convert(smalldatetime,substring(dt_teste,1,4)+ substring(dt_teste,5,2) 
      + substring(dt_teste,7,2))as dt_ordem
from tb_teste_date

update [dbo].[tb_teste_date]
set dt_teste = '14042021'

--- Declarando variavel e utilizando conversão de data no where

declare @dt_inicio smalldatetime = '2021-04-14' 

select @dt_inicio

select dt_teste from tb_teste_date
where  convert(smalldatetime,substring(dt_teste,7,4)+ substring(dt_teste,4,2) 
      + substring(dt_teste,1,2))= @dt_inicio





