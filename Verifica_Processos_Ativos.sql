
SELECT
	Processo      = spid
	,Computador   = hostname
	,Usuario      = loginame
	,Status       = status
	,BloqueadoPor = blocked
	,TipoComando  = cmd
	,Aplicativo   = program_name
FROM
	master..sysprocesses
WHERE
	status in ('runnable', 'suspended')
ORDER BY
	blocked desc, status, spid