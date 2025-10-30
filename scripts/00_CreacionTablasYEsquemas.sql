--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------


-----------CREACION DE LA BASE DE DATOS-----------

--Cambia a master
USE master
GO

--Eliminar la db
--En caso de que haya conexiones y/o transacciones abiertas ejecutar
--alter database COM2900_G04 set single_user with rollback immediate
DROP DATABASE IF EXISTS COM2900_G04;
GO 


--Crea la db
IF DB_ID('COM2900_G04') IS NULL
	CREATE DATABASE COM2900_G04 COLLATE Latin1_General_CI_AS; -- (Santi) TODO: creo que cambiaría a CS_AS
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

----------------CREACION DE TABLAS----------------
IF OBJECT_ID('adm.TipoServicioLimpieza') IS NULL
BEGIN
    CREATE TABLE adm.TipoServicioLimpieza(
        id_tipo_serv_limpieza INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(45) NOT NULL,

        CONSTRAINT PK_TipoServicioLimpieza PRIMARY KEY (id_tipo_serv_limpieza)
);END

IF OBJECT_ID('adm.TipoServicioPublico') IS NULL
BEGIN
    CREATE TABLE adm.TipoServicioPublico( 
        id_tipo_serv_publico INT IDENTITY(1,1) NOT NULL,
        nombre VARCHAR(45) NOT NULL,

        CONSTRAINT PK_TipoServicioPublico PRIMARY KEY (id_tipo_serv_publico)
);END

IF OBJECT_ID('adm.Consorcio') IS NULL
BEGIN
    CREATE TABLE adm.Consorcio(
        id_consorcio INT IDENTITY(1,1) NOT NULL,
        id_tipo_serv_limpieza INT,
        nombre VARCHAR(25) NOT NULL,
        direccion VARCHAR(75) NOT NULL,
        metros_totales SMALLINT NOT NULL,
        cantidad_uf TINYINT NOT NULL,
        precio_bauleraM2 DECIMAL(10,2) default 0,
        precio_cocheraM2 DECIMAL(10,2) default 0,
        
        CONSTRAINT PK_consorcio PRIMARY KEY (id_consorcio),
        CONSTRAINT FK_serv_limp_consorcio FOREIGN KEY (id_tipo_serv_limpieza) REFERENCES adm.TipoServicioLimpieza(id_tipo_serv_limpieza) ON DELETE SET NULL,
        CONSTRAINT CK_consorcio_M2 CHECK (metros_totales > 0),
        CONSTRAINT CK_consorcio_precioBaulera CHECK (precio_bauleraM2 >=0),
        CONSTRAINT CK_consorcio_precioCochera CHECK (precio_cocheraM2 >=0)

); END

IF OBJECT_ID('adm.Proveedor') IS NULL
BEGIN
    CREATE TABLE adm.Proveedor(
        id_proveedor INT IDENTITY(1,1) NOT NULL,
        razon_social NVARCHAR(51) NOT NULL,
        cuit CHAR(11) NOT NULL,
        motivo VARCHAR(30) NOT NULL,
        id_consorcio INT NOT NULL,
        cbu CHAR(22)

        CONSTRAINT PK_Proveedor PRIMARY KEY (id_proveedor),
        CONSTRAINT FK_ConsorcioProveedor FOREIGN KEY (id_consorcio) REFERENCES adm.Consorcio(id_consorcio),
        CONSTRAINT CK_MotivoProveedor CHECK (motivo in 
            ('GASTOS BANCARIOS','GASTOS DE ADMINISTRACION','SEGUROS','SERVICIOS PUBLICOS','GASTOS DE LIMPIEZA'))
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
        CONSTRAINT FK_Consorcio_Expensa FOREIGN KEY (id_consorcio) REFERENCES adm.Consorcio(id_consorcio),
        CONSTRAINT UQ_ExpensaDelMes UNIQUE (id_consorcio, fechaGenerado)
); END


IF OBJECT_ID('adm.Propietario') IS NULL
BEGIN
    CREATE TABLE adm.Propietario(
        id_prop INT IDENTITY(1,1),
        nombre NVARCHAR(30) NOT NULL,
        apellido NVARCHAR(30) NOT NULL,
        dni INT NOT NULL,
        email NVARCHAR(50) NOT NULL,
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
        email NVARCHAR(50) NOT NULL,
        telefono INT NOT NULL,
        cbu CHAR(22) NOT NULL,

        CONSTRAINT PK_Inquilino PRIMARY KEY (id_inq)
        
); END

IF OBJECT_ID('adm.UnidadFuncional') IS NULL
BEGIN
    CREATE TABLE adm.UnidadFuncional(
        id_uni_func INT IDENTITY(1,1),
        id_inq INT,
        id_prop INT,
        id_consorcio INT NOT NULL,
        total_m2 SMALLINT NOT NULL,
        piso VARCHAR(4) NOT NULL,
        depto VARCHAR(4) NOT NULL,
        coeficiente DECIMAL(3,2) NOT NULL,
        cbu CHAR(22),
        baulera_m2 TINYINT NOT NULL,
        cochera_m2 TINYINT NOT NULL

        CONSTRAINT PK_UnidadFuncional PRIMARY KEY (id_uni_func),
        CONSTRAINT FK_Inq_UnidadFuncional FOREIGN KEY (id_inq) REFERENCES adm.Inquilino(id_inq) ON DELETE SET NULL,
        CONSTRAINT FK_Prop_UnidadFuncional FOREIGN KEY (id_prop) REFERENCES adm.Propietario(id_prop) ON DELETE SET NULL,
        CONSTRAINT FK_Consorcio_UnidadFuncional FOREIGN KEY (id_consorcio) REFERENCES adm.Consorcio(id_consorcio),
        CONSTRAINT CK_UF_MayorCero CHECK (baulera_m2 >=0 AND cochera_m2 >=0),
        CONSTRAINT CK_UF_Superficie CHECK (baulera_m2+cochera_m2 <= total_m2),
        CONSTRAINT CK_UF_cbu CHECK (LEN(cbu)=22 AND cbu NOT LIKE '%[^0-9]%'),
        CONSTRAINT UQ_UF_ConsorcioDepto UNIQUE (id_consorcio, piso, depto)

); END


IF OBJECT_ID('fin.Factura') IS NULL
BEGIN
    CREATE TABLE fin.Factura(
        id_factura INT IDENTITY(1,1) NOT NULL,
        id_proveedor INT,
        nro_Factura VARCHAR(15) NOT NULL,
        fecha_Emision DATETIME NOT NULL,
        importe DECIMAL(10,2) NOT NULL,

        CONSTRAINT PK_Factura PRIMARY KEY (id_factura),
        CONSTRAINT FK_Proveedor_Factura FOREIGN KEY (id_proveedor) REFERENCES adm.Proveedor(id_proveedor) ON DELETE SET NULL,
        CONSTRAINT CK_Factura_Importe CHECK (importe>=0),
        CONSTRAINT UQ_Factura_nro UNIQUE (nro_factura)
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

IF OBJECT_ID('gasto.ServicioPublico') IS NULL
BEGIN
    CREATE TABLE gasto.ServicioPublico(
        id_serv_pub INT IDENTITY(1,1) NOT NULL,
        id_expensa INT NOT NULL,
        id_factura INT NOT NULL,
        id_tipo_serv_publico INT,
        descripcion varchar(100),

        CONSTRAINT PK_GastoServicioPublico PRIMARY KEY (id_expensa, id_serv_pub),
        CONSTRAINT FK_Expensa_GastoServicioPublico FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa),
        CONSTRAINT FK_Factura_GastoServicioPublico FOREIGN KEY (id_factura) REFERENCES fin.Factura(id_factura),
        CONSTRAINT FK_TipoServPub_GastoServicioPublico FOREIGN KEY (id_tipo_serv_publico) REFERENCES adm.TipoServicioPublico(id_tipo_serv_publico) ON DELETE SET NULL
);END

IF OBJECT_ID('gasto.General') IS NULL
BEGIN
    CREATE TABLE gasto.General(
        id_gasto_general INT IDENTITY(1,1) NOT NULL,
        id_expensa INT NOT NULL,
        id_factura INT NOT NULL,
        descripcion varchar(100),

        CONSTRAINT PK_GastoGeneral PRIMARY KEY (id_expensa, id_gasto_general),
        CONSTRAINT FK_Expensa_GastoGeneral FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa),
        CONSTRAINT FK_Factura_GastoGeneral FOREIGN KEY (id_factura) REFERENCES fin.Factura(id_factura)
);END

IF OBJECT_ID('gasto.Extraordinario') IS NULL
BEGIN
    CREATE TABLE gasto.Extraordinario(
        id_extraordinario INT IDENTITY(1,1) NOT NULL,
        id_expensa INT NOT NULL,
        id_factura INT NOT NULL,
        descripcion varchar(100),
        nro_cuota TINYINT,
        total_cuotas TINYINT,

        CONSTRAINT PK_GastoExtraordinario PRIMARY KEY (id_expensa, id_extraordinario),
        CONSTRAINT FK_Expensa_GastoExtraordinario FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa),
        CONSTRAINT FK_Factura_GastoExtraordinario FOREIGN KEY (id_factura) REFERENCES fin.Factura(id_factura),
        CONSTRAINT CK_Extraordinario_Cuotas CHECK(nro_cuota<=total_cuotas)
);END

IF OBJECT_ID('gasto.Bancario') IS NULL
BEGIN
    CREATE TABLE gasto.Bancario(
        id_bancario INT IDENTITY(1,1) NOT NULL,
        id_expensa INT NOT NULL,
        id_factura INT NOT NULL,
        descripcion varchar(100),

        CONSTRAINT PK_GastoBancario PRIMARY KEY (id_expensa, id_bancario),
        CONSTRAINT FK_Expensa_GastoBancario FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa),
        CONSTRAINT FK_Factura_GastoBancario FOREIGN KEY (id_factura) REFERENCES fin.Factura(id_factura)
);END

IF OBJECT_ID('fin.ResumenBancarioCSV') IS NULL
BEGIN
    CREATE TABLE fin.ResumenBancarioCSV(
        id_expensa INT NOT NULL,
        fechaCreado DATETIME

        CONSTRAINT PK_ResumenCSV PRIMARY KEY (id_expensa),
        CONSTRAINT FK_Expensa_ResumenCSV FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa)
);END

IF OBJECT_ID('adm.EnviadoA') IS NULL
BEGIN
    CREATE TABLE adm.EnviadoA(
        id_expensa INT NOT NULL,
        id_uni_func INT NOT NULL,
        medio_Comunicacion_Prop VARCHAR(9) NOT NULL,
        medio_Comunicacion_Inq VARCHAR(9) NOT NULL,
    
        CONSTRAINT PK_EnviadoA PRIMARY KEY (id_expensa, id_uni_func),
        CONSTRAINT FK_UF_EnviadoA FOREIGN KEY (id_uni_func) REFERENCES adm.UnidadFuncional(id_uni_func),
        CONSTRAINT FK_Expensa_EnviadoA FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa),
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
        CONSTRAINT FK_UniFunc_Pago FOREIGN KEY (id_uni_func) REFERENCES adm.UnidadFuncional(id_uni_func),
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
        CONSTRAINT FK_Expensa_EstadoFinanciero FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa),
        CONSTRAINT CK_EstadoFinancieroMayorCero CHECK (ing_en_termino>=0 AND ing_exp_adeudadas>=0 AND ing_adelantado>=0 AND egresos>=0 AND saldo_cierre>=0)
);END

IF OBJECT_ID('fin.EstadoDeCuenta') IS NULL
BEGIN
    CREATE TABLE fin.EstadoDeCuenta(
        id_expensa INT NOT NULL,
        id_est_de_cuenta INT IDENTITY(1,1) NOT NULL,
        id_uni_func INT NOT NULL,
        prorateo DECIMAL(2,2) NOT NULL,
        depto VARCHAR(4) NOT NULL,
        cochera DECIMAL(7,2),
        baulera DECIMAL(7,2),
        nom_y_ap_propietario VARCHAR(50) NOT NULL,
        saldo_ant_abonado DECIMAL(7,2),
        pago_recibido DECIMAL(7,2),
        deuda DECIMAL(7,2),
        interes_mora DECIMAL(7,2),
        expensas_ordinarias DECIMAL(7,2) NOT NULL,
        expensas_extraordinarias DECIMAL(7,2),
        total_a_pagar DECIMAL(7,2) NOT NULL,

        CONSTRAINT PK_EstadoDeCuenta PRIMARY KEY (id_expensa, id_est_de_cuenta),
        CONSTRAINT FK_Expensa_EstadoDeCuenta FOREIGN KEY (id_expensa) REFERENCES adm.Expensa(id_expensa),
        CONSTRAINT FK_UF_EstadoDeCuenta FOREIGN KEY (id_uni_func) REFERENCES adm.UnidadFuncional(id_uni_func),
        --creo que hay que agregar constraint >=0 a casi todo
);END