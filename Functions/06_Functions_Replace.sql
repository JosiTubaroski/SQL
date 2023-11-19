update dbo.tgr_lista_Pep
set documentos = (REPLACE(REPLACE(REPLACE([documentos],'.', ''),'-', ''),'/', ''))
