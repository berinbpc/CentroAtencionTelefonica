create or replace function asignar_operadore_a_llamado()
returns boolean as $$
declare
    v_id_cola_atencion int;
    v_id_operadore int;

begin
    select id_cola_atencion into v_id_cola_atencion
    from cola_atencion
    where estado = 'en espera'
    order by f_inicio_llamado
    limit 1;
    if v_id_cola_atencion is null then
        insert into error (
            operacion, f_error, motivo
        ) 
        values (
            'atencion llamado', now(), 'no existe ningún llamado en espera'
        );
        return false;
    end if;

    select id_operadore into v_id_operadore
    from operadore
    where disponible = true
    limit 1;

    if v_id_operadore is null then
        insert into error (
            operacion, id_cola_atencion, f_error, motivo
        ) 
        values (
            'atencion llamado', v_id_cola_atencion, now(), 'no existe ningune operadore disponible'
        );
        return false;
    end if;

    update operadore
    set disponible = false
    where id_operadore = v_id_operadore;

    update cola_atencion
    set id_operadore = v_id_operadore,
        f_inicio_atencion = now(),
        estado = 'en linea'
    where id_cola_atencion = v_id_cola_atencion;

    return true;

end;
$$ language plpgsql;
