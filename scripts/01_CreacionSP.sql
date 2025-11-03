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

CREATE OR ALTER PROCEDURE adm.AgregarConsorcio
	@nombre VARCHAR(25),
	@direccion VARCHAR(75),
	@metros_totales SMALLINT,
	@cantidad_de_deptos TINYINT,
	@precio_bauleraM2 DECIMAL(10,2),
	@precio_cocheraM2 DECIMAL(10,2),
	@id_tipo_serv_limpieza INT
AS
BEGIN
    BEGIN TRANSACTION
	BEGIN TRY
		IF @metros_totales <= 0
		BEGIN
			RAISERROR('Los metros totales deben ser mayores a 0.', 16, 1);
			RETURN;
		END;

		IF @cantidad_de_deptos <= 0
		BEGIN
			RAISERROR('La cantidad de departamentos debe ser mayor a 0.', 16, 1);
			RETURN;
		END;

		IF NOT EXISTS (SELECT 1 FROM adm.TipoServicioLimpieza WHERE id_tipo_serv_limpieza = @id_tipo_serv_limpieza)
		BEGIN
			RAISERROR('El tipo de servicio de limpieza indicado no existe.', 16, 1);
			RETURN;
		END;

		DECLARE @id_consorcio INT
		DECLARE @i INT = 1

		INSERT INTO adm.Consorcio(nombre, direccion, metros_totales, cantidad_uf, precio_bauleraM2, precio_cocheraM2, id_tipo_serv_limpieza)
			VALUES (@nombre, @direccion, @metros_totales, @cantidad_de_deptos, @precio_bauleraM2, @precio_cocheraM2, @id_tipo_serv_limpieza)
	
	COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		PRINT 'Ocurrio un error al generar el consorcio.';
		PRINT 'Mensaje: ' + ERROR_MESSAGE();
	END CATCH
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

CREATE OR ALTER PROCEDURE adm.AgregarProveedor
	@razon_social NVARCHAR(51),
    @motivo VARCHAR(30),
    @id_consorcio INT,
    @cuenta VARCHAR(50),
	@id_proveedor INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		
		--Validar existencia de consorcio
		IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE id_consorcio = @id_consorcio)
        BEGIN
            RAISERROR('El consorcio indicado no existe.', 16, 1)
            RETURN
        END

		--Validar que razon social no esté vacío
		IF LEN(LTRIM(RTRIM(@razon_social))) = 0
        BEGIN
            RAISERROR('La razón social no puede estar vacía.', 16, 1)
            RETURN
        END

		--Normalizar motivo
		SET @motivo = UPPER(RTRIM(LTRIM(@motivo)))

		--Validar que no existe proveedor con esa razon social para ese consorcio
		 IF EXISTS (
            SELECT 1 FROM adm.Proveedor 
            WHERE LTRIM(RTRIM(LOWER(razon_social))) = LTRIM(RTRIM(LOWER(@razon_social)))
              AND id_consorcio = @id_consorcio
        )
        BEGIN
            RAISERROR('Ya existe un proveedor con esa razón social para este consorcio.', 16, 1);
            RETURN
        END

		INSERT INTO adm.Proveedor(razon_social,motivo,id_consorcio,cuenta)
		VALUES (@razon_social,@motivo,@id_consorcio,@cuenta)

		SET @id_proveedor = SCOPE_IDENTITY()

	END TRY
	BEGIN CATCH
		PRINT('Error al agregar proveedor: ' + ERROR_MESSAGE())
	END CATCH
END
GO

-------------- GASTO --------------
-- TODO: Creo que se puede hacer con SQL Dinamico toda esta parte. El SP es el mismo, solo cambia 
--		 el nombre de la tabla. Salvo el gasto de limpieza y el extraordinario

CREATE OR ALTER PROCEDURE gasto.AgregarGastoAdministracion
	@id_consorcio INT,
	@id_expensa INT,
	@importe DECIMAL(10,2),
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
	@importe DECIMAL(10,2),
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
	@importe DECIMAL(10,2),
	@fecha_expensa DATE,
	@descripcion VARCHAR(100),
	@nro_cuota TINYINT,
	@total_cuotas TINYINT
AS
BEGIN
	DECLARE @nro_factura INT
	DECLARE @fecha_factura DATE = DATEADD(DAY, -8, @fecha_expensa) -- Como no hay fecha de gastos, lo ponemos en algun momento durante el mes
	DECLARE @id_proveedor INT
	EXEC fin.AgregarFactura 
		@id_proveedor, 
		@fecha_factura,
		@importe,
		@nro_factura OUTPUT

	INSERT INTO gasto.Extraordinario(id_expensa, nro_factura, descripcion, nro_cuota, total_cuotas)
		VALUES (@id_expensa, @nro_factura, @descripcion, @nro_cuota, @total_cuotas)
END
GO

-- TODO Revisar este SP tambien. Siempre va a tener proveedor NULL cuando importamos los gastos. El json viene sin gastos generales.
CREATE OR ALTER PROCEDURE gasto.AgregarGastoGeneral
	@id_consorcio INT,
	@id_expensa INT,
	@importe DECIMAL(10,2),
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
	@importe DECIMAL(10,2),
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
	@importe DECIMAL(10,2),
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
	@importe DECIMAL(10,2),
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
	@id_uni_func INT,
	@fecha DATE,
	@cuenta_origen CHAR(22),
	@monto DECIMAL(10,2)
AS
BEGIN
	INSERT INTO fin.Pago(id_uni_func, fecha, cbu_cvu, monto)
		VALUES (@id_uni_func, @fecha, @cuenta_origen, @monto)
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
	@importe DECIMAL(10,2),
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

CREATE OR ALTER PROCEDURE fin.AgregarEstadoFinanciero
    @id_expensa INT,
    @ing_en_termino DECIMAL(10,2),
    @ing_exp_adeudadas DECIMAL(10,2),
    @ing_adelantado DECIMAL(10,2),
    @egresos DECIMAL(10,2),
    @saldo_cierre DECIMAL(10,2)
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
    @id_expensa INT, @id_consorcio INT, @id_uni_func INT, @prorateo DECIMAL(4,2), @piso VARCHAR(4), @depto VARCHAR(4),
    @cochera DECIMAL(10,2),@baulera DECIMAL(10,2),@nom_y_ap_propietario VARCHAR(50),
    @anio VARCHAR(10), @mes VARCHAR(15), @total_expensa_ordinarios DECIMAL(10,2), @total_expensa DECIMAL(10,2)
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

		IF EXISTS (SELECT 1 FROM fin.EstadoDeCuenta WHERE id_expensa = @id_expensa AND id_uni_func = @id_uni_func)
		BEGIN
            RAISERROR('Ya existe un Estado de Cuenta para esta combinacion de Expensa y UF.', 16, 1)
            RETURN
        END
		-- TODO: Si estoy en Enero esto rompe. 
		DECLARE @id_expensa_anterior INT = (SELECT id_expensa from fin.Vista_GastosPorExpensa 
												where id_consorcio = @id_consorcio AND mes = (@mes-1) AND anio = @anio)
		-- Ayuda para multiplicar valores
		DECLARE @multiplicador DECIMAL(4,2) = @prorateo / 100
		DECLARE @fecha_expensa_generada DATE,
				@fecha_primer_venc DATE,
				@fecha_segundo_venc DATE,
				@monto_pagado DECIMAL(10,2),
				@fecha_ultimo_pago DATE,
				@saldo_anterior DECIMAL(10,2),
				@deuda DECIMAL(10,2),
				@interes_mora DECIMAL(10,2)

		IF @id_expensa_anterior IS NOT NULL
		BEGIN
			
		-- Comenzamos pagos de la expensa anterior... 
			SET @fecha_expensa_generada = (SELECT fechaGenerado from adm.Expensa where id_expensa= @id_expensa_anterior)
			SET @fecha_primer_venc = (SELECT fechaPrimerVenc from adm.Expensa where id_expensa= @id_expensa_anterior)
			SET @fecha_segundo_venc = (SELECT fechaSegVenc from adm.Expensa where id_expensa= @id_expensa_anterior)
			
			-- TODO: Cambiar como se calcula el monto pagado. Deberiamos fijarnos cuanto ingreso antes del primer vencimiento
			-- con esa info nos fijamos si ya no tiene que pagar mas nada. Si ya tiene el saldo en <=0 , leemos todo el resto de
			-- pagos que haya hecho durante el mes (seria ultimo dia del mes - 1 para que no colisione con la fecha de generacion
			-- del siguiente mes), y le sumamos a monto pagado. De esa forma sabemos en que momento pago y si adeuda. De la forma
			-- en la que esta codeado ahora, si el tipo pago todo pero hizo una transferencia a mitad de mes, le cobra una deuda
			-- cuando en realidad ya la podia tener saldada.
			SET @monto_pagado = (SELECT SUM(monto) from fin.Pago 
									WHERE id_uni_func = @id_uni_func AND
										fecha >= @fecha_expensa_generada AND fecha <= DATEADD(DAY, 1, @fecha_segundo_venc))
			SET @fecha_ultimo_pago = (SELECT MAX(fecha) from fin.Pago 
											WHERE id_uni_func = @id_uni_func AND
												fecha >= @fecha_expensa_generada AND fecha <= DATEADD(DAY, 1, @fecha_segundo_venc))
			SET @saldo_anterior = (SELECT total_a_pagar from fin.EstadoDeCuenta 
										where id_expensa = @id_expensa_anterior AND id_uni_func = @id_uni_func)
			SET @deuda = @saldo_anterior - @monto_pagado
			IF (@fecha_ultimo_pago <= @fecha_primer_venc) AND @deuda <= 0
				SET @interes_mora = 0
			ELSE IF (@fecha_ultimo_pago > @fecha_primer_venc) AND (@fecha_ultimo_pago <= @fecha_segundo_venc)
				SET @interes_mora = 0.02 * @saldo_anterior
			ELSE
				SET @interes_mora = 0.05 * @saldo_anterior
		END
		ELSE
		BEGIN
		-- Si es la primera expensa del edificio, el saldo anterior y etc es 0.
			SET @saldo_anterior = 0
			SET @monto_pagado = 0
			SET @deuda = 0
			SET @interes_mora = 0
		END
		
		-- Total extraordinarias es TotalDeTodos - ordinarias.
		DECLARE @expensas_extraordinarias DECIMAL(10,2) = @total_expensa - @total_expensa_ordinarios
		DECLARE @total_a_pagar DECIMAL (10,2)= (@total_expensa * @multiplicador) + @deuda + @interes_mora + @cochera + @baulera

        INSERT INTO fin.EstadoDeCuenta (
            id_expensa, id_uni_func, prorateo, piso, depto, cochera, baulera,
            nom_y_ap_propietario, saldo_anterior, pago_recibido, deuda,
            interes_mora, expensas_ordinarias, expensas_extraordinarias, total_a_pagar)
        VALUES (
            @id_expensa, @id_uni_func, @prorateo, @piso, @depto, @cochera, @baulera,
            @nom_y_ap_propietario, @saldo_anterior, @monto_pagado, @deuda, @interes_mora, 
			@total_expensa_ordinarios * @multiplicador, 
			@expensas_extraordinarias * @multiplicador, 
			@total_a_pagar)

    END TRY
    BEGIN CATCH
        PRINT('Error al agregar el estado de cuenta: ' + ERROR_MESSAGE())
    END CATCH
END
GO
