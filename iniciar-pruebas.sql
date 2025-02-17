create or replace function iniciar_pruebas()returns void  as $$
declare
    var datos_de_prueba%ROWTYPE;
begin
    for var in select * from datos_de_prueba order by id_orden loop
        if var.operacion = 'nuevo llamado' then
            perform ingreso_llamado(var.id_cliente);
        end if;

        if var.operacion = 'atencion llamado' then
            perform asignar_operadore_a_llamado();
        end if;

        if var.operacion = 'baja llamado' then
            perform desistir_llamado(var.id_cola_atencion);
        end if;

        if var.operacion = 'alta tramite' then
            perform alta_tramite(var.id_cola_atencion, var.tipo_tramite, var.descripcion_tramite);
        end if;

        if var.operacion = 'fin llamado' then
            perform finalizacion_llamado(var.id_cola_atencion);
        end if;

        if var.operacion = 'cierre tramite' then
            perform cerrar_tramite(var.id_tramite,var.estado_cierre_tramite,var.respuesta_tramite);
        end if;

    end loop;
end
$$ language plpgsql;
