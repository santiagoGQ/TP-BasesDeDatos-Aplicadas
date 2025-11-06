--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------
-- Este archivo crea la clave de encrpitacion que sera usada para cifrar los datos sensibles.
-- Esto es parte del TP 7.

--Cambia a COM2900_G04
USE COM2900_G04
GO

-- Crear clave maestra en la base
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Grupo04#2025';

-- Crear certificado que protegerá la clave simétrica
CREATE CERTIFICATE CertificadoCifrado
WITH SUBJECT = 'Certificado para cifrar datos sensibles';

-- Crear la clave simétrica propiamente dicha
CREATE SYMMETRIC KEY ClaveSimetricaDatos
WITH ALGORITHM = AES_256
ENCRYPTION BY CERTIFICATE CertificadoCifrado;
