USE parcial2_biblioteca;

-- Crear roles
CREATE ROLE rol_lector;
CREATE ROLE rol_bibliotecario;
CREATE ROLE rol_admin_biblioteca;

-- Lector: consultar únicamente las dos vistas
GRANT SELECT ON parcial2_biblioteca.vw_socios_publico
TO rol_lector;

GRANT SELECT ON parcial2_biblioteca.vw_prestamos_activos
TO rol_lector;

-- Bibliotecario: heredar lector y ejecutar las rutinas
GRANT rol_lector TO rol_bibliotecario;

GRANT EXECUTE ON PROCEDURE parcial2_biblioteca.sp_registrar_prestamo
TO rol_bibliotecario;

GRANT EXECUTE ON PROCEDURE parcial2_biblioteca.sp_registrar_devolucion
TO rol_bibliotecario;

GRANT EXECUTE ON FUNCTION parcial2_biblioteca.fn_calcular_multa
TO rol_bibliotecario;

-- Administrador: gestionar las tres tablas
GRANT SELECT, INSERT, UPDATE, DELETE
ON parcial2_biblioteca.socios
TO rol_admin_biblioteca;

GRANT SELECT, INSERT, UPDATE, DELETE
ON parcial2_biblioteca.libros
TO rol_admin_biblioteca;

GRANT SELECT, INSERT, UPDATE, DELETE
ON parcial2_biblioteca.prestamos
TO rol_admin_biblioteca;

-- Auditoría: solo consulta
GRANT SELECT ON parcial2_biblioteca.auditoria_socios
TO rol_admin_biblioteca;

-- Crear usuarios
CREATE USER 'u_lector'@'%'
IDENTIFIED BY 'Lector2026*';

CREATE USER 'u_bibliotecario'@'%'
IDENTIFIED BY 'Biblio2026*'
WITH MAX_USER_CONNECTIONS 3
PASSWORD EXPIRE INTERVAL 60 DAY;

CREATE USER 'u_admin_biblio'@'%'
IDENTIFIED BY 'Admin2026*';

-- Asignar roles
GRANT rol_lector TO 'u_lector'@'%';

GRANT rol_bibliotecario TO 'u_bibliotecario'@'%';

GRANT rol_admin_biblioteca TO 'u_admin_biblio'@'%';

-- Activar el rol por defecto de cada usuario
SET DEFAULT ROLE rol_lector
FOR 'u_lector'@'%';

SET DEFAULT ROLE rol_bibliotecario
FOR 'u_bibliotecario'@'%';

SET DEFAULT ROLE rol_admin_biblioteca
FOR 'u_admin_biblio'@'%';

-- Verificar asignaciones y restricciones
SHOW GRANTS FOR 'u_lector'@'%';
SHOW GRANTS FOR 'u_bibliotecario'@'%';
SHOW GRANTS FOR 'u_admin_biblio'@'%';

SHOW CREATE USER 'u_bibliotecario'@'%';