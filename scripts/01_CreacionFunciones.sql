CREATE FUNCTION adm.fn_QuitarEspaciosEmail(
    @email VARCHAR(100)
)
RETURNS VARCHAR(100)
AS
BEGIN
    -- Elimina espacios al principio y al final
    DECLARE @resultado VARCHAR(100) = LTRIM(RTRIM(@email));

    -- Elimina espacios intermedios
    SET @resultado = REPLACE(@resultado, ' ', '');

    RETURN @resultado;
END;
GO