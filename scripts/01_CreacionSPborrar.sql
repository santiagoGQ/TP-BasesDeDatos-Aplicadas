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

CREATE OR ALTER PROCEDURE adm.BorrarTipoServicioLimpieza
	@id_tipo_servlimpieza INT
AS
BEGIN
	SET NOCOUNT ON

	IF NOT EXISTS(SELECT 1 FROM adm.TipoServicioLimpieza WHERE id_tipo_serv_limpieza = @id_tipo_servlimpieza)
	BEGIN
		RAISERROR('No existe el tipo servicio de limpieza',16,1)
		RETURN
	END

	BEGIN TRY
		BEGIN TRANSACTION

			UPDATE adm.Consorcio
			SET id_tipo_serv_limpieza = NULL
			WHERE id_tipo_serv_limpieza = @id_tipo_servlimpieza
				                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
			DELETE 
			FROM adm.TipoServicioLimpieza 
			WHERE id_tipo_serv_limpieza = @id_tipo_servlimpieza

			COMMIT TRANSACTION

			RAISERROR('Tipo de servicio de limpieza eliminado correctamente',10,1)
	END TRY

	BEGIN CATCH
		IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
		RAISERROR('Error al eliminar tipo de servicio', 16, 1);
		RETURN;
	END CATCH
END
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