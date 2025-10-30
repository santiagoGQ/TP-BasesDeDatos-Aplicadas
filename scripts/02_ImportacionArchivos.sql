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
        detalle VARCHAR(25) COLLATE Latin1_General_CI_AS,
        consorcio VARCHAR(25) COLLATE Latin1_General_CI_AS
    )

    ------------------------------------------------------------
    -- 2. Importar los datos desde Excel (hoja 'Proveedores')
    ------------------------------------------------------------
    DECLARE @sql NVARCHAR(MAX);
    SET @sql = N'
        INSERT INTO #ProveedoresTemp (tipo_de_gasto, razon_social, detalle, consorcio)
        SELECT
            F1 AS tipo_de_gasto,
            F2 AS razon_social,
            F3 AS detalle,
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
                     THEN LTRIM(RTRIM(detalle))
                ELSE LTRIM(RTRIM(razon_social))
            END AS razon_social_final,

            -- Si no es limpieza, limpiar el detalle y dejar solo números
            CASE 
                WHEN tipo_de_gasto NOT LIKE '%LIMPIEZA%' 
                     THEN REPLACE(REPLACE(REPLACE(
                            TRANSLATE(detalle, 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ', REPLICATE(' ', 53)), ' ', ''), '-', ''), '.', '')
                ELSE NULL
            END AS cbu_final,

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
               d.cbu_final
           FROM #DatosLimpios d
           INNER JOIN adm.Consorcio c ON c.nombre = d.consorcio
           WHERE d.tipo_de_gasto NOT LIKE '%LIMPIEZA%' -- por ahora ignoramos limpieza
       ) AS origen
       ON destino.id_consorcio = origen.id_consorcio
          AND destino.motivo = origen.tipo_de_gasto
       WHEN MATCHED THEN
           UPDATE SET 
               destino.razon_social = origen.razon_social_final,
               destino.cbu = origen.cbu_final
       WHEN NOT MATCHED THEN
           INSERT (razon_social, cuit, motivo, id_consorcio)
           VALUES (
               origen.razon_social_final,
               '00000000000',              -- cuit placeholder
               origen.tipo_de_gasto,
               origen.id_consorcio
           );

    ------------------------------------------------------------
    -- 5. Inserción específica para los de limpieza
    ------------------------------------------------------------
    INSERT INTO adm.Proveedor (razon_social, cuit, motivo, id_consorcio)
    SELECT 
        d.razon_social_final,
        '00000000000',
        d.tipo_de_gasto,
        c.id_consorcio
    FROM #DatosLimpios d
    INNER JOIN adm.Consorcio c ON c.nombre = d.consorcio
    WHERE d.tipo_de_gasto LIKE '%LIMPIEZA%'
      AND NOT EXISTS (
            SELECT 1 
            FROM adm.Proveedor p 
            WHERE p.id_consorcio = c.id_consorcio
              AND p.motivo = d.tipo_de_gasto
        );

    ------------------------------------------------------------
    DROP TABLE #ProveedoresTemp;
    DROP TABLE #DatosLimpios;
END;
GO

/*
adm.AgregarTipoServicioLimpieza 'Limpieza test'
exec adm.ImportarConsorcios N'C:\Temp\datos varios.xlsx'
exec adm.ImportarProveedores N'C:\Temp\datos varios.xlsx'

select * from adm.Consorcio
select * from adm.Proveedor order by id_consorcio

delete from adm.Proveedor
*/