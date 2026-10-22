USE parcial2_biblioteca;

CREATE VIEW vw_socios_publico AS
SELECT
    id,
    nombre,
    CONCAT(
        REPEAT('*', GREATEST(CHAR_LENGTH(documento) - 4, 0)),
        RIGHT(documento, 4)
    ) AS documento,
    CONCAT(
        REPEAT('*', GREATEST(CHAR_LENGTH(telefono) - 4, 0)),
        RIGHT(telefono, 4)
    ) AS telefono,
    estado
FROM socios;

CREATE VIEW vw_prestamos_activos AS
SELECT
    p.id,
    s.nombre AS socio,
    l.titulo AS libro,
    p.fecha_prestamo,
    p.fecha_limite,
    GREATEST(DATEDIFF(CURDATE(), p.fecha_limite), 0) AS dias_retraso,
    fn_calcular_multa(p.fecha_limite, CURDATE()) AS multa_estimada
FROM prestamos p
JOIN socios s ON p.socio_id = s.id
JOIN libros l ON p.libro_id = l.id
WHERE p.estado = 'ACTIVO';

-- Comprobar las dos vistas
SELECT * FROM vw_socios_publico;
SELECT * FROM vw_prestamos_activos;