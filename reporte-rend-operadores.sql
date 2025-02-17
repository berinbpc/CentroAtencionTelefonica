create or replace function actualizar_rendimiento_operador()
returns trigger as $$
declare
	v_duracion_interval interval;
begin
	v_duracion_interval := new.f_fin_atencion - new.f_inicio_atencion;

	if new.estado = 'desistido' then
        if new.id_operadore is null then
            return new;
        end if;

		if not exists (select 1 from rendimiento_operadore where id_operadore = new.id_operadore) then
			insert into rendimiento_operadore(id_operadore, fecha_atencion, duracion_total_atenciones, cantidad_total_atenciones, duracion_promedio_total_atenciones, duracion_atenciones_desistidas, cantidad_atenciones_desistidas, duracion_promedio_atenciones_desistidas)
				values(new.id_operadore, now(), v_duracion_interval, 1, v_duracion_interval, v_duracion_interval, 1, v_duracion_interval);
		else
			update rendimiento_operadore
			set 
				fecha_atencion = now(),
				duracion_total_atenciones = duracion_total_atenciones + v_duracion_interval,
				cantidad_total_atenciones = cantidad_total_atenciones + 1,
				duracion_promedio_total_atenciones = (duracion_total_atenciones / cantidad_total_atenciones),
				duracion_atenciones_desistidas = duracion_atenciones_desistidas + v_duracion_interval,
				cantidad_atenciones_desistidas = cantidad_atenciones_desistidas + 1,
				duracion_promedio_atenciones_desistidas = (duracion_atenciones_desistidas / cantidad_atenciones_desistidas)
			where id_operadore = new.id_operadore;
		end if;
	end if;		
	if new.estado = 'finalizado' then
		if not exists (select 1 from rendimiento_operadore where id_operadore = new.id_operadore) then
			insert into rendimiento_operadore(id_operadore, fecha_atencion, duracion_total_atenciones, cantidad_total_atenciones, duracion_promedio_total_atenciones, duracion_atenciones_finalizadas, cantidad_atenciones_finalizadas, duracion_promedio_atenciones_finalizadas)
				values(new.id_operadore, now(), v_duracion_interval, 1, v_duracion_interval, v_duracion_interval, 1, v_duracion_interval);
		else
			update rendimiento_operadore
			set 	
				fecha_atencion = now(),
				duracion_total_atenciones = duracion_total_atenciones + v_duracion_interval,
				cantidad_total_atenciones = cantidad_total_atenciones + 1,
				duracion_promedio_total_atenciones = (duracion_total_atenciones / cantidad_total_atenciones),
				duracion_atenciones_finalizadas = duracion_atenciones_finalizadas + v_duracion_interval,
				cantidad_atenciones_finalizadas = cantidad_atenciones_finalizadas + 1,
				duracion_promedio_atenciones_finalizadas = (duracion_atenciones_finalizadas / cantidad_atenciones_finalizadas)
			where id_operadore = new.id_operadore;
		end if;
	end if;
	return new;
end;
$$ language plpgsql;

-- creo trigger para que revise cada fila de cola_atencion
create or replace trigger actualizar_rend_operadores_trigger
after update on cola_atencion
for each row
execute procedure actualizar_rendimiento_operador()

