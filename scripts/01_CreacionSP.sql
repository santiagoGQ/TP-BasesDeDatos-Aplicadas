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
	SET @email_formateado = adm.fn_QuitarEspaciosEmail(@email)

	INSERT INTO adm.Proveedor(razon_social, cuit, email, telefono) 
		values (@razon_social, @cuit, @email_formateado, @telefono)
END
GO

