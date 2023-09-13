/* Modelo do Arquivo Lido
{ 
  "pessoas": {
      "pessoa": [
        {
           "id": "1",
           "nm": "Priscila Laborão",
           "profissao": "Recrutadora"
         },
         {
           "id": "2",
           "nm": "Tiragato Dakatola",
           "profissao": "Mágico"
         },
         {
           "id": "3",
           "nm": "Rick Win",
           "profissao": "Usineiro"
         }
      ]}}
*/

use master
go

--------------------------------------------------
-- JSON => Variável
--------------------------------------------------
declare @j varchar(max) = (select bulkcolumn from openrowset (bulk 'c:\tmp\pessoas.json', single_clob) a)
select @j as [json]
 
 
--------------------------------------------------
-- JSON => Variável => Tabela
--------------------------------------------------
select
    *
from openjson (@j, '$.pessoas.pessoa') 
with (id int, nm varchar(100), profissao varchar(100)) pessoas
 
 
--------------------------------------------------
-- Tabela => json
--------------------------------------------------
declare @pessoas table (id int, nm varchar(100), profissao varchar(100))
insert into @pessoas values
    (1, 'Priscila Laborão', 'Recrutadora'),
    (2, 'Tiragato Dakatola', 'Analista de TI'),
    (3, 'Ric Wyndfuck', 'Usineiro')
 
select
    * 
from @pessoas as pessoa 
for json auto, root('pessoas')
go

