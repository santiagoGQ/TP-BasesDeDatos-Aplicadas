CREATE OR ALTER VIEW fin.Vista_GastosPorExpensa
AS
SELECT *,
       total_gastado - gastos_extraordinarios AS total_gastos_ordinarios
FROM (
    SELECT 
        -- Identificadores
        e.id_expensa,
        c.id_consorcio,
        c.nombre AS nombre_consorcio,

        -- Fechas de la expensa
        e.fechaGenerado AS fecha_de_cierre,
        e.fechaPrimerVenc AS fecha_primer_vencimiento,
        e.fechaSegVenc AS fecha_segundo_vencimiento,

        -- Año y mes separados
        YEAR(e.fechaGenerado) AS anio,
        MONTH(e.fechaGenerado) AS mes,

        -- Totales por tipo de gasto
        ISNULL(SUM(DISTINCT fa_admin.importe_total), 0) AS gastos_administracion,
        ISNULL(SUM(DISTINCT fa_banc.importe_total), 0) AS gastos_bancarios,
        ISNULL(SUM(DISTINCT fa_extra.importe_total), 0) AS gastos_extraordinarios,
        ISNULL(SUM(DISTINCT fa_gen.importe_total), 0) AS gastos_generales,
        ISNULL(SUM(DISTINCT fa_limp.importe_total), 0) AS gastos_limpieza,
        ISNULL(SUM(DISTINCT fa_seg.importe_total), 0) AS gastos_seguros,
        ISNULL(SUM(DISTINCT fa_serv.importe_total), 0) AS gastos_servicios_publicos,

        -- Total general
        ISNULL(SUM(DISTINCT fa_admin.importe_total), 0)
        + ISNULL(SUM(DISTINCT fa_banc.importe_total), 0)
        + ISNULL(SUM(DISTINCT fa_extra.importe_total), 0)
        + ISNULL(SUM(DISTINCT fa_gen.importe_total), 0)
        + ISNULL(SUM(DISTINCT fa_limp.importe_total), 0)
        + ISNULL(SUM(DISTINCT fa_seg.importe_total), 0)
        + ISNULL(SUM(DISTINCT fa_serv.importe_total), 0)
        AS total_gastado

    FROM adm.Expensa e
    INNER JOIN adm.Consorcio c ON c.id_consorcio = e.id_consorcio

    -- ADMINISTRACION
    LEFT JOIN (
        SELECT ga.id_expensa, SUM(fa.importe) AS importe_total
        FROM gasto.Administracion ga
        INNER JOIN fin.Factura fa ON fa.nro_factura = ga.nro_factura
        GROUP BY ga.id_expensa
    ) fa_admin ON fa_admin.id_expensa = e.id_expensa

    -- BANCARIOS
    LEFT JOIN (
        SELECT gb.id_expensa, SUM(fb.importe) AS importe_total
        FROM gasto.Bancario gb
        INNER JOIN fin.Factura fb ON fb.nro_factura = gb.nro_factura
        GROUP BY gb.id_expensa
    ) fa_banc ON fa_banc.id_expensa = e.id_expensa

    -- EXTRAORDINARIOS
    LEFT JOIN (
        SELECT ge.id_expensa, SUM(fx.importe) AS importe_total
        FROM gasto.Extraordinario ge
        INNER JOIN fin.Factura fx ON fx.nro_factura = ge.nro_factura
        GROUP BY ge.id_expensa
    ) fa_extra ON fa_extra.id_expensa = e.id_expensa

    -- GENERALES
    LEFT JOIN (
        SELECT gg.id_expensa, SUM(fg.importe) AS importe_total
        FROM gasto.General gg
        INNER JOIN fin.Factura fg ON fg.nro_factura = gg.nro_factura
        GROUP BY gg.id_expensa
    ) fa_gen ON fa_gen.id_expensa = e.id_expensa

    -- LIMPIEZA
    LEFT JOIN (
        SELECT gl.id_expensa, SUM(fl.importe) AS importe_total
        FROM gasto.Limpieza gl
        INNER JOIN fin.Factura fl ON fl.nro_factura = gl.nro_factura
        GROUP BY gl.id_expensa
    ) fa_limp ON fa_limp.id_expensa = e.id_expensa

    -- SEGUROS
    LEFT JOIN (
        SELECT gs.id_expensa, SUM(fs.importe) AS importe_total
        FROM gasto.Seguro gs
        INNER JOIN fin.Factura fs ON fs.nro_factura = gs.nro_factura
        GROUP BY gs.id_expensa
    ) fa_seg ON fa_seg.id_expensa = e.id_expensa

    -- SERVICIOS PUBLICOS
    LEFT JOIN (
        SELECT gsp.id_expensa, SUM(fp.importe) AS importe_total
        FROM gasto.ServicioPublico gsp
        INNER JOIN fin.Factura fp ON fp.nro_factura = gsp.nro_factura
        GROUP BY gsp.id_expensa
    ) fa_serv ON fa_serv.id_expensa = e.id_expensa

    GROUP BY 
        e.id_expensa,
        c.id_consorcio,
        c.nombre,
        e.fechaGenerado,
        e.fechaPrimerVenc,
        e.fechaSegVenc,
        YEAR(e.fechaGenerado),
        MONTH(e.fechaGenerado)
) AS Resultado;
GO

CREATE OR ALTER VIEW fin.Vista_UfYConsorcio
AS
SELECT 
    cons.id_consorcio,
    cons.nombre,
    cons.direccion,
    cons.precio_bauleraM2,
    cons.precio_cocheraM2,
    ROW_NUMBER() OVER (PARTITION BY cons.id_consorcio order by uf.id_uni_func) as nro_uf,
    uf.id_uni_func,
    uf.id_inq,
    uf.id_prop,
    uf.total_m2,
    uf.piso,
    uf.depto,
    uf.coeficiente,
    uf.cbu,
    uf.baulera_m2,
    uf.cochera_m2
FROM adm.UnidadFuncional uf inner join adm.Consorcio cons on cons.id_consorcio = uf.id_consorcio
GO

-- SELECT * FROM fin.Vista_GastosPorExpensa
-- SELECT * FROM fin.Vista_UfYConsorcio where id_consorcio=6
-- SELECT (SELECT nombre from adm.Consorcio where id_consorcio=1) + (SELECT direccion from adm.Consorcio where id_consorcio=1)