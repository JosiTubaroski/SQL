--------------------------------------------------
-- JSON => Variável
--------------------------------------------------
declare @j varchar(max) = (select bulkcolumn from openrowset (bulk 'c:\tmp\03_git_follow.json', single_clob) a)
select @j as [json]
 
 
--------------------------------------------------
-- JSON => Variável => Tabela
--------------------------------------------------
select
    *
from openjson (@j, '$') 
with (login varchar(max)) 
 
 

