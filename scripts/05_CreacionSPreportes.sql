--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------
-- Este archivo contiene la creacion de los Store Procedure de reportes pertenecientes al TP 6.

--Cambia a COM2900_G04
USE COM2900_G04
GO

---------CREACION DE LOS STORE PROCEDURES---------

---------REPORTE 1 - Flujo de caja semanal---------
CREATE OR ALTER PROCEDURE rep.Uno_FlujoSemanal
	@id_consorcio INT, @anio INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		--Validacion de parametros de entrada
		IF @id_consorcio IS NULL OR @anio IS NULL
		BEGIN
			RAISERROR('Debe especificar un consorcio y un año.',16,1)
			RETURN
		END

		IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE id_consorcio=@id_consorcio)
		BEGIN
			RAISERROR('No existe consorcio con ese id.',16,1)
			RETURN
		END

		IF @anio IS NULL OR @anio> YEAR(GETDATE())
		BEGIN
			RAISERROR('Debe especificar una fecha valida.',16,1)
			RETURN
		END;

		--CTE 1 - Ingresos semanales (pagos recibidos)
		WITH CTE_Ingresos AS(
			SELECT
				YEAR(e.fechaGenerado) AS Anio,
				DATEPART(WEEK,e.fechaGenerado) AS Semana,
				SUM(ISNULL(ec.pago_recibido,0)) AS TotalIngresos
			FROM fin.EstadoDeCuenta ec
			JOIN adm.Expensa e
				ON e.id_expensa = ec.id_expensa
			JOIN fin.vista_UFyConsorcio uf
				ON uf.id_uni_func = ec.id_uni_func
			WHERE uf.id_consorcio = @id_consorcio
				  AND YEAR(e.fechaGenerado) = @anio
			GROUP BY YEAR(e.fechaGenerado), DATEPART(WEEK,e.fechaGenerado)),

		--CTE 2 - Egresos semanales (gastos)
		CTE_Egresos AS(
			SELECT
				YEAR(f.fecha_de_cierre) AS Anio,
				DATEPART(WEEK,f.fecha_de_cierre) AS Semana,
				SUM(ISNULL(f.total_gastado,0)) AS TotalEgresos
				FROM fin.vista_GastosPorExpensa f
				WHERE f.id_consorcio = @id_consorcio
					AND YEAR(f.fecha_de_cierre) = @anio
				GROUP BY YEAR(f.fecha_de_cierre),DATEPART(WEEK,f.fecha_de_cierre))

		--
		SELECT
			ISNULL(i.Anio,e.Anio) AS Anio,
			ISNULL(i.Semana, e.Semana) AS Semana,
			ISNULL(i.TotalIngresos,0) AS TotalIngresos,
			ISNULL(e.TotalEgresos,0) AS TotalEgresos,
			AVG(ISNULL(i.TotalIngresos,0) - ISNULL(e.TotalEgresos,0))
				OVER() AS PromedioSemanal,
			SUM(ISNULL(i.TotalIngresos,0) - ISNULL(e.TotalEgresos,0))
				OVER(ORDER BY ISNULL(i.Semana,e.Semana)) AS Acumulado
		FROM CTE_Ingresos i
		FULL JOIN CTE_Egresos e
		ON i.Anio = e.Anio AND i.Semana = e.Semana
		ORDER BY Anio,Semana
	END TRY
	BEGIN CATCH
		PRINT('Error al generar el reporte: ' + ERROR_MESSAGE())
	END CATCH
END
GO

---------REPORTE 2 - Recaudacion por UF por mes---------
CREATE OR ALTER PROCEDURE rep.Dos_TotalUFporMes
	@id_consorcio INT, @anio INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		--Validacion de parametros de entrada
		IF @id_consorcio IS NULL OR @anio IS NULL
		BEGIN
			RAISERROR('Debe especificar un consorcio y un año validos.',16,1)
			RETURN
		END

		IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE id_consorcio=@id_consorcio)
		BEGIN
			RAISERROR('No existe consorcio con ese id.',16,1)
			RETURN
		END

		IF @anio IS NULL OR @anio> YEAR(GETDATE())
		BEGIN
			RAISERROR('Debe especificar una fecha valida.',16,1)
			RETURN
		END;

		--CTE Recaudacion
			--Unidad funcional, Mes, Total Pagado
		WITH CTE_Recaudacion AS(
			SELECT
				uf.id_uni_func,
				DATENAME(MONTH,e.fechaGenerado) AS Mes, --Datename retorna string
				SUM(ISNULL(ec.pago_recibido,0))AS TotalPagado
			FROM fin.EstadoDeCuenta ec
			JOIN adm.Expensa e
				ON e.id_expensa = ec.id_expensa
			JOIN fin.vista_UFyConsorcio uf
				ON uf.id_uni_func = ec.id_uni_func
			WHERE uf.id_consorcio = @id_consorcio
				  AND YEAR(e.fechaGenerado) = @anio
			GROUP BY uf.id_uni_func, DATENAME(MONTH, e.fechaGenerado))

		--Pivot del CTE Recaudacion
		SELECT * FROM CTE_Recaudacion
		PIVOT(SUM(TotalPagado) FOR Mes IN ([enero],[febrero],[marzo],[abril],[mayo],[junio],
							[julio],[agosto],[septiembre],[octubre],[noviembre],[diciembre])
		)AS Recaudacion_Pivot
		ORDER BY id_uni_func;
	END TRY
	BEGIN CATCH
		PRINT('Error al generar el reporte: ' + ERROR_MESSAGE())
	END CATCH
END
GO

---------REPORTE 3 - Recaudacion por origen---------
CREATE OR ALTER PROCEDURE rep.Tres_RecaudacionPorProcedencia
	@id_consorcio INT, @anio INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		--Validacion de parametros ingresados
		IF @id_consorcio IS NULL
		BEGIN
			RAISERROR('Debe especificar un consorcio.',16,1)
			RETURN
		END

		IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE id_consorcio=@id_consorcio)
		BEGIN
			RAISERROR('No existe consorcio con ese id.',16,1)
			RETURN
		END

		IF @anio IS NULL OR @anio> YEAR(GETDATE())
		BEGIN
			RAISERROR('Debe especificar una fecha valida.',16,1)
			RETURN
		END

		--Consulta del reporte
		SELECT
			ex.fechaGenerado AS Periodo,
			SUM(ISNULL(ec.expensas_ordinarias,0)) AS Ordinario,
			SUM(ISNULL(ec.expensas_extraordinarias,0)) AS Extraordinario,
			SUM(ISNULL(ec.cochera,0)) + SUM(ISNULL(ec.baulera,0)) AS Otros
		FROM fin.EstadoDeCuenta ec
		JOIN adm.Expensa ex ON ex.id_expensa = ec.id_expensa
		WHERE (ex.id_consorcio = @id_consorcio)
		  AND YEAR(ex.fechaGenerado)=@anio
		GROUP BY ex.fechaGenerado
		ORDER BY Periodo
	END TRY

	BEGIN CATCH
		PRINT('Error al generar el reporte: ' + ERROR_MESSAGE())
	END CATCH
END
GO

---------REPORTE 4 - TOP 5 meses con mayores gastos e ingresos---------
CREATE OR ALTER PROCEDURE rep.Cuatro_TopMeses
	@id_consorcio INT, @anio INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	--Validacion de parametros ingresados
		IF @id_consorcio IS NULL
		BEGIN
			RAISERROR('Debe especificar un consorcio.',16,1)
			RETURN
		END

		IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE id_consorcio=@id_consorcio)
		BEGIN
			RAISERROR('No existe consorcio con ese id.',16,1)
			RETURN
		END

		IF @anio IS NULL OR @anio> YEAR(GETDATE())
		BEGIN
			RAISERROR('Debe especificar una fecha valida.',16,1)
			RETURN
		END;

		--CTE 1 - Ingresos
		WITH CTE_Ingresos AS (
		   SELECT
			   YEAR(e.fechaGenerado) AS Anio,
			   MONTH(e.fechaGenerado) AS Mes,
			   DATENAME(MONTH, e.fechaGenerado) AS NombreMes,
			   SUM(ISNULL(ec.pago_recibido, 0)) AS TotalIngresos
		   FROM fin.EstadoDeCuenta ec
		   JOIN adm.Expensa e
			   ON e.id_expensa = ec.id_expensa
		   JOIN fin.vista_UFyConsorcio uf
			   ON uf.id_uni_func = ec.id_uni_func
		   WHERE uf.id_consorcio = @id_consorcio
			 AND YEAR(e.fechaGenerado) = @anio
		   GROUP BY YEAR(e.fechaGenerado), MONTH(e.fechaGenerado), DATENAME(MONTH, e.fechaGenerado)),

		--CTE 2 -Egresos
		CTE_Egresos AS (
		   SELECT
			   YEAR(e.fechaGenerado) AS Anio,
			   MONTH(e.fechaGenerado) AS Mes,
			   DATENAME(MONTH, e.fechaGenerado) AS NombreMes,
			   SUM(ISNULL(g.total_gastado, 0)) AS TotalEgresos
		   FROM fin.vista_GastosPorExpensa g
		   JOIN adm.Expensa e
			   ON g.id_expensa = e.id_expensa
		   WHERE g.id_consorcio = @id_consorcio
			 AND YEAR(e.fechaGenerado) = @anio
		   GROUP BY YEAR(e.fechaGenerado), MONTH(e.fechaGenerado), DATENAME(MONTH, e.fechaGenerado))

		--
		SELECT TOP 5 
			ISNULL(i.Anio, e.Anio) AS Anio,
			ISNULL(i.NombreMes, e.NombreMes) AS Mes,
			ISNULL(i.TotalIngresos, 0) AS TotalIngresos,
			ISNULL(e.TotalEgresos, 0) AS TotalEgresos,
			(ISNULL(i.TotalIngresos, 0) - ISNULL(e.TotalEgresos, 0)) AS Diferencia,
			AVG(ISNULL(i.TotalIngresos, 0)) OVER() AS PromedioIngresos,
			AVG(ISNULL(e.TotalEgresos, 0)) OVER() AS PromedioEgresos
		FROM CTE_Ingresos i
		FULL JOIN CTE_Egresos e
			ON i.Anio=e.Anio AND i.Mes=e.Mes
		ORDER BY (ISNULL(i.TotalIngresos, 0) + ISNULL(e.TotalEgresos, 0)) DESC
		FOR XML PATH('Mes'), ROOT('TopMeses'),ELEMENTS;
	END TRY
	BEGIN CATCH
		PRINT('Error al generar el reporte: ' + ERROR_MESSAGE())
	END CATCH
END
GO


---------REPORTE 5 - TOP 3 propietarios con morosidad---------
CREATE OR ALTER PROCEDURE rep.Cinco_TopMora
	@id_consorcio INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	--Validacion de parametros ingresados
		IF @id_consorcio IS NULL
		BEGIN
			RAISERROR('Debe especificar un consorcio.',16,1)
			RETURN
		END

		IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE id_consorcio=@id_consorcio)
		BEGIN
			RAISERROR('No existe consorcio con ese id.',16,1)
			RETURN
		END;

		--CTE Deudas de propietario
		WITH CTE_Deuda AS(
			SELECT
				--datos propietario
				p.nombre, p.apellido,p.dni, p.email, p.telefono,
				SUM(ISNULL(ec.deuda,0)) AS deuda
				FROM fin.EstadoDeCuenta ec
				JOIN fin.Vista_UfYConsorcio uf
					ON uf.id_uni_func=ec.id_uni_func
				JOIN adm.Propietario p
					ON p.id_prop=uf.id_prop
				WHERE uf.id_consorcio=@id_consorcio
				GROUP BY p.dni, p.nombre, p.apellido, p.email, p.telefono)

		--
		SELECT TOP 3
			c.apellido+', '+c.nombre AS Propietario,
			c.dni,c.email, c.telefono, c.deuda
		FROM CTE_Deuda c
		ORDER BY c.deuda ASC
		FOR XML PATH('Propietario'), ROOT('TopMorosos'),ELEMENTS;
	END TRY
	BEGIN CATCH
		PRINT('Error al generar el reporte: ' + ERROR_MESSAGE())
	END CATCH
END			
GO

CREATE OR ALTER PROCEDURE rep.Seis_DiasPagosUF
	@id_consorcio INT, @anio INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
	--Validacion de parametros ingresados
		IF @id_consorcio IS NULL
		BEGIN
			RAISERROR('Debe especificar un consorcio.',16,1)
			RETURN
		END

		IF NOT EXISTS (SELECT 1 FROM adm.Consorcio WHERE id_consorcio=@id_consorcio)
		BEGIN
			RAISERROR('No existe consorcio con ese id.',16,1)
			RETURN
		END

		IF @anio IS NULL OR @anio> YEAR(GETDATE())
		BEGIN
			RAISERROR('Debe especificar una fecha valida.',16,1)
			RETURN
		END;

		WITH PagosOrd AS(
			SELECT
				uf.id_uni_func AS Unidad_Funcional,
				uf.piso AS Piso,
				uf.depto AS Depto,
				p.fecha AS Fecha_de_Pago,
				DATEDIFF(day,lag(p.fecha) over(partition by uf.id_uni_func order by p.fecha),p.fecha) AS Dias_entre_Pagos
			FROM fin.Pago p
			JOIN adm.UnidadFuncional uf ON uf.id_uni_func = p.id_uni_func
			WHERE
				uf.id_consorcio=@id_consorcio AND YEAR(p.fecha) = @anio AND p.asociado = 1)
		SELECT * FROM PagosOrd
		ORDER BY Unidad_Funcional, Fecha_de_Pago;
	END TRY
	BEGIN CATCH
		PRINT('Error al generar el reporte: ' + ERROR_MESSAGE())
	END CATCH
END
GO