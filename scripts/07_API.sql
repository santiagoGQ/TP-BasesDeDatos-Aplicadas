--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------
-- Este archivo contiene la creacion de un Store Procedure que llama a la API de feriados argentinos.
-- Lo ejecutamos una vez antes de comenzar las pruebas, ya que carga los feriados en una tabla global.

--Cambia a COM2900_G04
USE COM2900_G04
GO

-- Configuracion previa
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
GO

-- Este SP realiza un GET a https://api.argentinadatos.com/v1/feriados/2025 y trae todos los feriados del año 2025.
CREATE OR ALTER PROCEDURE adm.TraerFeriadosArgentinos
AS
BEGIN
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..##Feriados') IS NOT NULL DROP TABLE ##Feriados;
    CREATE TABLE ##Feriados (fecha DATE, nombre NVARCHAR(100));

    DECLARE @response NVARCHAR(MAX);
    CREATE TABLE #Feriados (json NVARCHAR(MAX));

    INSERT INTO #Feriados(json)
    EXEC xp_cmdshell 'curl -s -L https://api.argentinadatos.com/v1/feriados/2025';

    SELECT @response = STRING_AGG(json, '')
    FROM #Feriados
    WHERE json IS NOT NULL;

    INSERT INTO ##Feriados (fecha, nombre)
    SELECT fecha, nombre
    FROM OPENJSON(@response)
    WITH (fecha DATE, nombre NVARCHAR(100));

    DROP TABLE #Feriados;
END;
GO

exec adm.TraerFeriadosArgentinos