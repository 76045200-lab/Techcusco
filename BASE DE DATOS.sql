-- =====================================================================
-- ARCHIVO 1: CREACIÓN DE TABLAS, RELACIONES Y DATOS DE EJEMPLO
-- Curso: Data Analytics para los Negocios
-- Caso de negocio: TechCusco - Tienda online de tecnología
-- =====================================================================
---------
DROP TABLE IF EXISTS detalle_pedido CASCADE;
DROP TABLE IF EXISTS pedidos        CASCADE;
DROP TABLE IF EXISTS productos      CASCADE;
DROP TABLE IF EXISTS categorias     CASCADE;
DROP TABLE IF EXISTS clientes       CASCADE;

-- ---------------------------------------------------------------------
-- 1. Tabla CLIENTES
-- ---------------------------------------------------------------------
CREATE TABLE clientes (
    id_cliente      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre          VARCHAR(50)  NOT NULL,
    apellido        VARCHAR(50)  NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    ciudad          VARCHAR(50)  NOT NULL,
    fecha_registro  DATE         NOT NULL DEFAULT CURRENT_DATE
);

-- ---------------------------------------------------------------------
-- 2. Tabla CATEGORIAS
-- ---------------------------------------------------------------------
CREATE TABLE categorias (
    id_categoria  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre        VARCHAR(50)  NOT NULL UNIQUE,
    descripcion   VARCHAR(150)
);

-- ---------------------------------------------------------------------
--3. Tabla PRODUCTOS 
-- ---------------------------------------------------------------------
CREATE TABLE productos (
    id_producto   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    id_categoria  INTEGER      NOT NULL,
    precio        NUMERIC(10,2) NOT NULL CHECK (precio > 0),
    stock         INTEGER      NOT NULL DEFAULT 0 CHECK (stock >= 0),
    CONSTRAINT fk_productos_categoria
        FOREIGN KEY (id_categoria) REFERENCES categorias (id_categoria)
);

-- ---------------------------------------------------------------------
--4. Tabla PEDIDOS 
-- ---------------------------------------------------------------------
CREATE TABLE pedidos (
    id_pedido     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_cliente    INTEGER     NOT NULL,
    fecha_pedido  DATE        NOT NULL DEFAULT CURRENT_DATE,
    estado        VARCHAR(20) NOT NULL DEFAULT 'Pendiente'
                  CHECK (estado IN ('Pendiente', 'Enviado', 'Entregado', 'Cancelado')),
    metodo_pago   VARCHAR(30) NOT NULL
                  CHECK (metodo_pago IN ('Tarjeta', 'Yape', 'Transferencia')),
    CONSTRAINT fk_pedidos_cliente
        FOREIGN KEY (id_cliente) REFERENCES clientes (id_cliente)
);

-- ---------------------------------------------------------------------
-- 5. Tabla DETALLE_PEDIDO 
-- ---------------------------------------------------------------------
CREATE TABLE detalle_pedido (
    id_detalle       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_pedido        INTEGER       NOT NULL,
    id_producto      INTEGER       NOT NULL,
    cantidad         INTEGER       NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(10,2) NOT NULL CHECK (precio_unitario > 0),
    CONSTRAINT fk_detalle_pedido
        FOREIGN KEY (id_pedido)   REFERENCES pedidos (id_pedido)     ON DELETE CASCADE,
    CONSTRAINT fk_detalle_producto
        FOREIGN KEY (id_producto) REFERENCES productos (id_producto)
);

-- =====================================================================
-- DATOS DE EJEMPLO
-- =====================================================================

-- Clientes (ids 1 a 6)
INSERT INTO clientes (nombre, apellido, email, ciudad, fecha_registro) VALUES
('Ana',   'Quispe',  'ana.quispe@mail.com',   'Cusco',    '2026-01-10'),
('Luis',  'Mamani',  'luis.mamani@mail.com',  'Lima',     '2026-01-15'),
('María', 'Huamán',  'maria.huaman@mail.com', 'Arequipa', '2026-02-03'),
('Carlos','Flores',  'carlos.flores@mail.com','Cusco',    '2026-02-20'),
('Lucía', 'Ramos',   'lucia.ramos@mail.com',  'Lima',     '2026-03-05'),
('Jorge', 'Condori', 'jorge.condori@mail.com','Trujillo', '2026-03-18');

-- Categorías (ids 1 a 4)
INSERT INTO categorias (nombre, descripcion) VALUES
('Laptops',    'Computadoras portátiles para estudio y trabajo'),
('Celulares',  'Smartphones de gama media y alta'),
('Accesorios', 'Periféricos y complementos de cómputo'),
('Audio',      'Audífonos y parlantes');

-- Productos (ids 1 a 10)
INSERT INTO productos (nombre, id_categoria, precio, stock) VALUES
('Laptop Lenovo IdeaPad 3',     1, 2399.00, 15),
('Laptop HP 15',                1, 2799.00, 10),
('Samsung Galaxy A15',          2,  799.00, 30),
('Xiaomi Redmi Note 13',        2,  899.00, 25),
('Mouse inalámbrico Logitech',  3,   59.90, 80),
('Teclado mecánico Redragon',   3,  189.00, 40),
('Mochila para laptop',         3,   99.00, 50),
('Audífonos Bluetooth JBL',     4,  149.00, 60),
('Parlante Bluetooth Sony',     4,  259.00, 20),
('Webcam HD 1080p',             3,  129.00, 35);

-- Pedidos (ids 1 a 10)
INSERT INTO pedidos (id_cliente, fecha_pedido, estado, metodo_pago) VALUES
(1, '2026-04-02', 'Entregado', 'Tarjeta'),
(2, '2026-04-10', 'Entregado', 'Yape'),
(3, '2026-04-18', 'Entregado', 'Transferencia'),
(1, '2026-05-05', 'Entregado', 'Tarjeta'),
(4, '2026-05-12', 'Cancelado', 'Yape'),
(5, '2026-05-20', 'Entregado', 'Tarjeta'),
(2, '2026-06-01', 'Enviado',   'Yape'),
(3, '2026-06-15', 'Pendiente', 'Transferencia'),
(4, '2026-07-03', 'Entregado', 'Tarjeta'),
(5, '2026-07-22', 'Enviado',   'Yape');

-- Detalle de pedidos
INSERT INTO detalle_pedido (id_pedido, id_producto, cantidad, precio_unitario) VALUES
(1, 1, 1, 2399.00),
(1, 5, 1,   59.90),
(2, 3, 1,  799.00),
(2, 7, 1,   99.00),
(3, 2, 1, 2799.00),
(3, 6, 1,  189.00),
(4, 8, 2,  149.00),
(5, 4, 1,  899.00),
(6, 9, 1,  259.00),
(6, 5, 2,   59.90),
(7, 4, 1,  899.00),
(7, 8, 1,  149.00),
(8, 1, 1, 2399.00),
(9, 6, 1,  189.00),
(9, 7, 2,   99.00),
(10, 3, 2,  799.00),
(10, 5, 1,   59.90);

-- Verificación rápida: cantidad de registros por tabla
SELECT 'clientes' AS tabla, COUNT(*) AS registros FROM clientes
UNION ALL SELECT 'categorias',     COUNT(*) FROM categorias
UNION ALL SELECT 'productos',      COUNT(*) FROM productos
UNION ALL SELECT 'pedidos',        COUNT(*) FROM pedidos
UNION ALL SELECT 'detalle_pedido', COUNT(*) FROM detalle_pedido;
