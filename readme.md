# Introducción

Este almacen es parte del proyecto [filmoteca](https://github.com/filmoteca/filmoteca) y es requerido para realizar su despliege (*deployment* en inglés).

# Requerimientos

Para realizar el proceso de *deployment* se requiere tener instalado
**ruby** `2.*.*`.

**TODO**: agregar instrucciones para instalar ruby
 
Para probar que se tiene la versión correcta de ruby se puede correr
el comando `ruby --version` el cual debera mostrar la versión de ruby
que tenemos instalada en el sistema. Por ejemplo 
`ruby 2.0.3p484 (2013-11-22 revision 43786) [x86_64-linux]`

Una vez que se tiene instalado ruby necesitamos instalar el manejador
de dependencias de ruby **bundler**. 

```bash
sudo gem install bundler
```

Además la vagrant debe estar *up* ya se tiene que construir (build en inglés) algunos assets, por ejemplo, las fuentes de letras y las hojas de estilos.

# Despliegue (deployment)

## Preparación

Antes de poder desplegar la aplicación se deben copiar manualmente 
al directorio `config/deploy/` los archivos `prod.rb` y 
`staging.rb`, los cuales contienen configuración especial para cada uno
de los dos ambientes y no son versionados ya que podrían contener 
información sensible.

El proceso de deployment es independiente del proyecto principal y por esto existen dos formas de utilizarlo. La primera, clonar éste almacen, entrar al directorio creado por el proceso de clonado y usarlo. La otra opción es entrar al directorio del proyecto principal e ir a `vendor/filmoteca/deployment` y usarlo.

Las dos opciones se utilizan de la misma forma, pero en la segunda no se tiene que realizar el clonado de éste almacen, ya que al ser este paquete una dependencia de desarollo es clonado automaticamente al directorio indicado arriba.

Una vez elegido el método para usar este almacen debemos entra a su directorio e instalar sus dependencias con el commando

```bash
bundle
```

## Desplegando (deploying)

En esta sección se muestra como utilizar éste almacen y se asume que te encuentras dentro de su directorio, ya sea usando la opcion 1 o 2.

Para deplegar la aplicación en una versión especifica se debe correr el siguiente comando

```bash
bundle exec cap prod deploy BRANCH=nombre_de_branch_o_tag
```

cambiando `nombre_de_branch_o_tag` por el nombre del *branch* o *tag* del cual se desea hacer deployment. Por ejemplo `2.0.1` o `development`. 

### Opcional

El comando anterior es muy largo para usarlo constantemente. Así que se puede crear un *alias* para él. Para hacer esto se debe agregar la linea

```bash
alias cap="bundle exec cap"
```
Al archivo, `~/.bashrc` or `~/.zshrc` or `~/.profile` (Linux o Mac solamente). Para ver que archivo tenemos podemos correr el comando `ls ~/*rc.`

## Funcionamiento

El proceso de deployment creará una estructura de carpetas en el ambiente en el cual se hizo el deployment, que se ven como esto

```txt
├── current -> /var/www/my_app_name/releases/20150120114500/
├── releases
│   ├── 20150120114500
│   ├── 20150090083000
│   ├── 20150100093500
└── shared
    └── uploads
    └── resources
    └── logs
```

En el directorio **shared** se guardan archivos que son compartidos entre liberaciones, es decir aquellos archivos que permanecen constantes entre liberación y liberación. Un ejemplo de ellos, son los archivos que sube un usuario a través de la admin zone. Luego **releases** (liberaciones en español) tiene una lista de liberaciones (a lo más 3) y en su interior se encuentra un proyecto *filmoteca* completamente funcional y con la correspondiente estructura de directorios. Por último, el directorio más importante: **current** (actual en español). Este directorio es enlace simbólico (un accesso directo) a una liberación. Es donde el servidor web buscará la aplicación.

Esta estructura de directorios nos da seguridad y precisión al realizar una liberación. Ya que si algo falla mientras se esta deplegando la aplicación, por ejemplo, no se puedieron subir los assets, el enlace simbólico no actualizará y el servidor web, y por lo tanto el usuario del sitio, no verán ningún cambio. El enlace simbólico solo se actualizará si todo el proceso de deployment fue exitoso. Además nos permite regresar a una versión anterior si algo realmente no funciona para nada bien. A éste proceso se le conoce como **rollback** y es el último recurso para cuando algo fue mal.

La mayoría de los servidores web apuntan a la carpeta `ruta_al_proyecto/htdocs` entonces para no cambiar la configuración del servidor se crea, manualmente, un enlace simbólico de `ruta_al_proyecto/current/htdocs` a `ruta_al_proyecto/htdocs`. Por lo tanto, si se desea cambiar o mirar archivos de la liberación actual se debe entrar al directorio `ruta_al_proyecto/current/htdocs`
