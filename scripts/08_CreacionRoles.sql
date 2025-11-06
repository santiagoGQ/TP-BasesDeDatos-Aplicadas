--------------------------------------------------
-- BASES DE DATOS APLICADAS
--  GRUPO 04
--  INTEGRANTES
--   CONDE, FRANCO
--   GARAY QUINTERO, SANTIAGO
--   SIMCIC, TOBIAS
--------------------------------------------------
-- Este archivo crea los diferentes roles para los usuarios de este sistema. Esto es parte del TP 7.

--Cambia a COM2900_G04
USE COM2900_G04
GO


-- Creación de roles
CREATE ROLE Rol_AdministrativoGeneral;
CREATE ROLE Rol_AdministrativoBancario;
CREATE ROLE Rol_AdministrativoOperativo;
CREATE ROLE Rol_Sistemas;

-- Permisos por rol
-- Administrativo general
GRANT EXECUTE ON OBJECT::adm.ActualizarUF TO Rol_AdministrativoGeneral;
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_AdministrativoGeneral;

-- Administrativo bancario
GRANT EXECUTE ON OBJECT::fin.ImportarInfoBancaria TO Rol_AdministrativoBancario;
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_AdministrativoBancario;

-- Administrativo operativo
GRANT EXECUTE ON OBJECT::adm.ActualizarUF TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::rep.Dos_TotalUFporMes TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_Sistemas;

-- Sistemas
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Dos_TotalUFporMes TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_Sistemas;


--EXEC  2,2025
--EXEC rep.Cuatro_TopMeses 2,2025
--EXEC rep.Cinco_TopMora 2
