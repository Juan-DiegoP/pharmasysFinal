-- ============================================================
--  PHARMASYS - Medicamentos Confiables S.A. 
-- ============================================================
CREATE DATABASE pharmasys;
USE pharmasys;


CREATE TABLE proveedores (
    id SERIAL PRIMARY KEY, codigo VARCHAR(20) UNIQUE NOT NULL, razon_social VARCHAR(150) NOT NULL,
    pais VARCHAR(80), contacto VARCHAR(100), correo VARCHAR(120), certificaciones VARCHAR(80), estado VARCHAR(15) DEFAULT 'ACTIVO'
);
CREATE TABLE principios_activos (
    id SERIAL PRIMARY KEY, codigo VARCHAR(20) UNIQUE NOT NULL, nombre_cientifico VARCHAR(200) NOT NULL,
    formula VARCHAR(80), clasificacion_terapeutica VARCHAR(100), origen VARCHAR(15) CHECK (origen IN ('SINTETICO','NATURAL','SEMISINTETICO')),
    precauciones TEXT, id_proveedor INT REFERENCES proveedores(id)
);
CREATE TABLE medicamentos (
    id SERIAL PRIMARY KEY, codigo VARCHAR(20) UNIQUE NOT NULL, nombre_comercial VARCHAR(150) NOT NULL,
    forma VARCHAR(20) CHECK (forma IN ('TABLETA','CAPSULA','JARABE','INYECTABLE','CREMA')),
    presentacion VARCHAR(100), indicaciones TEXT, contraindicaciones TEXT, posologia TEXT,
    registro_sanitario VARCHAR(60), precio NUMERIC(10,2)
);
CREATE TABLE medicamento_principio_activo (
    id SERIAL PRIMARY KEY, id_medicamento INT REFERENCES medicamentos(id),
    id_principio INT REFERENCES principios_activos(id), concentracion VARCHAR(50)
);
CREATE TABLE materias_primas (
    id SERIAL PRIMARY KEY, codigo VARCHAR(20) UNIQUE NOT NULL, nombre VARCHAR(150) NOT NULL,
    tipo VARCHAR(60), condiciones_almacenamiento VARCHAR(100), periodo_cuarentena_dias INT,
    fecha_caducidad DATE, categoria_riesgo VARCHAR(10) CHECK (categoria_riesgo IN ('BAJO','MEDIO','ALTO')),
    id_proveedor INT REFERENCES proveedores(id)
);
CREATE TABLE equipos (
    id SERIAL PRIMARY KEY, numero_serie VARCHAR(60) UNIQUE NOT NULL, tipo VARCHAR(80),
    marca VARCHAR(60), modelo VARCHAR(60), ubicacion VARCHAR(100),
    fecha_ult_calibracion DATE, proxima_calibracion DATE,
    cualificacion VARCHAR(15) CHECK (cualificacion IN ('IQ','OQ','PQ','IQ/OQ','IQ/OQ/PQ')),
    estado VARCHAR(15) DEFAULT 'OPERATIVO'
);
CREATE TABLE protocolos_fabricacion (
    id SERIAL PRIMARY KEY, codigo VARCHAR(30) UNIQUE NOT NULL, id_medicamento INT REFERENCES medicamentos(id),
    version VARCHAR(10), parametros_criticos TEXT, condiciones_ambientales VARCHAR(150),
    estado_validacion VARCHAR(15) DEFAULT 'VALIDADO', fecha_validacion DATE
);
CREATE TABLE lotes_produccion (
    id SERIAL PRIMARY KEY, numero_lote VARCHAR(30) UNIQUE NOT NULL, id_medicamento INT REFERENCES medicamentos(id),
    id_protocolo INT REFERENCES protocolos_fabricacion(id), fecha_fabricacion DATE,
    cantidad_producida INT, personal_responsable VARCHAR(150), fecha_caducidad DATE,
    estado VARCHAR(20) DEFAULT 'EN_CUARENTENA' CHECK (estado IN ('EN_CUARENTENA','APROBADO','RECHAZADO','DISTRIBUIDO'))
);
CREATE TABLE lote_materia_prima (
    id SERIAL PRIMARY KEY, id_lote INT REFERENCES lotes_produccion(id),
    id_materia INT REFERENCES materias_primas(id), numero_lote_mp VARCHAR(40), cantidad_usada NUMERIC(12,3), unidad VARCHAR(15)
);
CREATE TABLE control_calidad (
    id SERIAL PRIMARY KEY, codigo VARCHAR(30) UNIQUE NOT NULL, id_lote INT REFERENCES lotes_produccion(id),
    fecha DATE, tipo VARCHAR(20) CHECK (tipo IN ('FISICA','QUIMICA','MICROBIOLOGICA')),
    especificaciones TEXT, resultados TEXT, analista VARCHAR(120), id_equipo INT REFERENCES equipos(id),
    conforme BOOLEAN, certificado VARCHAR(50)
);
CREATE TABLE estudios_estabilidad (
    id SERIAL PRIMARY KEY, codigo VARCHAR(30) UNIQUE NOT NULL, id_medicamento INT REFERENCES medicamentos(id),
    lotes TEXT, temp_c NUMERIC(4,1), hr_pct NUMERIC(4,1), periodos TEXT, conclusion TEXT, fecha_inicio DATE
);
CREATE TABLE clientes_mayoristas (
    id SERIAL PRIMARY KEY, codigo VARCHAR(20) UNIQUE NOT NULL, razon_social VARCHAR(150) NOT NULL,
    licencia_sanitaria VARCHAR(60), direccion TEXT, contacto VARCHAR(100), correo VARCHAR(120),
    condiciones_comerciales TEXT, calificacion VARCHAR(15) DEFAULT 'APROBADO'
);
CREATE TABLE trazabilidad (
    id SERIAL PRIMARY KEY, id_lote INT REFERENCES lotes_produccion(id), fecha TIMESTAMP DEFAULT NOW(),
    tipo VARCHAR(20) CHECK (tipo IN ('FABRICACION','ANALISIS','LIBERACION','ALMACENAMIENTO','DISTRIBUCION','DESTRUCCION')),
    ubicacion VARCHAR(150), responsable VARCHAR(120), id_cliente INT REFERENCES clientes_mayoristas(id),
    cantidad INT, documentacion TEXT
);

-- ======================== INSERTS ========================

INSERT INTO proveedores (codigo,razon_social,pais,contacto,correo,certificaciones) VALUES
('PRV-001','Química Fina del Norte S.A.','México','Ing. Roberto Salinas','ventas@qfnorte.mx','ISO 9001, GMP'),
('PRV-002','BioSynth Europe GmbH','Alemania','Dr. Klaus Müller','sales@biosynth.de','ISO 9001, ISO 14001'),
('PRV-003','Natural Extracts Andinos','Colombia','Dra. María López','info@naturalandinos.co','BPL, GMP'),
('PRV-004','Asian Pharma Ingredients','India','Mr. Rajesh Patel','export@asiapharma.in','WHO-GMP, ISO 9001');

INSERT INTO principios_activos (codigo,nombre_cientifico,formula,clasificacion_terapeutica,origen,precauciones,id_proveedor) VALUES
('PA-001','Paracetamol','C8H9NO2','Analgésico/Antipirético','SINTETICO','Evitar oxidantes; lugar seco',1),
('PA-002','Ibuprofeno','C13H18O2','AINE','SINTETICO','Sensible a humedad; EPP completo',2),
('PA-003','Amoxicilina','C16H19N3O5S','Antibiótico betalactámico','SEMISINTETICO','Alto potencial alergénico; mascarilla FFP2',4),
('PA-004','Omeprazol','C17H19N3O3S','Inhibidor bomba de protones','SINTETICO','Inestable a pH ácido; proteger de humedad',1),
('PA-005','Loratadina','C22H23ClN2O2','Antihistamínico','SINTETICO','Evitar exposición prolongada a luz',2);

INSERT INTO medicamentos (codigo,nombre_comercial,forma,presentacion,indicaciones,contraindicaciones,posologia,registro_sanitario,precio) VALUES
('MED-001','Dolorfin 500','TABLETA','Caja x 20 tabs 500mg','Dolor leve-moderado, fiebre','Insuficiencia hepática, hipersensibilidad','1 tab c/6-8h; máx 4g/día','RS-MX-2019-0445',45.00),
('MED-002','Ibuflam 400','TABLETA','Caja x 10 tabs 400mg','Dolor, inflamación, fiebre','Úlcera péptica, insuficiencia renal','1 tab c/8h con alimento','RS-MX-2018-0210',58.50),
('MED-003','Amoxín 250 Jarabe','JARABE','Frasco 100ml/250mg por 5ml','Infecciones bacterianas','Alergia a penicilinas','Niños 25-50mg/kg/día c/8h','RS-MX-2020-0089',120.00),
('MED-004','Omepral 20','CAPSULA','Caja x 14 cáps 20mg','Úlcera gástrica, ERGE','Hipersensibilidad, uso con atazanavir','1 cápsula/día en ayunas','RS-MX-2018-1102',145.00),
('MED-005','Aleridin 10','TABLETA','Caja x 30 tabs 10mg','Rinitis alérgica, urticaria','Hipersensibilidad a loratadina','1 tableta/día','RS-MX-2017-0567',95.00);

INSERT INTO medicamento_principio_activo (id_medicamento,id_principio,concentracion) VALUES
(1,1,'500 mg'),(2,2,'400 mg'),(3,3,'250 mg/5 ml'),(4,4,'20 mg'),(5,5,'10 mg');

INSERT INTO materias_primas (codigo,nombre,tipo,condiciones_almacenamiento,periodo_cuarentena_dias,fecha_caducidad,categoria_riesgo,id_proveedor) VALUES
('MP-001','Paracetamol API','Principio Activo','15-25°C, HR<60%, seco',14,'2026-12-31','BAJO',1),
('MP-002','Ibuprofeno API','Principio Activo','15-25°C, HR<50%',14,'2026-06-30','BAJO',2),
('MP-003','Amoxicilina trihidrato API','Principio Activo','2-8°C, HR<60%',21,'2025-12-31','MEDIO',4),
('MP-004','Celulosa microcristalina PH-102','Excipiente','15-25°C, seco',7,'2027-06-30','BAJO',1),
('MP-005','Estearato de magnesio','Lubricante','15-25°C, HR<50%',7,'2027-12-31','BAJO',1),
('MP-006','Sacarosa grado farmacéutico','Excipiente','15-25°C, seco',5,'2027-03-31','BAJO',3);

INSERT INTO equipos (numero_serie,tipo,marca,modelo,ubicacion,fecha_ult_calibracion,proxima_calibracion,cualificacion,estado) VALUES
('EQ-001','Tableteadora rotativa','Fette','FE35','Producción - Sala 1','2024-11-01','2025-11-01','IQ/OQ/PQ','OPERATIVO'),
('EQ-002','Mezcladora alta cizalla','Collette','Gral 25','Producción - Sala 2','2024-10-15','2025-10-15','IQ/OQ/PQ','OPERATIVO'),
('EQ-003','HPLC Análisis API','Agilent','1260 Infinity','Lab. Calidad - Área A','2025-01-10','2025-07-10','IQ/OQ','OPERATIVO'),
('EQ-004','Balanza analítica','Mettler Toledo','XS205','Lab. Calidad - Área B','2025-02-01','2025-08-01','IQ/OQ','OPERATIVO'),
('EQ-005','Llenadora de jarabe','Bosch','MLF-5000','Producción - Sala 4','2024-09-05','2025-09-05','IQ/OQ/PQ','MANTENIMIENTO');

INSERT INTO protocolos_fabricacion (codigo,id_medicamento,version,parametros_criticos,condiciones_ambientales,fecha_validacion) VALUES
('PF-MED001-V3',1,'v3.0','Temp secado 60°C±5°C; presión tableteado 8-12kN; dureza 6-9kP','20-25°C, HR 45-55%, Clase D ISO-8','2022-06-15'),
('PF-MED003-V2',3,'v2.0','pH 5.0-6.0; viscosidad 100-200cP; temp disolución 25-30°C','18-22°C, HR<60%, Área clase C ISO-7','2021-11-20'),
('PF-MED004-V1',4,'v1.0','Resist entérica >2h pH1.2; disol >80% a 45min pH6.8','18-22°C, HR<40%, Clase D ISO-8','2023-03-10');

INSERT INTO lotes_produccion (numero_lote,id_medicamento,id_protocolo,fecha_fabricacion,cantidad_producida,personal_responsable,fecha_caducidad,estado) VALUES
('LOT-2025-001',1,1,'2025-01-10',50000,'Q.F. Ana Martínez / Tec. Juan Flores','2027-01-10','APROBADO'),
('LOT-2025-002',3,2,'2025-02-05',8000,'Q.F. Carlos Ruiz / Tec. Laura Soto','2026-08-05','APROBADO'),
('LOT-2025-003',4,3,'2025-02-18',20000,'Q.F. Ana Martínez / Tec. Juan Flores','2027-02-18','APROBADO'),
('LOT-2025-004',2,NULL,'2025-03-01',30000,'Q.F. Carlos Ruiz / Tec. Pedro Ramírez','2027-03-01','EN_CUARENTENA');

INSERT INTO lote_materia_prima (id_lote,id_materia,numero_lote_mp,cantidad_usada,unidad) VALUES
(1,1,'MP-PA001-2024-10',25000,'g'),(1,4,'MP-EXC004-2024-09',12500,'g'),(1,5,'MP-LUB005-2024-11',375,'g'),
(2,3,'MP-PA003-2024-08',4000,'g'),(2,6,'MP-EXC006-2024-12',60000,'g'),
(3,1,'MP-PA001-2024-11',400,'g'),(4,2,'MP-PA002-2024-12',12000,'g'),(4,4,'MP-EXC004-2024-11',9000,'g');

INSERT INTO control_calidad (codigo,id_lote,fecha,tipo,especificaciones,resultados,analista,id_equipo,conforme,certificado) VALUES
('CC-2025-0101',1,'2025-01-14','FISICA','Dureza 6-9kP; friabilidad ≤1%; desint ≤15min','Dureza 7.5kP ✔; friab 0.3% ✔; desint 8min ✔','Q.F. Sofía Herrera',4,TRUE,'CERT-2025-0101'),
('CC-2025-0102',1,'2025-01-15','QUIMICA','Contenido API 95-105%; impurezas ≤0.5%','Contenido 101.2% ✔; impurezas 0.18% ✔','Q.F. Sofía Herrera',3,TRUE,'CERT-2025-0102'),
('CC-2025-0103',1,'2025-01-16','MICROBIOLOGICA','Recuento ≤1000 UFC/g; ausencia patógenos','Recuento 45 UFC/g ✔; E.coli ausente ✔','Q.F. Marco Vidal',NULL,TRUE,'CERT-2025-0103'),
('CC-2025-0201',2,'2025-02-10','QUIMICA','pH 5.0-6.0; contenido API 95-105%','pH 5.4 ✔; contenido 98.6% ✔','Q.F. Marco Vidal',3,TRUE,'CERT-2025-0201'),
('CC-2025-0301',3,'2025-02-22','FISICA','Peso ±5%; resist entérica >2h pH1.2','Peso 281mg ✔; resistencia 2.5h ✔','Q.F. Sofía Herrera',4,TRUE,'CERT-2025-0301'),
('CC-2025-0401',4,'2025-03-05','FISICA','Dureza 5-8kP; friabilidad ≤1%','Dureza 6.8kP ✔; friab 0.4% ✔ (en curso)','Q.F. Marco Vidal',4,TRUE,NULL);

INSERT INTO estudios_estabilidad (codigo,id_medicamento,lotes,temp_c,hr_pct,periodos,conclusion,fecha_inicio) VALUES
('EST-001',1,'LOT-2025-001',40.0,75.0,'0,1,2,3,6 meses','Vida útil estimada 24 meses a 25°C/60%HR (ICH Q1A)','2025-02-01'),
('EST-002',3,'LOT-2025-002',5.0,NULL,'0,3,6,9,12,18 meses','Vida útil estimada 18 meses a 2-8°C (en curso)','2025-03-01');

INSERT INTO clientes_mayoristas (codigo,razon_social,licencia_sanitaria,direccion,contacto,correo,condiciones_comerciales) VALUES
('CLI-001','Distribuidora Farma Nacional S.A.','LIC-2021-0089','Blvd. Farmacéutico 1200, CDMX','Lic. Gabriela Reyes','pedidos@dfnacional.mx','Crédito 30 días; 8% descuento ≥5000 uds'),
('CLI-002','Mayoreo Médico del Centro','LIC-2019-0234','Av. Salud 450, Guadalajara','C.P. Armando Cruz','compras@maymedcentro.mx','Contado o crédito 15 días'),
('CLI-003','Distribuidor Hospitalario IMSS','LIC-HOSP-2018-0012','Unidad Médica Central, CDMX','Dr. Ernesto Fuentes','abastecimiento@imss.gob.mx','Licitación anual por partida');

INSERT INTO trazabilidad (id_lote,fecha,tipo,ubicacion,responsable,id_cliente,cantidad,documentacion) VALUES
(1,'2025-01-10 08:00','FABRICACION','Producción - Sala 1','Q.F. Ana Martínez',NULL,50000,'OP-2025-0101'),
(1,'2025-01-15 09:00','ANALISIS','Lab. Control Calidad','Q.F. Sofía Herrera',NULL,200,'CC-2025-0101/0102/0103'),
(1,'2025-01-17 14:00','LIBERACION','Almacén Producto Terminado','Dir. Técnico Dr. R. Gómez',NULL,49800,'CERT-LOT-2025-001'),
(1,'2025-02-01 08:30','DISTRIBUCION','Despacho → CLI-001','Jefe Logística M. Ortiz',1,20000,'REM-2025-0020, F-2025-0201'),
(1,'2025-02-15 09:00','DISTRIBUCION','Despacho → CLI-002','Jefe Logística M. Ortiz',2,15000,'REM-2025-0035, F-2025-0215'),
(2,'2025-02-05 07:30','FABRICACION','Producción - Sala 4','Q.F. Carlos Ruiz',NULL,8000,'OP-2025-0103'),
(2,'2025-02-11 15:00','LIBERACION','Almacén Producto Terminado','Dir. Técnico Dr. R. Gómez',NULL,7990,'CERT-LOT-2025-002'),*
(2,'2025-02-20 10:00','DISTRIBUCION','Despacho → CLI-003','Jefe Logística M. Ortiz',3,3000,'REM-2025-0045, F-2025-0220'),
(3,'2025-02-18 07:00','FABRICACION','Producción - Sala 5','Q.F. Ana Martínez',NULL,20000,'OP-2025-0104'),
(3,'2025-02-23 17:00','LIBERACION','Almacén Producto Terminado','Dir. Técnico Dr. R. Gómez',NULL,19980,'CERT-LOT-2025-003'),
(4,'2025-03-01 08:00','FABRICACION','Producción - Sala 1','Q.F. Carlos Ruiz',NULL,30000,'OP-2025-0105'),
(4,'2025-03-05 09:00','ANALISIS','Lab. Control Calidad','Q.F. Marco Vidal',NULL,200,'CC-2025-0401 (en curso)');

-- FIN DEL SCRIPT - PHARMASYS

-- SP MEDICAMENTOS


DELIMITER // 

-- OBTENER 
CREATE PROCEDURE sp_ObtenerMedicamento(IN p_codigo VARCHAR(20))
BEGIN 
SELECT codigo, nombre_comercial, forma, presentacion, indicaciones, precio
FROM medicamentos WHERE codigo = p_codigo;
END //

-- INSERTAR
CREATE PROCEDURE sp_InsertarMedicamento(
IN p_codigo VARCHAR(20),
IN p_nombre VARCHAR(150),
IN p_forma VARCHAR(20),
IN p_presentacion VARCHAR(100),
IN p_indicaciones TEXT,
IN p_precio DECIMAL(10,2)
)
BEGIN 
INSERT INTO medicamentos(
codigo,nombre_comercial,forma,presentacion,
indicaciones,precio
)
VALUES(
p_codigo,p_nombre,p_forma,p_presentacion,
p_indicaciones,p_precio
);
END //

-- ACTUALIZAR
CREATE PROCEDURE sp_ActualizarMedicamento(
IN p_codigo VARCHAR(20),
IN p_nombre VARCHAR(150),
IN p_forma VARCHAR(20),
IN p_presentacion VARCHAR(100),
IN p_indicaciones TEXT,
IN p_precio DECIMAL(10,2)
)
BEGIN 

UPDATE medicamentos
SET
nombre_comercial = p_nombre,
forma = p_forma,
presentacion = p_presentacion,
indicaciones = p_indicaciones,
precio = p_precio
WHERE codigo = p_codigo;
END //

-- ELIMINAR
CREATE PROCEDURE sp_EliminarMedicamento(IN p_codigo VARCHAR(20))
BEGIN 
DELETE FROM medicamentos WHERE codigo = p_codigo;
END //

-- MOSTRAR TODOS
CREATE PROCEDURE sp_ListarMedicamentos()
BEGIN
    SELECT
        codigo,
        nombre_comercial,
        forma,
        presentacion,
        indicaciones,
        precio
    FROM medicamentos;
END //

DELIMITER ;

-- SP PROVEEDORES

-- OBTENER
DELIMITER //

CREATE PROCEDURE sp_ObtenerProveedor(IN p_codigo VARCHAR(20)) 
BEGIN
SELECT codigo, razon_social, pais, contacto, correo, estado
FROM proveedores
WHERE codigo = p_codigo;

END //

-- INSERTAR PROVEEDORES

CREATE PROCEDURE sp_InsertarProveedor(
IN p_codigo VARCHAR(20),
IN p_razon_social VARCHAR(150),
IN p_pais VARCHAR(80),
IN p_contacto VARCHAR(100),
IN p_correo VARCHAR(120),
IN p_estado VARCHAR(15)
)
BEGIN

INSERT INTO proveedores(
codigo,
razon_social,
pais,
contacto,
correo,
estado
)

VALUES(
p_codigo,
p_razon_social,
p_pais,
p_contacto,
p_correo,
p_estado
);

END //

-- ACTUALIZAR

CREATE PROCEDURE sp_ActualizarProveedor(
IN p_codigo VARCHAR(20),
IN p_razon_social VARCHAR(150),
IN p_pais VARCHAR(80),
IN p_contacto VARCHAR(100),
IN p_correo VARCHAR(120),
IN p_estado VARCHAR(15)
)
BEGIN

UPDATE proveedores
SET
razon_social = p_razon_social,
pais = p_pais,
contacto = p_contacto,
correo = p_correo,
estado = p_estado

WHERE codigo = p_codigo;

END //

-- ELIMINAR

CREATE PROCEDURE sp_EliminarProveedor(IN p_codigo VARCHAR(20))
BEGIN

DELETE FROM proveedores
WHERE codigo = p_codigo;

END //

-- MOSTRAR TODOS 
CREATE PROCEDURE sp_ListarProveedores()
BEGIN
    SELECT
        codigo,
        razon_social,
        pais,
        contacto,
        correo,
        estado
    FROM proveedores;
END //

DELIMITER ;

-- SP PRINCIPIOS ACTIVOS

DELIMITER //

-- OBTENER
CREATE PROCEDURE sp_ObtenerPrincipio(
IN p_codigo VARCHAR(20)
)
BEGIN
SELECT codigo, nombre_cientifico, formula, origen, precauciones, id_proveedor
FROM principios_activos
WHERE codigo = p_codigo;
END //

-- INSERTAR
CREATE PROCEDURE sp_InsertarPrincipio(
IN p_codigo VARCHAR(20),
IN p_nombre_cientifico VARCHAR(200),
IN p_formula VARCHAR(80),
IN p_origen VARCHAR(15),
IN p_precauciones TEXT,
IN p_id_proveedor INT
)
BEGIN
INSERT INTO principios_activos(
codigo,
nombre_cientifico,
formula,
origen,
precauciones,
id_proveedor
)
VALUES(
p_codigo,
p_nombre_cientifico,
p_formula,
p_origen,
p_precauciones,
p_id_proveedor
);
END //

-- ACTUALIZAR
CREATE PROCEDURE sp_ActualizarPrincipio(
IN p_codigo VARCHAR(20),
IN p_nombre_cientifico VARCHAR(200),
IN p_formula VARCHAR(80),
IN p_origen VARCHAR(15),
IN p_precauciones TEXT,
IN p_id_proveedor INT
)
BEGIN
UPDATE principios_activos
SET
nombre_cientifico = p_nombre_cientifico,
formula = p_formula,
origen = p_origen,
precauciones = p_precauciones,
id_proveedor = p_id_proveedor
WHERE codigo = p_codigo;
END //

-- ELIMINAR
CREATE PROCEDURE sp_EliminarPrincipio(
IN p_codigo VARCHAR(20)
)
BEGIN
DELETE FROM principios_activos
WHERE codigo = p_codigo;
END //

-- MOSTRAR TODOS
CREATE PROCEDURE sp_ListarPrincipios()
BEGIN
    SELECT codigo, nombre_cientifico, formula, origen, precauciones, id_proveedor
    FROM principios_activos;
END //


DELIMITER ;

-- CLIENTES

DELIMITER //

-- OBTENER

CREATE PROCEDURE sp_ObtenerCliente(
IN p_codigo VARCHAR(20)
)
BEGIN
SELECT 
codigo,
razon_social,
contacto,
correo,
calificacion
FROM clientes_mayoristas
WHERE codigo = p_codigo;
END //

-- INSERTAR 
CREATE PROCEDURE sp_InsertarCliente(
IN p_codigo VARCHAR(20),
IN p_razon_social VARCHAR(150),
IN p_contacto VARCHAR(100),
IN p_correo VARCHAR(120),
IN p_calificacion VARCHAR(15)
)
BEGIN
INSERT INTO clientes_mayoristas(
codigo,
razon_social,
contacto,
correo,
calificacion
)
VALUES(
p_codigo,
p_razon_social,
p_contacto,
p_correo,
p_calificacion
);
END //

-- ACTUALIZAR
CREATE PROCEDURE sp_ActualizarCliente(
IN p_codigo VARCHAR(20),
IN p_razon_social VARCHAR(150),
IN p_contacto VARCHAR(100),
IN p_correo VARCHAR(120),
IN p_calificacion VARCHAR(15)
)
BEGIN
UPDATE clientes_mayoristas
SET
razon_social = p_razon_social,
contacto = p_contacto,
correo = p_correo,
calificacion = p_calificacion
WHERE codigo = p_codigo;
END //

-- ELIMINAR 
CREATE PROCEDURE sp_EliminarCliente(
IN p_codigo VARCHAR(20)
)
BEGIN
DELETE FROM clientes_mayoristas
WHERE codigo = p_codigo;
END //

 -- MOSTRAR TODOS
CREATE PROCEDURE sp_ListarClientes()
BEGIN
    SELECT
        codigo,
        razon_social,
        contacto,
        correo,
        calificacion
    FROM clientes_mayoristas;
END //

DELIMITER ;

