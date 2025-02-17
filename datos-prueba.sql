insert into datos_de_prueba(id_orden,operacion,id_cliente) values(1,'nuevo llamado',21);
insert into datos_de_prueba(id_orden,operacion,id_cliente) values(2,'nuevo llamado',4);
insert into datos_de_prueba(id_orden,operacion) values(3,'atencion llamado');
insert into datos_de_prueba(id_orden,operacion) values(4,'atencion llamado');
insert into datos_de_prueba(id_orden,operacion,id_cliente) values(5,'nuevo llamado',8);
insert into datos_de_prueba(id_orden,operacion,id_cliente) values(6,'nuevo llamado',12);
insert into datos_de_prueba(id_orden,operacion,id_cliente) values(7,'nuevo llamado',16);
insert into datos_de_prueba(id_orden,operacion,id_cola_atencion) values(8,'baja llamado',2);
insert into datos_de_prueba(id_orden,operacion,id_cola_atencion) values(9,'baja llamado',2);
insert into datos_de_prueba(id_orden,operacion,id_cliente) values(10,'nuevo llamado',20);
insert into datos_de_prueba(id_orden,operacion,id_cola_atencion,tipo_tramite,descripcion_tramite) values(11,'alta tramite',1,'consulta','¿Es posible suspender temporalmente el servicio por 2 meses?(vacaciones)');
insert into datos_de_prueba(id_orden,operacion,id_cola_atencion,tipo_tramite,descripcion_tramite) values(12,'alta tramite',1,'reclamo','El monto de la ultima factura fue debitado dos veces en la tarjeta de credito');
insert into datos_de_prueba(id_orden,operacion) values(13,'atencion llamado');
insert into datos_de_prueba(id_orden,operacion) values(14,'atencion llamado');
insert into datos_de_prueba(id_orden,operacion) values(15,'atencion llamado');
insert into datos_de_prueba(id_orden,operacion,id_cola_atencion) values(16,'fin llamado',1);
insert into datos_de_prueba(id_orden,operacion) values(17,'atencion llamado');
insert into datos_de_prueba(id_orden,operacion,id_cola_atencion) values(18,'baja llamado',3);
insert into datos_de_prueba(id_orden,operacion,id_tramite,estado_cierre_tramite,respuesta_tramite) values(19,'cierre tramite',2,'rechazado','Los dos cobros corresponden a facturas de meses diferentes');
insert into datos_de_prueba(id_orden,operacion,id_tramite,estado_cierre_tramite,respuesta_tramite) values(20,'cierre tramite',1,'solucionado','Es posible suspender el servicio, avisando con 20 dias de anticipacion');
insert into datos_de_prueba(id_orden,operacion,id_cola_atencion) values(21,'fin llamado',4);
insert into datos_de_prueba(id_orden,operacion,id_cola_atencion) values(22,'fin llamado',5);
--A partir de aqui insertamos un nuevo tramite que creamos de prueba
insert into datos_de_prueba(id_orden,operacion,id_cola_atencion,tipo_tramite,descripcion_tramite) values(23,'alta tramite',2,'reclamo','El servicio funciona mal');
insert into datos_de_prueba(id_orden,operacion,id_tramite,estado_cierre_tramite,respuesta_tramite) values(24,'cierre tramite',3,'solucionado','Se realizará un reintegro del 40% en la proxima factura');

--Tramite para que se inserte en tabla error
insert into datos_de_prueba(id_orden,operacion,id_cola_atencion,tipo_tramite,descripcion_tramite) values(25,'alta tramite',3,'queja','Pesimo servicio otorgado');
