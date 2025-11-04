--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------
-- Este archivo crea los Store Procedures que generan los datos para las pruebas.

--Cambia a COM2900_G04
USE COM2900_G04
GO

-- Genera un consorcio de prueba con parametros deseados
-- Generando a su vez prop e inq y asignandoles UF
CREATE OR ALTER PROCEDURE test.GeneraConsorcioPersonasUF
    @tieneBaulera BIT, 
    @tieneCochera BIT,
    @id_consorcio INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF @tieneBaulera NOT IN (0,1) OR @tieneCochera NOT IN (0,1)
    BEGIN
        RAISERROR('Error en la entrada de datos.', 16, 1);
        RETURN;
    END;

    -- Asegura un tipo de servicio de limpieza
    IF NOT EXISTS (SELECT 1 FROM adm.TipoServicioLimpieza)
        INSERT INTO adm.TipoServicioLimpieza(nombre) VALUES ('Empresa de limpieza');

    -- Crear consorcio
    DECLARE
        @numeroConsorcio TINYINT,
        @nombre NVARCHAR(15),
        @calle NVARCHAR(22),
        @metros_totales SMALLINT = 720,
        @cantidad_departamentos TINYINT = 12,
        @precio_baulera DECIMAL(10,2) = 5000.00,
        @precio_cochera DECIMAL(10,2) = 10000.00,
        @id_tipo_limpieza INT = 1

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

    -- Crear propietarios, inquilinos y unidades funcionales
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
        -- Determinar piso y m2 según el número de depto
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

        -- Asignar depto A/B/C/D en ciclo
        SET @depto = CHAR(64 + ((@i - 1) % 4) + 1); -- 1=A, 2=B, 3=C, 4=D

        -- Generar propietario
        SET @nombrePers = 'Prop_' + CAST(@i AS NVARCHAR(5));
        SET @apellido   = 'Apellido' + CAST(@i AS NVARCHAR(5));
        SET @dni        = 40000000 + @i;
        SET @telefono   = 1122000000 + @i;
        SET @email      = @nombrePers + '@hotmail.com';
        SET @cbu        = RIGHT(CONCAT('21314151000000000000', @i), 22);

        EXEC adm.AgregarPropietario 
            @nombrePers, @apellido, @dni, @email, @telefono, @cbu;

        SET @id_prop = IDENT_CURRENT('adm.Propietario');

        -- Generar inquilino solo si i es par
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

        -- Generar valores de baulera y cochera
        IF @tieneBaulera = 1
            SET @baulera_m2 = CAST(FLOOR(RAND() * 6) as TINYINT); -- entre 0 y 5
        ELSE
            SET @baulera_m2 = 0;

        IF @tieneCochera = 1
            SET @cochera_m2 = CAST(FLOOR(RAND() * 6) as TINYINT);
        ELSE
            SET @cochera_m2 = 0;

        -- Crear la Unidad Funcional
        INSERT INTO adm.UnidadFuncional
            (id_consorcio, id_inq, id_prop, total_m2, piso, depto, coeficiente, cbu, baulera_m2, cochera_m2)
        VALUES
            (@id_consorcio, @id_inq, @id_prop, @total_m2, @piso, @depto, @coef, @cbu, @baulera_m2, @cochera_m2);

        SET @i += 1;
    END;
    RETURN @id_consorcio
    PRINT 'Consorcio ' + @nombre + ' generado correctamente con sus unidades funcionales, propietarios e inquilinos.';
END;
GO

CREATE OR ALTER PROCEDURE test.GeneraExpensaProveedorGastos
    @id_consorcio INT,
    @mes VARCHAR(20),
    @gasto_extraordinario BIT --Genera gasto extrarordinario si se encuentra en 1

AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @fecha DATETIME,
        @id_expensa INT,
        @id_limpieza INT, @id_admin INT, @id_seguro INT, @id_bancario INT,
        @id_servpublico INT

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE id_consorcio = @id_consorcio)
        BEGIN
            RAISERROR('No existe el consorcio con esa id.',16,1)
            ROLLBACK TRANSACTION
            RETURN
        END

        IF @gasto_extraordinario IS NULL
        BEGIN
            RAISERROR('Elija 1 o 0, si quiere o no gasto extraordinario',16,1)
            ROLLBACK TRANSACTION
            RETURN
        END

        --Generación de expensa
        DECLARE @mes_expensa VARCHAR(20) = adm.ObtenerMesSiguiente(@mes)
        EXEC adm.AgregarExpensa
            @id_consorcio, @mes_expensa, @id_expensa OUTPUT

        --Creación de proveedores si no existen, guardando su id
        IF NOT EXISTS (SELECT 1 FROM adm.Proveedor WHERE motivo = 'GASTOS DE LIMPIEZA' AND id_consorcio = @id_consorcio)
            EXEC adm.AgregarProveedor
                'Empresa Limpieza', 'GASTOS DE LIMPIEZA', @id_consorcio, '21314151000000000001', @id_limpieza OUTPUT
        ELSE
            SELECT @id_limpieza = id_proveedor FROM adm.Proveedor 
            WHERE motivo = 'GASTOS DE LIMPIEZA' AND id_consorcio = @id_consorcio

        IF NOT EXISTS (SELECT 1 FROM adm.Proveedor WHERE motivo = 'GASTOS BANCARIOS' AND id_consorcio = @id_consorcio)
            EXEC adm.AgregarProveedor
                'Empresa Bancaria', 'GASTOS BANCARIOS', @id_consorcio, '21314151000000000002', @id_bancario OUTPUT
        ELSE
            SELECT @id_bancario = id_proveedor FROM adm.Proveedor 
            WHERE motivo = 'GASTOS BANCARIOS' AND id_consorcio = @id_consorcio

        IF NOT EXISTS (SELECT 1 FROM adm.Proveedor WHERE motivo = 'GASTOS DE ADMINISTRACION' AND id_consorcio = @id_consorcio)
            EXEC adm.AgregarProveedor
                'Empresa Administrativa', 'GASTOS DE ADMINISTRACION', @id_consorcio, '21314151000000000003', @id_admin OUTPUT
        ELSE
            SELECT @id_admin = id_proveedor FROM adm.Proveedor 
            WHERE motivo = 'GASTOS DE ADMINISTRACION' AND id_consorcio = @id_consorcio

        IF NOT EXISTS (SELECT 1 FROM adm.Proveedor WHERE motivo = 'SEGUROS' AND id_consorcio = @id_consorcio)
            EXEC adm.AgregarProveedor
                'Empresa de seguros', 'SEGUROS', @id_consorcio, '21314151000000000004', @id_seguro OUTPUT
        ELSE
            SELECT @id_seguro = id_proveedor FROM adm.Proveedor 
            WHERE motivo = 'SEGUROS' AND id_consorcio = @id_consorcio

        IF NOT EXISTS (SELECT 1 FROM adm.Proveedor WHERE motivo = 'SERVICIOS PUBLICOS' AND id_consorcio = @id_consorcio)
            EXEC adm.AgregarProveedor
                'Empresa de servicios publicos', 'SERVICIOS PUBLICOS', @id_consorcio, '21314151000000000005', @id_servpublico OUTPUT
        ELSE
            SELECT @id_servpublico = id_proveedor FROM adm.Proveedor 
            WHERE motivo = 'SERVICIOS PUBLICO' AND id_consorcio = @id_consorcio

        --Generación de fecha para las facturas
        DECLARE @mes_formateado INT = MONTH(adm.ObtenerPrimerDiaDelMes(@mes))
        SET @fecha = DATEFROMPARTS ( 2025, @mes_formateado, 12)

        --Generación de gastos y facturas
        EXEC gasto.AgregarGastoAdministracion
            @id_consorcio, @id_expensa, 120000, @fecha, 'Gasto administrativo'

        EXEC gasto.AgregarGastoBancario
            @id_consorcio, @id_expensa, 150000, @fecha, 'Gasto bancario'

        EXEC gasto.AgregarGastoLimpieza
            @id_consorcio, @id_expensa, 60000, @fecha, 'Gasto de limpieza'

        EXEC gasto.AgregarGastoSeguro
            @id_consorcio, @id_expensa, 100000, @fecha, 'Gasto de seguro'

        EXEC gasto.AgregarGastoServicioPublico --No se si agregar el tipo de servicio
            @id_consorcio, @id_expensa, 200000, @fecha, 'Gasto de luz'

        EXEC gasto.AgregarGastoGeneral
            @id_consorcio, @id_expensa, 35000, @fecha, 'Gasto general'

        IF @gasto_extraordinario = 1
            EXEC gasto.AgregarGastoExtraordinario
                @id_expensa, 80000, @fecha, 'Gasto extraordinario', 1, 1

        COMMIT TRANSACTION

    END TRY
    BEGIN CATCH
        PRINT('Error al generar gastos: ' + ERROR_MESSAGE())
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION
        RETURN
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE test.GenerarPagos
    @id_consorcio INT,
    @mes VARCHAR(20)

AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @id_uni_func INT,
        @fecha DATETIME,
        @cbu_cvu CHAR(22),
        @monto DECIMAL(10,2),
        @i INT = 1,
        @total_uni_func INT

    BEGIN TRY
        BEGIN TRANSACTION

        IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE id_consorcio = @id_consorcio)
        BEGIN
            RAISERROR('No existe consorcio con esa id.', 16, 1)
            ROLLBACK TRANSACTION
            RETURN
        END

        --Tabla temporal para almacenar las UF
        DECLARE @ufs TABLE (
            fila INT IDENTITY(1,1),
            id_uni_func INT,
            cbu CHAR(22)
        )

        --Insercion de valores a la tabla temporal
        INSERT INTO @ufs (id_uni_func, cbu)
        SELECT id_uni_func, cbu
        FROM adm.UnidadFuncional
        WHERE id_consorcio = @id_consorcio

        SET @total_uni_func = (SELECT COUNT(*) FROM @ufs)

        --WHILE que recorre las UFs
        WHILE @i <= @total_uni_func
        BEGIN
            SELECT 
                @id_uni_func = id_uni_func,
                @cbu_cvu = cbu
            FROM @ufs
            WHERE fila = @i

            DECLARE @mes_formateado INT = MONTH(adm.ObtenerPrimerDiaDelMes(@mes))
            SET @fecha = DATEFROMPARTS(2025, @mes_formateado, (@i % 10) + 1)
           
            SET @monto = (@i % 4) * 10000 + 120000

            EXEC fin.AgregarPago
                @id_uni_func, @fecha, @cbu_cvu, @monto

            SET @i += 1
        END

        --Generación de datos para pago no asociado
        SET @cbu_cvu = RIGHT(CONCAT('213741512000000000000', @i), 22)
        SET @fecha = DATEADD(DAY,2,@fecha)

        --Agregado de pago no asociado
        EXEC fin.AgregarPago
            NULL, @fecha, @cbu_cvu, @monto

        COMMIT TRANSACTION

    END TRY
    BEGIN CATCH
        PRINT('Error al generar pagos: ' + ERROR_MESSAGE())
        IF XACT_STATE() <> 0 ROLLBACK TRANSACTION
        RETURN  
    END CATCH

END
GO