create or replace function cerrar_tramite(
	p_id_tramite int,
	p_estado_cierre char(15),
	p_respuesta text
)
returns boolean as $$
declare
	v_estado_actual char(15);
begin
	if p_estado_cierre not in('solucionado','rechazado') then
		insert into error (
			operacion, id_tramite, estado_cierre_tramite, f_error, motivo
		) values (
			'cierre tramite', p_id_tramite, p_estado_cierre, now(), 'estado de cierre no valido'
		);
		return false;
	end if;

	select estado into v_estado_actual
	from  tramite
	where id_tramite = p_id_tramite;

	if v_estado_actual is null then
		insert into error (
			operacion, id_tramite, estado_cierre_tramite, f_error, motivo
		) values (
			'cierre tramite', p_id_tramite, p_estado_cierre, now(), 'id de tramite no valido'
		);
		return false;
	end if;

	if v_estado_actual <> 'iniciado' then
		insert into error (
			operacion, id_tramite, estado_cierre_tramite, f_error, motivo
		) values (
			'cierre tramite', p_id_tramite, p_estado_cierre, now(), 'el tramite se encuentra cerrado'
		);
		return false;
	end if;

	update tramite
	set f_fin_gestion = now(),
		estado = p_estado_cierre,
		respuesta = p_respuesta
	where id_tramite = p_id_tramite;

	return true;

end;
$$ language plpgsql;		
