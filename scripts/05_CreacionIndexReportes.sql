--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------
-- Este archivo contiene la creacion de los INDEX de reportes pertenecientes al TP 6.

--Cambia a COM2900_G04
USE COM2900_G04
GO

-------------CREACION DE LOS INDICES-------------
-- REPORTE 1 (flujo semanal)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pago_Fecha_CBU')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Pago_Fecha_CBU
    ON fin.Pago (fecha, cbu_cvu)
    INCLUDE (monto)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_UF_Consorcio_CBU')
BEGIN
    CREATE NONCLUSTERED INDEX IX_UF_Consorcio_CBU
    ON adm.UnidadFuncional (id_consorcio, cbu)
END
GO

-- REPORTE 2 (recaudación mensual por UF)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Expensa_Consorcio_Fecha')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Expensa_Consorcio_Fecha
    ON adm.Expensa (id_consorcio, fechaGenerado)
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_EstadoCuenta_UF_Expensa')
BEGIN
    CREATE NONCLUSTERED INDEX IX_EstadoCuenta_UF_Expensa
    ON fin.EstadoDeCuenta (id_uni_func, id_expensa)
    INCLUDE (pago_recibido, expensas_ordinarias, expensas_extraordinarias, deuda)
END
GO

-- REPORTE 3 (recaudación por procedencia)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Expensa_Consorcio_AnioMes')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Expensa_Consorcio_AnioMes
    ON adm.Expensa (id_consorcio, fechaGenerado)
    INCLUDE (id_expensa)
END
GO

-- REPORTE 6 (días entre pagos)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pago_UF_Fecha')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Pago_UF_Fecha
    ON fin.Pago (id_uni_func, fecha)
    INCLUDE (monto, asociado)
END
GO