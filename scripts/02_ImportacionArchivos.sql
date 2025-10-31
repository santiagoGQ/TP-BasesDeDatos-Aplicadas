--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------

---------CREACION DE LOS STORE PROCEDURES---------

--Cambia a COM2900_G04
USE COM2900_G04
GO
-- TODO: Agregar transacciones para que se atomico
CREATE OR ALTER PROCEDURE adm.ImportarConsorcios
    @ruta_archivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #ConsorciosTemp (
        id INT IDENTITY(1,1) PRIMARY KEY,
        nombreConsorcio NVARCHAR(100),
        domicilio NVARCHAR(100),
        cantUnidadesFuncionales INT,
        m2Totales INT
    );

    DECLARE @sql NVARCHAR(MAX);

    -- Armo la consulta dinámica para importar desde Excel
    SET @sql = N'
        INSERT INTO #ConsorciosTemp (nombreConsorcio, domicilio, cantUnidadesFuncionales, m2Totales)
        SELECT
            [Nombre del consorcio],
            [Domicilio],
            [Cant unidades funcionales],
            [m2 totales]
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;HDR=YES;Database=' + @ruta_archivo + N''',
            ''SELECT * FROM [Consorcios$]''
        );
    ';

    EXEC sp_executesql @sql;

    --------------------------------------------------------
    -- Recorremos las filas
    --------------------------------------------------------

    DECLARE 
        @id INT,
        @nombreConsorcio VARCHAR(25),
        @domicilio VARCHAR(75),
        @cantUnidadesFuncionales TINYINT,
        @m2Totales SMALLINT;

    WHILE EXISTS (SELECT 1 FROM #ConsorciosTemp)
    BEGIN
        SELECT TOP 1
            @id = id,
            @nombreConsorcio = nombreConsorcio,
            @domicilio = domicilio,
            @cantUnidadesFuncionales = cantUnidadesFuncionales,
            @m2Totales = m2Totales
        FROM #ConsorciosTemp
        ORDER BY id;

        -- Verifico si ya existe en la tabla adm.Consorcio
        IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE nombre = @nombreConsorcio AND direccion = @domicilio)
        BEGIN
            EXEC adm.AgregarConsorcioImportado
                @nombreConsorcio,
                @domicilio,
                @m2Totales,
                @cantUnidadesFuncionales
                
        END
        DELETE FROM #ConsorciosTemp WHERE id = @id;
    END;

END;
GO

CREATE OR ALTER PROCEDURE adm.AgregarConsorcioImportado
    @nombre VARCHAR(25),
    @direccion VARCHAR(75),
    @metros_totales INT,
    @cantidad_uf INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_consorcio INT;
    DECLARE @ruta_txt NVARCHAR(255);

    -- Ruta al archivo TXT (ajustar según tu entorno)
    -- Ejemplo: C:\Importaciones\Consorcios.txt
    SET @ruta_txt = N'C:\Temp\UF por consorcio.txt';

    
    ------------------------------------------------------------
    -- 1. Insertar consorcio y obtener su ID
    ------------------------------------------------------------
    INSERT INTO adm.Consorcio (nombre, direccion, metros_totales, cantidad_uf, id_tipo_serv_limpieza,
        precio_bauleraM2, precio_cocheraM2)
    VALUES (@nombre, @direccion, @metros_totales, @cantidad_uf, 1, 2000.0, 5000.0); -- TODO: Agregar bien el tipo de servicio de limpieza
        
    SET @id_consorcio = SCOPE_IDENTITY();

    ------------------------------------------------------------
    -- 2. Crear tabla temporal para las unidades funcionales
    ------------------------------------------------------------
    CREATE TABLE #UFsTemp (
        nombreConsorcio NVARCHAR(100),
        nroUnidadFuncional NVARCHAR(10),
        piso NVARCHAR(10),
        departamento NVARCHAR(10),
        coeficiente NVARCHAR(10),         
        m2_unidad_funcional NVARCHAR(10),
        bauleras NVARCHAR(2),
        cochera NVARCHAR(2),
        m2_baulera NVARCHAR(10),
        m2_cochera NVARCHAR(10)
    );

    ------------------------------------------------------------
    -- 3. Importar desde el TXT (CSV separado por tabulaciones)
    ------------------------------------------------------------
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        BULK INSERT #UFsTemp
        FROM ''' + @ruta_txt + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ''\t'',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001'',  -- UTF-8
            KEEPNULLS
        );
    ';
    EXEC sp_executesql @sql;

    ------------------------------------------------------------
    -- 4. Insertar las UFs del consorcio actual
    ------------------------------------------------------------
    INSERT INTO adm.UnidadFuncional (
        id_consorcio,
        piso,
        depto,
        coeficiente,
        total_m2,
        baulera_m2,
        cochera_m2
    )
    SELECT
        @id_consorcio,
        piso,
        departamento,
        CAST(REPLACE(coeficiente, ',', '.') AS DECIMAL(5,2)),
        CAST(m2_unidad_funcional AS DECIMAL(8,2)),
        CAST(m2_baulera AS DECIMAL(8,2)),
        CAST(m2_cochera AS DECIMAL(8,2))
    FROM #UFsTemp
    WHERE nombreConsorcio = @nombre;

    DROP TABLE #UFsTemp;
END;
GO

--exec adm.ImportarConsorcios N'C:\Temp\datos varios.xlsx'

CREATE OR ALTER PROCEDURE adm.ImportarProveedores ---- Todo: implementar mensaje de error si el consorcio no existe sin dropear toda la ejecucion
    @ruta_archivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    ------------------------------------------------------------
    -- 1. Tabla temporal para importar los datos del Excel
    ------------------------------------------------------------
    CREATE TABLE #ProveedoresTemp (
        tipo_de_gasto VARCHAR(25) COLLATE Latin1_General_CI_AS,
        razon_social VARCHAR(100) COLLATE Latin1_General_CI_AS,
        cuenta VARCHAR(50) COLLATE Latin1_General_CI_AS,
        consorcio VARCHAR(25) COLLATE Latin1_General_CI_AS
    )

    ------------------------------------------------------------
    -- 2. Importar los datos desde Excel (hoja 'Proveedores')
    ------------------------------------------------------------
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        INSERT INTO #ProveedoresTemp (tipo_de_gasto, razon_social, cuenta, consorcio)
        SELECT
            F1 AS tipo_de_gasto,
            F2 AS razon_social,
            F3 AS cuenta,
            [Nombre del consorcio] AS consorcio
        FROM OPENROWSET(
            ''Microsoft.ACE.OLEDB.12.0'',
            ''Excel 12.0;HDR=YES;Database=' + @ruta_archivo + N''',
            ''SELECT * FROM [Proveedores$]''
        );
    ';
    EXEC sp_executesql @sql;

    ------------------------------------------------------------
    -- 3. Limpiar y preparar los datos antes del merge
    ------------------------------------------------------------
        SELECT 
            tipo_de_gasto,
            -- Si es limpieza y la razon_social = 'Serv. Limpieza', usar detalle como razon_social
            CASE 
                WHEN tipo_de_gasto LIKE '%LIMPIEZA%' 
                     AND LTRIM(RTRIM(UPPER(razon_social))) = 'SERV. LIMPIEZA'
                     THEN LTRIM(RTRIM(cuenta))
                ELSE LTRIM(RTRIM(razon_social))
            END AS razon_social_final,

            -- Si no es limpieza, limpiar el detalle y dejar solo números
            CASE 
                WHEN tipo_de_gasto NOT LIKE '%LIMPIEZA%' 
                     THEN REPLACE(REPLACE(REPLACE(
                            TRANSLATE(cuenta, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ', REPLICATE(' ', 53)), ' ', ''), '-', ''), '.', '')
                ELSE NULL
            END AS cuenta_final,

            LTRIM(RTRIM(consorcio)) AS consorcio
        INTO #DatosLimpios
        FROM #ProveedoresTemp

    ------------------------------------------------------------
    -- 4. MERGE: Insertar o actualizar en adm.Proveedor
    ------------------------------------------------------------
    MERGE adm.Proveedor AS destino
       USING (
           SELECT 
               c.id_consorcio,
               d.tipo_de_gasto,
               d.razon_social_final,
               d.cuenta_final
           FROM #DatosLimpios d
           INNER JOIN adm.Consorcio c ON c.nombre = d.consorcio
           WHERE d.tipo_de_gasto NOT LIKE '%LIMPIEZA%' -- por ahora ignoramos limpieza
       ) AS origen
       ON destino.id_consorcio = origen.id_consorcio
          AND destino.motivo = origen.tipo_de_gasto
          AND destino.razon_social = origen.razon_social_final
       WHEN MATCHED THEN
           UPDATE SET 
               destino.cuenta = origen.cuenta_final
       WHEN NOT MATCHED THEN
           INSERT (razon_social, motivo, id_consorcio,cuenta)
           VALUES (
               origen.razon_social_final,
               origen.tipo_de_gasto,
               origen.id_consorcio,
               origen.cuenta_final
           );

    ------------------------------------------------------------
    -- 5. Inserción específica para los de limpieza
    ------------------------------------------------------------
    INSERT INTO adm.Proveedor (razon_social, motivo, id_consorcio, cuenta)
    SELECT 
        d.razon_social_final,
        d.tipo_de_gasto,
        c.id_consorcio,
        d.cuenta_final
    FROM #DatosLimpios d
    INNER JOIN adm.Consorcio c ON c.nombre = d.consorcio
    WHERE d.tipo_de_gasto LIKE '%LIMPIEZA%'
      AND NOT EXISTS (
            SELECT 1 
            FROM adm.Proveedor p 
            WHERE p.id_consorcio = c.id_consorcio
              AND p.motivo = d.tipo_de_gasto
              AND p.razon_social = d.razon_social_final
        );

    ------------------------------------------------------------
    DROP TABLE #ProveedoresTemp;
    DROP TABLE #DatosLimpios;
END;
GO

CREATE OR ALTER PROCEDURE adm.ImportarInquilinoYPropietarios
    @ruta_archivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #InqPropsTemp (
        nombre NVARCHAR(100),
        apellido NVARCHAR(100),
        dni NVARCHAR(20),
        email_personal NVARCHAR(200),
        telefono_contacto NVARCHAR(20),
        cvu_cbu NVARCHAR(30),
        inquilino BIT
    );

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        BULK INSERT #InqPropsTemp
        FROM ''' + @ruta_archivo + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '';'',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''1252''
        );
    ';
    EXEC sp_executesql @sql;

    DECLARE @id INT = 1, @max INT;
    SELECT @max = COUNT(*) FROM #InqPropsTemp;

    WHILE @id <= @max
    BEGIN
        DECLARE @nombre NVARCHAR(30),
                @apellido NVARCHAR(30),
                @dni INT,
                @email NVARCHAR(50),
                @telefono INT,
                @cbu CHAR(22),
                @inquilino BIT;

        SELECT TOP 1
            @nombre = nombre,
            @apellido = apellido,
            @dni = dni,
            @email = email_personal,
            @telefono = telefono_contacto,
            @inquilino = inquilino,
            @cbu = cvu_cbu
        FROM #InqPropsTemp

        IF @inquilino = 1
            EXEC adm.AgregarInquilino @nombre, @apellido, @dni, @email, @telefono, @cbu;
        ELSE
            EXEC adm.AgregarPropietario @nombre, @apellido, @dni, @email, @telefono, @cbu;
        DELETE TOP (1) FROM #InqPropsTemp;
        SET @id += 1;
    END

    DROP TABLE #InqPropsTemp

END;
GO

CREATE OR ALTER PROCEDURE adm.ImportarRelacionEntreUFyPropInq
    @ruta_archivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #RelacionesTemp (
        cbu_cvu NVARCHAR(50),
        nombre_consorcio NVARCHAR(50),
        nro_uf NVARCHAR(4),
        piso NCHAR(2),
        departamento NCHAR(1)
    );

    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        BULK INSERT #RelacionesTemp
        FROM ''' + @ruta_archivo + N'''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ''|'',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''1252''
        );
    ';
    EXEC sp_executesql @sql;

    DECLARE @id INT = 1, @max INT;
    SELECT @max = COUNT(*) FROM #RelacionesTemp;

    WHILE @id <= @max
    BEGIN
        DECLARE @cbu_cvu NVARCHAR(50),
                @nombre_consorcio NVARCHAR(50),
                @nro_uf NVARCHAR(4),
                @piso NCHAR(2),
                @departamento NCHAR(1)

        SELECT TOP 1
            @cbu_cvu = cbu_cvu,
            @nombre_consorcio = nombre_consorcio,
            @nro_uf = nro_uf,
            @piso = piso,
            @departamento = departamento
        FROM #RelacionesTemp

        EXEC adm.AsociarHuespedAUnidadFuncional @cbu_cvu, @nombre_consorcio, @nro_uf, @piso, @departamento
        
        DELETE TOP (1) FROM #RelacionesTemp;
        SET @id += 1;
    END

END
GO

CREATE OR ALTER PROCEDURE adm.AsociarHuespedAUnidadFuncional
    @cbu CHAR(22),
    @nombre_consorcio VARCHAR(25),
    @nro_uf NVARCHAR(4),
    @piso NCHAR(2),
    @departamento NCHAR(1)
AS
BEGIN
    DECLARE @id_consorcio INT = (SELECT id_consorcio FROM adm.Consorcio where nombre = @nombre_consorcio)
    DECLARE @id_inquilino INT = (SELECT id_inq FROM adm.Inquilino WHERE cbu = @cbu)
    DECLARE @id_propietario INT = (SELECT id_prop FROM adm.Propietario WHERE cbu = @cbu)

     UPDATE  adm.UnidadFuncional
        SET id_inq = @id_inquilino,
            id_prop = @id_propietario,
            cbu = @cbu
        WHERE id_consorcio = @id_consorcio AND piso = @piso AND depto = @departamento;

END
GO

CREATE OR ALTER PROCEDURE adm.ImportarGastos -- TODO: Habria que poner una verificacion de que si los pagos ya fueron ingresados que no se pueda reemplazar
    @ruta_archivo NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #GastosTemp (
        Nombre_del_consorcio NVARCHAR(100),
        Mes VARCHAR(20),
        BANCARIOS DECIMAL(18,2),
        LIMPIEZA DECIMAL(18,2),
        ADMINISTRACION DECIMAL(18,2),
        SEGUROS DECIMAL(18,2),
        GASTOS_GENERALES DECIMAL(18,2),
        SERVICIOS_PUBLICOS_Agua DECIMAL(18,2),
        SERVICIOS_PUBLICOS_Luz DECIMAL(18,2)
    );

    DECLARE @json NVARCHAR(MAX);
    DECLARE @sql NVARCHAR(MAX);

    SET @sql = N'
    SELECT @jsonOut = BulkColumn
    FROM OPENROWSET(
        BULK ''' + @ruta_archivo + ''',
        SINGLE_CLOB
    ) AS j;
    ';
    EXEC sp_executesql @sql, N'@jsonOut NVARCHAR(MAX) OUTPUT', @jsonOut=@json OUTPUT;

    INSERT INTO #GastosTemp 
    SELECT
        JSON_VALUE(value, '$."Nombre del consorcio"'),
        REPLACE(JSON_VALUE(value, '$.Mes'), ' ', ''),
        fin.FormatearNumero(JSON_VALUE(value, '$.BANCARIOS')),
        fin.FormatearNumero(JSON_VALUE(value, '$.LIMPIEZA')),
        fin.FormatearNumero(JSON_VALUE(value, '$.ADMINISTRACION')),
        fin.FormatearNumero(JSON_VALUE(value, '$.SEGUROS')),
        fin.FormatearNumero(JSON_VALUE(value, '$."GASTOS GENERALES"')),
        fin.FormatearNumero(JSON_VALUE(value, '$."SERVICIOS PUBLICOS-Agua"')),
        fin.FormatearNumero(JSON_VALUE(value, '$."SERVICIOS PUBLICOS-Luz"'))
    FROM OPENJSON(@json);

    DECLARE @id INT = 1, @max INT;
    SELECT @max = COUNT(*) FROM #GastosTemp;
       
    BEGIN TRANSACTION
    BEGIN TRY
        WHILE @id <= @max
        BEGIN
            DECLARE @nombre_consorcio NVARCHAR(100),
                @mes VARCHAR(20),
                @bancarios DECIMAL(18,2),
                @limpieza DECIMAL(18,2),
                @administracion DECIMAL(18,2),
                @seguros DECIMAL(18,2),
                @gastos_generales DECIMAL(18,2),
                @servicios_publicos_agua DECIMAL(18,2),
                @servicios_publicos_luz DECIMAL(18,2)
            DECLARE @id_consorcio INT
            DECLARE @id_expensa INT
            DECLARE @fecha_expensa DATE

            SELECT TOP 1
                @nombre_consorcio = Nombre_del_consorcio,
                @mes = Mes,
                @bancarios = BANCARIOS,
                @limpieza = LIMPIEZA,
                @administracion = ADMINISTRACION,
                @seguros = SEGUROS,
                @gastos_generales = GASTOS_GENERALES,
                @servicios_publicos_agua = SERVICIOS_PUBLICOS_Agua,
                @servicios_publicos_luz = SERVICIOS_PUBLICOS_Luz

            FROM #GastosTemp

            IF(@nombre_consorcio IS NOT NULL)
            BEGIN
                SET @id_consorcio = (SELECT id_consorcio FROM adm.Consorcio WHERE nombre = @nombre_consorcio)
                exec adm.AgregarExpensa @id_consorcio, @mes, @id_expensa OUTPUT

                SET @fecha_expensa = (SELECT fechaGenerado FROM adm.Expensa where id_expensa = @id_expensa)

                exec gasto.AgregarGastoAdministracion @id_consorcio, @id_expensa, @administracion, @fecha_expensa, NULL
                exec gasto.AgregarGastoBancario @id_consorcio, @id_expensa, @bancarios, @fecha_expensa, NULL
                exec gasto.AgregarGastoGeneral @id_consorcio, @id_expensa, @gastos_generales, @fecha_expensa, NULL
                exec gasto.AgregarGastoLimpieza @id_consorcio, @id_expensa, @limpieza, @fecha_expensa, NULL
                exec gasto.AgregarGastoSeguro @id_consorcio, @id_expensa, @seguros, @fecha_expensa, NULL
                exec gasto.AgregarGastoServicioPublico @id_consorcio, @id_expensa, @servicios_publicos_agua, @fecha_expensa, 'AYSA'
                exec gasto.AgregarGastoServicioPublico @id_consorcio, @id_expensa, @servicios_publicos_luz, @fecha_expensa, 'EDENOR'
            END
            DELETE TOP (1) FROM #GastosTemp;
            SET @id += 1;
            
        END
        COMMIT

    END TRY
    BEGIN CATCH
        ROLLBACK
		PRINT 'Ocurrio un error al generar la expensa.';
		PRINT 'Mensaje: ' + ERROR_MESSAGE();
	END CATCH
END
/*
Para probar

adm.AgregarTipoServicioLimpieza 'Limpieza test'
exec adm.ImportarConsorcios N'C:\Temp\datos varios.xlsx'
exec adm.ImportarProveedores N'C:\Temp\datos varios.xlsx'
exec adm.ImportarInquilinoYPropietarios N'C:\Temp\Inquilino-propietarios-datos.csv'
exec adm.ImportarRelacionEntreUFyPropInq N'C:\Temp\Inquilino-propietarios-UF.csv'

exec adm.ImportarGastos N'C:\Temp\Servicios.Servicios.json'

*/