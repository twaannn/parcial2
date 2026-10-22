-- =====================================================================
-- SEGUNDO PARCIAL - BASES DE DATOS II - 21 de octubre de 2026
-- Script base: Biblioteca Municipal de Cartago
-- Ejecutar completo como root. NO modificar este script.
-- =====================================================================
DROP DATABASE IF EXISTS parcial2_biblioteca;
CREATE DATABASE parcial2_biblioteca CHARACTER SET utf8mb4;
USE parcial2_biblioteca;

CREATE TABLE socios (
    id         INT AUTO_INCREMENT PRIMARY KEY,
    documento  VARCHAR(15) NOT NULL UNIQUE,
    nombre     VARCHAR(60) NOT NULL,
    email      VARCHAR(80) NOT NULL,
    telefono   VARCHAR(15) NOT NULL,
    estado     ENUM('ACTIVO', 'SUSPENDIDO') NOT NULL DEFAULT 'ACTIVO'
) ENGINE = InnoDB;

CREATE TABLE libros (
    id                      INT AUTO_INCREMENT PRIMARY KEY,
    isbn                    VARCHAR(20)  NOT NULL UNIQUE,
    titulo                  VARCHAR(120) NOT NULL,
    autor                   VARCHAR(80)  NOT NULL,
    ejemplares_totales      INT NOT NULL,
    ejemplares_disponibles  INT NOT NULL,
    CONSTRAINT chk_ejemplares CHECK (ejemplares_disponibles BETWEEN 0 AND ejemplares_totales)
) ENGINE = InnoDB;

CREATE TABLE prestamos (
    id                INT AUTO_INCREMENT PRIMARY KEY,
    socio_id          INT  NOT NULL,
    libro_id          INT  NOT NULL,
    fecha_prestamo    DATE NOT NULL,
    fecha_limite      DATE NOT NULL,
    fecha_devolucion  DATE NULL,
    multa             DECIMAL(10,2) NOT NULL DEFAULT 0,
    multa_pagada      TINYINT(1)    NOT NULL DEFAULT 0,
    estado            ENUM('ACTIVO', 'DEVUELTO') NOT NULL DEFAULT 'ACTIVO',
    CONSTRAINT fk_prestamo_socio FOREIGN KEY (socio_id) REFERENCES socios(id),
    CONSTRAINT fk_prestamo_libro FOREIGN KEY (libro_id) REFERENCES libros(id)
) ENGINE = InnoDB;

CREATE TABLE auditoria_socios (
    id                   INT AUTO_INCREMENT PRIMARY KEY,
    socio_id             INT NOT NULL,
    campo                VARCHAR(30)  NOT NULL,
    valor_anterior       VARCHAR(100),
    valor_nuevo          VARCHAR(100),
    usuario_sesion       VARCHAR(100) NOT NULL,
    usuario_privilegios  VARCHAR(100) NOT NULL,
    fecha                DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE = InnoDB;

INSERT INTO socios (documento, nombre, email, telefono, estado) VALUES
('1112100001', 'Mariana Ospina',   'mariana@correo.com',  '3104561234', 'ACTIVO'),
('1112100002', 'Julián Castaño',   'julian@correo.com',   '3127894561', 'ACTIVO'),
('1112100003', 'Valentina Ríos',   'valentina@correo.com','3209871234', 'ACTIVO'),
('1112100004', 'Santiago Loaiza',  'santiago@correo.com', '3001237896', 'SUSPENDIDO'),
('1112100005', 'Camila Henao',     'camila@correo.com',   '3155550011', 'ACTIVO'),
('1112100006', 'Daniel Zapata',    'daniel@correo.com',   '3168884422', 'ACTIVO');

INSERT INTO libros (isbn, titulo, autor, ejemplares_totales, ejemplares_disponibles) VALUES
('978-958-001', 'Cien años de soledad',           'Gabriel García Márquez', 3, 1),
('978-958-002', 'María',                          'Jorge Isaacs',           2, 2),
('978-958-003', 'La vorágine',                    'José Eustasio Rivera',   2, 1),
('978-958-004', 'Delirio',                        'Laura Restrepo',         1, 0),
('978-958-005', 'El olvido que seremos',          'Héctor Abad Faciolince', 2, 1),
('978-958-006', 'Fundamentos de bases de datos',  'Silberschatz',           4, 4),
('978-958-007', 'Sistemas de bases de datos',     'Coronel y Morris',       2, 2),
('978-958-008', 'Rosario Tijeras',                'Jorge Franco',           1, 1);

-- Las fechas se calculan a partir de HOY para que los retrasos sean siempre los mismos
INSERT INTO prestamos (socio_id, libro_id, fecha_prestamo, fecha_limite, fecha_devolucion, multa, multa_pagada, estado) VALUES
-- Activos al día
(1, 1, CURDATE() - INTERVAL 5 DAY,  CURDATE() + INTERVAL 10 DAY, NULL, 0, 0, 'ACTIVO'),
(2, 3, CURDATE() - INTERVAL 3 DAY,  CURDATE() + INTERVAL 12 DAY, NULL, 0, 0, 'ACTIVO'),
-- Activos vencidos
(3, 1, CURDATE() - INTERVAL 20 DAY, CURDATE() - INTERVAL 5 DAY,  NULL, 0, 0, 'ACTIVO'),
(5, 4, CURDATE() - INTERVAL 40 DAY, CURDATE() - INTERVAL 25 DAY, NULL, 0, 0, 'ACTIVO'),
(1, 5, CURDATE() - INTERVAL 16 DAY, CURDATE() - INTERVAL 1 DAY,  NULL, 0, 0, 'ACTIVO'),
-- Devueltos (Julián tiene una multa SIN pagar)
(2, 2, CURDATE() - INTERVAL 60 DAY, CURDATE() - INTERVAL 45 DAY, CURDATE() - INTERVAL 40 DAY, 7500, 0, 'DEVUELTO'),
(6, 6, CURDATE() - INTERVAL 30 DAY, CURDATE() - INTERVAL 15 DAY, CURDATE() - INTERVAL 16 DAY, 0,    0, 'DEVUELTO'),
(4, 7, CURDATE() - INTERVAL 90 DAY, CURDATE() - INTERVAL 75 DAY, CURDATE() - INTERVAL 50 DAY, 30000, 1, 'DEVUELTO');

SELECT 'Base del parcial creada correctamente' AS mensaje;
SELECT (SELECT COUNT(*) FROM socios) AS socios,
       (SELECT COUNT(*) FROM libros) AS libros,
       (SELECT COUNT(*) FROM prestamos) AS prestamos;