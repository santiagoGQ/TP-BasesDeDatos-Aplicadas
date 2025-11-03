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
    @tieneBaulera BIT, 
    @tieneCochera BIT
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

    ----------------------------------------------------------
    -- 1. Crear consorcio base
    ----------------------------------------------------------
    DECLARE
        @numeroConsorcio TINYINT,
        @nombre NVARCHAR(15),
        @calle NVARCHAR(22),
        @metros_totales SMALLINT = 720,
        @cantidad_departamentos TINYINT = 12,
        @precio_baulera DECIMAL(10,2) = 5000.00,
        @precio_cochera DECIMAL(10,2) = 10000.00,
        @id_tipo_limpieza INT = 1,
        @id_consorcio INT;

    BEGIN TRY
        SET @numeroConsorcio = (SELECT ISNULL(MAX(id_consorcio),0) + 1 FROM adm.Consorcio);
        SET @nombre = 'Consorcio_' + CAST(@numeroConsorcio AS VARCHAR);
        SET @calle  = 'Calle ' + @nombre + ' 1816';
        DECLARE @precio_baulera_final DECIMAL(10,2) =  @precio_baulera * @tieneBaulera

        DECLARE @precio_cochera_final DECIMAL(10,2) =  @precio_cochera * @tieneCochera

        EXEC adm.AgregarConsorcio
            @nombre,
            @calle,
            @metros_totales,
            @cantidad_departamentos,
            @precio_baulera_final,
            @precio_cochera_final,
            @id_tipo_limpieza;

        SET @id_consorcio = IDENT_CURRENT('adm.Consorcio');
    END TRY
    BEGIN CATCH
        PRINT('Error al generar consorcio: ' + ERROR_MESSAGE());
        RETURN;
    END CATCH;

    ----------------------------------------------------------
    -- 2. Crear propietarios, inquilinos y unidades funcionales
    ----------------------------------------------------------
    DECLARE 
        @i INT = 1,
        @id_prop INT,
        @id_inq INT,
        @nombrePers NVARCHAR(30),
        @apellido NVARCHAR(30),
        @dni INT,
        @telefono INT,
        @email NVARCHAR(50),
        @cbu CHAR(22),
        @total_m2 SMALLINT,
        @piso VARCHAR(4),
        @depto CHAR(1),
        @coef DECIMAL(5,2),
        @baulera_m2 TINYINT,
        @cochera_m2 TINYINT;

    WHILE @i <= @cantidad_departamentos
    BEGIN
        ------------------------------------------------------
        -- Determinar piso y m2 según el número de depto
        ------------------------------------------------------
        IF @i BETWEEN 1 AND 4
        BEGIN
            SET @total_m2 = 40;
            SET @piso = 'PB';
            SET @coef = 5.56;
        END
        ELSE IF @i BETWEEN 5 AND 8
        BEGIN
            SET @total_m2 = 60;
            SET @piso = '1';
            SET @coef = 8.33;
        END
        ELSE
        BEGIN
            SET @total_m2 = 80;
            SET @piso = '2';
            SET @coef = 11.11;
        END;

        ------------------------------------------------------
        -- Asignar depto A/B/C/D en ciclo
        ------------------------------------------------------
        SET @depto = CHAR(64 + ((@i - 1) % 4) + 1); -- 1=A, 2=B, 3=C, 4=D

        ------------------------------------------------------
        -- Generar propietario
        ------------------------------------------------------
        SET @nombrePers = 'Prop_' + CAST(@i AS NVARCHAR(5));
        SET @apellido   = 'Apellido' + CAST(@i AS NVARCHAR(5));
        SET @dni        = 40000000 + @i;
        SET @telefono   = 1122000000 + @i;
        SET @email      = @nombrePers + '@hotmail.com';
        SET @cbu        = RIGHT(CONCAT('21314151000000000000', @i), 22);

        EXEC adm.AgregarPropietario 
            @nombrePers, @apellido, @dni, @email, @telefono, @cbu;

        SET @id_prop = IDENT_CURRENT('adm.Propietario');

        ------------------------------------------------------
        -- Generar inquilino solo si i es par
        ------------------------------------------------------
        IF (@i % 2 = 0)
        BEGIN
            SET @nombrePers = 'Inq_' + CAST(@i AS NVARCHAR(5));
            SET @apellido   = 'Apellido' + CAST(@i AS NVARCHAR(5));
            SET @dni        = 41000000 + @i;
            SET @telefono   = 1133000000 + @i;
            SET @email      = @nombrePers + '@hotmail.com';
            SET @cbu        = RIGHT(CONCAT('31313131000000000000', @i), 22);

            EXEC adm.AgregarInquilino 
                @nombrePers, @apellido, @dni, @email, @telefono, @cbu;

            SET @id_inq = IDENT_CURRENT('adm.Inquilino');
        END
        ELSE
            SET @id_inq = NULL;

        ------------------------------------------------------
        -- Generar valores de baulera y cochera
        ------------------------------------------------------
        IF @tieneBaulera = 1
            SET @baulera_m2 = CAST(FLOOR(RAND() * 6) as TINYINT); -- entre 0 y 5
        ELSE
            SET @baulera_m2 = 0;

        IF @tieneCochera = 1
            SET @cochera_m2 = CAST(FLOOR(RAND() * 6) as TINYINT);
        ELSE
            SET @cochera_m2 = 0;

        ------------------------------------------------------
        -- Crear la Unidad Funcional
        ------------------------------------------------------
        INSERT INTO adm.UnidadFuncional
            (id_consorcio, id_inq, id_prop, total_m2, piso, depto, coeficiente, cbu, baulera_m2, cochera_m2)
        VALUES
            (@id_consorcio, @id_inq, @id_prop, @total_m2, @piso, @depto, @coef, @cbu, @baulera_m2, @cochera_m2);

        SET @i += 1;
    END;

    PRINT 'Consorcio ' + @nombre + ' generado correctamente con sus unidades funcionales, propietarios e inquilinos.';
END;
GO


-- exec test.GeneraConsorcioPersonasUF 1, 0
-- CREATE SCHEMA test