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
    EXEC('CREATE SCHEMA gasto');
END
GO

/*
IF OBJECT_ID('') IS NULL
BEGIN
    CREATE TABLE (
    
    CONSTRAINT PK_    
);END
*/
----------------CREACION DE TABLAS----------------
IF OBJECT_ID('adm.TipoServicioLimpieza') IS NULL
BEGIN
    CREATE TABLE adm.TipoServicioLimpieza(
        id_tipo_servLimpieza INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(45) NOT NULL,

        CONSTRAINT PK_TipoServicioLimpieza PRIMARY KEY (id_tipo_servLimpieza)
);END

IF OBJECT_ID('adm.TipoServicioPublico') IS NULL
BEGIN
    CREATE TABLE adm.TipoServicioPublico( 
        id_tipo_servPublico INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(45) NOT NULL,

        CONSTRAINT PK_TipoServicioPublico PRIMARY KEY (id_tipo_servPublico)
);END

IF OBJECT_ID('adm.Proveedor') IS NULL
BEGIN
    CREATE TABLE adm.Proveedor(
        id_proveedor INT IDENTITY(1,1) NOT NULL,
        razon_social VARCHAR(45),
        cuit SMALLINT NOT NULL,
        email VARCHAR(100),
        telefono VARCHAR(10),

        CONSTRAINT PK_Proveedor PRIMARY KEY (id_proveedor)
); END

IF OBJECT_ID('adm.Consorcio') IS NULL
BEGIN
    CREATE TABLE adm.Consorcio(
        id_consorcio INT IDENTITY(1,1) NOT NULL,
        id_tipo_servlimpieza INT NOT NULL,
        nombre VARCHAR(25) NOT NULL,
        direccion VARCHAR(75) NOT NULL,
        metros_totales SMALLINT NOT NULL,
        cantidad_uf TINYINT NOT NULL,
        precio_bauleraM2 DECIMAL(10,2) NOT NULL,
        
        CONSTRAINT PK_consorcio PRIMARY KEY (id_consorcio),
        CONSTRAINT FK_serv_limp_consorcio FOREIGN KEY (id_tipo_servlimpieza) 
        REFERENCES adm.TipoServicioLimpieza(id_tipo_servlimpieza)
); END

IF OBJECT_ID('adm.Expensa') IS NULL
BEGIN
    CREATE TABLE adm.Expensa(
        id_expensa INT IDENTITY(1,1) NOT NULL,
        id_consorcio INT NOT NULL,
        fechaGenerado DATE NOT NULL,
        fechaPrimerVenc DATE NOT NULL,
        fechaSegVenc DATE NOT NULL,
        
        CONSTRAINT PK_Expensa PRIMARY KEY (id_expensa),
        CONSTRAINT FK_Consorcio_Expensa FOREIGN KEY (id_consorcio) REFERENCES adm.Consorcio(id_consorcio)
); END


IF OBJECT_ID('adm.Propietario') IS NULL
BEGIN
    CREATE TABLE adm.Propietario(
        id_prop INT IDENTITY(1,1),
        nombre NVARCHAR(30) NOT NULL,
        apellido NVARCHAR(30) NOT NULL,
        dni INT NOT NULL,
        email NVARCHAR(30) NOT NULL,
        telefono INT NOT NULL,
        cbu CHAR(22) NOT NULL,

        CONSTRAINT PK_Propietario PRIMARY KEY (id_prop)
        
); END

IF OBJECT_ID('adm.Inquilino') IS NULL
BEGIN
    CREATE TABLE adm.Inquilino(
        id_inq INT IDENTITY(1,1),
        nombre NVARCHAR(30) NOT NULL,
        apellido NVARCHAR(30) NOT NULL,
        dni INT NOT NULL,
        email NVARCHAR(30) NOT NULL,
        telefono INT NOT NULL,
        cbu CHAR(22) NOT NULL,

        CONSTRAINT PK_Inquilino PRIMARY KEY (id_inq)
        
); END

IF OBJECT_ID('adm.UnidadFuncional') IS NULL
BEGIN
    CREATE TABLE adm.UnidadFuncional(
        id_uni_func INT IDENTITY(1,1),
        id_inq INT NOT NULL,
        id_prop INT NOT NULL,
        id_consorcio INT NOT NULL,
        total_m2 SMALLINT NOT NULL,
        depto VARCHAR(4) NOT NULL,
        cbu CHAR(22) NOT NULL,
        baulera_m2 TINYINT NOT NULL,
        cochera_m2 TINYINT NOT NULL

        CONSTRAINT PK_UnidadFuncional PRIMARY KEY (id_uni_func),
        CONSTRAINT FK_Inq_UnidadFuncional FOREIGN KEY (id_inq) REFERENCES adm.Inquilino(id_inq),
        CONSTRAINT FK_Prop_UnidadFuncional FOREIGN KEY (id_prop) REFERENCES adm.Propietario(id_prop),
        CONSTRAINT FK_Consorcio_UnidadFuncional FOREIGN KEY (id_consorcio) REFERENCES adm.Consorcio(id_consorcio),
); END


IF OBJECT_ID('fin.Factura') IS NULL
BEGIN
    CREATE TABLE fin.Factura(
        id_factura INT IDENTITY(1,1) NOT NULL,
        id_proveedor INT NOT NULL,
        nro_Factura VARCHAR(15) NOT NULL,
        fecha_Emision DATE NOT NULL,
        fecha_Vencimiento DATE NOT NULL,
        importe DECIMAL(10,2) NOT NULL,

        CONSTRAINT PK_Factura PRIMARY KEY (id_factura),
        CONSTRAINT FK_Proveedor_Factura FOREIGN KEY (id_proveedor) REFERENCES adm.Proveedor(id_proveedor)
);END

IF OBJECT_ID('gasto.Limpieza') IS NULL
BEGIN
    CREATE TABLE gasto.Limpieza(
        id_expensa INT NOT NULL,
        id_factura INT NOT NULL,
        descripcion varchar(100),

        CONSTRAINT PK_GastoLimpieza PRIMARY KEY (id_expensa),
        CONSTRAINT FK_Expensa_GastoLimpieza FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa),
        CONSTRAINT FK_Factura_GastoLimpieza FOREIGN KEY (id_factura) REFERENCES fin.Factura(id_factura)
);END

IF OBJECT_ID('gasto.Seguro') IS NULL
BEGIN
    CREATE TABLE gasto.Seguro(
        id_seguro INT IDENTITY(1,1) NOT NULL,
        id_expensa INT NOT NULL,
        id_factura INT NOT NULL,
        descripcion varchar(100),

        CONSTRAINT PK_GastoSeguro PRIMARY KEY (id_seguro),
        CONSTRAINT FK_Expensa_GastoSeguro FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa),
        CONSTRAINT FK_Factura_GastoSeguro FOREIGN KEY (id_factura) REFERENCES fin.Factura(id_factura)
);END

IF OBJECT_ID('gasto.Administracion') IS NULL
BEGIN
    CREATE TABLE gasto.Administracion(
        id_admin INT IDENTITY(1,1) NOT NULL,
        id_expensa INT NOT NULL,
        id_factura INT NOT NULL,
        descripcion varchar(100),

        CONSTRAINT PK_GastoAdmin PRIMARY KEY (id_admin),
        CONSTRAINT FK_Expensa_GastoAdmin FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa),
        CONSTRAINT FK_Factura_GastoAdmin FOREIGN KEY (id_factura) REFERENCES fin.Factura(id_factura)
);END

IF OBJECT_ID('fin.ResumenBancarioCSV') IS NULL
BEGIN
    CREATE TABLE fin.ResumenBancarioCSV(
        id_expensa INT NOT NULL,

        CONSTRAINT PK_ResumenCSV PRIMARY KEY (id_expensa),
        CONSTRAINT FK_Expensa_ResumenCSV FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa)
);END

IF OBJECT_ID('adm.EnviadoA') IS NULL
BEGIN
    CREATE TABLE adm.EnviadoA(
        id_expensa INT IDENTITY(1,1) NOT NULL,
        id_uni_func INT NOT NULL,
        medio_Comunicacion_Prop VARCHAR(9) NOT NULL,
        medio_Comunicacion_Inq VARCHAR(9) NOT NULL,
    
        CONSTRAINT PK_EnviadoA PRIMARY KEY (id_expensa),
        CONSTRAINT FK_UF_EnviadoA FOREIGN KEY (id_uni_func) REFERENCES adm.UnidadFuncional(id_uni_func),
        CONSTRAINT CHK_EnviadoA1 CHECK (medio_Comunicacion_Prop IN ('EMAIL','TELEFONO','IMPRESO')),
        CONSTRAINT CHK_EnviadoA2 CHECK (medio_Comunicacion_Inq IN ('EMAIL','TELEFONO','IMPRESO'))
);END

IF OBJECT_ID('fin.Pago') IS NULL
BEGIN
    CREATE TABLE fin.Pago(
        id_resumen INT NOT NULL,
        id_pago INT IDENTITY(1,1) NOT NULL,
        id_uni_func INT,
        fecha DATETIME NOT NULL,
        cuenta_origen CHAR(22) NOT NULL,
        monto DECIMAL(7,2) NOT NULL,

        CONSTRAINT PK_Pago PRIMARY KEY (id_resumen, id_pago),
        CONSTRAINT FK_Resumen_Pago FOREIGN KEY (id_resumen) REFERENCES fin.ResumenBancarioCSV(id_expensa),
        CONSTRAINT FK_UniFunc_Pago FOREIGN KEY (id_uni_func) REFERENCES adm.UnidadFuncional(id_uni_func)
);END


IF OBJECT_ID('fin.EstadoFinanciero') IS NULL
BEGIN
    CREATE TABLE fin.EstadoFinanciero(
        id_expensa INT NOT NULL,
        ing_en_termino DECIMAL(7,2) NOT NULL,
        ing_exp_adeudadas DECIMAL(7,2),
        ing_adelantado DECIMAL(7,2) NOT NULL,
        egresos DECIMAL(7,2) NOT NULL,
        saldo_cierre DECIMAL(7,2) NOT NULL,

        CONSTRAINT PK_EstadoFinanciero PRIMARY KEY (id_expensa),
        CONSTRAINT FK_Expensa_EstadoFinanciero FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa)
);END