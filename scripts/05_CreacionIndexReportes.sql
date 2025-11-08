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
--REPORTE 1 y 2 (flujo semanal y total UF por mes)  
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Expensa_Consorcio_Fecha')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Expensa_Consorcio_Fecha
    ON adm.Expensa (id_consorcio, fechaGenerado);
END;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_EstadoCuenta_UF_Pago')
BEGIN
    CREATE NONCLUSTERED INDEX IX_EstadoCuenta_UF_Pago
    ON fin.EstadoDeCuenta (id_uni_func, pago_recibido)
    INCLUDE (expensas_ordinarias, expensas_extraordinarias, deuda);
END;
GO

--REPORTE 3 (recaudación por procedencia)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_EstadoCuenta_Expensa_Anio')
BEGIN
    CREATE NONCLUSTERED INDEX IX_EstadoCuenta_Expensa_Anio
    ON fin.EstadoDeCuenta (id_expensa)
    INCLUDE (expensas_ordinarias, expensas_extraordinarias, total_a_pagar);
END;
GO

-- REPORTE 6 (días entre pagos por UF)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Pago_UF_Fecha')
BEGIN
    CREATE NONCLUSTERED INDEX IX_Pago_UF_Fecha
    ON fin.Pago (id_uni_func, fecha)
    INCLUDE (monto, asociado);
END;
GO