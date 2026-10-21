
-- CONSULTAS SQL
-- Curso: Data Analytics para los Negocios
-- Caso de negocio: TechCusco - Tienda online de tecnología

-- ---------------------------------------------------------------------
-- CONSULTA 1: SELECT básico con filtro y orden
-- Productos con precio mayor a S/ 500, del más caro al más barato

SELECT id_producto, nombre, precio, stock
FROM productos
WHERE precio > 500
ORDER BY precio DESC;

-- CONSULTA 2: INNER JOIN (productos + categorias)
-- Catálogo de productos con el nombre de su categoría

SELECT p.id_producto,
       p.nombre      AS producto,
       c.nombre      AS categoria,
       p.precio
FROM productos p
INNER JOIN categorias c ON c.id_categoria = p.id_categoria
ORDER BY c.nombre, p.nombre;


-- CONSULTA 3: INNER JOIN (pedidos + clientes)
-- Listado de pedidos con el nombre del cliente

SELECT pe.id_pedido,
       cl.nombre || ' ' || cl.apellido AS cliente,
       cl.ciudad,
       pe.fecha_pedido,
       pe.estado,
       pe.metodo_pago
FROM pedidos pe
INNER JOIN clientes cl ON cl.id_cliente = pe.id_cliente
ORDER BY pe.fecha_pedido;


-- CONSULTA 4: LEFT JOIN + COUNT
-- Cantidad de pedidos por cliente (incluye clientes sin pedidos)

SELECT cl.id_cliente,
       cl.nombre || ' ' || cl.apellido AS cliente,
       COUNT(pe.id_pedido)             AS total_pedidos
FROM clientes cl
LEFT JOIN pedidos pe ON pe.id_cliente = cl.id_cliente
GROUP BY cl.id_cliente, cl.nombre, cl.apellido
ORDER BY total_pedidos DESC;


-- CONSULTA 5: JOIN de 3 tablas + SUM
-- Ventas totales (S/) por categoría, sin contar pedidos cancelados

SELECT c.nombre AS categoria,
       SUM(d.cantidad * d.precio_unitario) AS ventas_totales
FROM detalle_pedido d
INNER JOIN productos  p  ON p.id_producto  = d.id_producto
INNER JOIN categorias c  ON c.id_categoria = p.id_categoria
INNER JOIN pedidos    pe ON pe.id_pedido   = d.id_pedido
WHERE pe.estado <> 'Cancelado'
GROUP BY c.nombre
ORDER BY ventas_totales DESC;


-- CONSULTA 6: AVG
-- Precio promedio de los productos por categoría

SELECT c.nombre AS categoria,
       ROUND(AVG(p.precio), 2) AS precio_promedio
FROM productos p
INNER JOIN categorias c ON c.id_categoria = p.id_categoria
GROUP BY c.nombre
ORDER BY precio_promedio DESC;


-- CONSULTA 7: MAX y MIN
-- Producto más caro y más barato de cada categoría

SELECT c.nombre AS categoria,
       MAX(p.precio) AS precio_maximo,
       MIN(p.precio) AS precio_minimo
FROM productos p
INNER JOIN categorias c ON c.id_categoria = p.id_categoria
GROUP BY c.nombre
ORDER BY c.nombre;


-- CONSULTA 8: SUM + HAVING
-- Clientes que han gastado más de S/ 1,000 (pedidos no cancelados)

SELECT cl.nombre || ' ' || cl.apellido AS cliente,
       COUNT(DISTINCT pe.id_pedido)    AS pedidos,
       SUM(d.cantidad * d.precio_unitario) AS total_gastado
FROM clientes cl
INNER JOIN pedidos        pe ON pe.id_cliente = cl.id_cliente
INNER JOIN detalle_pedido d  ON d.id_pedido   = pe.id_pedido
WHERE pe.estado <> 'Cancelado'
GROUP BY cl.id_cliente, cl.nombre, cl.apellido
HAVING SUM(d.cantidad * d.precio_unitario) > 1000
ORDER BY total_gastado DESC;


-- CONSULTA 9: Productos más vendidos (SUM de unidades)
-- Top 5 productos por cantidad de unidades vendidas

SELECT p.nombre AS producto,
       SUM(d.cantidad) AS unidades_vendidas
FROM detalle_pedido d
INNER JOIN productos p  ON p.id_producto = d.id_producto
INNER JOIN pedidos   pe ON pe.id_pedido  = d.id_pedido
WHERE pe.estado <> 'Cancelado'
GROUP BY p.nombre
ORDER BY unidades_vendidas DESC
LIMIT 5;


-- CONSULTA 10: Ticket promedio por método de pago (COUNT + AVG)
-- Cuántos pedidos y qué valor promedio tiene cada método de pago

SELECT t.metodo_pago,
       COUNT(*)                     AS pedidos,
       ROUND(AVG(t.total_pedido),2) AS ticket_promedio
FROM (
    SELECT pe.id_pedido,
           pe.metodo_pago,
           SUM(d.cantidad * d.precio_unitario) AS total_pedido
    FROM pedidos pe
    INNER JOIN detalle_pedido d ON d.id_pedido = pe.id_pedido
    WHERE pe.estado <> 'Cancelado'
    GROUP BY pe.id_pedido, pe.metodo_pago
) t
GROUP BY t.metodo_pago
ORDER BY ticket_promedio DESC;


-- CONSULTA 11: Ventas por mes (agrupación por fecha)

SELECT TO_CHAR(pe.fecha_pedido, 'YYYY-MM') AS mes,
       COUNT(DISTINCT pe.id_pedido)        AS pedidos,
       SUM(d.cantidad * d.precio_unitario) AS ventas
FROM pedidos pe
INNER JOIN detalle_pedido d ON d.id_pedido = pe.id_pedido
WHERE pe.estado <> 'Cancelado'
GROUP BY TO_CHAR(pe.fecha_pedido, 'YYYY-MM')
ORDER BY mes;


-- CONSULTA 12: LEFT JOIN + IS NULL
-- Productos que nunca se han vendido

SELECT p.id_producto, p.nombre, p.stock
FROM productos p
LEFT JOIN detalle_pedido d ON d.id_producto = p.id_producto
WHERE d.id_detalle IS NULL;


-- CONSULTA 13: Reporte completo (JOIN de 5 tablas)
-- Detalle de cada venta: cliente, producto, categoría y subtotal

SELECT pe.id_pedido,
       pe.fecha_pedido,
       cl.nombre || ' ' || cl.apellido AS cliente,
       c.nombre                        AS categoria,
       p.nombre                        AS producto,
       d.cantidad,
       d.precio_unitario,
       (d.cantidad * d.precio_unitario) AS subtotal
FROM detalle_pedido d
INNER JOIN pedidos    pe ON pe.id_pedido    = d.id_pedido
INNER JOIN clientes   cl ON cl.id_cliente   = pe.id_cliente
INNER JOIN productos  p  ON p.id_producto   = d.id_producto
INNER JOIN categorias c  ON c.id_categoria  = p.id_categoria
ORDER BY pe.id_pedido, p.nombre;
