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

-------------- ADM --------------

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

-- Falta SP nuevo de agregar proveedor

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

	BEGIN TRY 
	-- Si el propietario existe, lo actualizamos
	IF EXISTS (SELECT 1 from adm.Propietario Prop where Prop.dni = @dni)
		UPDATE adm.Propietario
        SET nombre = @nombre,
            apellido = @apellido,
            email = @email,
            telefono = @telefono,
            cbu = @cbu
        WHERE DNI = @dni;
	ELSE
		INSERT INTO adm.Propietario(nombre, apellido, dni, email, telefono, cbu)
			VALUES(@nombre_formateado, @apellido_formateado, @dni, @email_formateado, @telefono, @cbu)
	END TRY

	BEGIN CATCH
		PRINT 'Ocurrió un error al agregar un propietario.';
		PRINT 'Mensaje: ' + ERROR_MESSAGE();
	END CATCH
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

	BEGIN TRY
	-- Si el inquilino existe, lo actualizamos
	IF EXISTS (SELECT 1 from adm.Inquilino Inq where Inq.dni = @dni)
		UPDATE adm.Inquilino
        SET nombre = @nombre,
            apellido = @apellido,
            email = @email,
            telefono = @telefono,
            cbu = @cbu
        WHERE DNI = @dni;
	ELSE
		INSERT INTO adm.Inquilino(nombre, apellido, dni, email, telefono, cbu)
			VALUES(@nombre_formateado, @apellido_formateado, @dni, @email_formateado, @telefono, @cbu)
	END TRY
	BEGIN CATCH
		PRINT 'Ocurrió un error al agregar un inquilino.';
		PRINT 'Mensaje: ' + ERROR_MESSAGE();
	END CATCH
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
		PRINT('Error al agregar: ' + ERROR_MESSAGE())
	END CATCH
END
GO

-------------- GASTO --------------
-- TODO: Creo que se puede hacer con SQL Dinamico toda esta parte. El SP es el mismo, solo cambia 
--		 el nombre de la tabla. Salvo el gasto de limpieza y el extraordinario

CREATE OR ALTER PROCEDURE gasto.AgregarGastoAdministracion
	@id_consorcio INT,
	@id_expensa INT,
	@importe DECIMAL(18,2),
	@fecha_expensa DATE,
	@descripcion VARCHAR(100)
AS
BEGIN
	DECLARE @nro_factura INT
	DECLARE @fecha_factura DATE = DATEADD(DAY, -8, @fecha_expensa) -- Como no hay fecha de gastos, lo ponemos en algun momento durante el mes
	DECLARE @id_proveedor INT = (SELECT id_proveedor FROM adm.Proveedor where id_consorcio = @id_consorcio AND motivo = 'GASTOS DE ADMINISTRACION')
	EXEC fin.AgregarFactura 
		@id_proveedor, 
		@fecha_factura,
		@importe,
		@nro_factura OUTPUT

	INSERT INTO gasto.Administracion(id_expensa, nro_factura, descripcion)
		VALUES (@id_expensa, @nro_factura, @descripcion)
END
GO

CREATE OR ALTER PROCEDURE gasto.AgregarGastoBancario
	@id_consorcio INT,
	@id_expensa INT,
	@importe DECIMAL(18,2),
	@fecha_expensa DATE,
	@descripcion VARCHAR(100)
AS
BEGIN
	
	DECLARE @nro_factura INT
	DECLARE @fecha_factura DATE = DATEADD(DAY, -8, @fecha_expensa) -- Como no hay fecha de gastos, lo ponemos en algun momento durante el mes
	DECLARE @id_proveedor INT = (SELECT id_proveedor FROM adm.Proveedor where id_consorcio = @id_consorcio AND motivo = 'GASTOS BANCARIOS')
	EXEC fin.AgregarFactura 
		@id_proveedor, 
		@fecha_factura,
		@importe,
		@nro_factura OUTPUT
	

	INSERT INTO gasto.Bancario(id_expensa, nro_factura, descripcion)
		VALUES (@id_expensa, @nro_factura, @descripcion)
END
GO

-- TODO: Revisar este SP
CREATE OR ALTER PROCEDURE gasto.AgregarGastoExtraordinario
	@id_expensa INT,
	@nro_factura INT,
	@descripcion VARCHAR(100),
	@nro_cuota TINYINT,
	@total_cuotas TINYINT
AS
BEGIN
	INSERT INTO gasto.Extraordinario(id_expensa, nro_factura, descripcion, nro_cuota, total_cuotas)
		VALUES (@id_expensa, @nro_factura, @descripcion, @nro_cuota, @total_cuotas)
END
GO

-- TODO Revisar este SP tambien. Siempre va a tener proveedor NULL cuando importamos los gastos. El json viene sin gastos generales.
CREATE OR ALTER PROCEDURE gasto.AgregarGastoGeneral
	@id_consorcio INT,
	@id_expensa INT,
	@importe DECIMAL(18,2),
	@fecha_expensa DATE,
	@descripcion VARCHAR(100)
AS
BEGIN
	
	DECLARE @nro_factura INT
	DECLARE @fecha_factura DATE = DATEADD(DAY, -8, @fecha_expensa) -- Como no hay fecha de gastos, lo ponemos en algun momento durante el mes
	DECLARE @id_proveedor INT = (SELECT id_proveedor FROM adm.Proveedor where id_consorcio = @id_consorcio AND motivo = 'GASTOS GENERAL')
	EXEC fin.AgregarFactura 
		@id_proveedor, 
		@fecha_factura,
		@importe,
		@nro_factura OUTPUT

	INSERT INTO gasto.General(id_expensa, nro_factura, descripcion)
		VALUES (@id_expensa, @nro_factura, @descripcion)
END
GO

CREATE OR ALTER PROCEDURE gasto.AgregarGastoLimpieza
	@id_consorcio INT,
	@id_expensa INT,
	@importe DECIMAL(18,2),
	@fecha_expensa DATE,
	@descripcion VARCHAR(100)
AS
BEGIN
	DECLARE @nro_factura INT
	DECLARE @fecha_factura DATE = DATEADD(DAY, -8, @fecha_expensa) -- Como no hay fecha de gastos, lo ponemos en algun momento durante el mes
	DECLARE @id_proveedor INT = (SELECT id_proveedor FROM adm.Proveedor where id_consorcio = @id_consorcio AND motivo = 'GASTOS DE LIMPIEZA')
	EXEC fin.AgregarFactura 
		@id_proveedor, 
		@fecha_factura,
		@importe,
		@nro_factura OUTPUT

	INSERT INTO gasto.Limpieza(id_expensa, nro_factura, descripcion)
		VALUES (@id_expensa, @nro_factura, @descripcion)
END
GO

CREATE OR ALTER PROCEDURE gasto.AgregarGastoSeguro
	@id_consorcio INT,
	@id_expensa INT,
	@importe DECIMAL(18,2),
	@fecha_expensa DATE,
	@descripcion VARCHAR(100)
AS
BEGIN
	DECLARE @nro_factura INT
	DECLARE @fecha_factura DATE = DATEADD(DAY, -8, @fecha_expensa) -- Como no hay fecha de gastos, lo ponemos en algun momento durante el mes
	DECLARE @id_proveedor INT = (SELECT id_proveedor FROM adm.Proveedor where id_consorcio = @id_consorcio AND motivo = 'SEGUROS')
	EXEC fin.AgregarFactura 
		@id_proveedor, 
		@fecha_factura,
		@importe,
		@nro_factura OUTPUT
	
	INSERT INTO gasto.Seguro(id_expensa, nro_factura, descripcion)
		VALUES (@id_expensa, @nro_factura, @descripcion)
END
GO

CREATE OR ALTER PROCEDURE gasto.AgregarGastoServicioPublico
	@id_consorcio INT,
	@id_expensa INT,
	@importe DECIMAL(18,2),
	@fecha_expensa DATE,
	@descripcion VARCHAR(100)
AS
BEGIN
	DECLARE @nro_factura INT
	DECLARE @fecha_factura DATE = DATEADD(DAY, -8, @fecha_expensa) -- Como no hay fecha de gastos, lo ponemos en algun momento durante el mes
	DECLARE @id_proveedor INT = (SELECT 1 id_proveedor FROM adm.Proveedor where id_consorcio = @id_consorcio AND motivo = 'SERVICIOS PUBLICOS' AND razon_social LIKE @descripcion)
	EXEC fin.AgregarFactura 
		@id_proveedor, 
		@fecha_factura,
		@importe,
		@nro_factura OUTPUT
	
	INSERT INTO gasto.ServicioPublico(id_expensa, nro_factura, descripcion)
		VALUES (@id_expensa, @nro_factura, @descripcion)
END
GO

-------------- FIN --------------

CREATE OR ALTER PROCEDURE fin.AgregarPago
	@id_resumen INT,
	@id_uni_func INT,
	@fecha DATETIME,
	@cuenta_origen CHAR(22),
	@monto DECIMAL(7,2)
AS
BEGIN
	INSERT INTO fin.Pago(id_resumen, id_uni_func, fecha, cuenta_origen, monto)
		VALUES (@id_resumen, @id_uni_func, @fecha, @cuenta_origen, @monto)
END
GO

-- Generar Estado Financiero
-- Leer Resumen Bancario
-- Generar Estado de Cuenta

CREATE OR ALTER PROCEDURE adm.AgregarExpensa
	@id_consorcio INT, 
	@mes VARCHAR(20),
	@id_expensa INT OUTPUT

AS
BEGIN
	BEGIN TRY
		
		IF NOT EXISTS(SELECT TOP 1 * FROM adm.Consorcio WHERE id_consorcio=@id_consorcio)
		BEGIN
			RAISERROR('No existe consorcio con ese id.',16,1)
			RETURN
		END
		DECLARE @fecha_expensa DATE = DATEADD(DAY, -1, adm.ObtenerPrimerDiaDelMes(@mes)) -- Expensa al dia siguiente al ultimo dia del mes que acaba de terminar. Si la expensa es de Agosto, entonces la fecha de la expensa es al 01/9.
		DECLARE @primer_vencimiento DATE = DATEADD(DAY, 5, @fecha_expensa) -- Primer vencimiento al 5
		DECLARE @segundo_vencimiento DATE = DATEADD(DAY, 5, @primer_vencimiento) -- Primer vencimiento al 10

		INSERT INTO adm.Expensa(id_consorcio,fechaGenerado,fechaPrimerVenc,fechaSegVenc)
			VALUES (@id_consorcio, @fecha_expensa, @primer_vencimiento, @segundo_vencimiento)
		SET @id_expensa = SCOPE_IDENTITY();

	END TRY
	BEGIN CATCH
		PRINT('Error al agregar la expensa: ' + ERROR_MESSAGE())
	END CATCH
END
GO
--------------------------ESQUEMA FINANZAS--------------------------
CREATE OR ALTER PROCEDURE fin.AgregarFactura
    @id_proveedor INT,
	@fecha_emision DATE,
	@importe DECIMAL(18,2),
	@nro_factura INT OUTPUT
AS
BEGIN
	BEGIN TRY

		INSERT INTO fin.Factura (id_proveedor, fecha_emision, importe)
			VALUES (@id_proveedor, @fecha_emision, @importe)
		SET @nro_factura = SCOPE_IDENTITY()
	END TRY
	BEGIN CATCH
		PRINT('Error al agregar la factura: ' + ERROR_MESSAGE())
	END CATCH
END
GO

CREATE OR ALTER PROCEDURE fin.AgregarPago
    @id_resumen INT,@id_uni_func INT=NULL,
	@fecha DATETIME,@cuenta_origen CHAR(22),@monto DECIMAL(7,2)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM fin.ResumenBancarioCSV WHERE id_expensa=@id_resumen)
        BEGIN
            RAISERROR('No existe resumen bancario con ese id.', 16, 1)
            RETURN
        END

        IF @id_uni_func IS NOT NULL AND NOT EXISTS (SELECT 1 FROM adm.UnidadFuncional WHERE id_uni_func=@id_uni_func)
        BEGIN
            RAISERROR('No existe unidad funcional con ese id.', 16, 1)
            RETURN
        END

        IF @fecha > GETDATE()
        BEGIN
            RAISERROR('La fecha del pago no puede ser posterior a la actual.', 16, 1)
            RETURN
        END

        INSERT INTO fin.Pago (id_resumen, id_uni_func, fecha, cuenta_origen, monto)
        VALUES (@id_resumen, @id_uni_func, @fecha, @cuenta_origen, @monto)

    END TRY
    BEGIN CATCH
        PRINT('Error al registrar el pago: ' + ERROR_MESSAGE())
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE fin.AgregarEstadoFinanciero
    @id_expensa INT,
    @ing_en_termino DECIMAL(7,2),
    @ing_exp_adeudadas DECIMAL(7,2),
    @ing_adelantado DECIMAL(7,2),
    @egresos DECIMAL(7,2),
    @saldo_cierre DECIMAL(7,2)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM adm.Expensa WHERE id_expensa=@id_expensa)
        BEGIN
            RAISERROR('No existe expensa con ese id.', 16, 1)
            RETURN
        END

        IF EXISTS (SELECT 1 FROM fin.EstadoFinanciero WHERE id_expensa=@id_expensa)
        BEGIN
            RAISERROR('Ya existe un estado financiero para la expesna.', 16, 1)
            RETURN
        END

        IF @saldo_cierre < 0
        BEGIN
            RAISERROR('El saldo de cierre no puede ser negativo.', 16, 1)
            RETURN
        END

        INSERT INTO fin.EstadoFinanciero (id_expensa, ing_en_termino, ing_exp_adeudadas, ing_adelantado, egresos, saldo_cierre)
        VALUES (@id_expensa, @ing_en_termino, @ing_exp_adeudadas, @ing_adelantado, @egresos, @saldo_cierre)

    END TRY
    BEGIN CATCH
        PRINT('Error al agregar estado financiero: ' + ERROR_MESSAGE())
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE fin.AgregarEstadoDeCuenta
    @id_expensa INT,@id_uni_func INT,@prorateo DECIMAL(4,2),@depto VARCHAR(4),
    @cochera DECIMAL(7,2),@baulera DECIMAL(7,2),@nom_y_ap_propietario VARCHAR(50),
    @saldo_ant_abonado DECIMAL(7,2),@pago_recibido DECIMAL(7,2),@deuda DECIMAL(7,2),
    @interes_mora DECIMAL(7,2),@expensas_ordinarias DECIMAL(7,2),
	@expensas_extraordinarias DECIMAL(7,2),@total_a_pagar DECIMAL(7,2)
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM adm.Expensa WHERE id_expensa = @id_expensa)
        BEGIN
            RAISERROR('No existe expensa con ese id.', 16, 1)
            RETURN
        END

        IF NOT EXISTS (SELECT 1 FROM adm.UnidadFuncional WHERE id_uni_func = @id_uni_func)
        BEGIN
            RAISERROR('No existe unidad funcional con ese id.', 16, 1)
            RETURN
        END

        IF @total_a_pagar < 0
        BEGIN
            RAISERROR('El total a pagar no puede ser negativo.', 16, 1)
            RETURN
        END

        INSERT INTO fin.EstadoDeCuenta (
            id_expensa, id_uni_func, prorateo, depto, cochera, baulera,
            nom_y_ap_propietario, saldo_ant_abonado, pago_recibido, deuda,
            interes_mora, expensas_ordinarias, expensas_extraordinarias, total_a_pagar)
        VALUES (
            @id_expensa, @id_uni_func, @prorateo, @depto, @cochera, @baulera,
            @nom_y_ap_propietario, @saldo_ant_abonado, @pago_recibido, @deuda,
            @interes_mora, @expensas_ordinarias, @expensas_extraordinarias, @total_a_pagar)

    END TRY
    BEGIN CATCH
        PRINT('Error al agregar el estado de cuenta: ' + ERROR_MESSAGE())
    END CATCH
END
GO
