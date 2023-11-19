-- Defina suas duas datas
DECLARE @dataInicial DATETIME = '2022-01-01';
DECLARE @dataFinal DATETIME = '2023-01-01';

-- Calcule a diferença em dias
DECLARE @diasPassados INT;
SET @diasPassados = DATEDIFF(DAY, @dataInicial, @dataFinal);

-- Calcule a diferença em horas, minutos e segundos
DECLARE @horasPassadas INT, @minutosPassados INT, @segundosPassados INT;
SET @horasPassadas = DATEDIFF(HOUR, @dataInicial, @dataFinal);
SET @minutosPassados = DATEDIFF(MINUTE, @dataInicial, @dataFinal);
SET @segundosPassados = DATEDIFF(SECOND, @dataInicial, @dataFinal);

-- Exiba os resultados
PRINT 'Passaram-se ' + CAST(@diasPassados AS VARCHAR) + ' dias.';
PRINT 'Passaram-se ' + CAST(@horasPassadas AS VARCHAR) + ' horas.';
PRINT 'Passaram-se ' + CAST(@minutosPassados AS VARCHAR) + ' minutos.';
PRINT 'Passaram-se ' + CAST(@segundosPassados AS VARCHAR) + ' segundos.';
