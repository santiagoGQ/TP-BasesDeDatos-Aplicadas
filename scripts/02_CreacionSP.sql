--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------

-- Este archivo crea la mayoria de los Store Procedures que se usarán en el sistema.
-- Todos los SP que agregan datos, tambien modifican en caso de que se le permita a la tabla.
-- Ejemplo: aceptamos modificaciones de datos de adm.UnidadFuncional, pero no de la tabla fin.Pago

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
		PRINT 'Ocurrio un error al agregar un propietario.';
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
		PRINT 'Ocurrio un error al agregar un inquilino.';
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

		--Validar que razon social no esta vacio
		IF LEN(LTRIM(RTRIM(@razon_social))) = 0
        BEGIN
            RAISERROR('La razon social no puede estar vacia.', 16, 1)
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
            RAISERROR('Ya existe un proveedor con esa razon social para este consorcio.', 16, 1);
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

-------------- GASTO --------------

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
	DECLARE @asociado BIT = 0

	--Validacion de duplicado
	IF NOT EXISTS (SELECT 1 FROM fin.Pago 
					WHERE ISNULL(id_uni_func,-1) = ISNULL(@id_uni_func,-1) AND fecha = @fecha AND ISNULL(cbu_cvu,-1) = ISNULL(@cuenta_origen,-1))
	BEGIN
		--Validacion de cbu, si se encuentra pago asociado, caso contrario pago no asociado
		IF EXISTS (SELECT 1 FROM adm.UnidadFuncional WHERE cbu = @cuenta_origen)
			SET @asociado = 1

		INSERT INTO fin.Pago(id_uni_func, fecha, cbu_cvu, monto, asociado)
			VALUES (@id_uni_func, @fecha, @cuenta_origen, @monto, @asociado)
	END
END
GO

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
	@id_consorcio INT
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

		DECLARE @id_expensa_anterior INT,
				@saldo_anterior DECIMAL(10,2),
				@ing_en_termino DECIMAL(10,2),
				@ing_exp_adeudadas DECIMAL(10,2),
				@ing_adelantado DECIMAL(10,2),
				@egresos DECIMAL(10,2),
				@saldo_al_cierre DECIMAL(10,2),
				@gastos_cochera DECIMAL(10,2), -- No son parte de la vista
				@gastos_baulera DECIMAL(10,2)  -- No son parte de la vista

		SELECT TOP 1 @id_expensa_anterior = e.id_expensa
		FROM adm.Expensa e
		WHERE e.id_consorcio = @id_consorcio
		  AND e.id_expensa < @id_expensa
		ORDER BY e.fechaGenerado DESC;

		IF @id_expensa_anterior IS NULL -- Si es la primera expensa del consorcio..
		BEGIN
			SET @saldo_anterior = 0
			SET @ing_en_termino = 0
			SET @ing_exp_adeudadas = 0
			SET @ing_adelantado = 0
			SET @gastos_cochera = (SELECT SUM(cochera) from fin.EstadoDeCuenta where id_expensa = @id_expensa)
			SET @gastos_baulera = (SELECT SUM(baulera) from fin.EstadoDeCuenta where id_expensa = @id_expensa)
			SET @egresos = @gastos_baulera + @gastos_cochera + (SELECT total_gastado from Vista_GastosPorExpensa where id_expensa = @id_expensa)
			INSERT INTO fin.EstadoFinanciero (id_expensa, saldo_anterior, ing_en_termino, ing_exp_adeudadas, ing_adelantado, egresos, saldo_cierre)
			VALUES (@id_expensa, @saldo_anterior, @ing_en_termino, @ing_exp_adeudadas, @ing_adelantado, @egresos, @egresos)
		END
		ELSE
		BEGIN
			exec fin.CalcularIngresosPorExpensasAdeudadas @id_expensa, @ing_exp_adeudadas OUTPUT
			exec fin.CalcularIngresosPorGastos @id_expensa, @ing_en_termino OUTPUT
			exec fin.CalcularIngresosPorExpensasAdelantadas @id_expensa, @ing_adelantado OUTPUT
			SET @gastos_cochera = (SELECT SUM(cochera) from fin.EstadoDeCuenta where id_expensa = @id_expensa)
			SET @gastos_baulera = (SELECT SUM(baulera) from fin.EstadoDeCuenta where id_expensa = @id_expensa)
			SET @egresos = @gastos_baulera + @gastos_cochera + (SELECT total_gastado from Vista_GastosPorExpensa where id_expensa = @id_expensa)
			SET @saldo_anterior = (SELECT saldo_cierre from fin.EstadoFinanciero where id_expensa = @id_expensa_anterior)
			SET @saldo_al_cierre = @saldo_anterior - (@ing_exp_adeudadas + @ing_en_termino + @ing_adelantado ) + @egresos

			INSERT INTO fin.EstadoFinanciero (id_expensa, saldo_anterior, ing_en_termino, ing_exp_adeudadas, ing_adelantado, egresos, saldo_cierre)
			VALUES (@id_expensa, @saldo_anterior, @ing_en_termino, @ing_exp_adeudadas, @ing_adelantado, @egresos, @saldo_al_cierre)
		END
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
			
			SET @monto_pagado = (SELECT SUM(monto) from fin.Pago 
									WHERE id_uni_func = @id_uni_func AND
										fecha >= @fecha_expensa_generada AND fecha <= DATEADD(DAY, 10, @fecha_segundo_venc))
			SET @fecha_ultimo_pago = (SELECT MAX(fecha) from fin.Pago 
											WHERE id_uni_func = @id_uni_func AND
												fecha >= @fecha_expensa_generada AND fecha <= DATEADD(DAY, 1, @fecha_segundo_venc))
			SET @saldo_anterior = (SELECT total_a_pagar from fin.EstadoDeCuenta 
										where id_expensa = @id_expensa_anterior AND id_uni_func = @id_uni_func)
			SET @deuda = @saldo_anterior - @monto_pagado
			IF (@fecha_ultimo_pago <= @fecha_primer_venc) AND @deuda <= 0
				SET @interes_mora = 0
			ELSE IF (@fecha_ultimo_pago > @fecha_primer_venc) AND (@fecha_ultimo_pago <= @fecha_segundo_venc) AND @deuda > 0
				SET @interes_mora = 0.02 * @saldo_anterior
			ELSE IF (@fecha_ultimo_pago > @fecha_segundo_venc) AND @deuda > 0
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
		
		-- Total extraordinarias es TotalDeTodo - ordinarias.
		DECLARE @expensas_extraordinarias DECIMAL(10,2) = @total_expensa - @total_expensa_ordinarios
		DECLARE @total_a_pagar DECIMAL (10,2)= (@total_expensa * @multiplicador) + @deuda + ISNULL(@interes_mora, 0) + @cochera + @baulera

        INSERT INTO fin.EstadoDeCuenta (
            id_expensa, id_uni_func, prorateo, piso, depto, cochera, baulera,
            nom_y_ap_propietario, saldo_anterior, pago_recibido, deuda,
            interes_mora, expensas_ordinarias, expensas_extraordinarias, total_a_pagar)
        VALUES (
            @id_expensa, @id_uni_func, @prorateo, @piso, @depto, @cochera, @baulera,
            @nom_y_ap_propietario, @saldo_anterior, @monto_pagado, @deuda, ISNULL(@interes_mora, 0), 
			@total_expensa_ordinarios * @multiplicador, 
			@expensas_extraordinarias * @multiplicador, 
			@total_a_pagar)

    END TRY
    BEGIN CATCH
        PRINT('Error al agregar el estado de cuenta: ' + ERROR_MESSAGE())
    END CATCH
END
GO

CREATE OR ALTER PROCEDURE fin.CalcularIngresosPorExpensasAdeudadas
    @id_expensa_actual INT,
    @ingreso_total DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_consorcio INT;
    DECLARE @id_expensa_anterior INT;
    SET @ingreso_total = 0;

    -- buscamos consorcio e id de expensa anterior
    SELECT @id_consorcio = e.id_consorcio
    FROM adm.Expensa e
    WHERE e.id_expensa = @id_expensa_actual;

    SELECT TOP 1 @id_expensa_anterior = e.id_expensa
    FROM adm.Expensa e
    WHERE e.id_consorcio = @id_consorcio
      AND e.id_expensa < @id_expensa_actual
    ORDER BY e.fechaGenerado DESC;

    IF @id_expensa_anterior IS NULL
    BEGIN
        RAISERROR('No se encontro una expensa anterior para este consorcio.',16,1);
        RETURN;
    END;

    ;WITH Datos AS (
        SELECT 
            a.id_uni_func,
            pago_recibido = ISNULL(a.pago_recibido, 0),

            -- Solo deuda positiva del periodo anterior
            deuda_anterior_pos = CASE 
                                   WHEN ISNULL(p.deuda,0) + ISNULL(p.interes_mora,0) > 0 
                                   THEN ISNULL(p.deuda,0) + ISNULL(p.interes_mora,0) 
                                   ELSE 0 
                                 END,

            -- Solo gastos anteriores positivos
            gastos_anteriores_pos = CASE 
                                      WHEN ISNULL(p.expensas_ordinarias,0)
                                         + ISNULL(p.expensas_extraordinarias,0)
                                         + ISNULL(p.cochera,0)
                                         + ISNULL(p.baulera,0) > 0
                                      THEN ISNULL(p.expensas_ordinarias,0)
                                         + ISNULL(p.expensas_extraordinarias,0)
                                         + ISNULL(p.cochera,0)
                                         + ISNULL(p.baulera,0)
                                      ELSE 0
                                    END,

            -- Si el saldo anterior de la fila actual es negativo (a favor), no hay deuda a cobrar
            saldo_anterior = ISNULL(a.saldo_anterior,0)
        FROM fin.EstadoDeCuenta a
        JOIN fin.EstadoDeCuenta p
          ON p.id_expensa = @id_expensa_anterior
         AND p.id_uni_func = a.id_uni_func
        WHERE a.id_expensa = @id_expensa_actual
    ),
    Normalizado AS (
        SELECT
            id_uni_func,
            pago_recibido,
            -- Si el saldo anterior actual ya es a favor, fuerzo deuda = 0
            deuda_valida = CASE WHEN saldo_anterior < 0 THEN 0 ELSE deuda_anterior_pos END,
            gastos_val = gastos_anteriores_pos
        FROM Datos
    ),
    Resultado AS (
        SELECT
            id_uni_func,
            ingreso_por_deuda = 
                CASE 
                    WHEN pago_recibido > gastos_val 
                    THEN 
                        CASE 
                            WHEN (pago_recibido - gastos_val) > deuda_valida 
                            THEN deuda_valida
                            ELSE (pago_recibido - gastos_val)
                        END
                    ELSE 0
                END
        FROM Normalizado
    )
    SELECT @ingreso_total = SUM(ingreso_por_deuda)
    FROM Resultado;

    RETURN @ingreso_total;
END
GO

CREATE OR ALTER PROCEDURE fin.CalcularIngresosPorGastos
    @id_expensa_actual INT,
	@ingreso_total DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_consorcio INT;
    DECLARE @id_expensa_anterior INT;
    SET @ingreso_total = 0;

    -- id consorcio de la expensa actual
    SELECT @id_consorcio = e.id_consorcio
    FROM adm.Expensa e
    WHERE e.id_expensa = @id_expensa_actual;

    IF @id_consorcio IS NULL
    BEGIN
        RAISERROR('No existe la expensa actual.', 16, 1);
        RETURN;
    END

    -- buscar expensa anterior del mismo consorcio
    SELECT TOP 1 @id_expensa_anterior = e.id_expensa
    FROM adm.Expensa e
    WHERE e.id_consorcio = @id_consorcio
      AND e.id_expensa < @id_expensa_actual
    ORDER BY e.fechaGenerado DESC;

    IF @id_expensa_anterior IS NULL
    BEGIN
        RAISERROR('No se encontro expensa anterior para este consorcio.', 16, 1);
        RETURN;
    END

    --  Calcular ingresos aplicados a gastos de la expensa ANTERIOR
    --  contra lo pagado en la expensa actual, por UF
    ;WITH Datos AS (
        SELECT
            a.id_uni_func,
            pago_actual      = ISNULL(a.pago_recibido, 0),
            gastos_anteriores = 
                ISNULL(b.expensas_ordinarias, 0)
              + ISNULL(b.expensas_extraordinarias, 0)
              + ISNULL(b.cochera, 0)
              + ISNULL(b.baulera, 0)
        FROM fin.EstadoDeCuenta a   -- actual
        JOIN fin.EstadoDeCuenta b   -- anterior
              ON b.id_uni_func = a.id_uni_func
             AND b.id_expensa  = @id_expensa_anterior
        WHERE a.id_expensa = @id_expensa_actual
    )
    SELECT 
        @ingreso_total = SUM(
            CASE 
                WHEN pago_actual <= gastos_anteriores THEN pago_actual
                ELSE gastos_anteriores
            END
        )
    FROM Datos;

    RETURN @ingreso_total
END
GO


CREATE OR ALTER PROCEDURE fin.CalcularIngresosPorExpensasAdelantadas
    @id_expensa_actual INT,
	@ingreso_total DECIMAL(18,2) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    SET @ingreso_total = 0;

    -- calculamos pagos adelantados por unidad funcional
    ;WITH Datos AS (
        SELECT 
            id_uni_func,
            ISNULL(saldo_anterior, 0) AS saldo_anterior,
            ISNULL(pago_recibido, 0) AS pago_recibido
        FROM fin.EstadoDeCuenta
        WHERE id_expensa = @id_expensa_actual
    )
    SELECT 
        @ingreso_total = SUM(
            CASE 
                -- Si el saldo anterior es negativo o cero (a favor), todo el pago es ingreso adelantado
                WHEN saldo_anterior <= 0 THEN pago_recibido
                -- Si el saldo anterior es positivo, solo lo que exceda ese saldo es adelantado
                WHEN pago_recibido > saldo_anterior THEN (pago_recibido - saldo_anterior)
                ELSE 0
            END
        )
    FROM Datos;

    RETURN @ingreso_total
END
GO


-- exec fin.CalcularIngresosPorExpensasAdeudadas 3
-- exec fin.CalcularIngresosPorGastos 3