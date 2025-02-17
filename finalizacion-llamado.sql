create or replace function finalizacion_llamado(p_id_cola_atencion int )
returns boolean as $$
declare
 	valor cola_atencion%ROWTYPE;
begin
	select * into valor 
    from cola_atencion 
 	where id_cola_atencion = p_id_cola_atencion;
	if not found then
        insert into error(operacion, id_cola_atencion, id_cliente, motivo) 
        values ('fin llamado', p_id_cola_atencion, valor.id_cliente, 'id de cola de atención no válido.');
        return false;
    end if;

	if valor.estado not in ('en linea', 'finalizado') then
          insert into error(operacion, id_cola_atencion, id_cliente, motivo) 
          values ('fin llamado', p_id_cola_atencion, valor.id_cliente, 'el llamado no está en línea.');
      	  return false;
     else
     	if valor.estado = 'en linea' then
     	
     		update cola_atencion
     	    set estado = 'finalizado',
     	    f_fin_atencion = now() + interval '10 second' * (random() * 600)
     	    where id_cola_atencion = p_id_cola_atencion;

     	    update operadore
     	    set disponible = true
     	    where id_operadore = valor.id_operadore;
  		end if;
  		return true;
  	end if;	
end;
$$ language plpgsql;
