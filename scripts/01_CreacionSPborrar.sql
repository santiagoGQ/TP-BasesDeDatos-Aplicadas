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

CREATE OR ALTER PROCEDURE adm.BorrarPropietario
	@id_prop INT
AS
BEGIN
	BEGIN TRY
		IF NOT EXISTS(SELECT 1 FROM adm.Propietario WHERE id_prop=@id_prop)
		BEGIN
			RAISERROR('No existe propietario con esa id.',16,1)
			RETURN
		END

		DELETE FROM adm.Propietario WHERE id_prop=@id_prop
	END TRY

	BEGIN CATCH
        PRINT('Error al eliminar propietario: ' + ERROR_MESSAGE())
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE adm.BorrarInquilino
	@id_inq INT
AS
BEGIN
	BEGIN TRY
		IF NOT EXISTS(SELECT 1 FROM adm.Inquilino WHERE id_inq=@id_inq)
		BEGIN
			RAISERROR('No existe inquilino con esa id.',16,1)
			RETURN
		END

		DELETE FROM adm.Inquilino WHERE id_inq=@id_inq
	END TRY

	BEGIN CATCH
        PRINT('Error al eliminar inquilino: ' + ERROR_MESSAGE());
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE adm.BorrarTipoServicioLimpieza
	@id_tipo_servlimpieza INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS(SELECT 1 FROM adm.TipoServicioLimpieza WHERE id_tipo_serv_limpieza = @id_tipo_servlimpieza)
		BEGIN
			RAISERROR('No existe tipo de servicio de limpieza con esa id',16,1)
			RETURN
		END
				                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
		DELETE FROM adm.TipoServicioLimpieza WHERE id_tipo_serv_limpieza = @id_tipo_servlimpieza

		RAISERROR('Tipo de servicio de limpieza eliminado correctamente',10,1)
	END TRY

	BEGIN CATCH
		DECLARE @errmsg NVARCHAR(4000) = ERROR_MESSAGE()
		RAISERROR('Error al eliminar tipo de servicio: %s', 16, 1 ,@errmsg)
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE adm.BorrarTipoServicioPublico
	@id_tipo_servpublico INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS(SELECT 1 FROM adm.TipoServicioPublico WHERE id_tipo_serv_publico = @id_tipo_servpublico)
		BEGIN
			RAISERROR('No existe tipo de servicio publico con esa id',16,1)
			RETURN
		END
				                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
		DELETE FROM adm.TipoServicioPublico WHERE id_tipo_serv_publico = @id_tipo_servpublico

		RAISERROR('Tipo de servicio publico eliminado correctamente',10,1)
	END TRY

	BEGIN CATCH
		DECLARE @errmsg NVARCHAR(4000) = ERROR_MESSAGE()
		RAISERROR('Error al eliminar tipo de servicio: %s', 16, 1 ,@errmsg)
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE adm.BorrarConsorcio
	@id_consorcio INT
AS
BEGIN
	--TODO: Borrado lógico o en cascada

END
GO

CREATE OR ALTER PROCEDURE adm.BorrarProveedor
	@id_proveedor INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS(SELECT 1 FROM adm.Proveedor WHERE id_proveedor = @id_proveedor)
		BEGIN
			RAISERROR('No existe proveedor con esa id',16,1)
			RETURN
		END
				                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
		DELETE FROM adm.Proveedor WHERE id_proveedor = @id_proveedor

		RAISERROR('Proveedor eliminado correctamente',10,1)
	END TRY

	BEGIN CATCH
		DECLARE @errmsg NVARCHAR(4000) = ERROR_MESSAGE()
		RAISERROR('Error al eliminar proveedor: %s', 16, 1 ,@errmsg)
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE adm.BorrarEnviadoA
	@id_expensa INT,
	@id_uni_func INT
AS
BEGIN
	SET NOCOUNT ON
	BEGIN TRY
		IF NOT EXISTS(SELECT 1 FROM adm.EnviadoA WHERE id_expensa = @id_expensa AND id_uni_func = @id_uni_func)
		BEGIN
			RAISERROR('No existe registro con esas id',16,1)
			RETURN
		END
				                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
		DELETE FROM adm.EnviadoA WHERE id_expensa = @id_expensa AND id_uni_func = @id_uni_func

		RAISERROR('Registro eliminado correctamente',10,1)
	END TRY

	BEGIN CATCH
		DECLARE @errmsg NVARCHAR(4000) = ERROR_MESSAGE()
		RAISERROR('Error al eliminar registro: %s', 16, 1 ,@errmsg)
	END CATCH
END
GO