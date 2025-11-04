--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------
-- Este archivo contiene las sentencias que prueban un consorcio con cochera y baulera. 
-- Genera 7 meses de expensas.

DECLARE @id_consorcio INT 

-- Generar un consorcio con baulera sin cochera
exec test.GeneraConsorcioPersonasUF 0, 1, @id_consorcio OUTPUT

-- Gastos para el mes de marzo con un gasto extraordinario.
exec test.GeneraExpensaProveedorGastos @id_consorcio, 'marzo', 1

DECLARE @nombre_consorcio VARCHAR(25) = (SELECT nombre from adm.Consorcio where id_consorcio = @id_consorcio)
-- Generar la expensa de Marzo 2025. 
exec fin.GenerarExpensa '2025', '3', @nombre_consorcio

-- Generar pagos para la expensa de marzo (entran en Abril)
exec test.GenerarPagos @id_consorcio, 'abril'

-- Gastos para el mes de Abril sin un gasto extraordinario
exec test.GeneraExpensaProveedorGastos @id_consorcio, 'abril', 0

-- Generar la expensa de Abril 2025. 
exec fin.GenerarExpensa '2025', '4', @nombre_consorcio

-- Generar pagos para la expensa de Abril (entran en Mayo)
exec test.GenerarPagos @id_consorcio, 'mayo'

-- Gastos para el mes de Mayo
exec test.GeneraExpensaProveedorGastos @id_consorcio, 'mayo', 1

-- Generar la expensa de Mayo 2025. 
exec fin.GenerarExpensa '2025', '5', @nombre_consorcio

-- Generar pagos para la expensa de Mayo (entran en Junio)
exec test.GenerarPagos @id_consorcio, 'junio'


-- Gastos para el mes de Junio sin un gasto extraordinario
exec test.GeneraExpensaProveedorGastos @id_consorcio, 'junio', 0

-- Generar la expensa de Junio 2025. 
exec fin.GenerarExpensa '2025', '6', @nombre_consorcio

-- Generar pagos para la expensa de Junio (entran en Julio)
exec test.GenerarPagos @id_consorcio, 'julio'


-- Gastos para el mes de Julio con un gasto extraordinario
exec test.GeneraExpensaProveedorGastos @id_consorcio, 'julio', 1

-- Generar la expensa de Julio 2025. 
exec fin.GenerarExpensa '2025', '7', @nombre_consorcio

-- Generar pagos para la expensa de Julio (entran en Agosto)
exec test.GenerarPagos @id_consorcio, 'agosto'


-- Gastos para el mes de Agosto sin un gasto extraordinario
exec test.GeneraExpensaProveedorGastos @id_consorcio, 'agosto', 0

-- Generar la expensa de Agosto 2025. 
exec fin.GenerarExpensa '2025', '8', @nombre_consorcio

-- Generar pagos para la expensa de Agosto (entran en Septiembre)
exec test.GenerarPagos @id_consorcio, 'septiembre'
