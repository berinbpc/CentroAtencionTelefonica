create or replace function desistir_llamado(id_cola int) 
returns boolean as $$
declare
    valor cola_atencion%ROWTYPE;
begin
    select * into valor 
    from cola_atencion 
    where id_cola_atencion = id_cola;

    if not found then
        insert into error(operacion, id_cola_atencion, motivo) 
        values ('baja llamado', id_cola, 'ID de cola de atención no válido.');
        return false;
    end if;

    if valor.estado not in ('en espera', 'en linea') then
        insert into error(operacion, id_cola_atencion, motivo) 
        values ('baja llamado', id_cola, 'El llamado no está en espera ni en línea.');
        return false;
    else
        if valor.estado = 'en linea' then
            update cola_atencion 
            set estado = 'desistido', f_fin_atencion = now() + interval '10 second' * (random() * 600) 
            where id_cola_atencion = id_cola;
        else
            update cola_atencion 
            set estado = 'desistido' 
            where id_cola_atencion = id_cola;
        end if;
        return true;
    end if;
end;
$$ language plpgsql;

