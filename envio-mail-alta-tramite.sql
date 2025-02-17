create or replace function envio_mail_alta()
returns trigger as $$
declare
	v_id_cliente int;
	v_info_cliente record;
begin
	select id_cliente into v_id_cliente from tramite where id_tramite = new.id_tramite;
	select * into v_info_cliente from cliente where id_cliente = v_id_cliente;

	insert into envio_email(
		f_generacion, email_cliente, asunto, cuerpo, estado
	) values(
		now(), v_info_cliente.email, 'Skynet - nuevo trámite : ' || new.id_tramite,
		'Datos del cliente: ' || E'\n' ||
        'nombre: ' || v_info_cliente.nombre || ' ' || v_info_cliente.apellido || E'\n' ||
        'DNI: ' || v_info_cliente.dni || E'\n' ||
        'fecha_nacimiento: ' || v_info_cliente.fecha_nacimiento || E'\n' ||
	    'telefono: ' || v_info_cliente.telefono || E'\n' ||
        'Datos del tramite: ' || E'\n' ||
        'tipo de trámite: ' || new.tipo_tramite || E'\n' ||
        'fecha y hora de inicio: ' || new.f_inicio_gestion || E'\n' ||
        'descripción: ' || new.descripcion,
		'pendiente'
	);
	return new;
end;
$$ language plpgsql;

create or replace trigger envio_mail_alta
after insert on tramite
for each row
execute procedure envio_mail_alta();
