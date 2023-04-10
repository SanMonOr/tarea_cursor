drop database if exists supermercado;
create database supermercado;
use supermercado;

create table if not exists tipo_productos(
	id int primary key auto_increment,
    nombre varchar(50) not null
);

create table if not exists productos(
	id int primary key auto_increment,
    id_tipo_producto int not null,
    nombre varchar(50) not null,
    valor_venta int not null,
    foreign key (id_tipo_producto) references tipo_productos(id)
		on delete cascade
		on update cascade
);

create table if not exists inventario(
	id int primary key auto_increment,
	id_producto int not null,
    cantidad int not null,
    valor int,
    foreign key (id_producto) references productos(id)
		on delete cascade
        on update cascade
);

insert into tipo_productos(nombre) values ('carnes');
insert into tipo_productos(nombre) values ('frutas');

insert into productos(id_tipo_producto, nombre, valor_venta) values (1, 'carne molida', 14985);
insert into productos(id_tipo_producto, nombre, valor_venta) values (1, 'costilla de res', 14650);
insert into productos(id_tipo_producto, nombre, valor_venta) values (2, 'banano criollo (1lb)', 1900);
insert into productos(id_tipo_producto, nombre, valor_venta) values (2, 'fresa (1lb)', 12500);

-- Trigger
delimiter !
create trigger insercion_valor_total_productos before insert 
on inventario for each row
begin
	declare unidades int;
    declare valor_unidad int;
    declare precio_total int;
    
    --  Error: select new.cantidad into unidades from inventario;
    set unidades = new.cantidad;
    select P.valor_venta into valor_unidad from productos as P where P.id = new.id_producto;
    
    set precio_total = (unidades * valor_unidad);
	
    -- Error: update inventario set valor = precio_total where id = new.id;
    set new.valor = precio_total;
end
!
delimiter ;

insert into inventario(id_producto, cantidad) values (1, 2);
insert into inventario(id_producto, cantidad) values (2, 3);
insert into inventario(id_producto, cantidad) values (3, 14);
insert into inventario(id_producto, cantidad) values (4, 7);
-- drop trigger insercion_valor_total_productos;

-- Procedimiento Almacenado - Cursor
delimiter $
-- lista_por_categoria() recibe un id de categoría de producto y retorna una lista de todos los productos en un solo elemento varchar separados por comas
CREATE PROCEDURE lista_por_categoria (IN categoria_id int, OUT lista_productos VARCHAR(1000))
BEGIN
	DECLARE terminar INT DEFAULT 0;
    DECLARE producto VARCHAR(50) DEFAULT "";    
    
    DECLARE curProductos CURSOR FOR SELECT nombre FROM productos WHERE productos.id_tipo_producto = categoria_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET terminar = 1;
    
    SET lista_productos = "";
    
    OPEN curProductos;
    
    obtProducto: LOOP
		FETCH curProductos INTO producto;        
        IF terminar = 1 THEN
			LEAVE obtProducto;
		END IF;
        SET lista_productos = CONCAT(producto, ", ", lista_productos);        
	END LOOP obtProducto;
    
    set lista_productos = TRIM(", " from lista_productos);
    set lista_productos = CONCAT(lista_productos, ".");
    
    CLOSE curProductos;
END
$
DELIMITER ;

-- Ejemplo de Uso
SET @lista = "";
CALL lista_por_categoria(1, @lista);
SELECT @lista;

-- DROP PROCEDURE lista_por_categoria;
