# Introducción

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

Por último debemos de instalar las dpendencias del proceso de deployment
con el commando

```bash
bundle
```

# Despliegue (deployment)

## Preparación

Antes de poder desplegar la aplicación se deben copiar manualmente 
a la carpeta **config/deploy/** los archivos `production.rb` y 
`staging.rb`, los cuales contienen configuración especial para cada uno
de los dos ambientes y no son versionados ya que podrían contener 
información sensible.

## Desplegando (deploying)

Para realizar un deployment de alguna versión de la aplicación se
debe correr el siguiente commndo

```bash
bundle exec cap production deploy BRANCH=nombre_de_branch_o_tag
```

cambiando `nombre_de_branch_o_tag` por el nombre del *branch* o *tag* 
del cual se desea hacer deployment. Por ejemplo `2.0.1` o `development`. 

