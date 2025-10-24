--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------

-----------CREACION DE LA BASE DE DATOS-----------
/*
--Cambia a master
USE master
GO

--Eliminar la db
DROP DATABASE COM2900_G04;
GO 
*/

--Crea la db
IF DB_ID('COM2900_G04') IS NULL
	CREATE DATABASE COM2900_G04 COLLATE Latin1_General_CI_AS;
GO

--Cambia a COM2900_G04
USE COM2900_G04
GO

---------------CREACION DE ESQUEMAS---------------
--Esquema adm (Administracion) vinculado a tablas Consorcio, Unidad Funcional, Prop. e Inquilino.
IF SCHEMA_ID('adm') IS NULL
BEGIN
	EXEC('CREATE SCHEMA adm');
END

--Esquema fin (Finanzas) vinculado a tablas Pago, ResumenBancarioCSV, EstadoDeCuenta, Expensa, EstadoFinanciero, Factura.
IF SCHEMA_ID('fin') IS NULL
BEGIN
    EXEC('CREATE SCHEMA fin');
END
GO

--Esquema Gasto vinculado a tablas DetalleGastoGeneral, DetalleGastoServicioPublico, DetalleGastoExtraordinario,
--          DetalleGastoSeguro, DetalleGastoAdministracion, DetalleGastoLimpieza y DetalleMantenimientoBancario.
IF SCHEMA_ID('gasto') IS NULL
BEGIN
    EXEC('CREATE SCHEMA fin');
END
GO

--Esquema ref (Referencias) vinculado a tablas Proveedor, TipoServicioPublico, TipoServicioLimpieza y EnviadoA.
IF SCHEMA_ID('ref') IS NULL
BEGIN
    EXEC('CREATE SCHEMA fin');
END
GO

----------------CREACION DE TABLAS----------------

--ref
IF OBJECT_ID('ref.TipoServicioLimpieza') IS NULL
BEGIN
    CREATE TABLE ref.TipoServicioLimpieza(
        id_tipo_servlimpieza INT IDENTITY(1,1),
        nombre VARCHAR(25)

        CONSTRAINT PK_TipoServicioLimpieza PRIMARY KEY (id_tipo_servlimpieza)
);END



IF OBJECT_ID('adm.Consorcio') IS NULL
BEGIN
    CREATE TABLE adm.Consorcio(
        id_consorcio INT IDENTITY(1,1),
        id_tipo_servlimpieza INT,
        nombre VARCHAR(25),
        direccion VARCHAR(75),
        metros_totales SMALLINT,
        cantidad_uf TINYINT,
        precio_bauleraM2 DECIMAL(10,2)
        
        CONSTRAINT PK_consorcio PRIMARY KEY (id_consorcio)
        CONSTRAINT FK_consorcio 
        FOREIGN KEY (id_tipo_servlimpieza) REFERENCES ref.TipoServicioLimpieza(id_tipo_servlimpieza)
); END