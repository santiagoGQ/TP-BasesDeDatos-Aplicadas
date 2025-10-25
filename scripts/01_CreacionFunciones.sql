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

CREATE FUNCTION adm.fn_QuitarEspaciosEmail(
    @email NVARCHAR(50)
)
RETURNS NVARCHAR(50)
AS
BEGIN
    -- Elimina espacios al principio y al final
    DECLARE @resultado NVARCHAR(50) = LTRIM(RTRIM(@email));

    -- Elimina espacios intermedios
    SET @resultado = REPLACE(@resultado, ' ', '');

    RETURN @resultado;
END;
GO