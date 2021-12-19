## Mojon Twins Engine MK1 (Churrera) Dockerizado

### Introducción

Me aventuré a hacer un jueguillo en spectrum utilizando la churrera de los Mojon Twins. Al empezar me di cuenta que casi todas las herramientas estan pensadas para usarlas en windows, con lo que me puse a dockerizarlo para que cualquiera que quiera usarlo en cualquier sistema operativo lo pueda hacer de una manera fácil.

### Requesitos

* Docker
* Make
* Wine si no usas windows y quieres utilizar Mappy para los mapas y el ponedor para los enemigos (Recomendado)

### Instrucciones

Además de docker, he utilizado Make para automatizar con comandos las operaciones más habituales.

``` bash
git clone git@github.com:rtorralba/mojon-docker.git nombre_de_tu_juego
cd nombre_de_tu_juego
make clone-mk1 # Esto te creará una carpeta src con el juego ejemplo del repositorio de MK1
make clean-mojon-docker-git # Para borrar el reporitorio original y puedas setear el tuyo propio del proyecto
make build
```
Ya solo tendrás que abrir el juego .tap de la carpeta src/dev/

### Modificando el juego
Dentro del Makefile podrás cambiar cosas como el nombre del juego o el numero de pantallas.

``` bash
# Modify game settings
GAME = lala_beta
GAME_SCREENS_HEIGHT = 6 # If change that you shoul modify config.h too
GAME_SCREENS_WIDTH = 5 # If change that you shoul modify config.h too
```

A parte, como suponga ya sabes deberás seguir algún tutorial pasar saber que debes tocar para ir realizando tu juego, os recomiendo el tutorial de los (Mojon Twins)[https://github.com/mojontwins/MK1/tree/master/docs]

### Agradecimientos

Gracias a los (Mojon Twins)[https://www.mojontwins.com/] por haber creado este increible (motor)[https://github.com/mojontwins/MK1] y a GreenWebSevilla por la ayuda en el canal de Telegram.