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
    -- Corregimos si hay algun error de caracteres
    SET @resultado = REPLACE(@resultado, '¥', 'ñ');
    SET @resultado = REPLACE(@resultado, '¡', 'i');
    SET @resultado = REPLACE(@resultado, '‚', 'e');
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
    
    -- Corregimos si hay algun error de caracteres.
    SET @resultado = REPLACE(@resultado, '¥', 'Ñ');
    SET @resultado = REPLACE(@resultado, '¡', 'Í');
    SET @resultado = REPLACE(@resultado, '‚', 'é');

    -- Hacemos todas las letras mayusculas
    SET @resultado = UPPER(@resultado)

    RETURN @resultado
END
GO

CREATE OR ALTER FUNCTION adm.GenerarDatosUF(
    @i INT, @cantidad_de_pisos TINYINT, @metros_totales SMALLINT, @valor DECIMAL(4,2), @cbu CHAR(22))
RETURNS TABLE
AS
RETURN( SELECT
            --piso segun numero de la uf (i) y redondea para arriba
            CEILING(@i/4) AS piso,

            --asigna letra de la uf
            CASE
                WHEN @i%4=1 THEN 'A'
                WHEN @i%4=2 THEN 'B'
                WHEN @i%4=3 THEN 'C'
                ELSE 'D'
            END AS letra,

            --genera totalm2 con el valor generado en el sp
		    FLOOR((@metros_totales / (@cantidad_de_pisos * 4)) * @valor) AS total_m2,
            
            --cbu generado en el sp
            @cbu as cbu,

            --asigna m2 a baulera y cochera
            CASE
                WHEN @i%3=0 THEN 4
                ELSE 0
            END AS baulera_m2,
            
            CASE
                WHEN @i%2=0 THEN 4
                ELSE 0
            END AS cochera_m2
)
GO

CREATE OR ALTER FUNCTION fin.FormatearNumero (@numero NVARCHAR(50))
    RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @numero_formateado NVARCHAR(50) = REPLACE(@numero, '.', '')
    SET @numero_formateado = REPLACE(@numero_formateado, ',', '')
    SET @numero_formateado = substring(
                                @numero_formateado, 0, len(@numero_formateado)-1)
                                + '.' + 
                                substring(@numero_formateado,len(@numero_formateado)-1,len(@numero_formateado)
                             )
    
    RETURN CAST(@numero_formateado AS DECIMAL(10,2))
END
GO

CREATE OR ALTER FUNCTION adm.ObtenerPrimerDiaDelMes
(
    @nombreMes NVARCHAR(20)
)
RETURNS DATE
AS
BEGIN
    DECLARE @anioActual INT = YEAR(GETDATE());
    DECLARE @mes INT;

    SET @nombreMes = LTRIM(RTRIM(LOWER(@nombreMes)));

    -- Convertimos el nombre del mes a número
    SET @mes = CASE @nombreMes
        WHEN 'enero' THEN 1
        WHEN 'febrero' THEN 2
        WHEN 'marzo' THEN 3
        WHEN 'abril' THEN 4
        WHEN 'mayo' THEN 5
        WHEN 'junio' THEN 6
        WHEN 'julio' THEN 7
        WHEN 'agosto' THEN 8
        WHEN 'septiembre' THEN 9
        WHEN 'octubre' THEN 10
        WHEN 'noviembre' THEN 11
        WHEN 'diciembre' THEN 12
        ELSE NULL
    END;

    IF @mes IS NULL
        RETURN NULL;

    RETURN DATEFROMPARTS(@anioActual, @mes, 1);
END;
GO

CREATE OR ALTER FUNCTION fin.FormatearPago (@numero NVARCHAR(15))
    RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @numero_formateado NVARCHAR(15) = LTRIM(RTRIM(@numero))
    SET @numero_formateado = REPLACE(@numero_formateado, '$', '')
    SET @numero_formateado = REPLACE(@numero_formateado, '.', '')

    RETURN CAST(@numero_formateado AS DECIMAL(10,2))

END
GO