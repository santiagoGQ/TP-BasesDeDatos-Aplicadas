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
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_AdministrativoGeneral;
GRANT EXECUTE ON OBJECT::rep.Dos_TotalUFporMes TO Rol_AdministrativoGeneral;
GRANT EXECUTE ON OBJECT::rep.Tres_RecaudacionPorProcedencia TO Rol_AdministrativoGeneral;
GRANT EXECUTE ON OBJECT::rep.Cuatro_TopMeses TO Rol_AdministrativoGeneral;
GRANT EXECUTE ON OBJECT::rep.Cinco_TopMora TO Rol_AdministrativoGeneral;
GRANT EXECUTE ON OBJECT::rep.Seis_DiasPagosUF TO Rol_AdministrativoGeneral;
GRANT EXECUTE ON OBJECT::adm.ImportarInquilinoYPropietarios TO Rol_AdministrativoGeneral;
GRANT EXECUTE ON OBJECT::adm.ImportarRelacionEntreUFyPropInq TO Rol_AdministrativoGeneral;
GRANT EXECUTE ON OBJECT::adm.AgregarPropietario TO Rol_AdministrativoGeneral;
GRANT EXECUTE ON OBJECT::adm.AgregarInquilino TO Rol_AdministrativoGeneral;

-- Administrativo bancario
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_AdministrativoBancario;
GRANT EXECUTE ON OBJECT::rep.Dos_TotalUFporMes TO Rol_AdministrativoBancario;
GRANT EXECUTE ON OBJECT::rep.Tres_RecaudacionPorProcedencia TO Rol_AdministrativoBancario;
GRANT EXECUTE ON OBJECT::rep.Cuatro_TopMeses TO Rol_AdministrativoBancario;
GRANT EXECUTE ON OBJECT::rep.Cinco_TopMora TO Rol_AdministrativoBancario;
GRANT EXECUTE ON OBJECT::rep.Seis_DiasPagosUF TO Rol_AdministrativoBancario;
GRANT EXECUTE ON OBJECT::fin.ImportarPagos TO Rol_AdministrativoBancario;

-- Administrativo operativo
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::rep.Dos_TotalUFporMes TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::rep.Tres_RecaudacionPorProcedencia TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::rep.Cuatro_TopMeses TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::rep.Cinco_TopMora TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::rep.Seis_DiasPagosUF TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::adm.ImportarInquilinoYPropietarios TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::adm.ImportarRelacionEntreUFyPropInq TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::adm.AgregarPropietario TO Rol_AdministrativoOperativo;
GRANT EXECUTE ON OBJECT::adm.AgregarInquilino TO Rol_AdministrativoOperativo;

-- Sistemas
GRANT EXECUTE ON OBJECT::rep.Uno_FlujoSemanal TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Dos_TotalUFporMes TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Tres_RecaudacionPorProcedencia TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Cuatro_TopMeses TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Cinco_TopMora TO Rol_Sistemas;
GRANT EXECUTE ON OBJECT::rep.Seis_DiasPagosUF TO Rol_Sistemas;
