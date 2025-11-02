--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------

--Cambia a COM2900_G04
USE COM2900_G04
GO

--Genera un consorcio de prueba con parametros deseados
--Generando a su vez prop e inq y asignandoles UF
CREATE OR ALTER PROCEDURE test.GeneraConsorcioPersonasUF
    @tieneBaulera BIT, @tieneCochera BIT
AS
BEGIN
    SET NOCOUNT ON;

    -- Validacion de parametros
    IF @tieneBaulera NOT IN (0,1) OR @tieneCochera NOT IN (0,1)
    BEGIN
        RAISERROR('Error en la entrada de datos.', 16, 1);
        RETURN;
    END;

    -- Asegura un tipo de servicio de limpieza
    IF NOT EXISTS (SELECT 1 FROM adm.TipoServicioLimpieza)
        INSERT INTO adm.TipoServicioLimpieza(nombre) VALUES ('Empresa de limpieza');

    -- Genera consorcio
    DECLARE
        @numeroConsorcio TINYINT,
        @nombre NVARCHAR(15),
        @calle NVARCHAR(22),
        @metros_totales SMALLINT = 1000,
        @cant_pisos TINYINT = 2,
        @precio_baulera DECIMAL(10,2) = 60000.00,
        @precio_cochera DECIMAL(10,2) = 60000.00,
        @id_tipo_limpieza INT = 1,
        @id_consorcio INT;

    BEGIN TRY
        SET @numeroConsorcio = (SELECT ISNULL(MAX(id_consorcio),0) + 1 FROM adm.Consorcio);
        SET @nombre = 'Consorcio_' + CAST(@numeroConsorcio AS VARCHAR);
        SET @calle  = 'Calle ' + @nombre + ' 1816';

        EXEC adm.AgregarConsorcio
            @id_tipo_limpieza,
            @nombre,
            @calle,
            @metros_totales,
            @cant_pisos,
            @precio_baulera,
            @precio_cochera;

        SET @id_consorcio = IDENT_CURRENT('adm.Consorcio');
    END TRY
    BEGIN CATCH
        PRINT('Error al generar consorcio: ' + ERROR_MESSAGE());
        RETURN;
    END CATCH;

    -- Datos para personas y UF
    DECLARE
        @cantidadUF INT,
        @i INT = 1,
        @id_prop INT,
        @id_inq INT,
        @nombrePers NVARCHAR(30),
        @apellido NVARCHAR(30),
        @dni INT,
        @telefono INT,
        @email NVARCHAR(50),
        @cbu CHAR(22),
        @idUF INT;

    WHILE EXISTS (SELECT 1 FROM adm.UnidadFuncional WHERE id_consorcio = @id_consorcio AND id_prop IS NULL)
    BEGIN
        -- Selecciona la siguiente UF vacía (una diferente cada iteración)
        SELECT TOP 1 @idUF = id_uni_func
        FROM adm.UnidadFuncional
        WHERE id_consorcio = @id_consorcio AND id_prop IS NULL
        ORDER BY id_uni_func;

        --Crear propietario
        SET @nombrePers = 'Prop_' + CAST(@i AS NVARCHAR(5));
        SET @apellido   = 'Apellido' + CAST(@i AS NVARCHAR(5));
        SET @dni        = 40000000 + @i;
        SET @telefono   = 1122000000 + @i;
        SET @email      = @nombrePers + '@hotmail.com';
        SET @cbu        = RIGHT(CONCAT('21314151000000000000', @i), 22);

        EXEC adm.AgregarPropietario 
            @nombrePers, @apellido, @dni, @email, @telefono, @cbu;

        SET @id_prop = IDENT_CURRENT('adm.Propietario');

        --Crear inquilino (solo si i es par)
        IF (@i % 2 = 0)
        BEGIN
            SET @nombrePers = 'Inq_' + CAST(@i AS NVARCHAR(5));
            SET @apellido   = 'Apellido' + CAST(@i AS NVARCHAR(5));
            SET @dni        = 41000000 + @i;
            SET @telefono   = 1122000000 + @i;
            SET @email      = @nombrePers + '@hotmail.com';
            SET @cbu        = RIGHT(CONCAT('21314151000000000000', @i), 22);

            EXEC adm.AgregarInquilino 
                @nombrePers, @apellido, @dni, @email, @telefono, @cbu;

            SET @id_inq = IDENT_CURRENT('adm.Inquilino');
        END
        ELSE
            SET @id_inq = NULL;

        --Asignar propietario e inquilino
        UPDATE adm.UnidadFuncional
        SET id_prop = @id_prop,
            id_inq   = @id_inq
        WHERE id_uni_func = @idUF;

        SET @i += 1;
    END;
    PRINT 'Consorcio ' +@nombre + ' generado .';
END;
GO