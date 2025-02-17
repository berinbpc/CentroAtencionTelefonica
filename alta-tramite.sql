create or replace function alta_tramite(
    p_id_cola_atencion int,
    p_tipo_tramite char(10),
    p_descripcion text
)
returns int as $$
declare
    v_id_cliente int;
    v_id_tramite int;
    v_estado_cola char(15);
begin
    if p_tipo_tramite not in ('consulta', 'reclamo') then
        insert into error (
            operacion, id_cola_atencion, tipo_tramite, f_error, motivo
        ) values (
            'alta tramite', p_id_cola_atencion, p_tipo_tramite, now(), 'tipo de trámite no válido'
        );
        return -1;
    end if;

    select id_cliente, estado into v_id_cliente, v_estado_cola
    from cola_atencion
    where id_cola_atencion = p_id_cola_atencion;

    if v_id_cliente is null or v_estado_cola = 'en espera' then
        insert into error (
            operacion, id_cola_atencion, tipo_tramite, f_error, motivo
        ) values (
            'alta tramite', p_id_cola_atencion, p_tipo_tramite, now(), 'id de cola de atención no válido'
        );
        return -1;
    end if;

    insert into tramite (
        id_cliente, id_cola_atencion, tipo_tramite, f_inicio_gestion, descripcion, estado
    ) values (
        v_id_cliente, p_id_cola_atencion, p_tipo_tramite, now(), p_descripcion, 'iniciado'
    ) returning id_tramite into v_id_tramite;

    return v_id_tramite;

end;
$$ language plpgsql;
