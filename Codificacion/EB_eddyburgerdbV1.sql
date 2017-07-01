-- phpMyAdmin SQL Dump
-- version 4.5.1
-- http://www.phpmyadmin.net
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 02-07-2017 a las 01:16:52
-- Versión del servidor: 10.1.19-MariaDB
-- Versión de PHP: 5.6.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `eddyburgerdb`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `reportedep` (IN `idVent` INT, IN `idProd` INT)  BEGIN
	
	SELECT * FROM detalleVenta JOIN Producto ON Producto_idProducto = idProd WHERE Ventas_idVentas = idVent;    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reporteve` (IN `idVent` INT)  BEGIN
	
	SELECT * FROM Ventas JOIN Empleado on idEmpleado = Empleado_idEmpleado WHERE idVentas = idVent;    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addCliente` (IN `nom` VARCHAR(45), IN `apellidoP` VARCHAR(100), IN `apellidoM` VARCHAR(100), IN `emaile` VARCHAR(100), IN `calle` VARCHAR(100), IN `num` VARCHAR(45), IN `col` VARCHAR(45), IN `cp` INT(5), IN `ciud` VARCHAR(45), IN `est` VARCHAR(45), IN `lad` VARCHAR(45), IN `tel` INT)  BEGIN
		DECLARE contar int;
		DECLARE ids int;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
		START TRANSACTION;
        
        IF(trim(nom) = '' OR trim(apellidoP) = '' OR trim(apellidoM) = '' OR trim(emaile) = '' OR trim(calle) = '' OR trim(num) = '' OR trim(col) = '' OR cp = 0 OR trim(ciud) = '' OR trim(est) = '' OR trim(lad) = '' OR tel = 0) THEN
			SELECT "FALTAN DATOS";
		ELSE
			SELECT count(*) INTO contar FROM Estado where estado = trim(est);
                IF (contar = 0) THEN
					INSERT INTO Estado VALUES(0, trim(est));
                    SELECT idEstado INTO ids FROM Estado where estado = trim(est);
				ELSE
					SELECT idEstado INTO ids FROM Estado where estado = trim(est);
				END IF;
			SELECT count(*) INTO contar FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = ids;
				IF (contar = 0) THEN
					INSERT INTO Ciudad VALUES(0, trim(ciud), ids);
                    SELECT idEstadoCiudad INTO ids FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = ids;
				ELSE
					SELECT idEstadoCiudad INTO ids FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = ids;
				END IF;
			SELECT count(*) INTO contar FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = ids;
				IF (contar = 0) THEN
					INSERT INTO Colonia VALUES(0, trim(col), cp, ids);
                    SELECT idColonia INTO ids FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = ids;
				ELSE
					SELECT idColonia INTO ids FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = ids;
				END IF;
			SELECT count(*) INTO contar FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = ids;
				IF (contar = 0) THEN
					INSERT INTO Direccion VALUES(0, trim(calle), trim(num), ids);
                    SELECT idDireccion INTO ids FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = ids;
				ELSE
					SELECT idDireccion INTO ids FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = ids;
				END IF;
			SELECT count(*) INTO contar FROM Cliente where nombre = trim(nom) and apellido_P = trim(apellidoP) and apellido_M = trim(apellidoM) and email = trim(emaile) and Direccion_idDireccion = ids;
				IF (contar = 0) THEN
					INSERT INTO Cliente VALUES(0, nom, apellidoP, apellidoM, emaile, ids);
                    SELECT idCliente INTO ids FROM Cliente where nombre = trim(nom) and apellido_P = trim(apellidoP) and apellido_M = trim(apellidoM) and email = trim(emaile) and Direccion_idDireccion = ids;
				ELSE
					SELECT idCliente INTO ids FROM Cliente where nombre = trim(nom) and apellido_P = trim(apellidoP) and apellido_M = trim(apellidoM) and email = trim(emaile) and Direccion_idDireccion = ids;
				END IF;
            SELECT count(*) INTO contar FROM Telefono_C where lada = trim(lad) and telefono = tel;
				IF(contar = 0) THEN
					INSERT INTO Telefono_C VALUES(0, trim(lad), tel, ids);
                    COMMIT;
				ELSE
					SELECT "Este Cliente ya existe";
					ROLLBACK;
                END IF;
		END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addDetalleVenta` (IN `tProd` INT, IN `precio` FLOAT(9,2), IN `idProd` INT, IN `idVent` INT)  BEGIN
		DECLARE can INT;
        
	    DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
	START TRANSACTION;
		IF(trim(tProd) = 0 OR trim(precio) = 0 OR trim(idProd) = 0 OR trim(idVent) = 0) THEN
			SELECT "FALTAN DATOS";
		ELSE
			SELECT count(*) INTO can FROM detalleVenta WHERE Producto_idProducto = trim(idProd) and Ventas_idVentas = trim(idVent);
            IF (can = 0) THEN
			INSERT INTO DetalleVenta SET cantidad = trim(tProd), precio = trim(precio), subtotal = trim(tProd)*trim(precio), Producto_idProducto = trim(idProd), Ventas_idVentas = trim(idVent);
            commit;
            ELSE
            UPDATE detalleVenta SET cantidad = trim(tProd) WHERE Ventas_idVentas = trim(idVent) AND Producto_idProducto = trim(idProd);
            commit;
            END IF;
		END IF;
        
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addEmpleado` (IN `nom` VARCHAR(45), IN `apellidoP` VARCHAR(100), IN `apellidoM` VARCHAR(100), IN `emaile` VARCHAR(100), IN `calle` VARCHAR(100), IN `num` VARCHAR(45), IN `col` VARCHAR(45), IN `cp` INT(5), IN `ciud` VARCHAR(45), IN `est` VARCHAR(45), IN `lad` VARCHAR(45), IN `tel` INT)  BEGIN
		DECLARE contar int;
		DECLARE ids int;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
		START TRANSACTION;
        
        IF(trim(nom) = '' OR trim(apellidoP) = '' OR trim(apellidoM) = '' OR trim(emaile) = '' OR trim(calle) = '' OR trim(num) = '' OR trim(col) = '' OR cp = 0 OR trim(ciud) = '' OR trim(est) = '' OR trim(lad) = '' OR tel = 0) THEN
			SELECT "FALTAN DATOS";
		ELSE
			SELECT count(*) INTO contar FROM Estado where estado = trim(est);
                IF (contar = 0) THEN
					INSERT INTO Estado VALUES(0, trim(est));
                    SELECT idEstado INTO ids FROM Estado where estado = trim(est);
				ELSE
					SELECT idEstado INTO ids FROM Estado where estado = trim(est);
				END IF;
			SELECT count(*) INTO contar FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = ids;
				IF (contar = 0) THEN
					INSERT INTO Ciudad VALUES(0, trim(ciud), ids);
                    SELECT idEstadoCiudad INTO ids FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = ids;
				ELSE
					SELECT idEstadoCiudad INTO ids FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = ids;
				END IF;
			SELECT count(*) INTO contar FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = ids;
				IF (contar = 0) THEN
					INSERT INTO Colonia VALUES(0, trim(col), cp, ids);
                    SELECT idColonia INTO ids FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = ids;
				ELSE
					SELECT idColonia INTO ids FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = ids;
				END IF;
			SELECT count(*) INTO contar FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = ids;
				IF (contar = 0) THEN
					INSERT INTO Direccion VALUES(0, trim(calle), trim(num), ids);
                    SELECT idDireccion INTO ids FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = ids;
				ELSE
					SELECT idDireccion INTO ids FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = ids;
				END IF;
			SELECT count(*) INTO contar FROM Empleado where nombre = trim(nom) and apellido_P = trim(apellidoP) and apellido_M = trim(apellidoM) and email = trim(emaile) and Direccion_idDireccion = ids;
				IF (contar = 0) THEN
					INSERT INTO Empleado VALUES(0, nom, apellidoP, apellidoM, emaile, ids);
                    SELECT idEmpleado INTO ids FROM Empleado where nombre = trim(nom) and apellido_P = trim(apellidoP) and apellido_M = trim(apellidoM) and email = trim(emaile) and Direccion_idDireccion = ids;
				ELSE
					SELECT idEmpleado INTO ids FROM Empleado where nombre = trim(nom) and apellido_P = trim(apellidoP) and apellido_M = trim(apellidoM) and email = trim(emaile) and Direccion_idDireccion = ids;
				END IF;
            SELECT count(*) INTO contar FROM Telefono_E where lada = trim(lad) and telefono = tel;
				IF(contar = 0) THEN
					INSERT INTO Telefono_E VALUES(0, trim(lad), tel, ids);
                    COMMIT;
				ELSE
					SELECT "Este empleado ya existe";
					ROLLBACK;
                END IF;
		END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addProveedor` (IN `nom` VARCHAR(45), IN `emaile` VARCHAR(100), IN `calle` VARCHAR(100), IN `num` VARCHAR(45), IN `col` VARCHAR(45), IN `cp` INT(5), IN `ciud` VARCHAR(45), IN `est` VARCHAR(45), IN `lad` VARCHAR(45), IN `tel` INT)  BEGIN
		DECLARE contar int;
		DECLARE ids int;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
		START TRANSACTION;
        
        IF(trim(nom) = ''  OR trim(emaile) = '' OR trim(calle) = '' OR trim(num) = '' OR trim(col) = '' OR cp = 0 OR trim(ciud) = '' OR trim(est) = '' OR trim(lad) = '' OR tel = 0) THEN
			SELECT "FALTAN DATOS";
		ELSE
			SELECT count(*) INTO contar FROM Estado where estado = trim(est);
                IF (contar = 0) THEN
					INSERT INTO Estado VALUES(0, trim(est));
                    SELECT idEstado INTO ids FROM Estado where estado = trim(est);
				ELSE
					SELECT idEstado INTO ids FROM Estado where estado = trim(est);
				END IF;
			SELECT count(*) INTO contar FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = ids;
				IF (contar = 0) THEN
					INSERT INTO Ciudad VALUES(0, trim(ciud), ids);
                    SELECT idEstadoCiudad INTO ids FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = ids;
				ELSE
					SELECT idEstadoCiudad INTO ids FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = ids;
				END IF;
			SELECT count(*) INTO contar FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = ids;
				IF (contar = 0) THEN
					INSERT INTO Colonia VALUES(0, trim(col), cp, ids);
                    SELECT idColonia INTO ids FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = ids;
				ELSE
					SELECT idColonia INTO ids FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = ids;
				END IF;
			SELECT count(*) INTO contar FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = ids;
				IF (contar = 0) THEN
					INSERT INTO Direccion VALUES(0, trim(calle), trim(num), ids);
                    SELECT idDireccion INTO ids FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = ids;
				ELSE
					SELECT idDireccion INTO ids FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = ids;
				END IF;
			SELECT count(*) INTO contar FROM Proveedor where nombre = trim(nom)  and email = trim(emaile) and Direccion_idDireccion = ids;
				IF (contar = 0) THEN
					INSERT INTO Proveedor VALUES(0, nom, emaile, ids);
                    SELECT idProveedor INTO ids FROM Proveedor where nombre = trim(nom) and email = trim(emaile) and Direccion_idDireccion = ids;
				ELSE
					SELECT idProveedor INTO ids FROM Proveedor where nombre = trim(nom) and email = trim(emaile) and Direccion_idDireccion = ids;
				END IF;
            SELECT count(*) INTO contar FROM Telefono_P where lada = trim(lad) and telefono = tel;
				IF(contar = 0) THEN
					INSERT INTO Telefono_P VALUES(0, trim(lad), tel, ids);
                    COMMIT;
				ELSE
					SELECT "Este Proveedor ya existe";
					ROLLBACK;
                END IF;
		END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addVenta` (IN `pago` FLOAT(9,2), IN `tProd` FLOAT(9,2), IN `idProd` INT, IN `idEmp` INT)  BEGIN
	DECLARE exist INT;
    DECLARE pre FLOAT(9,2);
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
	START TRANSACTION;

		IF(trim(pago) = 0 OR trim(tProd) = 0 OR trim(idProd) = 0 OR trim(idEmp) = 0) THEN
			SELECT "Algunos datos estan vacios";
		ELSE
			SELECT count(*) INTO exist FROM Producto WHERE idProducto = trim(idProd);
			IF(exist <= 0) THEN
				SELECT "NO EXISTE EL PRODUCTO";
			ELSE
				INSERT INTO Ventas VALUES(0, 0, trim(pago), 0, NOW(), trim(idEmp));
                SELECT @idVent := LAST_INSERT_ID( );
                SET pre = (SELECT precio FROM Producto WHERE idProducto = idProd);
				CALL sp_addDetalleVenta(trim(tProd), trim(pre), trim(idProd), trim(@idVent));
                COMMIT;
			END IF;
		END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_addVentaDetalle` (IN `pag` FLOAT(9,2), IN `idPro` INT, IN `can` FLOAT, IN `idEmp` INT)  BEGIN
		DECLARE contar int;
		DECLARE ids int;
		DECLARE pre float;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
		START TRANSACTION;
        
        IF (pag = 0 OR idPro = 0 OR idEmp = 0 OR can = 0) THEN
			SELECT "Faltan datos";
        ELSE
				INSERT INTO Ventas VALUES(0, 0, pag, 0, NOW(), idEmp);
                SELECT @idV:=last_insert_id();
                SELECT (precio) INTO pre FROM Producto where idProducto = idPro;
                INSERT INTO DetalleVenta VALUES(0, can, pre, (pre*can), @idV);
                UPDATE Producto SET stock = stock - can where idProducto = idProducto;
                UPDATE Ventas SET totalVenta = totalVenta + (pre*can), pago = pago - (pre*can) where idVentas = @idV;
				COMMIT;
        END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delCliente` (IN `idCli` INT)  BEGIN
		DECLARE contar int;
		DECLARE idCi int;
		DECLARE idCo int;
		DECLARE idEs int;
		DECLARE idDir int;
		DECLARE ids int;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
		START TRANSACTION;
        
        IF (idCli = 0) THEN
			SELECT "FALTA EL ID DEL Cliente A ELIMINAR";
		ELSE
			SELECT Direccion_idDireccion INTO idDir FROM Cliente where idCliente = idCli;
            SELECT Colonia_idColonia INTO idCo FROM Direccion where idDireccion = idDir;
            SELECT Ciudad_idEstadoCiudad INTO idCi FROM Colonia where idColonia = idCo;
            SELECT Estado_idEstado INTO idEs FROM Ciudad where idEstadoCiudad = idCi;
            
            SELECT count(*) INTO contar FROM Cliente where Direccion_idDireccion = idDir;
				IF (contar > 1) THEN
					DELETE FROM Telefono_C where Cliente_idCliente = idCli;
					DELETE FROM Cliente where idCliente = idCli;
				ELSE
					DELETE FROM Telefono_C where Cliente_idCliente = idCli;
					DELETE FROM Cliente where idCliente = idCli;
				END IF;
			SELECT count(*) INTO contar FROM Direccion where Colonia_idColonia = idCo;
				IF (contar > 1) THEN
					DELETE FROM Direccion where idDireccion = idDir;
				ELSE
					DELETE FROM Direccion where idDireccion = idDir;
				END IF;		
			SELECT count(*) INTO contar FROM Colonia where Ciudad_idEstadoCiudad = idCi;
				IF (contar > 1) THEN
					DELETE FROM Colonia where idColonia = idCo;
				ELSE
					DELETE FROM Colonia where idColonia = idCi;
				END IF;
            SELECT count(*) INTO contar FROM Ciudad where Estado_idEstado = idEs;
				IF (contar > 1) THEN
					DELETE FROM Ciudad where idEstadoCiudad = idCi;
				ELSE
					DELETE FROM Ciudad where idEstadoCiudad = idEs;
					DELETE FROM Estado where idEstado = idEs;
				END IF;
                COMMIT;
		END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delDetalleVenta` (IN `idVen` INT, IN `idProd` INT)  BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			SHOW ERRORS LIMIT 1;
			ROLLBACK;
		END;
    START TRANSACTION;
		
        IF(trim(idVen) = 0) THEN
			SELECT "FALTA INFORMACIÓN PARA REALIZAR LA OPERACIÓN";
		ELSE
			IF(trim(idProd)=0) THEN
			DELETE FROM detalleVenta WHERE Ventas_idVentas = trim(idVen);
            CALL sp_delVenta(trim(idVen));
            COMMIT;
            ELSE
            DELETE FROM detalleVenta WHERE Ventas_idVentas = trim(idVen) AND Producto_idProducto = trim(idProd);
            CALL sp_delVenta(trim(idVen));
            COMMIT;
            END IF;
        END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delEmpleado` (IN `idEmp` INT)  BEGIN
		DECLARE contar int;
		DECLARE idCi int;
		DECLARE idCo int;
		DECLARE idEs int;
		DECLARE idDir int;
		DECLARE ids int;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
		START TRANSACTION;
        
        IF (idEmp = 0) THEN
			SELECT "FALTA EL ID DEL EMPLEADO A ELIMINAR";
		ELSE
			SELECT Direccion_idDireccion INTO idDir FROM Empleado where idEmpleado = idEmp;
            SELECT Colonia_idColonia INTO idCo FROM Direccion where idDireccion = idDir;
            SELECT Ciudad_idEstadoCiudad INTO idCi FROM Colonia where idColonia = idCo;
            SELECT Estado_idEstado INTO idEs FROM Ciudad where idEstadoCiudad = idCi;
            
            SELECT count(*) INTO contar FROM Empleado where Direccion_idDireccion = idDir;
				IF (contar = 1) THEN
					DELETE FROM Telefono_E where Empleado_idEmpleado = idEmp;
					DELETE FROM Empleado where idEmpleado = idEmp;
				END IF;
			SELECT count(*) INTO contar FROM Direccion where Colonia_idColonia = idCo;
				IF (contar > 1) THEN
					DELETE FROM Direccion where idDireccion = idDir;
				ELSE
					DELETE FROM Direccion where idDireccion = idDir;
                    SELECT * FROM Direccion;
				END IF;		
			SELECT count(*) INTO contar FROM Colonia where Ciudad_idEstadoCiudad = idCi;
				IF (contar > 1) THEN
					DELETE FROM Colonia where idColonia = idCo;
				ELSE
					DELETE FROM Colonia where idColonia = idCi;
				END IF;
            SELECT count(*) INTO contar FROM Ciudad where Estado_idEstado = idEs;
				IF (contar > 1) THEN
					DELETE FROM Ciudad where idEstadoCiudad = idCi;
				ELSE
					DELETE FROM Ciudad where idEstadoCiudad = idEs;
					DELETE FROM Estado where idEstado = idEs;
				END IF;
                COMMIT;
		END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delProveedor` (IN `idProve` INT)  BEGIN
		DECLARE contar int;
		DECLARE idCi int;
		DECLARE idCo int;
		DECLARE idEs int;
		DECLARE idDir int;
		DECLARE ids int;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
		START TRANSACTION;
        
        IF (idProve = 0) THEN
			SELECT "FALTA EL ID DEL PROVEEDOR A ELIMINAR";
		ELSE
			SELECT Direccion_idDireccion INTO idDir FROM Proveedor where idProveedor = idProve;
            SELECT Colonia_idColonia INTO idCo FROM Direccion where idDireccion = idDir;
            SELECT Ciudad_idEstadoCiudad INTO idCi FROM Colonia where idColonia = idCo;
            SELECT Estado_idEstado INTO idEs FROM Ciudad where idEstadoCiudad = idCi;
            
            SELECT count(*) INTO contar FROM Proveedor where Direccion_idDireccion = idDir;
				IF (contar > 1) THEN
					DELETE FROM Telefono_P where Proveedor_idProveedor = idProve;
					DELETE FROM Proveedor where idProveedor = idProve;
				ELSE
					DELETE FROM Telefono_P where Proveedor_idProveedor = idProve;
					DELETE FROM Proveedor where idProveedor = idProve;
				END IF;
			SELECT count(*) INTO contar FROM Direccion where Colonia_idColonia = idCo;
				IF (contar > 1) THEN
					DELETE FROM Direccion where idDireccion = idDir;
				ELSE
					DELETE FROM Direccion where idDireccion = idDir;
				END IF;		
			SELECT count(*) INTO contar FROM Colonia where Ciudad_idEstadoCiudad = idCi;
				IF (contar > 1) THEN
					DELETE FROM Colonia where idColonia = idCo;
				ELSE
					DELETE FROM Colonia where idColonia = idCi;
				END IF;
            SELECT count(*) INTO contar FROM Ciudad where Estado_idEstado = idEs;
				IF (contar > 1) THEN
					DELETE FROM Ciudad where idEstadoCiudad = idCi;
				ELSE
					DELETE FROM Ciudad where idEstadoCiudad = idEs;
					DELETE FROM Estado where idEstado = idEs;
				END IF;
                COMMIT;
		END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_delVenta` (IN `idVen` INT)  BEGIN
	DECLARE ven INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
	START TRANSACTION;

		IF(trim(idVen) = 0) THEN
			SELECT "Algunos datos estan vacios";
		ELSE
			SELECT count(*) INTO ven FROM Ventas WHERE idVentas = trim(idVen);
			IF(ven <= 0) THEN
				SELECT "NO EXISTE LA VENTA";
			ELSE
				DELETE FROM Ventas WHERE idVentas = trim(idVen);
				-- CALL sp_delDetalleVenta(trim(idVen));
                COMMIT;
			END IF;
		END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateCliente` (IN `idCli` INT, IN `nom` VARCHAR(45), IN `apellidoP` VARCHAR(100), IN `apellidoM` VARCHAR(100), IN `emaile` VARCHAR(100), IN `calle` VARCHAR(100), IN `num` VARCHAR(45), IN `col` VARCHAR(45), IN `cp` INT(5), IN `ciud` VARCHAR(45), IN `est` VARCHAR(45), IN `lad` VARCHAR(45), IN `tel` INT)  BEGIN
		DECLARE contar int;
		DECLARE idCi int;
		DECLARE idCo int;
		DECLARE idEs int;
		DECLARE idDir int;
		DECLARE ids int;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
		START TRANSACTION;
        
        IF(idCli = 0 OR trim(nom) = '' OR trim(apellidoP) = '' OR trim(apellidoM) = '' OR trim(emaile) = '' OR trim(calle) = '' OR trim(num) = '' OR trim(col) = '' OR cp = 0 OR trim(ciud) = '' OR trim(est) = '' OR trim(lad) = '' OR tel = 0) THEN
			SELECT "FALTAN DATOS";
		ELSE
			SELECT Direccion_idDireccion INTO idDir FROM Cliente where idCliente = idCli;
            SELECT Colonia_idColonia INTO idCo FROM Direccion where idDireccion = idDir;
            SELECT Ciudad_idEstadoCiudad INTO idCi FROM Colonia where idColonia = idCo;
            SELECT Estado_idEstado INTO idEs FROM Ciudad where idEstadoCiudad = idCi;
            
            
            SELECT count(*) INTO contar FROM Estado where estado = trim(est) and idEstado = idEs;
                IF (contar = 0) THEN
					 SELECT count(*) INTO contar FROM Estado where estado = trim(est);
                IF(contar = 0) THEN
					UPDATE Estado SET estado = trim(est) where idEstado = idEs;
				ELSE
					SELECT idEstado INTO idEs FROM Estado where estado = trim(est);
				END IF;
				END IF;
                
			SELECT count(*) INTO contar FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = idEs and idEstadoCiudad = idCi;
				IF (contar = 0) THEN
					SELECT count(*) INTO contar FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = idEs;
				IF(contar = 0) THEN
                
                IF(ids=0) THEN
					SET ids = 0;
					UPDATE Ciudad SET ciudad = trim(ciud) where idEstadoCiudad = idCi;
				ELSE
					UPDATE Ciudad SET ciudad = trim(ciud), Estado_idEstado = idEs where idEstadoCiudad = idCi;
                END IF;
                ELSE
					SELECT idEstadoCiudad INTO idCi FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = idEs;
				END IF;
				END IF;
                
                
			SELECT count(*) INTO contar FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = idCi and idColonia = idCo;
				IF (contar = 0) THEN
					SELECT count(*) INTO contar FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = idCi;
				IF (contar = 0) THEN
                IF (ids = 0) THEN
					SET ids = 0;
                    UPDATE Colonia SET colonia = trim(col), codigoPostal = cp where idColonia = idCo;
				ELSE
					UPDATE Colonia SET colonia = trim(col), codigoPostal = cp, Ciudad_idEstadoCiudad = idCi where idColonia = idCo;
                END IF;
                ELSE
					SELECT idColonia INTO idCo FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = idCi;
				END IF;
				END IF;
			
            
            SELECT count(*) INTO contar FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = idCo and idDireccion = idDir;
				IF (contar = 0) THEN
					SELECT count(*) INTO contar FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = idCo;
				IF (contar = 0) THEN
                IF (ids = 0) THEN
					SET ids = 0;
					UPDATE Direccion SET calle_dir = trim(calle), no_dir = trim(num) where idDireccion = idDir;
				ELSE
					UPDATE Direccion SET calle_dir = trim(calle), no_dir = trim(num), Colonia_idColonia = idCo where idDireccion = idDir;
				END IF;
                ELSE
					SELECT idDireccion INTO idDir FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = idCo;
				END IF;
				END IF;
			
            
            SELECT count(*) INTO contar FROM Cliente where nombre = trim(nom) and apellido_P = trim(apellidoP) and apellido_M = trim(apellidoM) and email = trim(emaile) and Direccion_idDireccion = idDir and idCliente = idCli;
				IF (contar = 0) THEN
					SELECT count(*) INTO contar FROM Cliente where nombre = trim(nom) and apellido_P = trim(apellidoP) and apellido_M = trim(apellidoM) and email = trim(emaile) and Direccion_idDireccion = idDir;
                IF (contar = 0) THEN
                IF (ids = 0) THEN
					SET ids = 0;
					UPDATE Cliente SET nombre = nom, apellido_P = apellidoP, apellido_M = apellidoM, email = emaile where idCliente = idCli;
				ELSE
                    UPDATE Cliente SET nombre = trim(nom), apellido_P = trim(apellidoP), apellido_M = trim(apellidoM), email = trim(emaile), Direccion_idDireccion = idDir where idCliente = idCli;
				END IF;
                END IF;
				END IF;
            
            
            SELECT count(*) INTO contar FROM Telefono_C where lada = trim(lad) and telefono = tel and Cliente_idCliente = idCli;
				IF(contar = 0) THEN
					UPDATE Telefono_C SET lada = trim(lad), telefono = tel where Cliente_idCliente = idCli;
                    COMMIT;
				ELSE
					COMMIT;
                END IF;
		END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateDetVen` (IN `tProd` FLOAT(9,2), IN `idProd` INT, IN `idVen` INT, IN `pre` FLOAT(9,2))  BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			SHOW ERRORS LIMIT 1;
			ROLLBACK;
		END;
    START TRANSACTION;
		IF (trim(tProd) = 0 AND trim(idProd) = 0 AND trim(idVen) = 0 AND trim(pre) = 0) THEN
			SELECT "NO HAY NADA POR HACER";
		ELSE
        IF (trim(idProd) = 0 OR trim(idVen) = 0) THEN
			SELECT "FALTAN DATOS";
        ELSE
			IF (trim(tProd) = 0) THEN
				IF (trim(pre) = 0) THEN
					SELECT "NO HAY NADA POR HACER";
				ELSE
					UPDATE detalleVenta SET precio = pre, subtotal = trim(tProd)*pre WHERE Producto_idProducto = idProd AND Ventas_idVentas = idVen;
                END IF;
			ELSE
				IF (trim(pre) = 0) THEN
					UPDATE detalleVenta SET cantidad = trim(tProd), subtotal = trim(tProd)*pre WHERE Producto_idProducto = idProd AND Ventas_idVentas = idVen;
                ELSE
					UPDATE detalleVenta SET cantidad = trim(tProd), precio = pre, subtotal = trim(tProd)*pre WHERE Producto_idProducto = idProd AND Ventas_idVentas = idVen;
                END IF;
            END IF;
        END IF;
        END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateProveedor` (IN `idProve` INT, IN `nom` VARCHAR(45), IN `emaile` VARCHAR(100), IN `calle` VARCHAR(100), IN `num` VARCHAR(45), IN `col` VARCHAR(45), IN `cp` INT(5), IN `ciud` VARCHAR(45), IN `est` VARCHAR(45), IN `lad` VARCHAR(45), IN `tel` INT)  BEGIN
		DECLARE contar int;
		DECLARE idCi int;
		DECLARE idCo int;
		DECLARE idEs int;
		DECLARE idDir int;
		DECLARE ids int;
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
			BEGIN
				SHOW ERRORS LIMIT 1;
				ROLLBACK;
			END; 
            
		START TRANSACTION;
        
        IF(idProve = 0 OR trim(nom) = '' OR trim(emaile) = '' OR trim(calle) = '' OR trim(num) = '' OR trim(col) = '' OR cp = 0 OR trim(ciud) = '' OR trim(est) = '' OR trim(lad) = '' OR tel = 0) THEN
			SELECT "FALTAN DATOS";
		ELSE
			SELECT Direccion_idDireccion INTO idDir FROM Proveedor where idProveedor = idProve;
            SELECT Colonia_idColonia INTO idCo FROM Direccion where idDireccion = idDir;
            SELECT Ciudad_idEstadoCiudad INTO idCi FROM Colonia where idColonia = idCo;
            SELECT Estado_idEstado INTO idEs FROM Ciudad where idEstadoCiudad = idCi;
            
            
            SELECT count(*) INTO contar FROM Estado where estado = trim(est) and idEstado = idEs;
                IF (contar = 0) THEN
					 SELECT count(*) INTO contar FROM Estado where estado = trim(est);
                IF(contar = 0) THEN
					UPDATE Estado SET estado = trim(est) where idEstado = idEs;
				ELSE
					SELECT idEstado INTO idEs FROM Estado where estado = trim(est);
				END IF;
				END IF;
                
			SELECT count(*) INTO contar FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = idEs and idEstadoCiudad = idCi;
				IF (contar = 0) THEN
					SELECT count(*) INTO contar FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = idEs;
				IF(contar = 0) THEN
                
                IF(ids=0) THEN
					SET ids = 0;
					UPDATE Ciudad SET ciudad = trim(ciud) where idEstadoCiudad = idCi;
				ELSE
					UPDATE Ciudad SET ciudad = trim(ciud), Estado_idEstado = idEs where idEstadoCiudad = idCi;
                END IF;
                ELSE
					SELECT idEstadoCiudad INTO idCi FROM Ciudad where ciudad = trim(ciud) and Estado_idEstado = idEs;
				END IF;
				END IF;
                
                
			SELECT count(*) INTO contar FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = idCi and idColonia = idCo;
				IF (contar = 0) THEN
					SELECT count(*) INTO contar FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = idCi;
				IF (contar = 0) THEN
                IF (ids = 0) THEN
					SET ids = 0;
                    UPDATE Colonia SET colonia = trim(col), codigoPostal = cp where idColonia = idCo;
				ELSE
					UPDATE Colonia SET colonia = trim(col), codigoPostal = cp, Ciudad_idEstadoCiudad = idCi where idColonia = idCo;
                END IF;
                ELSE
					SELECT idColonia INTO idCo FROM Colonia where colonia = trim(col) and codigoPostal = cp and Ciudad_idEstadoCiudad = idCi;
				END IF;
				END IF;
			
            
            SELECT count(*) INTO contar FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = idCo and idDireccion = idDir;
				IF (contar = 0) THEN
					SELECT count(*) INTO contar FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = idCo;
				IF (contar = 0) THEN
                IF (ids = 0) THEN
					SET ids = 0;
					UPDATE Direccion SET calle_dir = trim(calle), no_dir = trim(num) where idDireccion = idDir;
				ELSE
					UPDATE Direccion SET calle_dir = trim(calle), no_dir = trim(num), Colonia_idColonia = idCo where idDireccion = idDir;
				END IF;
                ELSE
					SELECT idDireccion INTO idDir FROM Direccion where calle_dir = trim(calle) and no_dir = trim(num) and Colonia_idColonia = idCo;
				END IF;
				END IF;
			
            
            SELECT count(*) INTO contar FROM Proveedor where nombre = trim(nom) and email = trim(emaile) and Direccion_idDireccion = idDir and idProveedor = idProve;
				IF (contar = 0) THEN
					SELECT count(*) INTO contar FROM Proveedor where nombre = trim(nom)  and email = trim(emaile) and Direccion_idDireccion = idDir;
                IF (contar = 0) THEN
                IF (ids = 0) THEN
					SET ids = 0;
					UPDATE Proveedor SET nombre = nom, email = emaile where idProveedor = idProve;
				ELSE
                    UPDATE Proveedor SET nombre = trim(nom), email = trim(emaile), Direccion_idDireccion = idDir where idProveedor = idProve;
				END IF;
                END IF;
				END IF;
            
            
            SELECT count(*) INTO contar FROM Telefono_P where lada = trim(lad) and telefono = tel and Proveedor_idProveedor = idProve;
				IF(contar = 1) THEN
					UPDATE Telefono_P SET lada = trim(lad), telefono = tel where Proveedor_idProveedor = idProve;
                    COMMIT;
				ELSE
					COMMIT;
                END IF;
		END IF;
	END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateVenta` (IN `pag` FLOAT(9,2), IN `tProd` FLOAT(9,2), IN `idProd` INT, IN `idEmp` INT, IN `idVen` INT)  BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
		BEGIN
			SHOW ERRORS LIMIT 1;
			ROLLBACK;
		END;
    START TRANSACTION;
		IF (trim(pag) = 0 AND trim(tProd) = 0 AND trim(idProd) = 0 AND trim(idEmp)) THEN
			SELECT "NO HAY NADA POR HACER";
		ELSE
			IF (trim(pag) = 0) THEN
                SET @pre = (SELECT precio FROM Producto WHERE idProducto = idProd);
				CALL sp_updateDetVen(tProd, idProd, idEmp, idVen, @pre);
			ELSE
				UPDATE Ventas SET pago = pag WHERE idVentas = idVen;
                SET @pre = (SELECT precio FROM Producto WHERE idProducto = idProd);
				CALL sp_updateDetVen(tProd, idProd, idVen, @pre);
            END IF;
		END IF;
END$$

--
-- Funciones
--
CREATE DEFINER=`root`@`localhost` FUNCTION `reporte` (`idVent` INT) RETURNS LONGTEXT CHARSET utf8 COLLATE utf8_spanish2_ci BEGIN
	DECLARE reporte LONGTEXT;
	SET reporte = (SELECT * FROM Ventas JOIN detalleVenta ON idVentas = Ventas_idVentas JOIN Empleado on idEmpleado = Empleado_idEmpleado WHERE idVentas = idVent);
    RETURN reporte;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `tempSubtotal` (`pre` INT, `cant` INT) RETURNS FLOAT(9,2) BEGIN
	DECLARE subtotal FLOAT(9,2);
    SET subtotal = pre * cant;
    RETURN subtotal;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `ultimoidV` () RETURNS INT(11) BEGIN
	DECLARE id INT;
    SET id = (SELECT max(idVentas) FROM Ventas);
    RETURN id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categoria`
--

CREATE TABLE `categoria` (
  `idCategoria` int(11) NOT NULL,
  `nombre` varchar(50) COLLATE utf8_spanish2_ci NOT NULL,
  `descripcion` varchar(300) COLLATE utf8_spanish2_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `categoria`
--

INSERT INTO `categoria` (`idCategoria`, `nombre`, `descripcion`) VALUES
(1, 'DULCES', 'DULCES Y CHCILES');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ciudad`
--

CREATE TABLE `ciudad` (
  `idEstadoCiudad` int(11) NOT NULL,
  `ciudad` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `Estado_idEstado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `ciudad`
--

INSERT INTO `ciudad` (`idEstadoCiudad`, `ciudad`, `Estado_idEstado`) VALUES
(1, 'Tarandacuao', 1),
(2, 'Acambaro', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente`
--

CREATE TABLE `cliente` (
  `idCliente` int(11) NOT NULL,
  `nombre` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `apellido_P` varchar(100) COLLATE utf8_spanish2_ci NOT NULL,
  `apellido_M` varchar(100) COLLATE utf8_spanish2_ci NOT NULL,
  `email` varchar(100) COLLATE utf8_spanish2_ci NOT NULL,
  `Direccion_idDireccion` int(11) NOT NULL,
  `password` varchar(10) COLLATE utf8_spanish2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `cliente`
--

INSERT INTO `cliente` (`idCliente`, `nombre`, `apellido_P`, `apellido_M`, `email`, `Direccion_idDireccion`, `password`) VALUES
(1, 'Luis', 'Rojas', 'Tello', 'cli@cl.com', 2, ''),
(7, 'Juan', 'Perdcdez', 'Hernandez', 'Juan@hotmail.com', 2, ''),
(9, 'Juan', 'Pez', 'Hernandez', 'Juan@hotmail.com', 2, '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `colonia`
--

CREATE TABLE `colonia` (
  `idColonia` int(11) NOT NULL,
  `colonia` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `codigoPostal` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `Ciudad_idEstadoCiudad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `colonia`
--

INSERT INTO `colonia` (`idColonia`, `colonia`, `codigoPostal`, `Ciudad_idEstadoCiudad`) VALUES
(1, 'Centro', '38790', 1),
(2, 'Centro', '38623', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detallepedido`
--

CREATE TABLE `detallepedido` (
  `Producto_idProducto` int(11) NOT NULL,
  `cantidad` double(9,2) NOT NULL,
  `precio` double(9,2) NOT NULL,
  `subtotal` double(9,2) NOT NULL,
  `Pedidos_idPedidos` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `detalleventa`
--

CREATE TABLE `detalleventa` (
  `Producto_idProducto` int(11) NOT NULL,
  `cantidad` float(9,2) NOT NULL,
  `precio` float(9,2) NOT NULL,
  `subtotal` float(9,2) NOT NULL,
  `Ventas_idVentas` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `detalleventa`
--

INSERT INTO `detalleventa` (`Producto_idProducto`, `cantidad`, `precio`, `subtotal`, `Ventas_idVentas`) VALUES
(1, 1.00, 1.00, 1.00, 146),
(1, 1.00, 1.00, 1.00, 148),
(2, 1.00, 7.50, 7.50, 148);

--
-- Disparadores `detalleventa`
--
DELIMITER $$
CREATE TRIGGER `tg_addDetven` AFTER INSERT ON `detalleventa` FOR EACH ROW BEGIN
	UPDATE Ventas SET totalVenta = totalVenta + new.subtotal, cambio = pago - totalVenta WHERE idVentas = new.Ventas_idVentas;
    UPDATE Producto SET stock = stock - new.cantidad WHERE idProducto = new.Producto_idProducto;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tg_delDetalleVenta` AFTER DELETE ON `detalleventa` FOR EACH ROW BEGIN
		UPDATE Ventas SET totalVenta = totalVenta - old.subtotal, cambio = pago - totalVenta WHERE idVentas = old.Ventas_idVentas;
		UPDATE Producto SET stock = stock + old.cantidad WHERE idProducto = old.Producto_idProducto;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `tg_updateDtVen` AFTER UPDATE ON `detalleventa` FOR EACH ROW BEGIN
	DECLARE sub FLOAT(9,2);
    DECLARE idv INT;
    
    SELECT idVentas INTO idv FROM Ventas WHERE idVentas = new.Ventas_idVentas;
    SELECT sum(subtotal) INTO sub FROM detalleVenta WHERE Ventas_idVentas = idv;
    
	UPDATE Ventas SET totalVenta = sub, cambio = pago - sub WHERE idVentas = new.Ventas_idVentas;
    UPDATE Producto SET stock = stock + old.cantidad WHERE idProducto = new.Producto_idProducto;
    UPDATE Producto SET stock = stock - new.cantidad WHERE idProducto = new.Producto_idProducto;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `direccion`
--

CREATE TABLE `direccion` (
  `idDireccion` int(11) NOT NULL,
  `calle_dir` varchar(100) COLLATE utf8_spanish2_ci NOT NULL,
  `no_dir` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `Colonia_idColonia` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `direccion`
--

INSERT INTO `direccion` (`idDireccion`, `calle_dir`, `no_dir`, `Colonia_idColonia`) VALUES
(1, '16 de Septiembre', '30-B', 1),
(2, '20 de Septiembre', '30-A', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleado`
--

CREATE TABLE `empleado` (
  `idEmpleado` int(11) NOT NULL,
  `nombre` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `apellido_P` varchar(100) COLLATE utf8_spanish2_ci NOT NULL,
  `apellido_M` varchar(100) COLLATE utf8_spanish2_ci NOT NULL,
  `email` varchar(100) COLLATE utf8_spanish2_ci NOT NULL,
  `Direccion_idDireccion` int(11) NOT NULL,
  `password` varchar(10) COLLATE utf8_spanish2_ci NOT NULL,
  `privi` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `empleado`
--

INSERT INTO `empleado` (`idEmpleado`, `nombre`, `apellido_P`, `apellido_M`, `email`, `Direccion_idDireccion`, `password`, `privi`) VALUES
(1, 'manuela', 'Lopez', 'Rojas', 'emple@em.com', 1, '', 0),
(2, 'manuec', 'Lopez', 'Rojas', 'empleado@em.com', 1, '', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado`
--

CREATE TABLE `estado` (
  `idEstado` int(11) NOT NULL,
  `estado` varchar(45) COLLATE utf8_spanish2_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `estado`
--

INSERT INTO `estado` (`idEstado`, `estado`) VALUES
(1, 'Guanajuato');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marca`
--

CREATE TABLE `marca` (
  `idMarca` int(11) NOT NULL,
  `nombre` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `Proveedor_idProveedor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `marca`
--

INSERT INTO `marca` (`idMarca`, `nombre`, `Proveedor_idProveedor`) VALUES
(1, 'SONRIX', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ofertas`
--

CREATE TABLE `ofertas` (
  `idGaleria` int(11) NOT NULL,
  `urlImagen` varchar(500) CHARACTER SET utf8 NOT NULL DEFAULT '0',
  `titulo` varchar(100) CHARACTER SET utf8 DEFAULT '0',
  `texto` varchar(500) CHARACTER SET utf8 DEFAULT '0',
  `fecha` date DEFAULT '0000-00-00',
  `hora` time DEFAULT NULL,
  `botonText` varchar(20) COLLATE utf32_spanish2_ci NOT NULL DEFAULT 'Saber más',
  `Empleado_idEmpleado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_spanish2_ci;

--
-- Volcado de datos para la tabla `ofertas`
--

INSERT INTO `ofertas` (`idGaleria`, `urlImagen`, `titulo`, `texto`, `fecha`, `hora`, `botonText`, `Empleado_idEmpleado`) VALUES
(5, 'uploads/galeria/t1.jpg', 'Productos', 'tenemos un amplio surtido de productos que satisfacen las necesidades básicas del hogar', '2016-12-02', '17:16:37', 'Saber más', 0),
(6, 'uploads/galeria/t2.jpg', 'Prueba nuestros productos', 'Te invitamos a visitarnos y probar nuestros productos', '2016-12-02', '17:18:06', 'Saber más', 0),
(7, 'uploads/galeria/t3.jpg', 'Ingredientes frescos', 'Los ingredientes usados en la elaboración de nuestros productos son frescos', '2016-12-02', '17:19:37', 'Saber más', 0),
(9, 'uploads/galeria/otros.jpg', 'Otros productos', 'Contamos con productos ligeros para tu desayuno como jugos naturales y gelatinas', '2016-12-02', '17:24:18', 'Saber más', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedidos`
--

CREATE TABLE `pedidos` (
  `idPedidos` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `total` int(11) NOT NULL,
  `estatus` tinyint(1) NOT NULL,
  `Cliente_idCliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto`
--

CREATE TABLE `producto` (
  `idProducto` int(11) NOT NULL,
  `urlImagen` varchar(200) COLLATE utf8_spanish2_ci NOT NULL,
  `nombre` varchar(150) COLLATE utf8_spanish2_ci NOT NULL,
  `descripcion` varchar(300) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `precio` float NOT NULL,
  `stock` float NOT NULL,
  `Marca_idMarca` int(11) NOT NULL,
  `Categoria_idCategoria` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `producto`
--

INSERT INTO `producto` (`idProducto`, `urlImagen`, `nombre`, `descripcion`, `precio`, `stock`, `Marca_idMarca`, `Categoria_idCategoria`) VALUES
(1, 'uploads/galeria/ins8.jpg', 'Torta de milanesa', 'Torta de milanesa de pollo, con lechuga, jitomate, aguacate, mayonesa y salsa.', 16, 20, 1, 1),
(2, 'uploads/galeria/ins2.jpg', 'Refresco', '600ml', 7.5, 19, 1, 1),
(3, 'uploads/galeria/ins7.jpg', 'Agua', 'Agua natural de 600ml', 7, 15, 1, 1),
(4, 'uploads/galeria/ins11.jpg', 'jamón', '1 kg de jamon de pavo', 10, 50, 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedor`
--

CREATE TABLE `proveedor` (
  `idProveedor` int(11) NOT NULL,
  `nombre` varchar(50) COLLATE utf8_spanish2_ci NOT NULL,
  `email` varchar(100) COLLATE utf8_spanish2_ci DEFAULT NULL,
  `Direccion_idDireccion` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `proveedor`
--

INSERT INTO `proveedor` (`idProveedor`, `nombre`, `email`, `Direccion_idDireccion`) VALUES
(1, 'Proveedor', 'emple@em.com', 1),
(2, 'pepsico', 'empleado@em.com', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `slider`
--

CREATE TABLE `slider` (
  `idImagen` int(11) NOT NULL,
  `urlImagen` varchar(500) CHARACTER SET utf8 NOT NULL DEFAULT '0',
  `texto` varchar(200) CHARACTER SET utf8 DEFAULT '0',
  `titulo` varchar(200) CHARACTER SET utf8 NOT NULL,
  `botonText` varchar(100) CHARACTER SET utf8 NOT NULL DEFAULT 'Saber más',
  `Empleado_idEmpleado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `slider`
--

INSERT INTO `slider` (`idImagen`, `urlImagen`, `texto`, `titulo`, `botonText`, `Empleado_idEmpleado`) VALUES
(1, 'uploads/slider/fondop.jpg', 'Conoce los productos que te ofrecemos', 'Somos EDDY BURGUER', 'Saber más', 0),
(2, 'uploads/slider/torta.jpg', 'Productos de calidad.', 'Variedad', 'Saber más', 0),
(3, 'uploads/slider/torta2.jpg', 'El tamaño justo para satisfacer tu hambre.', 'Precio justo', 'Saber más', 0),
(4, 'uploads/slider/torta3.jpg', 'Variedad en nuestros productos.', 'Conócenos', 'Saber más', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `telefono_c`
--

CREATE TABLE `telefono_c` (
  `idTelefono_C` int(11) NOT NULL,
  `lada` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `telefono` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `Cliente_idCliente` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `telefono_c`
--

INSERT INTO `telefono_c` (`idTelefono_C`, `lada`, `telefono`, `Cliente_idCliente`) VALUES
(1, '417', '1075644', 7),
(2, '417', '1055644', 7),
(3, '417', '1058644', 9);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `telefono_e`
--

CREATE TABLE `telefono_e` (
  `idTelefono_E` int(11) NOT NULL,
  `lada` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `telefono` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `Empleado_idEmpleado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `telefono_e`
--

INSERT INTO `telefono_e` (`idTelefono_E`, `lada`, `telefono`, `Empleado_idEmpleado`) VALUES
(1, '421', '1062525', 1),
(2, '421', '1072523', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `telefono_p`
--

CREATE TABLE `telefono_p` (
  `idTelefono_P` int(11) NOT NULL,
  `lada` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `telefono` varchar(45) COLLATE utf8_spanish2_ci NOT NULL,
  `Proveedor_idProveedor` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `telefono_p`
--

INSERT INTO `telefono_p` (`idTelefono_P`, `lada`, `telefono`, `Proveedor_idProveedor`) VALUES
(4, '421', '1062523', 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `idVentas` int(11) NOT NULL,
  `totalVenta` float NOT NULL,
  `pago` float NOT NULL,
  `cambio` float NOT NULL,
  `fecha` date NOT NULL,
  `Empleado_idEmpleado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish2_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`idVentas`, `totalVenta`, `pago`, `cambio`, `fecha`, `Empleado_idEmpleado`) VALUES
(146, 1, 55, 54, '2017-04-07', 1),
(148, 8.5, 60, 51.5, '2017-04-07', 1);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categoria`
--
ALTER TABLE `categoria`
  ADD PRIMARY KEY (`idCategoria`);

--
-- Indices de la tabla `ciudad`
--
ALTER TABLE `ciudad`
  ADD PRIMARY KEY (`idEstadoCiudad`,`Estado_idEstado`),
  ADD KEY `fk_Ciudad_Estado1_idx` (`Estado_idEstado`);

--
-- Indices de la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD PRIMARY KEY (`idCliente`,`Direccion_idDireccion`),
  ADD KEY `fk_Cliente_Direccion1_idx` (`Direccion_idDireccion`);

--
-- Indices de la tabla `colonia`
--
ALTER TABLE `colonia`
  ADD PRIMARY KEY (`idColonia`,`Ciudad_idEstadoCiudad`),
  ADD KEY `fk_Colonia_Ciudad1_idx` (`Ciudad_idEstadoCiudad`);

--
-- Indices de la tabla `detallepedido`
--
ALTER TABLE `detallepedido`
  ADD PRIMARY KEY (`Producto_idProducto`,`Pedidos_idPedidos`),
  ADD KEY `fk_Producto_has_Pedidos_Pedidos1_idx` (`Pedidos_idPedidos`),
  ADD KEY `fk_Producto_has_Pedidos_Producto1_idx` (`Producto_idProducto`);

--
-- Indices de la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD PRIMARY KEY (`Ventas_idVentas`,`Producto_idProducto`),
  ADD KEY `fk_Producto_has_Ventas_Ventas1_idx` (`Ventas_idVentas`),
  ADD KEY `fk_Producto_has_Ventas_Producto1_idx` (`Producto_idProducto`);

--
-- Indices de la tabla `direccion`
--
ALTER TABLE `direccion`
  ADD PRIMARY KEY (`idDireccion`,`Colonia_idColonia`),
  ADD KEY `fk_Direccion_Colonia1_idx` (`Colonia_idColonia`);

--
-- Indices de la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD PRIMARY KEY (`idEmpleado`,`Direccion_idDireccion`),
  ADD KEY `fk_Empleado_Direccion1_idx` (`Direccion_idDireccion`);

--
-- Indices de la tabla `estado`
--
ALTER TABLE `estado`
  ADD PRIMARY KEY (`idEstado`);

--
-- Indices de la tabla `marca`
--
ALTER TABLE `marca`
  ADD PRIMARY KEY (`idMarca`,`Proveedor_idProveedor`),
  ADD UNIQUE KEY `nombre_UNIQUE` (`nombre`),
  ADD KEY `fk_Marca_Proveedor1_idx` (`Proveedor_idProveedor`);

--
-- Indices de la tabla `ofertas`
--
ALTER TABLE `ofertas`
  ADD PRIMARY KEY (`idGaleria`,`Empleado_idEmpleado`),
  ADD KEY `fk_ofertas_empleado` (`Empleado_idEmpleado`);

--
-- Indices de la tabla `pedidos`
--
ALTER TABLE `pedidos`
  ADD PRIMARY KEY (`idPedidos`,`Cliente_idCliente`),
  ADD KEY `fk_Pedidos_Cliente1_idx` (`Cliente_idCliente`);

--
-- Indices de la tabla `producto`
--
ALTER TABLE `producto`
  ADD PRIMARY KEY (`idProducto`,`Categoria_idCategoria`,`Marca_idMarca`),
  ADD UNIQUE KEY `nombre_UNIQUE` (`nombre`),
  ADD KEY `fk_Producto_Marca_idx` (`Marca_idMarca`),
  ADD KEY `fk_Producto_Categoria1_idx` (`Categoria_idCategoria`);

--
-- Indices de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD PRIMARY KEY (`idProveedor`,`Direccion_idDireccion`),
  ADD UNIQUE KEY `nombre_UNIQUE` (`nombre`),
  ADD KEY `fk_Proveedor_Direccion1_idx` (`Direccion_idDireccion`);

--
-- Indices de la tabla `slider`
--
ALTER TABLE `slider`
  ADD PRIMARY KEY (`idImagen`,`Empleado_idEmpleado`),
  ADD KEY `fk_slider_empleado` (`Empleado_idEmpleado`);

--
-- Indices de la tabla `telefono_c`
--
ALTER TABLE `telefono_c`
  ADD PRIMARY KEY (`idTelefono_C`,`Cliente_idCliente`),
  ADD KEY `fk_Telefono_E_copy1_Cliente1_idx` (`Cliente_idCliente`);

--
-- Indices de la tabla `telefono_e`
--
ALTER TABLE `telefono_e`
  ADD PRIMARY KEY (`idTelefono_E`,`Empleado_idEmpleado`),
  ADD KEY `fk_Telefono_P_copy1_Empleado1_idx` (`Empleado_idEmpleado`);

--
-- Indices de la tabla `telefono_p`
--
ALTER TABLE `telefono_p`
  ADD PRIMARY KEY (`idTelefono_P`,`Proveedor_idProveedor`),
  ADD KEY `fk_Telefono_Proveedor1_idx` (`Proveedor_idProveedor`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`idVentas`,`Empleado_idEmpleado`),
  ADD KEY `fk_Ventas_Empleado1_idx` (`Empleado_idEmpleado`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categoria`
--
ALTER TABLE `categoria`
  MODIFY `idCategoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `ciudad`
--
ALTER TABLE `ciudad`
  MODIFY `idEstadoCiudad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `cliente`
--
ALTER TABLE `cliente`
  MODIFY `idCliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT de la tabla `colonia`
--
ALTER TABLE `colonia`
  MODIFY `idColonia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `direccion`
--
ALTER TABLE `direccion`
  MODIFY `idDireccion` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `empleado`
--
ALTER TABLE `empleado`
  MODIFY `idEmpleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `estado`
--
ALTER TABLE `estado`
  MODIFY `idEstado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `marca`
--
ALTER TABLE `marca`
  MODIFY `idMarca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT de la tabla `ofertas`
--
ALTER TABLE `ofertas`
  MODIFY `idGaleria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT de la tabla `pedidos`
--
ALTER TABLE `pedidos`
  MODIFY `idPedidos` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT de la tabla `producto`
--
ALTER TABLE `producto`
  MODIFY `idProducto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `proveedor`
--
ALTER TABLE `proveedor`
  MODIFY `idProveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `slider`
--
ALTER TABLE `slider`
  MODIFY `idImagen` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `telefono_c`
--
ALTER TABLE `telefono_c`
  MODIFY `idTelefono_C` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;
--
-- AUTO_INCREMENT de la tabla `telefono_e`
--
ALTER TABLE `telefono_e`
  MODIFY `idTelefono_E` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
--
-- AUTO_INCREMENT de la tabla `telefono_p`
--
ALTER TABLE `telefono_p`
  MODIFY `idTelefono_P` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;
--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `idVentas` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=149;
--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `ciudad`
--
ALTER TABLE `ciudad`
  ADD CONSTRAINT `fk_Ciudad_Estado1` FOREIGN KEY (`Estado_idEstado`) REFERENCES `estado` (`idEstado`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `cliente`
--
ALTER TABLE `cliente`
  ADD CONSTRAINT `fk_Cliente_Direccion1` FOREIGN KEY (`Direccion_idDireccion`) REFERENCES `direccion` (`idDireccion`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `colonia`
--
ALTER TABLE `colonia`
  ADD CONSTRAINT `fk_Colonia_Ciudad1` FOREIGN KEY (`Ciudad_idEstadoCiudad`) REFERENCES `ciudad` (`idEstadoCiudad`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `detallepedido`
--
ALTER TABLE `detallepedido`
  ADD CONSTRAINT `fk_Producto_has_Pedidos_Pedidos1` FOREIGN KEY (`Pedidos_idPedidos`) REFERENCES `pedidos` (`idPedidos`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Producto_has_Pedidos_Producto1` FOREIGN KEY (`Producto_idProducto`) REFERENCES `producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `detalleventa`
--
ALTER TABLE `detalleventa`
  ADD CONSTRAINT `fk_Producto_has_Ventas_Producto1` FOREIGN KEY (`Producto_idProducto`) REFERENCES `producto` (`idProducto`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Producto_has_Ventas_Ventas1` FOREIGN KEY (`Ventas_idVentas`) REFERENCES `ventas` (`idVentas`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `direccion`
--
ALTER TABLE `direccion`
  ADD CONSTRAINT `fk_Direccion_Colonia1` FOREIGN KEY (`Colonia_idColonia`) REFERENCES `colonia` (`idColonia`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `empleado`
--
ALTER TABLE `empleado`
  ADD CONSTRAINT `fk_Empleado_Direccion1` FOREIGN KEY (`Direccion_idDireccion`) REFERENCES `direccion` (`idDireccion`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `marca`
--
ALTER TABLE `marca`
  ADD CONSTRAINT `fk_Marca_Proveedor1` FOREIGN KEY (`Proveedor_idProveedor`) REFERENCES `proveedor` (`idProveedor`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `ofertas`
--
ALTER TABLE `ofertas`
  ADD CONSTRAINT `fk_ofertas_empleado` FOREIGN KEY (`Empleado_idEmpleado`) REFERENCES `empleado` (`idEmpleado`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `pedidos`
--
ALTER TABLE `pedidos`
  ADD CONSTRAINT `fk_Pedidos_Cliente1` FOREIGN KEY (`Cliente_idCliente`) REFERENCES `cliente` (`idCliente`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `producto`
--
ALTER TABLE `producto`
  ADD CONSTRAINT `fk_Producto_Categoria1` FOREIGN KEY (`Categoria_idCategoria`) REFERENCES `categoria` (`idCategoria`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  ADD CONSTRAINT `fk_Producto_Marca` FOREIGN KEY (`Marca_idMarca`) REFERENCES `marca` (`idMarca`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `proveedor`
--
ALTER TABLE `proveedor`
  ADD CONSTRAINT `fk_Proveedor_Direccion1` FOREIGN KEY (`Direccion_idDireccion`) REFERENCES `direccion` (`idDireccion`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `slider`
--
ALTER TABLE `slider`
  ADD CONSTRAINT `fk_slider_empleado` FOREIGN KEY (`Empleado_idEmpleado`) REFERENCES `empleado` (`idEmpleado`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `telefono_c`
--
ALTER TABLE `telefono_c`
  ADD CONSTRAINT `fk_Telefono_E_copy1_Cliente1` FOREIGN KEY (`Cliente_idCliente`) REFERENCES `cliente` (`idCliente`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `telefono_e`
--
ALTER TABLE `telefono_e`
  ADD CONSTRAINT `fk_Telefono_P_copy1_Empleado1` FOREIGN KEY (`Empleado_idEmpleado`) REFERENCES `empleado` (`idEmpleado`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `telefono_p`
--
ALTER TABLE `telefono_p`
  ADD CONSTRAINT `fk_Telefono_Proveedor1` FOREIGN KEY (`Proveedor_idProveedor`) REFERENCES `proveedor` (`idProveedor`) ON DELETE NO ACTION ON UPDATE NO ACTION;

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `fk_Ventas_Empleado1` FOREIGN KEY (`Empleado_idEmpleado`) REFERENCES `empleado` (`idEmpleado`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
