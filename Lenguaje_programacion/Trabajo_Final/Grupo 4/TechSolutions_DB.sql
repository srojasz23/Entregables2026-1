-- ============================================================
-- TECH SOLUTIONS - Script de Base de Datos
-- SQL Server 2019+
-- ============================================================

USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'TechSolutionsDB')
    DROP DATABASE TechSolutionsDB;
GO

CREATE DATABASE TechSolutionsDB;
GO

USE TechSolutionsDB;
GO

-- ============================================================
-- TABLA: Roles
-- ============================================================
CREATE TABLE Roles (
    RolID       INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      VARCHAR(50) NOT NULL UNIQUE,
    Descripcion VARCHAR(200)
);
GO

-- ============================================================
-- TABLA: Usuarios
-- ============================================================
CREATE TABLE Usuarios (
    UsuarioID   INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      VARCHAR(100) NOT NULL,
    Email       VARCHAR(150) NOT NULL UNIQUE,
    Password    VARBINARY(64) NOT NULL,      -- SHA-512 hash
    RolID       INT NOT NULL,
    Activo      BIT NOT NULL DEFAULT 1,
    FechaCreacion DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Usuarios_Roles FOREIGN KEY (RolID) REFERENCES Roles(RolID)
);
GO

-- ============================================================
-- TABLA: Categorias
-- ============================================================
CREATE TABLE Categorias (
    CategoriaID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre      VARCHAR(100) NOT NULL UNIQUE,
    Descripcion VARCHAR(300)
);
GO

-- ============================================================
-- TABLA: Productos
-- ============================================================
CREATE TABLE Productos (
    ProductoID  INT IDENTITY(1,1) PRIMARY KEY,
    Codigo      VARCHAR(20) NOT NULL UNIQUE,
    Nombre      VARCHAR(150) NOT NULL,
    Descripcion VARCHAR(500),
    Precio      DECIMAL(10,2) NOT NULL CHECK (Precio >= 0),
    Stock       INT NOT NULL DEFAULT 0 CHECK (Stock >= 0),
    StockMinimo INT NOT NULL DEFAULT 5,
    CategoriaID INT NOT NULL,
    Activo      BIT NOT NULL DEFAULT 1,
    FechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Productos_Categorias FOREIGN KEY (CategoriaID) REFERENCES Categorias(CategoriaID)
);
GO

-- ============================================================
-- TABLA: Clientes
-- ============================================================
CREATE TABLE Clientes (
    ClienteID   INT IDENTITY(1,1) PRIMARY KEY,
    DNI         VARCHAR(15) NOT NULL UNIQUE,
    Nombre      VARCHAR(100) NOT NULL,
    Apellido    VARCHAR(100) NOT NULL,
    Email       VARCHAR(150),
    Telefono    VARCHAR(20),
    Direccion   VARCHAR(300),
    Activo      BIT NOT NULL DEFAULT 1,
    FechaRegistro DATETIME NOT NULL DEFAULT GETDATE()
);
GO

-- ============================================================
-- TABLA: Ventas
-- ============================================================
CREATE TABLE Ventas (
    VentaID     INT IDENTITY(1,1) PRIMARY KEY,
    NumeroVenta VARCHAR(20) NOT NULL UNIQUE,
    ClienteID   INT NOT NULL,
    UsuarioID   INT NOT NULL,
    FechaVenta  DATETIME NOT NULL DEFAULT GETDATE(),
    Subtotal    DECIMAL(10,2) NOT NULL DEFAULT 0,
    IGV         DECIMAL(10,2) NOT NULL DEFAULT 0,   -- 18%
    Total       DECIMAL(10,2) NOT NULL DEFAULT 0,
    Estado      VARCHAR(20) NOT NULL DEFAULT 'Completada'
                CHECK (Estado IN ('Completada','Anulada')),
    Observacion VARCHAR(500),
    CONSTRAINT FK_Ventas_Clientes  FOREIGN KEY (ClienteID)  REFERENCES Clientes(ClienteID),
    CONSTRAINT FK_Ventas_Usuarios  FOREIGN KEY (UsuarioID)  REFERENCES Usuarios(UsuarioID)
);
GO

-- ============================================================
-- TABLA: DetalleVentas
-- ============================================================
CREATE TABLE DetalleVentas (
    DetalleID   INT IDENTITY(1,1) PRIMARY KEY,
    VentaID     INT NOT NULL,
    ProductoID  INT NOT NULL,
    Cantidad    INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnit  DECIMAL(10,2) NOT NULL CHECK (PrecioUnit >= 0),
    Subtotal    AS (Cantidad * PrecioUnit) PERSISTED,
    CONSTRAINT FK_Detalle_Ventas    FOREIGN KEY (VentaID)    REFERENCES Ventas(VentaID),
    CONSTRAINT FK_Detalle_Productos FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);
GO

-- ============================================================
-- STORED PROCEDURES
-- ============================================================

-- SP: Registrar Venta con transacción
CREATE PROCEDURE sp_RegistrarVenta
    @ClienteID   INT,
    @UsuarioID   INT,
    @Observacion VARCHAR(500),
    @Detalles    NVARCHAR(MAX),   -- JSON: [{ProductoID, Cantidad, PrecioUnit}]
    @VentaID     INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Generar número de venta
        DECLARE @NumVenta VARCHAR(20);
        SET @NumVenta = 'VTA-' + FORMAT(GETDATE(),'yyyyMMdd') + '-' +
                        RIGHT('0000' + CAST((SELECT ISNULL(MAX(VentaID),0)+1 FROM Ventas) AS VARCHAR),4);

        -- Insertar cabecera
        INSERT INTO Ventas (NumeroVenta, ClienteID, UsuarioID, Observacion)
        VALUES (@NumVenta, @ClienteID, @UsuarioID, @Observacion);

        SET @VentaID = SCOPE_IDENTITY();

        -- Insertar detalles desde JSON
        INSERT INTO DetalleVentas (VentaID, ProductoID, Cantidad, PrecioUnit)
        SELECT @VentaID,
               JSON_VALUE(j.value,'$.ProductoID'),
               JSON_VALUE(j.value,'$.Cantidad'),
               JSON_VALUE(j.value,'$.PrecioUnit')
        FROM OPENJSON(@Detalles) AS j;

        -- Descontar stock
        UPDATE P
        SET P.Stock = P.Stock - D.Cantidad
        FROM Productos P
        INNER JOIN DetalleVentas D ON P.ProductoID = D.ProductoID
        WHERE D.VentaID = @VentaID;

        -- Verificar stock negativo
        IF EXISTS (SELECT 1 FROM Productos WHERE Stock < 0)
        BEGIN
            ROLLBACK;
            RAISERROR('Stock insuficiente para uno o más productos.',16,1);
            RETURN;
        END

        -- Calcular totales
        UPDATE Ventas
        SET Subtotal = (SELECT SUM(Subtotal) FROM DetalleVentas WHERE VentaID = @VentaID),
            IGV      = (SELECT SUM(Subtotal) * 0.18 FROM DetalleVentas WHERE VentaID = @VentaID),
            Total    = (SELECT SUM(Subtotal) * 1.18 FROM DetalleVentas WHERE VentaID = @VentaID)
        WHERE VentaID = @VentaID;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- SP: Anular Venta y restaurar stock
CREATE PROCEDURE sp_AnularVenta
    @VentaID INT,
    @UsuarioID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Ventas WHERE VentaID = @VentaID AND Estado = 'Completada')
        BEGIN
            RAISERROR('Venta no encontrada o ya está anulada.',16,1);
            RETURN;
        END

        -- Restaurar stock
        UPDATE P
        SET P.Stock = P.Stock + D.Cantidad
        FROM Productos P
        INNER JOIN DetalleVentas D ON P.ProductoID = D.ProductoID
        WHERE D.VentaID = @VentaID;

        -- Cambiar estado
        UPDATE Ventas SET Estado = 'Anulada' WHERE VentaID = @VentaID;

        COMMIT;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        THROW;
    END CATCH
END;
GO

-- SP: Reporte de ventas por rango de fechas
CREATE PROCEDURE sp_ReporteVentas
    @FechaInicio DATETIME,
    @FechaFin    DATETIME,
    @UsuarioID   INT = NULL
AS
BEGIN
    SELECT V.VentaID, V.NumeroVenta, V.FechaVenta,
           C.Nombre + ' ' + C.Apellido AS Cliente,
           U.Nombre AS Vendedor,
           V.Subtotal, V.IGV, V.Total, V.Estado
    FROM   Ventas V
    INNER JOIN Clientes  C ON V.ClienteID = C.ClienteID
    INNER JOIN Usuarios  U ON V.UsuarioID = U.UsuarioID
    WHERE  V.FechaVenta BETWEEN @FechaInicio AND @FechaFin
    AND   (@UsuarioID IS NULL OR V.UsuarioID = @UsuarioID)
    ORDER BY V.FechaVenta DESC;
END;
GO

-- SP: Productos con bajo stock
CREATE PROCEDURE sp_ProductosBajoStock
AS
BEGIN
    SELECT ProductoID, Codigo, Nombre, Stock, StockMinimo,
           (StockMinimo - Stock) AS Faltante
    FROM   Productos
    WHERE  Stock <= StockMinimo AND Activo = 1
    ORDER BY Faltante DESC;
END;
GO

-- ============================================================
-- DATOS INICIALES
-- ============================================================
INSERT INTO Roles (Nombre, Descripcion) VALUES
('Administrador', 'Acceso total al sistema'),
('Vendedor',      'Acceso a ventas y consultas'),
('Almacenero',    'Gestión de productos y stock');

INSERT INTO Usuarios (Nombre, Email, Password, RolID) VALUES
('Administrador', 'admin@techsolutions.com',
 HASHBYTES('SHA2_512', 'Admin@2024'), 1);

INSERT INTO Categorias (Nombre) VALUES
('Laptops'),('Smartphones'),('Accesorios'),('Monitores'),('Componentes');

INSERT INTO Productos (Codigo, Nombre, Precio, Stock, StockMinimo, CategoriaID) VALUES
('LAP-001','Laptop HP 15" i5',       2899.00, 15, 5, 1),
('LAP-002','Laptop Lenovo ThinkPad', 3499.00, 10, 3, 1),
('CEL-001','Samsung Galaxy A54',     1299.00, 25, 8, 2),
('CEL-002','iPhone 15',              4999.00,  8, 3, 2),
('ACC-001','Mouse Inalámbrico',        89.00, 50,10, 3),
('ACC-002','Teclado Mecánico',        299.00, 30, 8, 3),
('MON-001','Monitor 24" Full HD',     699.00, 12, 4, 4),
('COM-001','SSD 1TB NVMe',           399.00, 20, 6, 5);

INSERT INTO Clientes (DNI, Nombre, Apellido, Email, Telefono) VALUES
('12345678','Carlos',  'Ramírez',   'carlos.ramirez@email.com',  '987654321'),
('87654321','Ana',     'Torres',    'ana.torres@email.com',      '912345678'),
('45678912','Luis',    'Mendoza',   'luis.mendoza@email.com',    '934567890');

PRINT 'Base de datos TechSolutionsDB creada exitosamente.';
GO
