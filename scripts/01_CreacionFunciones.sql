--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------

-------------CREACION DE LAS FUNCIONES------------

--Cambia a COM2900_G04
USE COM2900_G04
GO

CREATE OR ALTER FUNCTION adm.FormatearEmail(
    @email NVARCHAR(50)
)
RETURNS NVARCHAR(50)
AS
BEGIN
    -- Elimina espacios al principio y al final
    DECLARE @resultado NVARCHAR(50) = LTRIM(RTRIM(@email))

    -- Elimina espacios intermedios
    SET @resultado = REPLACE(@resultado, ' ', '')

    -- Convertimos todo a minusculas
    SET @resultado = LOWER(@resultado)

    RETURN @resultado;
END;
GO

CREATE OR ALTER FUNCTION adm.FormatearNombreOApellido(
    @cadena NVARCHAR(30)
)
RETURNS NVARCHAR(30)
AS
BEGIN
    -- Elimina espacios al principio y al final
    DECLARE @resultado NVARCHAR(30) = LTRIM(RTRIM(@cadena))
    -- Hacemos todas las letras mayusculas
    SET @resultado = UPPER(@resultado)

    RETURN @resultado
END
GO
