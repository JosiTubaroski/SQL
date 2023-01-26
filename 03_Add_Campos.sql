
--- Caso o campo não exista o campo na tabela então será adicionado

 If not exists (Select top 1 T.name AS Tabela,C.name AS Coluna
                from sys.sysobjects as T (nolock)
                inner join sys.all_columns AS C (NOLOCK) ON T.id = C.object_id AND T.XTYPE = 'U'
                Where T.name = 'tgr_funcionario' and C.NAME = 'dt_nascimento')

   ALTER TABLE dbo.tgr_funcionario 
   ADD dt_nascimento VARCHAR(30) NULL
