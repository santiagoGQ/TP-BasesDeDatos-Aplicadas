EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
EXEC xp_cmdshell 'curl -L https://api.argentinadatos.com/v1/feriados/2025';

DECLARE @response NVARCHAR(MAX);
CREATE TABLE #Feriados (json NVARCHAR(MAX));

INSERT INTO #Feriados(json)
EXEC xp_cmdshell 'curl -s -L https://api.argentinadatos.com/v1/feriados/2025';

SELECT @response = STRING_AGG(json, '') FROM #Feriados WHERE json IS NOT NULL;

SELECT fecha, nombre
FROM OPENJSON(@response)
WITH (
    fecha DATE,
    nombre NVARCHAR(100)
);
DROP TABLE #Feriados