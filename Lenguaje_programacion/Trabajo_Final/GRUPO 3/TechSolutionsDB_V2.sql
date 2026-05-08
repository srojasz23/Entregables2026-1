
--  Servidor : localhost | Auth: Windows (DESKTOP-9NEGIV2\HP)

USE master;
GO
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'TechSolutionsDB')
BEGIN
    ALTER DATABASE TechSolutionsDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TechSolutionsDB;
END
GO
CREATE DATABASE TechSolutionsDB COLLATE SQL_Latin1_General_CP1_CI_AS;
GO
USE TechSolutionsDB;
GO

-- ================================================================
-- TABLA: ROL
-- ================================================================
CREATE TABLE Rol (
    IdRol       INT           IDENTITY(1,1) PRIMARY KEY,
    Nombre      NVARCHAR(50)  NOT NULL UNIQUE,
    Descripcion NVARCHAR(200) NULL
);
INSERT INTO Rol (Nombre, Descripcion) VALUES
('Administrador', 'Acceso total al sistema'),
('Vendedor',      'Acceso a ventas y consultas'),
('Almacenero',    'Acceso a productos e inventario');


CREATE TABLE Permiso (
    IdPermiso   INT           IDENTITY(1,1) PRIMARY KEY,
    IdRol       INT           NOT NULL,
    Modulo      NVARCHAR(50)  NOT NULL,
    PuedeVer    BIT           DEFAULT 1,
    PuedeEditar BIT           DEFAULT 0,
    FOREIGN KEY (IdRol) REFERENCES Rol(IdRol)
);
INSERT INTO Permiso (IdRol, Modulo, PuedeVer, PuedeEditar) VALUES
(1,'Clientes',1,1),(1,'Productos',1,1),(1,'Ventas',1,1),(1,'Reportes',1,1),(1,'Usuarios',1,1),
(2,'Clientes',1,1),(2,'Productos',1,0),(2,'Ventas',1,1),(2,'Reportes',1,0),(2,'Usuarios',0,0),
(3,'Clientes',0,0),(3,'Productos',1,1),(3,'Ventas',0,0),(3,'Reportes',0,0),(3,'Usuarios',0,0);

-- ================================================================
-- TABLA: USUARIO
-- ================================================================
CREATE TABLE Usuario (
    IdUsuario   INT           IDENTITY(1,1) PRIMARY KEY,
    Nombres     NVARCHAR(100) NOT NULL,
    Usuario     NVARCHAR(50)  NOT NULL UNIQUE,
    Password    NVARCHAR(100) NOT NULL,
    IdRol       INT           NOT NULL DEFAULT 2,
    Estado      BIT           NOT NULL DEFAULT 1,
    FechaCreacion DATETIME    DEFAULT GETDATE(),
    FOREIGN KEY (IdRol) REFERENCES Rol(IdRol)
);
INSERT INTO Usuario (Nombres, Usuario, Password, IdRol, Estado) VALUES
('Administrador',  'admin',  '123', 1, 1),
('José Vendedor',  'José Velasquez',   '123', 2, 1),
('Marco Almacen',  'Marco Alvarado',  '123', 3, 1);

CREATE TABLE Categoria (
    IdCategoria INT           IDENTITY(1,1) PRIMARY KEY,
    Nombre      NVARCHAR(100) NOT NULL UNIQUE,
    Descripcion NVARCHAR(200) NULL,
    Estado      BIT           NOT NULL DEFAULT 1
);
INSERT INTO Categoria (Nombre, Descripcion) VALUES
('Laptops',        'Computadoras portatiles'),
('Accesorios',     'Perifericos y accesorios'),
('Monitores',      'Pantallas y monitores'),
('Almacenamiento', 'Discos y memorias'),
('Impresoras',     'Impresoras y consumibles'),
('Componentes',    'Componentes de PC');

CREATE TABLE Proveedor (
    IdProveedor INT           IDENTITY(1,1) PRIMARY KEY,
    RazonSocial NVARCHAR(150) NOT NULL,
    RUC         NVARCHAR(20)  NULL,
    Telefono    NVARCHAR(20)  NULL,
    Email       NVARCHAR(100) NULL,
    Direccion   NVARCHAR(200) NULL,
    Estado      BIT           NOT NULL DEFAULT 1
);
INSERT INTO Proveedor (RazonSocial, RUC, Telefono, Email) VALUES
('HP Peru SAC',        '20100234567', '01-6234567', 'ventas@hp.pe'),
('Logitech Peru',      '20200345678', '01-7345678', 'info@logitech.pe'),
('Samsung Electronics','20300456789', '01-8456789', 'samsung@samsung.pe'),
('Importaciones Tech', '20400567890', '01-9567890', 'admin@importech.pe');

CREATE TABLE Cliente (
    IdCliente   INT           IDENTITY(1,1) PRIMARY KEY,
    Nombres     NVARCHAR(100) NOT NULL,
    Documento   NVARCHAR(20)  NOT NULL,
    TipoDoc     NVARCHAR(10)  NOT NULL DEFAULT 'DNI',
    Telefono    NVARCHAR(20)  NULL,
    Email       NVARCHAR(100) NULL,
    Direccion   NVARCHAR(200) NULL,
    Estado      BIT           NOT NULL DEFAULT 1,
    FechaReg    DATETIME      DEFAULT GETDATE()
);
INSERT INTO Cliente (Nombres, Documento, TipoDoc, Telefono, Email) VALUES
('Juan Perez',    '12345678', 'DNI', '999111222', 'juan@gmail.com'),
('Maria Lopez',   '87654321', 'DNI', '988777666', 'maria@gmail.com'),
('Carlos Ramos',  '45612378', 'DNI', '977333444', 'carlos@gmail.com'),
('Ana Torres',    '32165498', 'DNI', '966555777', 'ana@gmail.com'),
('Pedro Sanchez', '65498732', 'DNI', '955444333', 'pedro@gmail.com');

CREATE TABLE Producto (
    IdProducto  INT           IDENTITY(1,1) PRIMARY KEY,
    Nombre      NVARCHAR(150) NOT NULL,
    IdCategoria INT           NOT NULL,
    IdProveedor INT           NULL,
    Precio      DECIMAL(10,2) NOT NULL CHECK (Precio > 0),
    Costo       DECIMAL(10,2) NOT NULL DEFAULT 0,
    Stock       INT           NOT NULL DEFAULT 0 CHECK (Stock >= 0),
    StockMinimo INT           NOT NULL DEFAULT 5,
    Estado      BIT           NOT NULL DEFAULT 1,
    FOREIGN KEY (IdCategoria) REFERENCES Categoria(IdCategoria),
    FOREIGN KEY (IdProveedor) REFERENCES Proveedor(IdProveedor)
);
INSERT INTO Producto (Nombre, IdCategoria, IdProveedor, Precio, Costo, Stock, StockMinimo) VALUES
('Laptop HP 250 G9',         1, 1, 2500.00, 2000.00, 10, 3),
('Laptop Dell Inspiron',     1, 4, 3200.00, 2600.00,  8, 3),
('Mouse Logitech M185',      2, 2,   50.00,   30.00,100, 10),
('Teclado Mecanico RGB',     2, 4,  120.00,   80.00, 50, 10),
('Monitor 24" Samsung FHD',  3, 3,  800.00,  600.00, 20, 5),
('Monitor 27" 4K',           3, 3, 1200.00,  950.00,  6, 3),
('Impresora Epson L3150',    5, 4,  750.00,  580.00,  8, 3),
('Disco SSD 512GB',          4, 4,  180.00,  130.00, 15, 5),
('Memoria RAM 8GB DDR4',     4, 4,   60.00,   40.00, 30, 8),
('Disco SSD 1TB',            4, 4,  280.00,  210.00, 12, 5);

CREATE TABLE Venta (
    IdVenta     INT           IDENTITY(1,1) PRIMARY KEY,
    Numero      NVARCHAR(20)  NOT NULL UNIQUE,
    Fecha       DATETIME      NOT NULL DEFAULT GETDATE(),
    IdCliente   INT           NOT NULL,
    IdUsuario   INT           NOT NULL,
    Subtotal    DECIMAL(10,2) NOT NULL DEFAULT 0,
    IGV         DECIMAL(10,2) NOT NULL DEFAULT 0,
    Total       DECIMAL(10,2) NOT NULL DEFAULT 0,
    Estado      NVARCHAR(20)  NOT NULL DEFAULT 'Completada',
    FOREIGN KEY (IdCliente)  REFERENCES Cliente(IdCliente),
    FOREIGN KEY (IdUsuario)  REFERENCES Usuario(IdUsuario)
);

CREATE TABLE DetalleVenta (
    IdDetalle   INT           IDENTITY(1,1) PRIMARY KEY,
    IdVenta     INT           NOT NULL,
    IdProducto  INT           NOT NULL,
    Cantidad    INT           NOT NULL CHECK (Cantidad > 0),
    PrecioUnit  DECIMAL(10,2) NOT NULL,
    Descuento   DECIMAL(10,2) NOT NULL DEFAULT 0,
    Subtotal    DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (IdVenta)    REFERENCES Venta(IdVenta),
    FOREIGN KEY (IdProducto) REFERENCES Producto(IdProducto)
);

CREATE TABLE Compra (
    IdCompra    INT           IDENTITY(1,1) PRIMARY KEY,
    Numero      NVARCHAR(20)  NOT NULL UNIQUE,
    Fecha       DATETIME      NOT NULL DEFAULT GETDATE(),
    IdProveedor INT           NOT NULL,
    IdUsuario   INT           NOT NULL,
    Total       DECIMAL(10,2) NOT NULL DEFAULT 0,
    Estado      NVARCHAR(20)  NOT NULL DEFAULT 'Recibida',
    FOREIGN KEY (IdProveedor) REFERENCES Proveedor(IdProveedor),
    FOREIGN KEY (IdUsuario)   REFERENCES Usuario(IdUsuario)
);

CREATE TABLE DetalleCompra (
    IdDetalle   INT           IDENTITY(1,1) PRIMARY KEY,
    IdCompra    INT           NOT NULL,
    IdProducto  INT           NOT NULL,
    Cantidad    INT           NOT NULL CHECK (Cantidad > 0),
    PrecioUnit  DECIMAL(10,2) NOT NULL,
    Subtotal    DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (IdCompra)   REFERENCES Compra(IdCompra),
    FOREIGN KEY (IdProducto) REFERENCES Producto(IdProducto)
);

INSERT INTO Venta (Numero, Fecha, IdCliente, IdUsuario, Subtotal, IGV, Total) VALUES
('V-000001', DATEADD(day,-5,GETDATE()), 1, 1, 2118.64, 381.36, 2500.00),
('V-000002', DATEADD(day,-4,GETDATE()), 2, 1,  677.97, 122.03,  800.00),
('V-000003', DATEADD(day,-3,GETDATE()), 3, 2,  271.19,  48.81,  320.00),
('V-000004', DATEADD(day,-2,GETDATE()), 4, 2, 1016.95, 183.05, 1200.00),
('V-000005', DATEADD(day,-1,GETDATE()), 5, 1,  635.59, 114.41,  750.00),
('V-000006', GETDATE(),                 1, 1,  423.73,  76.27,  500.00),
('V-000007', GETDATE(),                 2, 2,  847.46, 152.54, 1000.00),
('V-000008', GETDATE(),                 3, 1,  211.86,  38.14,  250.00);

INSERT INTO DetalleVenta (IdVenta, IdProducto, Cantidad, PrecioUnit, Subtotal) VALUES
(1,1,1,2500.00,2500.00),(2,5,1,800.00,800.00),
(3,3,2,50.00,100.00),(3,4,1,120.00,120.00),(3,9,1,60.00,60.00),(3,8,1,180.00,180.00),
(4,6,1,1200.00,1200.00),(5,7,1,750.00,750.00),
(6,3,3,50.00,150.00),(6,9,2,60.00,120.00),(6,8,1,180.00,180.00),(6,4,0,120.00,0.00),
(7,2,1,800.00,800.00),(7,5,1,200.00,200.00),
(8,3,1,50.00,50.00),(8,9,3,60.00,180.00),(8,4,0,120.00,0.00);

-- Ajustar stock
UPDATE Producto SET Stock=Stock-1 WHERE IdProducto IN (1,2);
UPDATE Producto SET Stock=Stock-7 WHERE IdProducto=3;
UPDATE Producto SET Stock=Stock-2 WHERE IdProducto=4;
UPDATE Producto SET Stock=Stock-2 WHERE IdProducto=5;
UPDATE Producto SET Stock=Stock-1 WHERE IdProducto IN (6,7);
UPDATE Producto SET Stock=Stock-2 WHERE IdProducto=8;
UPDATE Producto SET Stock=Stock-6 WHERE IdProducto=9;
GO

CREATE PROCEDURE sp_Dashboard
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        (SELECT ISNULL(SUM(Total),0) FROM Venta WHERE MONTH(Fecha)=MONTH(GETDATE()) AND YEAR(Fecha)=YEAR(GETDATE())) AS VentasMes,
        (SELECT COUNT(*) FROM Venta WHERE CAST(Fecha AS DATE)=CAST(GETDATE() AS DATE))   AS VentasHoy,
        (SELECT ISNULL(SUM(Total),0) FROM Venta WHERE CAST(Fecha AS DATE)=CAST(GETDATE() AS DATE)) AS MontoHoy,
        (SELECT COUNT(*) FROM Producto WHERE Estado=1)                                   AS TotalProductos,
        (SELECT COUNT(*) FROM Cliente WHERE Estado=1)                                    AS TotalClientes,
        (SELECT COUNT(*) FROM Producto WHERE Stock <= StockMinimo AND Estado=1)          AS StockBajo,
        (SELECT ISNULL(SUM(Total - (SELECT ISNULL(SUM(d.Cantidad*p.Costo),0) FROM DetalleVenta d JOIN Producto p ON d.IdProducto=p.IdProducto WHERE d.IdVenta=v.IdVenta)),0) FROM Venta v WHERE CAST(Fecha AS DATE)=CAST(GETDATE() AS DATE)) AS GananciaHoy;
END
GO

CREATE PROCEDURE sp_VentasPorFecha
    @Inicio DATETIME, @Fin DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.IdVenta,
           v.Numero,
           CONVERT(VARCHAR(20),v.Fecha,103) AS Fecha,
           c.Nombres AS Cliente,
           c.Documento,
           u.Nombres AS Vendedor,
           v.Subtotal, v.IGV, v.Total, v.Estado
    FROM Venta v
    INNER JOIN Cliente  c ON v.IdCliente = c.IdCliente
    INNER JOIN Usuario  u ON v.IdUsuario = u.IdUsuario
    WHERE v.Fecha BETWEEN @Inicio AND DATEADD(second,86399,@Fin)
    ORDER BY v.Fecha DESC;
END
GO

CREATE PROCEDURE sp_VentasDelDia
AS
BEGIN
    SET NOCOUNT ON;
    SELECT v.Numero, CONVERT(VARCHAR(8),v.Fecha,108) AS Hora,
           c.Nombres AS Cliente, v.Total, v.Estado,
           u.Nombres AS Vendedor
    FROM Venta v
    INNER JOIN Cliente c ON v.IdCliente=c.IdCliente
    INNER JOIN Usuario u ON v.IdUsuario=u.IdUsuario
    WHERE CAST(v.Fecha AS DATE) = CAST(GETDATE() AS DATE)
    ORDER BY v.Fecha DESC;
END
GO

CREATE PROCEDURE sp_ProductosMasVendidos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Nombre, cat.Nombre AS Categoria,
           SUM(d.Cantidad) AS TotalVendido,
           SUM(d.Subtotal) AS TotalIngreso
    FROM DetalleVenta d
    INNER JOIN Producto  p   ON d.IdProducto  = p.IdProducto
    INNER JOIN Categoria cat ON p.IdCategoria = cat.IdCategoria
    GROUP BY p.Nombre, cat.Nombre
    ORDER BY TotalVendido DESC;
END
GO

CREATE PROCEDURE sp_StockBajo
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.IdProducto, p.Nombre, cat.Nombre AS Categoria,
           p.Stock, p.StockMinimo, p.Precio
    FROM Producto p
    INNER JOIN Categoria cat ON p.IdCategoria=cat.IdCategoria
    WHERE p.Stock <= p.StockMinimo AND p.Estado=1
    ORDER BY p.Stock ASC;
END
GO

CREATE PROCEDURE sp_GananciaDia
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        v.Numero, c.Nombres AS Cliente, v.Total,
        ISNULL((SELECT SUM(d.Cantidad * pr.Costo) FROM DetalleVenta d
                JOIN Producto pr ON d.IdProducto=pr.IdProducto
                WHERE d.IdVenta=v.IdVenta),0) AS Costo,
        v.Total - ISNULL((SELECT SUM(d.Cantidad * pr.Costo) FROM DetalleVenta d
                JOIN Producto pr ON d.IdProducto=pr.IdProducto
                WHERE d.IdVenta=v.IdVenta),0) AS Ganancia
    FROM Venta v
    INNER JOIN Cliente c ON v.IdCliente=c.IdCliente
    WHERE CAST(v.Fecha AS DATE) = CAST(GETDATE() AS DATE)
    ORDER BY v.Fecha DESC;
END
GO

CREATE PROCEDURE sp_VentasPorCategoria
AS
BEGIN
    SET NOCOUNT ON;
    SELECT cat.Nombre AS Categoria, SUM(d.Subtotal) AS Total
    FROM DetalleVenta d
    JOIN Producto p  ON d.IdProducto=p.IdProducto
    JOIN Categoria cat ON p.IdCategoria=cat.IdCategoria
    GROUP BY cat.Nombre ORDER BY Total DESC;
END
GO

CREATE PROCEDURE sp_VentasPorMes
AS
BEGIN
    SET NOCOUNT ON;
    SELECT MONTH(Fecha) AS Mes, YEAR(Fecha) AS Anio,
           SUM(Total) AS Total, COUNT(*) AS Cantidad
    FROM Venta
    WHERE YEAR(Fecha)=YEAR(GETDATE())
    GROUP BY MONTH(Fecha), YEAR(Fecha)
    ORDER BY Mes;
END
GO

CREATE PROCEDURE sp_UltimasVentas
    @Top INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TOP(@Top) v.Numero,
           CONVERT(VARCHAR(20),v.Fecha,103) AS Fecha,
           c.Nombres AS Cliente, v.Total, v.Estado
    FROM Venta v
    INNER JOIN Cliente c ON v.IdCliente=c.IdCliente
    ORDER BY v.Fecha DESC;
END
GO

CREATE PROCEDURE sp_DetalleVenta
    @IdVenta INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT p.Nombre AS Producto, cat.Nombre AS Categoria,
           d.Cantidad, d.PrecioUnit, d.Descuento, d.Subtotal
    FROM DetalleVenta d
    JOIN Producto p ON d.IdProducto=p.IdProducto
    JOIN Categoria cat ON p.IdCategoria=cat.IdCategoria
    WHERE d.IdVenta=@IdVenta;
END
GO

CREATE FUNCTION fn_NroVenta()
RETURNS NVARCHAR(20)
AS
BEGIN
    DECLARE @num INT;
    SELECT @num = ISNULL(MAX(CAST(SUBSTRING(Numero,3,LEN(Numero)) AS INT)),0)+1 FROM Venta;
    RETURN 'V-' + RIGHT('000000'+CAST(@num AS VARCHAR),6);
END
GO

PRINT '================================================================';
PRINT ' TechSolutionsDB V2 creada correctamente';
PRINT ' Tablas: Rol, Permiso, Usuario, Categoria, Proveedor,';
PRINT '         Cliente, Producto, Venta, DetalleVenta,';
PRINT '         Compra, DetalleCompra';
PRINT '================================================================';
