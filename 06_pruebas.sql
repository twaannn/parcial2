USE parcial2_biblioteca;

-- R2: función de multas
-- Esperado: 0.00, 1500.00, 7500.00 y 30000.00
SELECT
    fn_calcular_multa(CURDATE(), CURDATE()) AS sin_retraso,
    fn_calcular_multa(CURDATE() - INTERVAL 1 DAY, CURDATE()) AS un_dia,
    fn_calcular_multa(CURDATE() - INTERVAL 5 DAY, CURDATE()) AS cinco_dias,
    fn_calcular_multa(CURDATE() - INTERVAL 25 DAY, CURDATE()) AS tope;

-- R6: consultar las vistas
SELECT * FROM vw_socios_publico;
SELECT * FROM vw_prestamos_activos;

-- R3: socio inexistente
-- Esperado: El socio no existe
CALL sp_registrar_prestamo('9999999999', '978-958-006', @id);

-- R3: socio suspendido
-- Esperado: El socio está suspendido
CALL sp_registrar_prestamo('1112100004', '978-958-006', @id);

-- R3: multas pendientes
-- Esperado: El socio tiene multas pendientes
CALL sp_registrar_prestamo('1112100002', '978-958-006', @id);

-- R3: libro inexistente
-- Esperado: El libro no existe
CALL sp_registrar_prestamo('1112100006', 'ISBN-INEXISTENTE', @id);

-- R3: sin ejemplares disponibles
-- Esperado: No hay ejemplares disponibles
CALL sp_registrar_prestamo('1112100006', '978-958-004', @id);

-- R3: préstamo exitoso
START TRANSACTION;

CALL sp_registrar_prestamo('1112100006', '978-958-006', @id);

SELECT
    p.id,
    p.socio_id,
    p.libro_id,
    p.fecha_prestamo,
    p.fecha_limite,
    DATEDIFF(p.fecha_limite, p.fecha_prestamo) AS dias_plazo,
    p.estado,
    l.ejemplares_disponibles
FROM prestamos p
JOIN libros l ON l.id = p.libro_id
WHERE p.id = @id;

-- R4 y R5: devolución con multa y recuperación del ejemplar
START TRANSACTION;

SELECT ejemplares_disponibles INTO @stock_antes
FROM libros
WHERE id = 4;

CALL sp_registrar_devolucion(4, @multa);

SELECT
    p.id,
    p.fecha_devolucion,
    p.estado,
    p.multa,
    @multa AS multa_retornada,
    @stock_antes AS disponibles_antes,
    l.ejemplares_disponibles AS disponibles_despues
FROM prestamos p
JOIN libros l ON l.id = p.libro_id
WHERE p.id = 4;



-- ==================================================
-- R7: ejecutar conectado como u_lector
-- ==================================================

SELECT USER(), CURRENT_ROLE();

-- Permitido
SELECT * FROM parcial2_biblioteca.vw_socios_publico;

-- Denegado: no puede consultar directamente socios
SELECT * FROM parcial2_biblioteca.socios;


-- ==================================================
-- R7: ejecutar conectado como u_bibliotecario
-- ==================================================

SELECT USER(), CURRENT_ROLE();

-- Permitido
SELECT parcial2_biblioteca.fn_calcular_multa(
    CURDATE() - INTERVAL 5 DAY,
    CURDATE()
) AS multa;

-- Denegado: no puede modificar directamente libros
UPDATE parcial2_biblioteca.libros
SET titulo = 'Cambio no permitido'
WHERE id = 1;


-- ==================================================
-- R7: ejecutar conectado como u_admin_biblio
-- ==================================================

SELECT USER(), CURRENT_ROLE();

-- Permitido
SELECT * FROM parcial2_biblioteca.socios;

-- Denegado: solo tiene SELECT sobre auditoría
DELETE FROM parcial2_biblioteca.auditoria_socios
WHERE id = 1;