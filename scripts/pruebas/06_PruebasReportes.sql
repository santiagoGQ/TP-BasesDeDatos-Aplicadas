--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------
-- Este archivo contiene las sentencias que prueban los reportes pertenecientes al TP 6. 

--Cambia a COM2900_G04
USE COM2900_G04
GO

----------------------REPORTE 1----------------------
--Objetivo: verificar ingresos/egresos semanales del consorcio.
--Resultado esperado: semanas del 2025 (de expensas del consorcio 1) con TotalIngresos, TotalEgresos, promedio semanal y acumulado.
EXEC rep.Uno_FlujoSemanal 1,2025
GO

----------------------REPORTE 2----------------------
--Objetivo: pivot que muestra por cada UF de un consorcio: montos pagados mes a mes del año especificado.
--Resultado esperado: total pagado por cada UF del consorcio 2 por cada mes del 2025
EXEC rep.Dos_TotalUFporMes 2,2025
GO

----------------------REPORTE 3----------------------
--Objetivo: mostrar la recaudacion de un consorcio por procedencia: Ordinario, Extraordinario u Otros
--Resultado esperado: procedencias de la recaudacion del consorcio 3 durante el 2025
EXEC rep.Tres_RecaudacionPorProcedencia 3,2025
GO

----------------------REPORTE 4----------------------
--Objetivo: obtener los 5 meses con mayores ingresos y egresos de un consorcio.
--Resultado esperado: XML con los meses, ingresos, egresos y diferencia total durante el año 2025 del consorcio 2.
EXEC rep.Cuatro_TopMeses 2,2025
GO

----------------------REPORTE 5----------------------
--Objetivo: obtener el top 3 de propietarios con mayor deuda
--Resultado esperado: XML con los datos de contacto de cada propietario del top del consorcio 2
EXEC rep.Cinco_TopMora 2
GO

----------------------REPORTE 6----------------------
--Objetivo: mostrar las fechas de pagos y la cantidad de días entre ellos por UF
--Resultado esperado: dias de diferencia entre pagos consecutivos del consorcio 2 en el año 2025
EXEC rep.Seis_DiasPagosUF 2,2025
GO