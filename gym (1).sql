-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-12-2024 a las 00:08:01
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `gym`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `asignar_rutina` (IN `p_id_membresia` INT, IN `p_descripcion` VARCHAR(500), IN `p_duracion_dias` INT)   BEGIN
    DECLARE v_estado_membresia VARCHAR(10);

    -- Verificar si la membresía está activa
    SELECT estado_membresia INTO v_estado_membresia
    FROM Membresias
    WHERE id_membresia = p_id_membresia;

    IF v_estado_membresia = 'Activo' THEN
        -- Insertar la rutina en la tabla Rutinas
        INSERT INTO Rutinas (
            id_membresia, 
            descripcion, 
            fecha_asignacion, 
            duracion_dias
        ) VALUES (
            p_id_membresia, 
            p_descripcion, 
            CURDATE(), 
            p_duracion_dias
        );
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La membresía no está activa. No se puede asignar una rutina.';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarAsistencias` (IN `p_asistio` VARCHAR(50), IN `p_no_asistio` VARCHAR(50), IN `p_fecha_inasistencia` DATE)   BEGIN
	 INSERT INTO asistencia (
	 	  asistio,
	 	  no_asistio,
	 	  fecha_inasistencia
	 ) VALUES ( 
	 	  p_asistio,
	 	  p_no_asistio,
	 	  p_fecha_inasistencia
	 );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrarMiembros` (IN `p_nombre_cliente` VARCHAR(200), IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, IN `p_tipo_membresia` VARCHAR(50))   BEGIN
	 INSERT INTO membresias (
	 	  nombre_cliente,
	 	  fecha_inicio,
	 	  fecha_fin,
	 	  estado_membresia
	 ) VALUES ( 
	 	  p_nombre_cliente,
	 	  p_fecha_inicio,
	 	  p_fecha_fin,
	 	  'Activo'
	 );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_pago` (IN `p_id_membresia` INT, IN `p_monto` DECIMAL(10,2), IN `p_metodo_pago` VARCHAR(50))   BEGIN
    DECLARE v_saldo_actual DECIMAL(10, 2);
    
    
    SELECT saldo_pago INTO v_saldo_actual
    FROM membresias
    WHERE id_membresia = p_id_membresia;
    
    
    IF v_saldo_actual > p_monto THEN
        UPDATE membresias
        SET saldo_pago = v_saldo_actual - p_monto
        WHERE id_membresia = p_id_membresia;
        
    
    ELSE
        UPDATE membresias
        SET saldo_pago = 0.00, estado_membresia = 'Activo'
        WHERE id_membresia = p_id_membresia;
    END IF;
    
    
    INSERT INTO pagos (
        id_membresia,
        monto,
        fecha_pago,
        metodo_pago
    ) VALUES (
        p_id_membresia,
        p_monto,
        CURDATE(),
        p_metodo_pago
    );
    
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alertas`
--

CREATE TABLE `alertas` (
  `id_alerta` int(11) NOT NULL,
  `id_membresia` int(11) DEFAULT NULL,
  `mensaje` varchar(255) DEFAULT NULL,
  `fecha_alerta` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `alertas`
--

INSERT INTO `alertas` (`id_alerta`, `id_membresia`, `mensaje`, `fecha_alerta`) VALUES
(1, 1, 'La membresía de Juan Pérez vencerá en 1 días.', '2024-12-07 19:04:39'),
(2, 1, 'La membresía de Juan Pérez vencerá en 1 días.', '2024-12-07 19:05:10');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asistencia`
--

CREATE TABLE `asistencia` (
  `tarjeta_asistencia` int(11) NOT NULL,
  `id_membresia` int(11) DEFAULT NULL,
  `asistio` varchar(50) DEFAULT NULL,
  `no_asistio` varchar(50) DEFAULT NULL,
  `fecha_inasistencia` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `asistencia`
--

INSERT INTO `asistencia` (`tarjeta_asistencia`, `id_membresia`, `asistio`, `no_asistio`, `fecha_inasistencia`) VALUES
(1, NULL, 'Si', 'Null', '0000-00-00'),
(2, NULL, 'No', 'No asistio', '2025-07-23');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `historialrutinas`
--

CREATE TABLE `historialrutinas` (
  `id_historial` int(11) NOT NULL,
  `id_rutina` int(11) DEFAULT NULL,
  `id_membresia` int(11) DEFAULT NULL,
  `nombre_rutina` varchar(255) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `duracion_estimada` int(11) DEFAULT NULL,
  `fecha_cambio` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `historialrutinas`
--

INSERT INTO `historialrutinas` (`id_historial`, `id_rutina`, `id_membresia`, `nombre_rutina`, `descripcion`, `duracion_estimada`, `fecha_cambio`) VALUES
(1, 1, 1, 'Cicuito intensivo', 'Ejercicios variados', 50, '2024-12-06 15:00:28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `membresias`
--

CREATE TABLE `membresias` (
  `id_membresia` int(11) NOT NULL,
  `nombre_cliente` varchar(100) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `estado_membresia` varchar(100) NOT NULL,
  `saldo_pago` decimal(10,2) DEFAULT 0.00
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `membresias`
--

INSERT INTO `membresias` (`id_membresia`, `nombre_cliente`, `fecha_inicio`, `fecha_fin`, `estado_membresia`, `saldo_pago`) VALUES
(1, 'Juan Pérez', '2024-11-01', '2024-12-08', 'Activo', 0.00),
(2, 'Ana Gómez', '2024-09-01', '2024-10-01', 'Activo', 0.00),
(3, 'Juan Pérez', '2024-11-01', '2024-10-22', 'inactivo', 0.00),
(4, 'Pepe', '2000-09-25', '2006-08-12', 'Activo', 0.00),
(5, 'Jhon Casas', '2022-05-01', '2023-11-30', 'inactivo', 0.00),
(6, 'María Guzman', '2024-01-15', '2024-12-10', 'Activo', 0.00),
(7, 'Carlos Gómez', '2024-01-20', '2024-11-20', 'Activo', 0.00);

--
-- Disparadores `membresias`
--
DELIMITER $$
CREATE TRIGGER `actualizar` AFTER UPDATE ON `membresias` FOR EACH ROW BEGIN
    INSERT INTO membresia_actualizada(nombre_cliente, fecha_inicio, fecha_fin, estado_membresia, Action)
    VALUES (NEW.nombre_cliente, NEW.fecha_inicio, NEW.fecha_fin, NEW.estado_membresia, 'Updated Register');
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `alerta_vencimiento_membresias` AFTER UPDATE ON `membresias` FOR EACH ROW BEGIN
    DECLARE dias_restantes INT;

    
    SET dias_restantes = DATEDIFF(NEW.fecha_fin, CURDATE());

    
    IF dias_restantes <= 7 AND dias_restantes > 0 AND NEW.estado_membresia = 'Activo' THEN
        INSERT INTO Alertas (id_membresia, mensaje, fecha_alerta)
        VALUES (
            NEW.id_membresia,
            CONCAT('La membresía de ', NEW.nombre_cliente, ' vencerá en ', dias_restantes, ' días.'),
            NOW()
        );
    END IF;

    
    IF dias_restantes <= 0 THEN
        UPDATE membresias
        SET estado = 'Inactivo'
        WHERE id_membresia = NEW.id_membresia;

        INSERT INTO Alertas (id_membresia, mensaje, fecha_alerta)
        VALUES (
            NEW.id_membresia,
            CONCAT('La membresía de ', NEW.nombre_cliente, ' ha vencido.'),
            NOW()
        );
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `membresia_actualizada`
--

CREATE TABLE `membresia_actualizada` (
  `id_membresia` int(11) NOT NULL,
  `nombre_cliente` varchar(100) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `estado_membresia` varchar(100) NOT NULL,
  `ACTION` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `membresia_actualizada`
--

INSERT INTO `membresia_actualizada` (`id_membresia`, `nombre_cliente`, `fecha_inicio`, `fecha_fin`, `estado_membresia`, `ACTION`) VALUES
(1, 'Juan Pérez', '2024-11-01', '2024-10-22', 'inactivo', 'Updated Register'),
(116, 'Juan Pérez', '2024-11-01', '2024-12-08', 'Activo', 'Updated Register'),
(117, 'Juan Pérez', '2024-11-01', '2024-12-08', 'Activo', 'Updated Register');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos`
--

CREATE TABLE `pagos` (
  `id_pago` int(11) NOT NULL,
  `id_membresia` int(11) DEFAULT NULL,
  `monto` decimal(10,2) DEFAULT NULL,
  `fecha_pago` date DEFAULT NULL,
  `metodo_pago` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `pagos`
--

INSERT INTO `pagos` (`id_pago`, `id_membresia`, `monto`, `fecha_pago`, `metodo_pago`) VALUES
(1, 1, 50.00, '2024-12-07', 'Tarjeta de crédito');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rutinas`
--

CREATE TABLE `rutinas` (
  `id_rutina` int(11) NOT NULL,
  `id_membresia` int(11) DEFAULT NULL,
  `nombre_rutina` varchar(255) DEFAULT NULL,
  `descripcion` text DEFAULT NULL,
  `duracion_estimada` int(11) DEFAULT NULL,
  `fecha_actualizacion` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `duracion_dias` int(11) DEFAULT NULL,
  `fecha_asignacion` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rutinas`
--

INSERT INTO `rutinas` (`id_rutina`, `id_membresia`, `nombre_rutina`, `descripcion`, `duracion_estimada`, `fecha_actualizacion`, `duracion_dias`, `fecha_asignacion`) VALUES
(1, 1, 'Cicuito intensivo', 'Ejercicios variados', 45, '2024-12-06 15:00:28', NULL, NULL),
(2, 1, NULL, 'Rutina de fuerza para principiantes', NULL, '2024-12-06 16:29:56', 30, '2024-12-06');

--
-- Disparadores `rutinas`
--
DELIMITER $$
CREATE TRIGGER `historial` BEFORE UPDATE ON `rutinas` FOR EACH ROW BEGIN
INSERT INTO historialrutinas (
	 id_rutina, 
    id_membresia, 
    nombre_rutina, 
    descripcion, 
    duracion_estimada, 
    fecha_cambio
 )
 VALUES(
 	   OLD.id_rutina, 
      OLD.id_membresia, 
      OLD.nombre_rutina, 
      OLD.descripcion, 
      OLD.duracion_estimada, 
      NOW()
    );
END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alertas`
--
ALTER TABLE `alertas`
  ADD PRIMARY KEY (`id_alerta`);

--
-- Indices de la tabla `asistencia`
--
ALTER TABLE `asistencia`
  ADD PRIMARY KEY (`tarjeta_asistencia`),
  ADD KEY `id_membresia` (`id_membresia`);

--
-- Indices de la tabla `historialrutinas`
--
ALTER TABLE `historialrutinas`
  ADD PRIMARY KEY (`id_historial`);

--
-- Indices de la tabla `membresias`
--
ALTER TABLE `membresias`
  ADD PRIMARY KEY (`id_membresia`);

--
-- Indices de la tabla `membresia_actualizada`
--
ALTER TABLE `membresia_actualizada`
  ADD PRIMARY KEY (`id_membresia`);

--
-- Indices de la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD PRIMARY KEY (`id_pago`),
  ADD KEY `id_membresia` (`id_membresia`);

--
-- Indices de la tabla `rutinas`
--
ALTER TABLE `rutinas`
  ADD PRIMARY KEY (`id_rutina`),
  ADD KEY `fk_id_membresia` (`id_membresia`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alertas`
--
ALTER TABLE `alertas`
  MODIFY `id_alerta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `asistencia`
--
ALTER TABLE `asistencia`
  MODIFY `tarjeta_asistencia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `historialrutinas`
--
ALTER TABLE `historialrutinas`
  MODIFY `id_historial` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `membresias`
--
ALTER TABLE `membresias`
  MODIFY `id_membresia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `membresia_actualizada`
--
ALTER TABLE `membresia_actualizada`
  MODIFY `id_membresia` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT de la tabla `pagos`
--
ALTER TABLE `pagos`
  MODIFY `id_pago` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `rutinas`
--
ALTER TABLE `rutinas`
  MODIFY `id_rutina` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `asistencia`
--
ALTER TABLE `asistencia`
  ADD CONSTRAINT `asistencia_ibfk_1` FOREIGN KEY (`id_membresia`) REFERENCES `membresias` (`id_membresia`);

--
-- Filtros para la tabla `pagos`
--
ALTER TABLE `pagos`
  ADD CONSTRAINT `pagos_ibfk_1` FOREIGN KEY (`id_membresia`) REFERENCES `membresias` (`id_membresia`);

--
-- Filtros para la tabla `rutinas`
--
ALTER TABLE `rutinas`
  ADD CONSTRAINT `fk_id_membresia` FOREIGN KEY (`id_membresia`) REFERENCES `membresias` (`id_membresia`);

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`root`@`localhost` EVENT `actualizar_estado_membresias` ON SCHEDULE EVERY 1 MINUTE STARTS '2024-12-06 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    UPDATE membresias
    SET estado_membrecia = 'Vencida'
    WHERE estado_membrecia = 'inactivo';
END$$

CREATE DEFINER=`root`@`localhost` EVENT `reportes_asistencia` ON SCHEDULE EVERY 1 SECOND STARTS '2024-12-06 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    UPDATE asistencia
    SET asistio = 'Si'
    WHERE no_asisitio = 'No asistio';
END$$

CREATE DEFINER=`root`@`localhost` EVENT `actualizar_estado_cuenta` ON SCHEDULE EVERY 1 SECOND STARTS '2024-12-07 12:50:44' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    UPDATE membresias
    SET estado_membresia = 'Inactivo'
    WHERE fecha_fin < CURDATE() AND estado_membresia != 'Inactivo';
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
