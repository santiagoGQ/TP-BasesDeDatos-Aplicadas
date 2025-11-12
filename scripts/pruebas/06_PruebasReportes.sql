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
-- Ponemos lenguaje en español para que el pivot de los meses funcione.
SET LANGUAGE Spanish
GO

OPEN SYMMETRIC KEY ClaveSimetricaDatos DECRYPTION BY CERTIFICATE CertificadoCifrado;

----------------------REPORTE 1----------------------
--Objetivo: Verificar recaudacion del consorcio semanalmente.
--Resultado esperado: Semanas del 2025 (de expensas del consorcio 1) con TotalSemanal, PromedioSemanal y Acumulado. Entre abril y junio.
--Parametros de entrada: id_consorcio, anio, mes_desde, mes_hasta
EXEC rep.Uno_FlujoSemanal @id_consorcio=1,@anio=2025,@mes_desde=4,@mes_hasta=6
GO

----------------------REPORTE 2----------------------
--Objetivo: Pivot que muestra por cada UF de un consorcio: montos pagados mes a mes del año especificado.
--Resultado esperado: Total pagado por cada UF del consorcio 2 por cada mes del 2025
--Parametros de entrada: id_consorcio, anio, id_uf (opcional)

--Todas las uf
EXEC rep.Dos_TotalUFporMes @id_consorcio=2,@anio=2025
GO

--Solamente uf=32
EXEC rep.Dos_TotalUFporMes @id_consorcio=2,@anio=2025,@id_uf=32
GO

----------------------REPORTE 3----------------------
--Objetivo: Mostrar la recaudacion de un consorcio por procedencia: Ordinario, Extraordinario u Otros
--Resultado esperado: Procedencias de la recaudacion del consorcio 3 durante el 2025
--Parametros de entrada: id_consorcio, anio, mes_desde, mes_hasta
EXEC rep.Tres_RecaudacionPorProcedencia 6,2025,1,12
GO

----------------------REPORTE 4----------------------
--Objetivo: Obtener los 5 meses con mayores ingresos y los 5 meses con mayores egresos de un consorcio.
--Resultado esperado: XML con los meses de ingresos y meses de egresos durante el año 2025 del consorcio 6.
--Parametros de entrada: id_consorcio, anio, top (los X primeros)
--SALIDA EN XML
EXEC rep.Cuatro_TopMeses 6,2025,5
GO

----------------------REPORTE 5----------------------
--Objetivo: Obtener el top 3 de propietarios con mayor deuda
--Resultado esperado: XML con los datos de contacto de cada propietario del top del consorcio 6
--Parametros de entrada: id_consorcio, piso, top (los X primeros)
--SALIDA EN XML

--Todos los pisos
EXEC rep.Cinco_TopMora @id_consorcio=6,@top=5
GO

--Solo 1er piso
EXEC rep.Cinco_TopMora @id_consorcio=6,@piso='1',@top=5
GO

----------------------REPORTE 6----------------------
--Objetivo: Mostrar las fechas de pagos y la cantidad de días entre ellos por UF
--Resultado esperado: Dias de diferencia entre pagos consecutivos del consorcio 2 en el año 2025
--Parametros de entrada: id_consorcio, anio, piso

--Todos los pisos
EXEC rep.Seis_DiasPagosUF @id_consorcio=2,@anio=2025
GO

--Solo Planta Baja
EXEC rep.Seis_DiasPagosUF @id_consorcio=2,@anio=2025,@piso='PB'
GO
   
CLOSE SYMMETRIC KEY ClaveSimetricaDatos;