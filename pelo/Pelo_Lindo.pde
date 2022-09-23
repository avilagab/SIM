//Proyecto final Simulacion
//Integrantes:
//William Andres Castro Cruz
//Maria Valentina Gómez Urbina
//Tatiana Tolosa Santamaría


// Valores iniciales
float gravedad = 5;
float masa = 10;
PVector fuerzaGravedad = new PVector(0, masa * gravedad);//Gravedad
float tiempo = 0.3; //Tiempo total de la simulación
PVector anclaje = new PVector(209, 20);
float k =2;   // Constante de Fuerza de K 
float amortiguamiento = 6;  //Variable de amortiguamiento
boolean isPaused;//evaluar falso o verdadero

Cabellera cabellera;

void setup(){  //Creación de la interfaz
  frameRate(24);
  size(500,300);
  int numeroCabellos = 100; //Cantidad de filamentos
  cabellera = new Cabellera(new PVector(100,100), numeroCabellos, 100, 50);//Crea una variable que la vuelve objeto, este será llamado cabellero y tiene un vector importado de las caracteristicas de #cabello
}

void draw() {
  background(255, 255, 255);
  stroke(0, 0, 0);
  if(!isPaused){
    cabellera.update();    
  }
  cabellera.draw();//Dibujar los cabellos
};

//Se crea movimiento de la cabeza a la que esta pegados los cabellosy se mueve con las flechas 
void keyPressed() {
  if (key == CODED) {
    if (keyCode == UP) {
      cabellera.move(new PVector(0, -3)); //mueve a izq la cabeza
    } else if (keyCode == DOWN) {
      cabellera.move(new PVector(0, +3));//mueve a derecha la cabeza
    }
    if (keyCode == LEFT) {
      cabellera.move(new PVector(-3, 0));//mueve a abajo la cabeza
    } else if (keyCode == RIGHT) {
      cabellera.move(new PVector(3, 0));//mueve a arriba la cabeza
    }
  } else {
    if (key == 32) {
      isPaused = !isPaused;
    }
  }
}

//clase cabellera
class Cabellera {
  float tallaCabeza = 100; //talla de la cabeza que tan grande es la circunferencia
  
  PVector posicion;
  int numeroCabellos;//numero de cabellos 
  Cabello[] cabellos; // cabellos 
  
  Cabellera(PVector posicionInicial, int numeroCabellos, float largoMinimo, float largoMaximo) {
    posicion = posicionInicial;
    this.numeroCabellos = numeroCabellos; //llama al objeto # cabellos
    cabellos = new Cabello[numeroCabellos];//llena arreglo cabellos con numero de cabellos 
    for(int i = 0; i < numeroCabellos; i++ ){//ciclo para crear cada cabello
      float rad = random(tallaCabeza/2); //radi de la cabeza , random=crea numero aleatorio  entre el radioo
      float x = posicion.x + rad * cos(rad);
      float y = posicion.x + rad * sin(rad);
      cabellos[i] = new Cabello(new PVector(x, y), random(largoMinimo, largoMaximo), 4);//llena arreglo con posicion ,longitud (# aleatorio en largo min o corto), numero de masas 4+2=(6)
    }
  }
  
  void move(PVector movimiento) { 
    posicion.add(movimiento); //mueve el circulo 1
    for(int i = 0; i < numeroCabellos; i++ ){
      cabellos[i].move(movimiento); // 2 el circulo llama al cabello a moverse
    }
  }
  
  void update() { //actualiza la fisica (cabellerla le dice a cabello actuliza, y cabello a masa)
    for(int i = 0; i < numeroCabellos; i++ ){ //for para cada cabello
      cabellos[i].update();//actualice
    }
  }
  
  void draw() {
    stroke(0, 0, 0);
    circle(posicion.x, posicion.y, tallaCabeza);//dibuja circulo (pos x, pos y , radio)
    for(int i = 0; i < numeroCabellos; i++ ){ //ciclo de dibujo de cabellos  (lineas entre las masas)
      cabellos[i].draw();//dibujar los cabellos con un arreglo construido anteriormente
    }
  }
}
//creo clase cabello 
class Cabello {
  PVector posicion;
  int cantidadMasas = 2; // numero de masas, minimo tiene dos para la union del cabello , >masas = mas real 
  Masa[] masas; //creo arreglo masa
  //constuctor del cabello 
  Cabello(PVector posicionInicial, float longitud, int numeroMasas) {
    posicion = posicionInicial;
    cantidadMasas = cantidadMasas + numeroMasas;
    masas = new Masa[cantidadMasas]; //llena un arreglo que tiene como elementos cantidad de masas por cabello 
    masas[0] = new Masa(new PVector(0,0), true, null);//creo primera masa anclaje (posicion, anclaje pq es la primera y va pegada a cabellera, masa anterior(ningungo)
    for(int i = 1; i < cantidadMasas; i++ ){//ciclo de masas empieza desde uno pq ya tenemos creamos el primer pelo 
      masas[i] = new Masa(new PVector(posicion.x, posicion.y + masas[i-1].posicion.y + (longitud/cantidadMasas)), false, masas[i-1]);//posicion, es anclaje no, masa anterior
    }
  }
  
  void move(PVector movimiento) {//funcion de movimiento
    masas[0].move(movimiento); //mueve masa (al anclaje)
  }
  
  void update() {//funciona de actualizacion 
    for(int i = 0; i < cantidadMasas; i++ ){
      masas[i].update(); //actualiza la masa
    }
  }
  //dibuja cabello 
  void draw() {
    stroke(random(255), random(255), random(255)); //cambio de color el cabello
    for(int i = 1; i < cantidadMasas; i++ ){ //ciclo de dibujo de cabello 
      line(posicion.x + masas[i].posicion.x, posicion.y + masas[i].posicion.y, posicion.x + masas[i-1].posicion.x, posicion.y + masas[i-1].posicion.y);
    }
  }
}
//crear clase masa
class Masa {
  boolean esAnclaje = false; //creamos la variable anclaje que tendra como valor verdadero o falso 
  PVector posicion = new PVector(0, 0);//vector posicion inicial
  PVector velocidad = new PVector(0, 0);//vector velocidad inicial
  PVector aceleracion = new PVector(0, 0);//vector aceleracion
  PVector fuerza = new PVector(0, 0); //vector fuerza
  PVector fuerzaResorte = new PVector(0, 0);//vector fuerza resorte
  PVector fuerzaamortiguamiento = new PVector(0, 0);//vector fuerza amortiguamiento 
  //sistema de multiples masas y resortes
  Masa masaAnterior; //anclaje
  Masa masaSiguiente;//masa 1
  //constructor como construyo objeto masa
  Masa(PVector posicionInicial, boolean esAnclaje, Masa anterior){
    posicion = posicionInicial;
    this.esAnclaje = esAnclaje;//llama al objeto anclaje 
    masaAnterior = anterior;
    if(masaAnterior != null){//comprueba si es anclaje, si no es anclaje quien es la anterior masa 1 y asi sucesivamente
      masaAnterior.masaSiguiente = this;
    }
  }
  void move(PVector movimiento) {//funcion movimiento
    posicion.add(movimiento);//mmovimiento dependiendo de la posicion
  }
  //funcion de actualizacion de las fisicas , donde se actualiza el estado de la masa
  void update() {
    if(esAnclaje) {//retornar anclaje 
      return; 
    }
    fuerzaamortiguamiento = velocidad.copy().mult(amortiguamiento); //fuerza amortiguamiento
    fuerzaResorte = (posicion.copy().sub(masaAnterior.posicion)).mult(-k);//fuerza resorte
    if(masaAnterior.esAnclaje) {
      fuerza = fuerzaResorte.copy().add(fuerzaGravedad).sub(fuerzaamortiguamiento).sub(masaSiguiente.fuerzaResorte).add(masaSiguiente.fuerzaamortiguamiento);//
    } else {
      fuerza = fuerzaResorte.copy().add(fuerzaGravedad).sub(fuerzaamortiguamiento);//
    }     
    aceleracion = fuerza.copy().div(masa); //calcula aceleracion
    velocidad.add(aceleracion.copy().mult(tiempo));//calcula velocidad
    posicion.add(velocidad.copy().mult(tiempo));//calcula porsicion
  }
}
