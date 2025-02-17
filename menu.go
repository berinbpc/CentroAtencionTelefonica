package main

import(
	"encoding/json"
	"database/sql"
	"fmt"
	_ "github.com/lib/pq"
	"log"
	"io/ioutil"
	bolt "go.etcd.io/bbolt"
	"strconv"
) 

var db *sql.DB
var err error

var db_bolt *bolt.DB
var err_bolt error

var data []byte
var err_jsondata error

func leerArchivo(direccionArchivo string) string {
	result, err := ioutil.ReadFile(direccionArchivo)
	if err != nil {
		log.Fatal(err)
	}
	return string(result)
}

func conectarPostgres() {
	var err error
	db, err = sql.Open("postgres", "user=postgres host=localhost dbname=postgres sslmode=disable")
	if err != nil{
		log.Fatal(err);
	}
}

func conectarDB() (*sql.DB, error) {
	db, err := sql.Open("postgres", "user=postgres host=localhost dbname=berini_carmona_faccini_flores_db1 sslmode=disable")
	if err != nil {
		return nil, err
	}
	return db, nil
}

func ejecutarConsulta(sqlScript string) error {
	db, err := conectarDB()
	if err != nil {
		return err
	}
	defer db.Close()
	_, err = db.Exec(sqlScript)
	return err
}

func mostrarMenu(){
	cantOpciones := 10;
	opciones := [10]string{"Salir", "Crear base de datos", "Crear tablas", "Agregar PKs y FKs", "Eliminar PKs y FKs", "Cargar datos", "Crear stored procedures y triggers", "Iniciar pruebas", "Cargar datos en BoltDB", "Mostrar Menu nuevamente"};

	fmt.Printf("\n Menú \n");

	for i := 0; i < cantOpciones; i++{
		fmt.Printf("%d " +  opciones[i]+ "\n", i);
	}
}

func escucharOpcion() (int){
	var opcion int;
	
	fmt.Printf("\nOpción>");
	fmt.Scanf("%d" + "\n", &opcion)
	
	return opcion;
}

func ejecutarOpcion(opcion int) bool {
	switch opcion {
	case 0:
		return salir()
	case 1:
		crearDB()
	case 2:
		crearTablas()
	case 3:
		agregarPKFK()
	case 4:
		eliminarPKFK()
	case 5:
		cargarDatos()
	case 6:
		crearSPyT()
	case 7:
		iniciarPruebas()
	case 8:
		cargarDatosBoltDB()
	case 9:
		mostrarMenu()
	default:
		fmt.Printf("Opcion no válida")
	}
	return true
}

func salir() (bool){
	fmt.Printf("Adios!\n");
	return false
}

func crearDB(){
	conectarPostgres()
	_, err := db.Exec(`drop database if exists berini_carmona_faccini_flores_db1`)
	if err != nil {
		log.Fatal(err)
	}
	_, err = db.Exec(`create database  berini_carmona_faccini_flores_db1`)
		if err != nil {
			log.Fatal(err)
		}
	fmt.Printf("\nBase de datos creada\n");	
}

func crearTablas(){
	sqlScript := leerArchivo("archivos-sql/tablas.sql")
	if err := ejecutarConsulta(sqlScript)
		err != nil {
			log.Fatal(err)
		}
	fmt.Printf("\nTablas creadas\n");
}

func agregarPKFK(){
	sqlScript := leerArchivo("archivos-sql/agregar-claves.sql");
	if err := ejecutarConsulta(sqlScript)
		err != nil {
			log.Fatal(err)
		}
	fmt.Printf("\nPK´s y FK´s creadas\n");
}

func eliminarPKFK(){
		sqlScript := leerArchivo("archivos-sql/eliminar-claves.sql");
		if err := ejecutarConsulta(sqlScript)
			err != nil {
				log.Fatal(err)
		}
	fmt.Printf("\nPK´s y FK´s eliminadas\n");
}

func cargarDatos(){
	archivos := []string {
			"archivos-sql/clientes.sql",
			"archivos-sql/operadore.sql",
			"archivos-sql/datos-prueba.sql",
		}
		for _, archivo := range archivos {
			sqlScript := leerArchivo(archivo)
			if err := ejecutarConsulta(sqlScript); 
			err != nil {
				log.Fatal(err)
			}
		}
	fmt.Printf("\nLos datos fueron cargados con éxito\n");
}

func crearSPyT(){
	archivos := []string{
					"archivos-sql/ingreso-llamado.sql",
					"archivos-sql/desistir-llamado.sql",
					"archivos-sql/asignar-operadore-a-llamado.sql",
					"archivos-sql/alta-tramite.sql",
					"archivos-sql/finalizacion-llamado.sql",
					"archivos-sql/cierre-tramite.sql",
					"archivos-sql/reporte-rend-operadores.sql",
					"archivos-sql/envio-mail-alta-tramite.sql",
					"archivos-sql/envio-mail-cierre-tramite.sql",
					"archivos-sql/iniciar-pruebas.sql",
				}
				for _, archivo := range archivos {
					sqlScript := leerArchivo(archivo)
					if err := ejecutarConsulta(sqlScript); 
						err != nil {
							log.Fatal(err)
					}
				}
	fmt.Printf("\nStored procedures y triggers creados\n");
}

func iniciarPruebas(){
	sqlScript := `select iniciar_pruebas();`
		if err := ejecutarConsulta(sqlScript); 
			err != nil {
				log.Fatal(err)
		}
	fmt.Printf("\nPruebas iniciadas\n");
}

type Cliente struct{
	Id_cliente int
	Nombre string
	Apellido string
	Dni int
	Fecha_nacimiento string
	Telefono string
	Email string
}

type Operadore struct{
	Id_operadore int
	Nombre string
	Apellido string
	Dni int
	Fecha_ingreso string
	Disponible bool
}

type Cola_atencion struct{
	Id_cola_atencion int
	Id_cliente int
	F_inicio_llamado string
	Id_operadore sql.NullInt64
	F_inicio_atencion sql.NullString
	F_fin_atencion sql.NullString
	Estado string
}

type Tramite struct{
	Id_tramite int
	Id_cliente int
	Id_cola_atencion int
	Tipo_tramite string
	F_inicio_gestion string
	Descripcion string
	F_fin_gestion sql.NullString
	Respuesta sql.NullString
	Estado string
}

func CreateUpdate(db *bolt.DB, bucketName string, key []byte, val []byte) error{
	tx, err := db.Begin(true);
	if err != nil{
		return err
	}
	defer tx.Rollback()

	b, _ := tx.CreateBucketIfNotExists([]byte(bucketName))

	err = b.Put(key, val)
	if err != nil{
		return err;
	}

	if err := tx.Commit(); err != nil{
		return err
	}

	return nil
}

func ReadUnique(db *bolt.DB, bucketName string, key []byte) ([]byte, error){
	var buf []byte

	err := db.View(func(tx *bolt.Tx) error{
		b := tx.Bucket([]byte(bucketName))
		buf = b.Get(key)
		return nil
	})

	return buf, err
}

func conectar_boltDB()(*bolt.DB, error){
	db_bolt, err_bolt := bolt.Open("berini_carmona_faccini_flores_db1", 0600, nil)
	if err_bolt != nil{
		log.Fatal(err_bolt)
	}
	return db_bolt, nil
}

func convertir_JSON (info interface{}) ([]byte, error){
	data, err_json := json.MarshalIndent(info, "", " ");
	if err_json != nil{
		log.Fatal(err_json)
	}
	return data, nil
}

func cargarClientes(){
	db, err = conectarDB()
	
	db_bolt, err_bolt = conectar_boltDB()
	defer db_bolt.Close()
	
	rows, err := db.Query(`select * from cliente`)

	if err != nil{
		log.Fatal(err)
	}
	defer rows.Close()

	var c Cliente

	for rows.Next(){
		if err := rows.Scan(&c.Id_cliente, &c.Nombre, &c.Apellido, &c.Dni, &c.Fecha_nacimiento, &c.Telefono, &c.Email); err != nil{
			log.Fatal(err)
		}

		data,err_jsondata =  convertir_JSON(c)

		CreateUpdate(db_bolt, "cliente", []byte(strconv.Itoa(c.Id_cliente)), data)
	}	

	if err = rows.Err(); err != nil{
		log.Fatal(err)
	}
	
}

func cargarOperadores(){
	db, err = conectarDB()

	db_bolt, err_bolt = conectar_boltDB()
	defer db_bolt.Close()
	
	rows, err := db.Query(`select * from operadore`)

	if err != nil{
		log.Fatal(err)
	}
	defer rows.Close()

	var o Operadore

	for rows.Next(){
		if err := rows.Scan(&o.Id_operadore, &o.Nombre, &o.Apellido, &o.Dni, &o.Fecha_ingreso, &o.Disponible); err != nil{
			log.Fatal(err)
		}
		
		data,err_jsondata =  convertir_JSON(o)

		CreateUpdate(db_bolt, "operadore", []byte(strconv.Itoa(o.Id_operadore)), data)
	}

	if err = rows.Err(); err != nil{
		log.Fatal(err)
	}
	
}

func cargarLlamados(){
	db, err = conectarDB()

	db_bolt, err_bolt = conectar_boltDB()
	defer db_bolt.Close()
	
	rows, err := db.Query(`select * from cola_atencion`)

	if err != nil{
		log.Fatal(err)
	}
	defer rows.Close()

	var ca Cola_atencion

	for rows.Next(){
		if err := rows.Scan(&ca.Id_cola_atencion, &ca.Id_cliente, &ca.F_inicio_llamado, &ca.Id_operadore, &ca.F_inicio_atencion, &ca.F_fin_atencion, &ca.Estado); err != nil{
			log.Fatal(err)
		}
				
		data,err_jsondata =  convertir_JSON(ca)
	
		CreateUpdate(db_bolt, "cola_atencion", []byte(strconv.Itoa(ca.Id_cola_atencion)), data)
	}

	if err = rows.Err(); err != nil{
		log.Fatal(err)
	}
	
}

func cargarTramites(){
	db, err = conectarDB()

	db_bolt, err_bolt = conectar_boltDB()
	defer db_bolt.Close()
	
	rows, err := db.Query(`select * from tramite`)

	if err != nil{
		log.Fatal(err)
	}
	defer rows.Close()

	var t Tramite

	for rows.Next(){
		if err := rows.Scan(&t.Id_tramite, &t.Id_cliente, &t.Id_cola_atencion, &t.Tipo_tramite, &t.F_inicio_gestion, &t.Descripcion, &t.F_fin_gestion, &t.Respuesta, &t.Estado); err != nil{
			log.Fatal(err)
		}

		data,err_jsondata =  convertir_JSON(t)
		
		CreateUpdate(db_bolt, "tramite", []byte(strconv.Itoa(t.Id_tramite)), data)
	}

	if err = rows.Err(); err != nil{
		log.Fatal(err)
	}
	
}

func cargarDatosBoltDB(){
	cargarClientes();
	cargarOperadores();
	cargarLlamados();
	cargarTramites();
	fmt.Printf("\nDatos cargados correctamente en Bolt DB\n");
}

func main(){
	var opcionElegida int;
	var ejecucion bool;
	ejecucion = true;

	mostrarMenu();

	for ejecucion == true {
		opcionElegida = escucharOpcion();

		ejecucion = ejecutarOpcion(opcionElegida);
	}
}
