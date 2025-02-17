create or replace function ingreso_llamado(p_id_cliente int)
returns int as $$
declare
    v_id_cola_atencion int;
    v_existe_cliente boolean;
begin
    select exists(select 1 from cliente where id_cliente = p_id_cliente) into v_existe_cliente;
    
    if not v_existe_cliente THEN
        insert into error (
            id_cliente, operacion, f_error, motivo
        ) values ( 
	         p_id_cliente, 'nuevo llamado', now(), 'id de cliente no válido'
        );
        return -1;
    end if;

    insert into cola_atencion (
        id_cliente, f_inicio_llamado, estado
    ) values (
        p_id_cliente, now(), 'en espera'
    ) RETURNING id_cola_atencion into v_id_cola_atencion;

    return v_id_cola_atencion;
end;
$$ language plpgsql;
