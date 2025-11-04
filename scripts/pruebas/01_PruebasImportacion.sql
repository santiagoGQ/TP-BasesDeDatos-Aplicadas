--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------
-- Este archivo contiene las sentencias que prueban la importacion de datos a traves de archivos.

adm.AgregarTipoServicioLimpieza 'Limpieza test'
exec adm.ImportarConsorcios N'C:\Temp\datos varios.xlsx', N'C:\Temp\UF por consorcio.txt'
exec adm.ImportarProveedores N'C:\Temp\datos varios.xlsx'
exec adm.ImportarInquilinoYPropietarios N'C:\Temp\Inquilino-propietarios-datos.csv'
exec adm.ImportarRelacionEntreUFyPropInq N'C:\Temp\Inquilino-propietarios-UF.csv'
exec adm.ImportarGastos N'C:\Temp\Servicios.Servicios.json'
exec fin.ImportarPagos N'C:\Temp\pagos_consorcios.csv'

exec fin.GenerarExpensa '2025', '3', 'Azcuenaga'
exec fin.GenerarExpensa '2025', '4', 'Azcuenaga'
exec fin.GenerarExpensa '2025', '5', 'Azcuenaga'

exec fin.GenerarExpensa '2025', '3', 'Alzaga'
exec fin.GenerarExpensa '2025', '4', 'Alzaga'
exec fin.GenerarExpensa '2025', '5', 'Alzaga'

exec fin.GenerarExpensa '2025', '3', 'Alberdi'
exec fin.GenerarExpensa '2025', '4', 'Alberdi'
exec fin.GenerarExpensa '2025', '5', 'Alberdi'

exec fin.GenerarExpensa '2025', '3', 'Unzue'
exec fin.GenerarExpensa '2025', '4', 'Unzue'
exec fin.GenerarExpensa '2025', '5', 'Unzue'

exec fin.GenerarExpensa '2025', '3', 'Pereyra Iraola'
exec fin.GenerarExpensa '2025', '4', 'Pereyra Iraola'
exec fin.GenerarExpensa '2025', '5', 'Pereyra Iraola'
