
SELECT 
    OBJECT_NAME(m.object_id) AS ProcedureName,
    m.definition AS ProcedureDefinition
FROM 
    sys.sql_modules m
    INNER JOIN sys.objects o ON m.object_id = o.object_id
WHERE 
    o.type = 'P' AND 
    m.definition like '%qtd_dias%';

select * from tsv_envio_email

sp_helptext spsv_processar_integracao_ad


