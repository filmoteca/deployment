# Introducción

Este almacén es parte del proyecto [filmoteca](https://github.com/filmoteca/filmoteca) y es requerido para realizar su despliege (*deployment* en inglés).

# Requerimientos

Para realizar el proceso de *deployment* se requiere tener instalado

* **ruby** `2.*`
* bundler. El manejador de depencencias de ruby
* bower. Requeridos para trabajar con los *assets* del proyecto filmoteca.

**TODO**: agregar instrucciones para instalar ruby
 
Se puede ver la versión de ruby instalada en el sistema con el comando `ruby --version`. Un ejemplo de la salida del comando podría ser `ruby 2.0.3p484 (2013-11-22 revision 43786) [x86_64-linux]`

Bundler puede ser instalado con el comando

```bash
sudo gem install bundler
```

# Despliegue (deployment)

## Preparación

El proceso de deployment es independiente del proyecto filmoteca así que hay dos formas de usarlo. La primera opcion es
clonar éste almacen y entrar al directorio creado por el proceso de clonado. La segunda opcion es entrar al directorio `vendor/filmoteca/deployment` la cual contiene el clone de este proyecto.

A partir de este punto se asume que te encuentras en el directorio de este proyecto.

## Instalación de dependencias

Para instalar todas las dependencias de proyecto basta correr

```bash
bundle
```

## Archivos de configuración

En el directorio `config/deploy` se deben de guardar los archivos de configuración de los servidores. Estos archivos no son versionados, es decir, no los encontraras en este repository, ya que contienen información sensible como contraseñas de los servidores. Entonces una vez que se tengas estos los archivos `prod.rb` y `staging.rb` (para producción y pruebas respectivamente) se deberan copiar al directorio `config/deploy`.

## Desplegando (deploying)

Para deplegar la aplicación en una versión especifica se debe correr el siguiente comando

```bash
bundle exec cap prod deploy BRANCH=nombre_de_branch_o_tag
```

cambiando `nombre_de_branch_o_tag` por el nombre del *branch* o *tag* del cual se desea hacer deployment. Por ejemplo `2.0.1` o `development`. 

### Opcional

El comando anterior es muy largo para usarlo constantemente. Así que se puede crear un *alias* para él. Para hacer esto se debe agregar la línea

```bash
alias cap="bundle exec cap"
```

Al archivo, `~/.bashrc` or `~/.zshrc` or `~/.profile` (Linux o Mac solamente). Para ver qué archivo tenemos podemos correr el comando `ls ~/*rc.`

## Funcionamiento

El proceso de deployment creará una estructura de carpetas en el ambiente en el cual se hizo el deployment, que se ve como esto

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

Esta estructura de directorios nos da seguridad y precisión al realizar una liberación. Ya que si algo falla mientras se esta deplegando la aplicación, por ejemplo, no se puedieron subir los assets, el enlace simbólico no actualizará y el servidor web, y por lo tanto el usuario del sitio, no verá ningún cambio. El enlace simbólico solo se actualizará si todo el proceso de deployment fue exitoso. Además nos permite regresar a una versión anterior si algo realmente no funciona para nada bien. A éste proceso se le conoce como **rollback** y es el último recurso para cuando algo fue mal.

La mayoría de los servidores web apuntan a la carpeta `ruta_al_proyecto/htdocs` entonces para no cambiar la configuración del servidor se crea, manualmente, un enlace simbólico de `ruta_al_proyecto/current/htdocs` a `ruta_al_proyecto/htdocs`. Por lo tanto, si se desea cambiar o mirar archivos de la liberación actual se debe entrar al directorio `ruta_al_proyecto/current/htdocs`

Además de esto, el proceso de deploment correra *migrations*, descargara composer e instalara las dependencias de proyecto en el servidor indicado, así como la preparación y subidad de los assets.
