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

	IF @metros_totales <= 0
	BEGIN
		RAISERROR('Los metros totales deben ser mayores a 0.', 16, 1);
		RETURN;
	END;

	IF @cantidad_de_pisos <= 0
	BEGIN
		RAISERROR('La cantidad de pisos debe ser mayor a 0.', 16, 1);
		RETURN;
	END;

	IF NOT EXISTS (SELECT 1 FROM adm.TipoServicioLimpieza WHERE id_tipo_serv_limpieza = @id_tipo_serv_limpieza)
	BEGIN
		RAISERROR('El tipo de servicio de limpieza indicado no existe.', 16, 1);
		RETURN;
	END;

	DECLARE @id_consorcio INT
	DECLARE @i INT = 1
	DECLARE @cant_deptos TINYINT = @cantidad_de_pisos * 4 -- Cada piso de los consorcios va a tener 4 departamentos.

	INSERT INTO adm.Consorcio(nombre, direccion, metros_totales, cantidad_uf, precio_bauleraM2, id_tipo_serv_limpieza)
		VALUES (@nombre, @direccion, @metros_totales, @cant_deptos, @precio_bauleraM2, @id_tipo_serv_limpieza)
	
	SET @id_consorcio=SCOPE_IDENTITY() --obtiene el valor del ultimo identity generado

	--generacion de unidades funcionales en el consorcio agregado
	WHILE @i<=@cant_deptos
	BEGIN
		DECLARE @piso INT, @letra CHAR(1), @total_m2 SMALLINT, @baulera_m2 TINYINT, @cochera_m2 TINYINT

		--valor con variacion del +-10%
        DECLARE @valor DECIMAL(4,2)=(0.9+RAND()*0.2)

		--genera cbu aleatorio de longitud 22
			--genera numero y lo castea como cadena, luego
			--right(cadena,m) agarra los m caracteres de la derecha
		DECLARE @cbu CHAR(22) = RIGHT('0000000000000000000000'+CAST(ABS(CHECKSUM(NEWID())) as VARCHAR(22)),22)

		SELECT
			@piso = tf.piso,
			@letra = tf.letra,
			@total_m2 = tf.total_m2,
			@cbu = tf.cbu,
			@baulera_m2 = tf.baulera_m2,
			@cochera_m2 = tf.cochera_m2
		FROM adm.GenerarDatosUF(@i,@cantidad_de_pisos,@metros_totales,@valor,@cbu) AS tf

		INSERT INTO adm.UnidadFuncional
			(id_consorcio, id_inq, id_prop, total_m2, depto, cbu, baulera_m2, cochera_m2)
			VALUES
				(@id_consorcio, NULL, NULL, @total_m2, CONCAT(@piso, @letra), @cbu, @baulera_m2, @cochera_m2);
		SET @i=@i+1
	END
	-- La idea es que una vez que creemos el consorcio, no quede solo, sino que tambien existan sus unidades funcionales asignadas.
	-- Esto creo que no deberia usarse para cuando leemos el CSV de unidades funcionales. Solo para cuando nosotros generemos datos.
END
GO

CREATE OR ALTER PROCEDURE adm.AgregarUnidadFuncional
	@id_inq INT,
	@id_prop INT,
	@id_consorcio INT,
	@total_m2 SMALLINT,
	@depto VARCHAR(4),
	@cbu CHAR(22),
	@baulera_m2 TINYINT,
	@cochera_m2 TINYINT
AS
BEGIN
	BEGIN TRY
		--validar existencia de consorcio
		IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE id_consorcio=@id_consorcio)
		BEGIN
			RAISERROR('No existe consorcio con ese id.',16,1)
			RETURN
		END
		--validar existencia de propietario
		IF NOT EXISTS (SELECT 1 FROM adm.Propietario WHERE id_prop=@id_prop)
		BEGIN
			RAISERROR('No existe propietario con ese id.',16,1)
			RETURN
		END
		--validar existencia de inquilino
		IF NOT EXISTS (SELECT 1 FROM adm.Inquilino WHERE id_inq=@id_inq)
		BEGIN
			RAISERROR('No existe inquilino con ese id',16,1)
			RETURN
		END

		INSERT INTO adm.UnidadFuncional (id_consorcio,id_inq,id_prop,total_m2,depto,cbu,baulera_m2,cochera_m2)
			VALUES (@id_consorcio,@id_inq,@id_prop,@total_m2,@depto,@cbu,@baulera_m2,@cochera_m2)
	END TRY
	BEGIN CATCH
		PRINT('Error al agregar la unidad funcional: ' + ERROR_MESSAGE())
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE adm.AgregarEnviadoA
	@expensa INT,
	@unidad_funcional INT,
	@medio_prop VARCHAR(9),
	@medio_inq VARCHAR(9)
AS
BEGIN
	BEGIN TRY
		--validar existencia de expensa
		IF NOT EXISTS (SELECT 1 FROM adm.Expensa WHERE id_expensa=@expensa)
		BEGIN
			RAISERROR('No existe expensa con ese id.',16,1)
			RETURN
		END
		--validar existencia de unidad funcional
		IF NOT EXISTS(SELECT 1 FROM adm.UnidadFuncional WHERE id_uni_func=@unidad_funcional)
		BEGIN
			RAISERROR('No existe unidad funcional con ese id.',16,1)
			RETURN
		END
		--validar medios de envio

		SET @medio_inq=UPPER(@medio_inq)
		SET @medio_prop=UPPER(@medio_prop)

		IF @medio_inq NOT IN ('EMAIL','TELEFONO','IMPRESO')
		BEGIN
			RAISERROR('Medio de envio del inquilino invalido.',16,1)
			RETURN
		END
		
		IF @medio_prop NOT IN ('EMAIL','TELEFONO','IMPRESO')
		BEGIN
			RAISERROR('Medio de envio del propietario invalido.',16,1)
			RETURN
		END

		INSERT INTO adm.EnviadoA(id_expensa,id_uni_func,medio_Comunicacion_Inq,medio_Comunicacion_Prop)
			VALUES (@expensa,@unidad_funcional,@medio_inq,@medio_prop)
	END TRY
	BEGIN CATCH
		PRINT('Error al agregar la unidad funcional: ' + ERROR_MESSAGE())
	END CATCH
END
GO