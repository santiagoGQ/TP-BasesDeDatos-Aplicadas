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

-- TODO: Para hacer la modificacion de Inquilino o Propietario podriamos usar SQL dinamico quizas.