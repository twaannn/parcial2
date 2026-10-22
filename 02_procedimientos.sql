USE parcial2_biblioteca;

DELIMITER //

CREATE PROCEDURE sp_registrar_prestamo(
    IN p_documento VARCHAR(15),
    IN p_isbn VARCHAR(20),
    OUT p_id_prestamo INT
)
BEGIN
    DECLARE v_socio_id INT;
    DECLARE v_estado VARCHAR(15);
    DECLARE v_libro_id INT;
    DECLARE v_disponibles INT;
    DECLARE v_cantidad INT;

    SELECT COUNT(*) INTO v_cantidad
    FROM socios
    WHERE documento = p_documento;

    IF v_cantidad = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El socio no existe';
    END IF;

    SELECT id, estado INTO v_socio_id, v_estado
    FROM socios
    WHERE documento = p_documento;

    IF v_estado = 'SUSPENDIDO' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El socio está suspendido';
    END IF;

    SELECT COUNT(*) INTO v_cantidad
    FROM prestamos
    WHERE socio_id = v_socio_id
      AND multa > 0
      AND multa_pagada = 0;

    IF v_cantidad > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El socio tiene multas pendientes';
    END IF;

    SELECT COUNT(*) INTO v_cantidad
    FROM prestamos
    WHERE socio_id = v_socio_id
      AND estado = 'ACTIVO';

    IF v_cantidad >= 3 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El socio ya tiene 3 préstamos activos';
    END IF;

    SELECT COUNT(*) INTO v_cantidad
    FROM libros
    WHERE isbn = p_isbn;

    IF v_cantidad = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El libro no existe';
    END IF;

    SELECT id, ejemplares_disponibles
    INTO v_libro_id, v_disponibles
    FROM libros
    WHERE isbn = p_isbn;

    IF v_disponibles = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No hay ejemplares disponibles';
    END IF;

    INSERT INTO prestamos (
        socio_id,
        libro_id,
        fecha_prestamo,
        fecha_limite
    )
    VALUES (
        v_socio_id,
        v_libro_id,
        CURDATE(),
        CURDATE() + INTERVAL 15 DAY
    );

    SET p_id_prestamo = LAST_INSERT_ID();

    UPDATE libros
    SET ejemplares_disponibles = ejemplares_disponibles - 1
    WHERE id = v_libro_id;
END //

CREATE PROCEDURE sp_registrar_devolucion(
    IN p_prestamo_id INT,
    OUT p_multa DECIMAL(10,2)
)
BEGIN
    DECLARE v_cantidad INT;
    DECLARE v_estado VARCHAR(15);
    DECLARE v_fecha_limite DATE;

    SELECT COUNT(*) INTO v_cantidad
    FROM prestamos
    WHERE id = p_prestamo_id;

    IF v_cantidad = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El préstamo no existe';
    END IF;

    SELECT estado, fecha_limite
    INTO v_estado, v_fecha_limite
    FROM prestamos
    WHERE id = p_prestamo_id;

    IF v_estado = 'DEVUELTO' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El préstamo ya fue devuelto';
    END IF;

    SET p_multa = fn_calcular_multa(v_fecha_limite, CURDATE());

    UPDATE prestamos
    SET fecha_devolucion = CURDATE(),
        multa = p_multa,
        estado = 'DEVUELTO'
    WHERE id = p_prestamo_id;
END //

DELIMITER ;