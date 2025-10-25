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

CREATE OR ALTER PROCEDURE adm.AgregarTipoServicioLimpieza 
	@nombre VARCHAR(45)
AS
BEGIN
	INSERT INTO adm.TipoServicioLimpieza(nombre) values (@nombre)
END
GO

CREATE OR ALTER PROCEDURE adm.AgregarTipoServicioPublico 
	@nombre VARCHAR(45)
AS
BEGIN
	INSERT INTO adm.TipoServicioPublico(nombre) values (@nombre)
END
GO

CREATE OR ALTER PROCEDURE adm.AgregarProveedor
	@razon_social VARCHAR(45),
	@cuit CHAR(11),
	@email NVARCHAR(50),
	@telefono VARCHAR(10)
AS
BEGIN
	DECLARE @email_formateado NVARCHAR(50)
	SET @email_formateado = adm.QuitarEspaciosEmail(@email)

	INSERT INTO adm.Proveedor(razon_social, cuit, email, telefono) 
		values (@razon_social, @cuit, @email_formateado, @telefono)
END
GO


CREATE OR ALTER PROCEDURE adm.AgregarPropietario
	@nombre NVARCHAR(30),
	@apellido NVARCHAR(30),
	@dni INT,
	@email NVARCHAR(50),
	@telefono INT,
	@cbu CHAR(22)
AS
BEGIN
	DECLARE @nombre_formateado NVARCHAR(30) = adm.FormatearNombreOApellido(@nombre)
	DECLARE @apellido_formateado NVARCHAR(30) = adm.FormatearNombreOApellido(@apellido)
	DECLARE @email_formateado NVARCHAR(50) = adm.FormatearEmail(@email)

	INSERT INTO adm.Propietario(nombre, apellido, dni, email, telefono, cbu)
		VALUES(@nombre_formateado, @apellido_formateado, @dni, @email_formateado, @telefono, @cbu)
	
END
GO

CREATE OR ALTER PROCEDURE adm.AgregarInquilino
	@nombre NVARCHAR(30),
	@apellido NVARCHAR(30),
	@dni INT,
	@email NVARCHAR(50),
	@telefono INT,
	@cbu CHAR(22)
AS
BEGIN
	DECLARE @nombre_formateado NVARCHAR(30) = adm.FormatearNombreOApellido(@nombre)
	DECLARE @apellido_formateado NVARCHAR(30) = adm.FormatearNombreOApellido(@apellido)
	DECLARE @email_formateado NVARCHAR(50) = adm.FormatearEmail(@email)

	INSERT INTO adm.Inquilino(nombre, apellido, dni, email, telefono, cbu)
		VALUES(@nombre_formateado, @apellido_formateado, @dni, @email_formateado, @telefono, @cbu)
END
GO

-- TODO: Para hacer la modificacion de Inquilino o Propietario a traves del CSV podriamos usar SQL dinamico quizas.


CREATE OR ALTER PROCEDURE adm.AgregarConsorcio
	@nombre VARCHAR(25),
	@direccion VARCHAR(75),
	@metros_totales SMALLINT,
	@cantidad_de_pisos TINYINT,
	@precio_bauleraM2 DECIMAL(10,2),
	@id_tipo_serv_limpieza INT
AS
BEGIN
	DECLARE @cant_deptos TINYINT = @cantidad_de_pisos * 4 -- Cada piso de los consorcios va a tener 4 departamentos.

	INSERT INTO adm.Consorcio(nombre, direccion, metros_totales, cantidad_uf, precio_bauleraM2, id_tipo_serv_limpieza)
		VALUES (@nombre, @direccion, @metros_totales, @cant_deptos, @precio_bauleraM2, @id_tipo_serv_limpieza)

	-- TODO: Falta agregar un loop que vaya creando Unidades Funcionales leyendo la cantidad de @cant_deptos
	-- Si la cant de deptos es 12, entonces crea 12 unidades funcionales. Esto tiene que hacerse llamando a un SP.
	-- La idea es que una vez que creemos el consorcio, no quede solo, sino que tambien existan sus unidades funcionales asignadas.
	-- Esto creo que no deberia usarse para cuando leemos el CSV de unidades funcionales. Solo para cuando nosotros generemos datos.

END
GO

-- Falta terminar
--CREATE OR ALTER PROCEDURE adm.AgregarUnidadFuncional
--	@id_inq INT,
--	@id_prop INT,
--	@id_consorcio INT,
--	@total_m2 SMALLINT,
--	@depto VARCHAR(4),
--	@cbu CHAR(22),
--	@baulera_m2 TINYINT,
--	@cochera_m2 TINYINT
--AS
--BEGIN
--	
--END
--GO
