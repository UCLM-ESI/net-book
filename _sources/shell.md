# Shell

El interprete de comandos (*shell*) es probablemente una de las herramientas más
interesantes del sistema operativo GNU/Linux o POSIX en general. Una shell es
esencialmente un programa interactivo que permite al usuario ejecutar otros programas.
Como con cualquier tecnología o herramienta que merezca la pena, es fácil encontrar
grandes partidarios y detractores. Lo cierto es que la shell es una herramienta extraña,
oscura y de aspecto absolutamente espartano en un mundo en el que las pantallas
multi-táctiles o el reconocimiento de voz son algo habitual.

En general, una interfaz de comandos ---a menudo denominada CLI--- es mucho menos intuitiva[^1]
que una GUI. Sin embargo, cuando la capacidad y el nivel de detalle (y por tanto la
complejidad) de la herramienta aumenta, la interfaz gráfica resulta mucho más difícil de
desarrollar, requiere tanto o más entrenamiento y su uso suele ser menos productivo que
una interfaz de comandos. Ejemplos muy evidentes de esto se pueden encontrar en programas
de diseño CAD con literalmente miles de opciones repartidas en innumerables menús.
Aplicaciones con un alto grado de especialización, que a pesar de contar también con
interfaz gráfica, suelen utilizarse mediante comandos, sobre todo por parte de los
usuarios expertos. Un ejemplo de esto podría ser el sistema IOS de CISCO.

[^1]: El manejo *intuitivo* se refiere a la posibilidad de realizar un uso productivo de
una herramienta sin conocimiento ni instrucción previa. El adjetivo se puede aplicar tanto
a la herramienta como al usuario.

Otra buena razón por la que la interfaz de comandos puede resultar más productiva es la
facilidad para combinar conjuntos de sentencias en forma de macros, lo que además permite
automatizar tareas repetitivas. Especificar o documentar un procedimiento, incluso de
complejidad media, usando comandos es mucho más sencillo que dar instrucciones para
utilizar menús, botones y listas desplegables, algo que a menudo requiere grabar en vídeo
la secuencia de acciones ---los llamados \emph{screencast}.

[//]: sidebar: FIXME: portada
«In the Beginning... Was the Command Line»[^2] de Neal STEPHESON, es un ensayo crítico (y a
ratos humorístico) sobre la influencia que los computadoras, los sistemas operativos y sus
distintas filosofías tienen sobre la sociedad actual, y especialmente sobre las personas
con inquietudes técnicas. Uno de los temas trata precisamente sobre las diferencias entre
interfaz gráfica e interfaz de comandos.

[^2] http://en.wikipedia.org/wiki/In_the_Beginning...\_Was_the_Command_Line

En todo caso, es importante entender que es un error subestimar o considerar anticuada una
aplicación simplemente por el hecho de usar una interfaz de comandos. A menudo, las
aplicaciones bien diseñadas definen un conjunto de acciones en una librería, que pueden
ser utilizadas indistintamente desde *front-ends* [^3], línea de comandos, o
incluso desarrollando otras aplicaciones a medida. Un ejemplo de este tipo de aplicaciones
puede ser VLC. Incluso servicios de Internet tan conocidos como HTTP, SMTP o FTP
pueden ser utilizados mediante comandos de texto, tal como veremos en capítulos
posteriores.

[^3]: Se denomina *front-end* a la capa de software que proporciona una interfaz ---del tipo
  que sea--- a un programa o librería que ofrece su funcionalidad por medio de una serie de
  funciones o clases (API).


## GNU Bash

Bash es probablemente una de las shells más famosas y potentes disponibles en los sistemas
GNU. Los sistemas POSIX han conocido una larga variedad de shell's desde principios de los
años 70. Aunque bash tiene características muy interesantes (como la «complección»
automática contextual) primero debemos abordar las cuestiones básicas que todo usuario
avanzado debería conocer.

Por otra parte, hay una colección de programas (agrupados con el nombre de
``gnu coreutils``) que realizan acciones relativamente sencillas, pero que están
diseñados de modo que se puedan combinar para realizar operaciones de complejidad nada
trivial de forma bastante simple, una vez que se entiende un concepto clave: la
redirección de la entrada/salida.

Estas y otras aplicaciones junto con el lenguaje de programación «C-Shell» proporcionan
una herramienta con infinitas posibilidades para todo tipo de tareas, que pueden ir desde
la administración de sistemas hasta las más sofisticadas técnicas de pen-testing, pasando
por el desarrollo de aplicaciones de todo tipo.


## Valor de retorno

En los sistemas POSIX se asume que cuando un programa acaba devuelve un valor entero.
Este valor es recogido por su proceso padre (que puede ser una shell) y ofrece información
muy útil para saber cómo ha ido su ejecución.

Un programa que realiza su función satisfactoriamente debería devolver siempre un valor 0.
Puede devolver un valor distinto (1, 2, etc) para indicar que hubo un problema concreto.

Éste es el motivo por el que el estándar del lenguaje C dice que toda función
``main`` ha de devolver un entero y que por defecto su valor de retorno debería ser
cero. Según eso, el «hola mundo» correcto en C es el siguiente:

```c
#include <stdio.h>
int main(int argc, char* argv[]) {
    puts("hello world\n");
    return 0;
}
```

Por ejemplo, el siguiente listado muestra la ejecución del comando ``ls /``, que lista
el contenido del directorio raíz:

```shell
david@amy:~$ ls /
bin   etc         lib         mnt   root  selinux  tmp  vmlinuz
boot  home        lost+found  opt   run   srv      usr
dev   initrd.img  media       proc  sbin  sys      var
```

Lo que ha ocurrido aquí es que la shell bash ha creado un proceso en el cuál ha ejecutado
el programa ``ls`` con el argumento ``/``, después esperó a que el programa terminase y
recogió su valor de retorno. Ese valor lo almacenó en una «variable de entorno» llamada
``?`` [^4]. Se puede obtener el valor de una variable de entorno utilizando el comando
``echo`` colocando el símbolo «$» delante del nombre de la variable, tal que:

[^4]: Sí, el signo de interrogación

```shell
david@amy:~$ echo $?
0
```

``` {admonition} Comando
**echo** escribe la cadena de texto que le se indique como argumento,
  expandiendo las variables que incluya (identificadores precedidos del
  símbolo ``$``.
```

Pero esto solo es aplicable al comando inmediatamente anterior. Una ejecución incorrecta
retornaría un código de error, como se puede comprobar en el siguiente ejemplo:

```shell
david@amy:~$ ls noexiste
ls: cannot access noexiste: No such file or directory
david@amy:~$ echo $?
2
```

La documentación de cada programa debe indicar lo que significa cada uno de los posibles
valores de retorno. Si consultamos la página de manual de ``ls`` (``man ls``)
veremos que:

```text
  Exit status:
      0      if OK,
      1      if minor problems (e.g., cannot access subdirectory),
      2      if serious trouble (e.g., cannot access command-line argument).
```

Las *señales* también se utilizan para indicar que un programa terminó como consecuencia
de una situación anómala y el SO (u otro programa) lo terminó («lo mató»). Por ejemplo, si
el usuario pulsa Control-C mientras un programa se ejecuta en una shell, esta le enviará
la señal SIGINT (-2) y ese será el valor de retorno del programa.


## Procesos
[//]: FIXME \label{sec:procesos}

El «proceso» es una abstracción del SO para ejecutar un programa conforme a
determinados parámetros de seguridad, prioridad y privilegios de acceso a recursos.
Cualquier proceso puede crear procesos hijos, que heredan algunas de sus propiedades tales
como privilegios y ficheros abiertos. Para listar procesos se utiliza
``ps``, que es un abreviatura de ``process status``. Por ejemplo, un usuario
puede ver los procesos asociados al terminal al que está conectado con el comando
``ps T``.

```shell
david@amy:~$ ps T
  PID TTY          TIME CMD
 4970 pts/2    00:00:00 bash
 5107 pts/2    00:00:01 emacs
 5164 pts/2    00:00:00 bash
 6021 pts/2    00:00:01 firefox-bin
 6204 pts/2    00:00:00 ps
```

La primera columna indica el PID de cada proceso. La segunda el TTY (el terminal
al que están asociados). La tercera (TIME) es el tiempo de procesador otorgado al
proceso hasta el momento. Y por último (CMD), el programa que se está ejecutando.

El programa ``ps`` dispone de una amplia variedad de opciones[⁵] para filtrar qué procesos
se desean listar, qué atributos o en qué formato. Por ejemplo, el siguiente comando
muestra las relaciones de «genealogía»:

[^5]: Es lo habitual en el mundo POSIX.

```shell
david@amy:~$ ps f
  PID TTY      STAT   TIME COMMAND
 4970 pts/2    Ss     0:00 bash
 5107 pts/2    T      0:01  \_ emacs
 5164 pts/2    S      0:00  \_ bash
 5300 pts/2    Sl     0:01      \_ /usr/lib/iceweasel/firefox-bin
 6283 pts/2    R+     0:00      \_ ps f
 4592 pts/0    Ss     0:00 bash
 4755 pts/0    S+     0:28  \_ emacs shell.tex
```

En esta ocasión aparece una columna adicional (STAT) que indica el estado del
proceso. La primera letra: R (*running*), T (*stopped*) y S (*sleep*). La
segunda: s (*session leader*), l (*multi-hilo*), + (*en primer plano*).

Por ejemplo, si un proceso no responde a su interfaz gráfica (si la tiene) y el usuario no
tiene control de otro modo, la operación más habitual es «matarlo» (con el comando
``kill``). A pesar de su nombre, el comando ``kill`` sirve para enviar una señal a un
proceso. La señal por defecto es SIGTERM, pero se puede enviar otra si se especifica como
argumento. Puede ver la lista de todas las señales con ``kill -l``. Por ejemplo, el
siguiente comando envía la señal SIGKILL (9) al proceso con PID 5200:

```shell
david@amy:~$ kill -9 5200
[1]+  Terminado (killed)      gedit
```

Algunas señales pueden ser ignoradas o bien capturadas por el programa para realizar
acciones especificadas por el programador[^6]  como es el caso de SIGTERM, que podríamos
considerarla una solicitud amistosa de terminación. Otras señales (como SIGKILL) no pueden
ser ignoradas para garantizar que el SO tiene el control sobre cualquier proceso.

[^6]: Vea ``man signal``.


## Trabajos

La shell crea un nuevo proceso hijo[^7] para ejecutar cada comando que se le pide. El
comportamiento normal de la shell es esperar a que ese proceso termine antes de permitir
la introducción de un nuevo comando. Esto es fácil de comprobar con el programa ``sleep``.
Es decir, por defecto, la ejecución de un comando es bloqueante, y a esto se llama
ejecución en «primer plano» o «foreground».

[^7]: La propia shell también se ejecuta en un proceso, que puede haber sido creado a su
    vez por otra shell.

Sin embargo, se puede alterar este comportamiento, es decir, la shell puede poner en
ejecución el programa que le pedimos en otro proceso e inmediatamente quedar disponible
para introducir una nueva orden. A eso se le llama ejecución en «segundo plano» o
«background». Para conseguir que la shell ejecute un comando en segundo plano basta con
añadir el símbolo «ampersand» ('``&``') al final de la línea de comandos:

```shell
david@amy:~$ gedit &
[1] 19777
david@amy:~$
```

Como se aprecia en el listado anterior, la shell está a la espera de un nuevo comando si
que el anterior haya terminado. El primer número [entre corchetes] identifica al «trabajo»
en segundo plano (proceso hijo de la shell). El segundo número es el PID de dicho
proceso, que lo identifica dentro del SO. Una shell puede ejecutar múltiples
trabajos en segundo plano. La forma más sencilla de ver cuáles son es el comando
``jobs``:

``` shell
david@amy:~$ firefox &
[2] 20847
david@amy:~$ jobs
[1]-  Running                 gedit &
[2]+  Running                 firefox &
```

Si el usuario ejecuta el comando ``fg`` (*foreground*), el último comando
ejecutado (marcado con el símbolo '``+``') pasará a primer plano, bloqueando
la shell. Opcionalmente admite como argumento el identificador del trabajo que se desea
traer a primer plano.

``` shell
david@amy:~$ fg %1
gedit
```

Si la shell se encuentra bloqueada en espera de la finalización de un comando en primer
plano, el usuario puede pararlo pulsando Control-Z (la shell lo representa con
``^Z``).

Partiendo de la situación anterior:

```shell
david@amy:~$ fg %1
^Z
[1]+  Stopped                 gedit
david@amy:~$ jobs
[1]+  Stopped                 gedit
[2]-  Running                 firefox &
david@amy:~$
```

Un trabajo **parado** puede volver a estado de ejecución en primer plano si se introduce
el comando ``fg`` o pasar a segundo plano si se introduce ``bg`` (por *background*).

```shell
david@amy:~$ jobs
[1]+  Stopped                 gedit
[2]-  Running                 firefox &
david@amy:~$ bg
[1]+ gedit &
david@amy:~$
```

Los identificadores de trabajo también se puede usar con el comando ``kill`` en lugar
de su PID.

```shell
david@amy:~$ kill -SIGKILL %2
[4]+  Killed                  firefox
```

## Otras formas de identificar procesos

A veces buscar en la lista de procesos (``ps``) no es la forma más cómoda de localizar
un proceso. Puede ser más sencillo localizarlo por su nombre (con ``pidof`` o
``pgrep``):

```shell
david@amy:~$ pidof firefox
105894
```

O bien lo podemos identificarlo por un fichero o dispositivo que el proceso tenga abierto, o
un puerto al que esté vinculado (con ``fuser``):

```shell
david@amy:~$ fuser 17500/tcp
17500/tcp:           10589
```

También se puede enviar una señal (por defecto con la intención de matarlo) con ambos
criterios (nombre y puerto):

```shell
david@amy:~$ pkill firefox
david@amy:~$ fuser --kill 17500/tcp
17500/tcp:           10589
```

Por supuesto, estos comandos tienen opciones que les permiten buscar procesos por otros
criterios (como el propietario o el órden de creación). Siempre hay una cantidad increible
de alternativas para hacer cualquier cosa, que además se pueden combinar. Es lo mejor que
tiene la shell, aunque de entrada no suene como algo bueno.


## Entrada, salida y salida de error

En los sistemas POSIX los programas interaccionan con el SO únicamente por medio de
ficheros ---o de abstracciones que ofrecen el mismo interfaz de uso. Es decir, la lectura
o escritura desde y hacia cualquier disco, pantalla, teclado, tarjeta de sonido o
cualquier otro periférico se realiza en términos de primitivas ``read``/``write`` de forma
similar a un fichero.

Todo proceso ---programa en ejecución--- dispone desde su inicio de tres descriptores de
fichero abiertos:

- la entrada estándar (o «stdin») con el descriptor 0,
- la salida estándar (o «stdout») con el descriptor 1 y
- la salida de error estándar (o «stderr») con el descriptor 2.

Eso significa que cuando el programa trata de escribir algo (con la función
``puts()`` (en C) o ``System.out.println()`` (en Java) lo hace sobre su
salida estándar. Del mismo modo, cuando el programa intenta leer o genera un mensaje de
error, esas operaciones se realizan respectivamente sobre su entrada y salida de error
estándar.

Normalmente, la entrada estándar está ligada al teclado, mientras que la salida y salida
de error estándar están ligadas a la pantalla. Para ser más precisos, están ligados al
«terminal que efectivamente, corresponde al teclado y la pantalla. Esta
asociación entre el terminal y los descriptores de fichero estándar la decide precisamente
la shell y, mediante las órdenes correspondientes, el usuario puede alterar esa asociación
para que la entrada y la salida de un proceso queden ligadas con otra cosa, tal
como un fichero en disco o incluso otro proceso...


% https://unix.stackexchange.com/questions/4126/
% what-is-the-exact-difference-between-a-terminal-a-shell-a-tty-and-a-con

```{note}
**shell, consola y terminal**: A menudo se confunden los términos «shell», «terminal» y «consola». Como hemos visto, la shell es un programa que interpreta y ejecuta comandos. El terminal es un
dispositivo físico que permite introducir y representar texto, o un programa que lo emula. Una consola es precisamente un terminal físico.
```

La anterior ejecución del comando ``ls /`` (el listado de ficheros del directorio raíz)
apareció en pantalla debido a que su salida estándar corresponde por defecto al terminal.


## Redirección

Es posible alterar la salida estándar de cualquier programa para que utilice un fichero  simplemente con el símbolo '``>``' (mayor-que) seguido del nombre del fichero:

```shell
david@amy:~$ ls -l / > /tmp/root-dir
david@amy:~$
```

```{note}
**``/tmp``** El directorio ``/tmp`` se utiliza por las aplicaciones
    para ficheros *temporales* en los que almacenar logs o datos de sesión. El
    contenido de este directorio se elimina al apagar/reiniciar el computador.
```

```{important}
La «redirección de salida» consigue que **cualquier** programa pueda
almacenar su resultado en un fichero sin que el creador de ese programa tenga que
hacer absolutamente nada para soportarlo. Todo gracias a la shell.
```

Dos cosas han cambiado respecto a la ejecución anterior del comando ``ls``: la
primera es que se ha especificado la opción ``-l`` que hace que se muestren permisos,
propietario y fecha de modificación de cada fichero o directorio. La segunda es que esta
vez *nada* ha aparecido en el terminal. La lista de los nombres de fichero ha sido
almacenada en el fichero ``/tmp/root-dir``.

Puede ver el contenido de dicho fichero utilizando el programa ``cat``:

```shell
david@amy:~$ cat /tmp/root-files
total 98
drwxr-xr-x   2 root root  4096 Aug 15 00:34 bin
drwxr-xr-x   4 root root  2048 Aug 17 22:22 boot
drwxr-xr-x  17 root root  3560 Aug 26 10:20 dev
drwxr-xr-x 193 root root 12288 Aug 25 18:29 etc
[...]
```

```{admonition} Comando
``cat`` lee el contenido de los ficheros que se le indiquen como
  argumentos y lo escribe en su salida estándar. Si no se le dan argumentos, leerá de su
  entrada estándar.
```

La redirección simple '`>`' crea siempre un fichero nuevo. Si existe un fichero con
el mismo nombre, su contenido se pierde y es substituido por los nuevos datos. Pero existe
otro tipo de redirección de salida que añade el contenido *al final* del fichero
especificado. Se indica con doble mayor-que '``>>``':

```shell
david@amy:~$ date > /tmp/now
david@amy:~$ date >> /tmp/now
david@amy:~$ cat /tmp/now
Mon Feb  8 15:40:59 CET 2021
Mon Feb  8 15:41:02 CET 2021
```

```{admonition} Comando
  `date` escribe en su salida estándar la fecha y hora actual con la zona
  horaria configurada.
```

Volviendo al fichero ``root-files`` veamos cómo podríamos filtrar sus líneas de
modo que aparezcan únicamente las que contengan la cadena «Jun» (en principio los ficheros
modificados en junio). Para ello se puede utilizar el comando ``grep`` del siguiente
modo:

```shell
david@amy:~$ grep Jun /tmp/root-files
drwxr-xr-x   6 root root  4096 Jun  6 17:58 home
lrwxrwxrwx   1 root root    32 Jun 27 13:09 initrd.img
lrwxrwxrwx   1 root root    28 Jun 27 13:09 vmlinuz
```

```{admonition} Comando
`grep` escribe en su salida estándar aquellas líneas que coincidan con
  un criterio especificado. Lee de los ficheros indicados como argumentos (o de su entrada
  estándar en su defecto).
```

`grep`, como muchos otros programas, utiliza su entrada estándar como fuente de
datos si no se le dan argumentos. Por tanto, utilizando la «redirección de entrada» (con
el carácter '`<`') se puede lograr lo mismo ejecutando:

```shell
david@amy:~$ grep Jun < /tmp/root-files
drwxr-xr-x   6 root root  4096 Jun  6 17:58 home
lrwxrwxrwx   1 root root    32 Jun 27 13:09 initrd.img
lrwxrwxrwx   1 root root    28 Jun 27 13:09 vmlinuz
```

La diferencia es que en este caso el comando `grep` no tiene constancia de estar
leyendo realmente de un fichero en disco. Resulta irrelevante.

Si se desea almacenar el resultado obtenido en otro fichero basta con utilizar de nuevo la
redirección de salida. Es posible combinar redirecciones de entrada y salida en el mismo
comando:

```shell
david@amy:~$ grep Jun < /tmp/root-files > /tmp/Jun-files
```

El contenido de ese fichero está ordenado por los nombres de los ficheros (la última
columna). Veamos cómo reordenar esa lista en función del tamaño (quinta columna)
utilizando el comando `sort`:

```shell
david@amy:~$ sort --numeric-sort --key=5 /tmp/Jun-files
lrwxrwxrwx   1 root root    28 Jun 27 13:09 vmlinuz
lrwxrwxrwx   1 root root    32 Jun 27 13:09 initrd.img
drwxr-xr-x   6 root root  4096 Jun  6 17:58 home
```

```{admonition} Comando
`sort` ordena las líneas de los ficheros que se le indiquen como
  argumento (o de su entrada estándar) y las escribe en su salida estándar. Se pueden
  especificar diferentes criterios de ordenación mediante opciones.
```

Para lograr este resultado se han creado dos ficheros temporales `root-files` y
`Jun-files`. Si lo único que interesa es el resultado final, hay una forma más
sencilla y rápida de conseguir lo mismo sin necesidad de crear ficheros intermedios: las
tuberías.

La tubería (*pipe*) conecta la salida estándar de un proceso directamente con la
entrada de otro, de modo que todo lo que el primer programa escriba podrá ser leído
inmediatamente por el segundo. Para indicar a la shell que cree una tubería se utiliza el
carácter '`|`' (AltGr-1 en el teclado español). El comando para obtener
directamente los ficheros del directorio raíz modificados en junio ordenados por tamaño
sería:

```shell
david@amy:~$ ls -l / | grep Jun | sort -n -k5
lrwxrwxrwx   1 root root    28 Jun 27 13:09 vmlinuz
lrwxrwxrwx   1 root root    32 Jun 27 13:09 initrd.img
drwxr-xr-x   6 root root  4096 Jun  6 17:58 home
```

Nótese que `grep` y `sort` no tienen nombres de fichero en sus argumentos,
y por tanto leen de sus respectivas entradas estándar.

```{tip}
  La mayoría de los programas CLI disponen de opciones que modifican su
  comportamiento aportando gran versatilidad. Una misma opción normalmente presenta dos
  formas equivalentes: un guión y una letra (`-h`) o dos guiones y una palabra
  (`--help`).

  El formato largo es el adecuado cuando se pretende que el comando sea lo más auto-explicativo posible (como en este documento) o cuando se escribe un *script* (un programa en un fichero de texto que será interpretado por la shell). El formato corto es más conveniente cuando el
  usuario escribe comandos directamente en el terminal, por el ahorro de tiempo
  obviamente.
```

Por supuesto es posible combinar la tubería y la redirección en el mismo comando. En este
caso el resultado del comando anterior se almacena en un fichero, del mismo modo que se
hacía con los comandos simples:

```shell
david@amy:~$ ls -l / | grep Jun | sort -n -k5 > /tmp/root-jun-files-sorted-by-size
```

Es fácil apreciar el gran potencial de este sencillo mecanismo. Cualquier sistema
POSIX (en especial GNU) dispone de una gran cantidad de pequeños programas
especializados ---como los que se han introducido aquí--- que pueden combinarse mediante
redirección para cubrir una gran variedad de necesidades puntuales de una forma rápida y
eficiente [^8].

[^8]: La web \url{https://www.commandlinefu.com/} es una buena prueba de la
gran versatilidad de la redirección y las capacidades de la shell.


% FIXME \section{Propietarios y permisos}


## Paquetes

Muchas distribuciones de GNU/Linux utilizan paquetes para distribuir sus programas. Un
paquete no es más que una colección de ficheros (normalmente comprimidos) estructurados
para ser colocados en rutas concretas dentro del sistema de ficheros cuando se instalan.

En Debian GNU/Linux o Ubuntu, estos paquetes son ficheros con extensión `.deb`.
Si descargas uno de estos ficheros directamente, puedes instalarlo con el comando `dpkg`:

```shell
david@amy:~$ ls
gedit_3.38.1-1_amd64.deb
david@amy:~$ sudo dpkg -i gedit_3.38.1-1_amd64.deb
(Leyendo la base de datos ... 497325 ficheros o directorios instalados actualmente.)
Preparando para desempaquetar gedit_3.38.1-1_amd64.deb ...
Desempaquetando gedit (3.38.1-1) sobre (3.38.1-1) ...
Configurando gedit (3.38.1-1) ...
```

Una carácteristica muy importante de estos paquetes es que tienen *dependencias*, es
decir, para que el programa que instalas pueda funcionar necesita que otros paquetes
concretos estén instalados previamente. Puedes ver las dependencias (y otra mucha información)
sobre un paquete con:

```shell
david@amy:~$ apt-cache show gedit
Package: gedit
Version: 3.38.1-1
Installed-Size: 1738
Maintainer: Debian GNOME Maintainers <pkg-gnome-maintainers@lists.alioth.debian.org>
Architecture: amd64
Depends: gedit-common (<< 3.39), gedit-common (>= 3.38), gir1.2-glib-2.0, gir1.2-gtk-3.0
(>= 3.22), gir1.2-gtksource-4, gir1.2-pango-1.0, gir1.2-peas-1.0,
gsettings-desktop-schemas, iso-codes, python3-gi (>= 3.0), python3-gi-cairo (>= 3.0),
[...]
```

Como se puede ver, para muchos de ellos se indica que deben corresponder a cierta versión.
En ese ejemplo, puedes ver que se requiere una versión del paquete `python3-gi`
que sea mayor o igual a la 3.0.

Obviamente encontrar, descargar e instalar manualmente (con `dpkg`) todos esos paquetes (y
sus respectivas dependencias) es una tarea terriblemente pesada. Afortunadamente hay otro
modo de hacerlo.

El programa `apt` (o `apt-get`) puede determinar automática y recursivamente las
dependencias de un paquete, descargarlos e instalarlos en el orden correcto.

```shell
david@amy:~$ sudo apt install gedit
Leyendo lista de paquetes... Hecho
Creando árbol de dependencias... Hecho
Leyendo la información de estado... Hecho
Se instalarán los siguientes paquetes adicionales:
  gedit-common gir1.2-gtksource-4 libamtk-5-0 libamtk-5-common libtepl-5-0
Paquetes sugeridos:
  gedit-plugins
Se instalarán los siguientes paquetes NUEVOS:
  gedit gedit-common gir1.2-gtksource-4 libamtk-5-0 libamtk-5-common libtepl-5-0
0 actualizados, 6 nuevos se instalarán, 0 para eliminar y 172 no actualizados.
Se necesita descargar 59,0 kB/2.146 kB de archivos.
Se utilizarán 15,5 MB de espacio de disco adicional después de esta operación.
¿Desea continuar? [S/n]
```


## Repositorios de paquetes

La pregunta obvia es «¿Cómo sabe `apt` de dónde descargar todos esos paquetes?». Las
distribuciones proporcionan servidores (normalmente web o FTP) dónde dejan publicamente accesibles
los ficheros `.deb`. Por ejemplo, en el caso de Debian en
https://ftp.debian.org/debian/, del cual existen cientos de «copias espejo»
(*mirrors*), normalmente una por país, como https://ftp.es.debian.org/debian/.

En estos repositorios, los paquetes se organizan en «releases» (o versiones) [^9] . En el
caso de Debian, estas «releases» tienen un número de versión y un nombre asociado. Por
ejemplo, Debian 10 lleva el nombre «buster».

[^9]: https://www.debian.org/releases/

De este modo, si queremos instalar (o actualizar) a una *release*, debemos indicárselo a
`apt` mediante el fichero `/etc/apt/sources.list`:

```text
deb http://deb.debian.org/debian/ buster main contrib non-free
```

Esta línea en concreto dice que queremos poder instalar paquetes oficiales mantenidos por
Debian (*main*), contribuciones de terceros (*contrib*) y software con licencias no
libres (*non-free*).

Este fichero puede contener muchos repositorios, y también se pueden crear otros ficheros
con extensión `.list` dentro del directorio `/etc/apt/sources.list.d` que tienen el
mismo tipo de contenido.

Para saber qué paquetes (y versiones) están disponibles en los repositorios configurados,
`apt` debe descargar una especie de índices que se encuentran allí mismo. Para eso
debemos ejecutar:

```shell
david@amy:~$ sudo apt update
```

Esto debemos hacerlo regularmente [^10] porque el contenido de los repositorios cambia
y regulamente se añaden nuevos paquetes o versiones.

[^10]: De hecho las distribuciones actuales tienen sistemas que lo hacen de forma
    autómática.

En concreto en Debian hay siempre tres versiones activas:

stable
: Es la última versión publicada y su contenido no debería cambiar. Esta
corresponde con «buster» en el momento de escribir este documento.

testing
: Contiene los paquetes que se están preparando para una futura versión
estable y por tanto, cambia continuamente. En este momento se denomina «bullseye» y ese
será el nombre que tendrá la siguiente versión estable.

unstable
: Que tiene paquetes recién incorporados, experimentales o que tienen algunos
problemas importantes para ser incluidos en una futura versión. Esta versión siempre se
llama «sid».

Por cuestiones de seguridad es importante que se puedan actualizar paquetes en los que se
han descubierto vulnerabilidades o problemas graves, incluso aunque correspondan a una
versión estable. Por eso, es conveniente tener los siguientes repositorios en el fichero
`/etc/apt/sources.list`:

```text
deb http://security.debian.org/debian-security buster/updates main
deb http://deb.debian.org/debian/ buster-updates main
```

Todo esto significa que los repositorios configurados determinan qué paquetes (y qué
versiones) podemos instalar. Si queremos tener un sistema completamente actualizado, es
decir, con las ultimas versiones de todos los paquetes disponibles en esos repositorios
podemos ejecutar:

```shell
david@amy:~$ sudo apt upgrade
```

Si incorporamos repositorios de versiones nuevas y queremos actualizarnos a ellos,
tendremos que ejecutar:

```shell
david@amy:~$ sudo apt dist-upgrade
```

Esto hará que la versión de nuestro sistema operativo corresponda con la versión del
repositorio más actual. Eso lo podemos ver con:

```shell
david@amy:~$ lsb_release -a
No LSB modules are available.
Distributor ID:	Debian
Description:	Debian GNU/Linux bullseye/sid
Release:	10.8
Codename:	buster
```

También podemos saber qué versiones de un determinado paquete tenemos disponibles en los
repositorios configurados y en cuál de ellos están:

```shell
david@amy:~$ apt-cache policy openconnect
openconnect:
  Instalados: (ninguno)
  Candidato:  8.02-1+deb10u1
  Tabla de versión:
     8.10-2+b1 650
        650 http://deb.debian.org/debian testing/main amd64 Packages
        600 http://deb.debian.org/debian sid/main amd64 Packages
     8.02-1+deb10u1 700
        700 http://deb.debian.org/debian buster/main amd64 Packages
        700 http://security.debian.org/debian-security buster/updates/main amd64 Packages
```

Esto significa, que no podremos instalar versiones de los paquetes que no estén en los
repositorios configurados. La solución puede ser añadir un repositorio más reciente que sí
lo contenga, pero teniendo cuidado porque las nuevas versiones de las dependencias podrían
afectar a otros paquetes.


% XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
# Catálogo de comandos

A continuación se introducen brevemente algunos de los programas más comunes y útiles
cuando se trabaja con la shell.


## Ficheros y directorios
% \label{sec:ficheros}

`cp` --- *copy*
: Dados un nombre de fichero existente y un directorio o nombre de fichero, copia el
  primero en el segundo. Si el fichero destino existe, lo sobrescribe.

`cut`
: Escribe en su salida partes de las líneas de entrada según sus opciones:

  ```shell
  david@amy:~$ date
  Sun Aug 26 12:47:35 CEST 2012
  david@amy:~$ date | cut --delimiter=" " --fields=2
  Aug
  ```

`diff`
: Muestra las diferencias entre dos ficheros.

`find`
: Encuentra ficheros a partir de su nombre.

`head`
: Escribe a su salida los primeros bytes o líneas de su entrada o del fichero indicado
  como argumento.

  ```shell
  david@amy:~$ head --lines=3 /etc/passwd
  root:x:0:0:root:/root:/bin/bash
  daemon:x:1:1:daemon:/usr/sbin:/bin/sh
  bin:x:2:2:bin:/bin:/bin/sh
  ```

`ln` --- *link*
: Crea enlaces a otros ficheros o directorios.

`md5sum`
: Calcula (o comprueba) la suma MD5 del fichero indicado (o de su entrada estándar).

`mkdir` --- *make dir*
: Crea un directorio.

`mkfifo`
: Crea una tubería con nombre ligado al sistema de ficheros.

`mv` --- *move*
: Es equivalente a `cp` pero borra el fichero original.

`nl` --- *number lines*
: Lee líneas de un fichero y las escribe a su salida precedidas del número de línea.

`pwd` --- *print working directory*
: Indica el nombre del directorio actual.

`rm` --- *remove*
: Elimina ficheros.

`rmdir` --- *remove dir*
: Borra directorios vacíos.

`split`
: Divide un fichero en trozos del tamaño indicado.

`stat`
: Muestra información detallada de ficheros.

`tac` --- *reverse cat*
: Escribe a su salida líneas de su entrada en orden inverso.

`tail`
: Escribe a su salida los últimos bytes o líneas de su entrada o del
  fichero indicado como argumento. Con la opción `-f/--follow` monitoriza el
  fichero mostrando el nuevo contenido tan pronto como se añada. Muy útil para hacer el
  seguimiento de un fichero de log.

`tee`
: Crea una «te». Lee de su entrada estándar y lo escribe al mismo tiempo a su salida
estándar y al fichero indicado.

`test`
: Realiza comprobaciones lógicas sobre ficheros, cadenas de texto y datos numéricos. Se
  utiliza habitualmente como condición en estructuras de control `if`, `while`, etc.

`touch`
: Cambia la fecha de un fichero (por defecto ahora). Si el fichero indicado no existe,
  crea uno vacío.

`tr` --- *translate*
: Lee líneas de su entrada y las escribe a su salida reemplazando *tokens* [^11] tal como
lo indiquen sus opciones.

[^11]: Un *token* es cualquier combinación de caracteres que cumpla una expresión regular
    concreta.

`uniq`
: Lee líneas de su entrada y las escribe a su salida, pero omitiendo líneas consecutivas
idénticas.

`wc` --- *word count*
: Cuenta letras, palabras y líneas del fichero indicado (o de su entrada estándar) y
  escribe los totales en su salida.

`yes`
: Escribe «y» y un salto de línea continuamente a su salida. Se utiliza para contestar
  afirmativamente a cualquier pregunta que haga un programa por línea de comando:

  ```shell
  david@amy:~$ touch kk
  david@amy:~$ yes | rm --interactive --verbose kk
  rm: remove regular empty file `kk'? removed `kk'
  ```

## \subsection{Sistema}
%====================================================================
% \label{sec:sistema}

`dd`
: Copia bloques de bytes en dispositivos (ficheros o discos).

`df` --- *disk free*
: Muestra información sobre el uso de los sistemas de ficheros montados en el computador.

`du` --- *disk usage*
: Calcula el espacio de disco utilizado por ficheros y directorios.

`fdisk`
: Muestra y manipula tablas de particiones.

`mount`
: Monta dispositivos de almacenamiento de cualquier tipo sobre el sistema de ficheros.

`uname` --- *unix name*
: Muestra información del sistema:

  ```shell
  david@amy:~$ uname -a
  Linux amy 5.8.0-3-amd64 #1 SMP Debian 5.8.14-1 (2020-10-10) x86_64 GNU/Linux
  ```

`sync`
: Escribe a disco inmediatamente las operaciones pendientes sobre ficheros.


## Procesos
% ===================================================================
% \label{sec:procesos-more}

`nice`
: Ejecuta un programa fijando un nivel de prioridad.

`nohup`
: Ejecuta un comando ignorando las señales para su finalización (SIGHUP). Permite que un
  proceso creado por una shell sobreviva a la propia shell.

`sleep`
: Realiza una pausa del número de segundos indicados.

`true` y `false`
: Simplemente retornan 0 y 1, los valores que corresponden a una ejecución correcta e
  incorrecta respectivamente.

`top`
: Muestra una lista actualizada de los procesos ordenada por el consumo de CPU.


## Usuarios y permisos
%========================================================
% \label{sec:usuarios}

`chmod` --- *change mode*
: Cambia los permisos de lectura, escritura y ejecución de un fichero o directorio.

`chown` --- *change owner*
: Cambia el propietario (usuario y grupo) de un fichero.

`chgrp` --- *change group
: Cambia el grupo propietario de un fichero.

`groups`
: Muestra los nombres de los grupos a los que pertenece el usuario.

`id`
: Muestra los identificadores del usuario y los grupos a los que pertenece.

`sudo` --- *superuser do*
: Permite ejecutar un comando con los privilegios de otro usuario, por defecto el
administrador.

`who`
: Muestra los usuarios conectados junto con los terminales que utilizan y la hora de la
  conexión (*login*).

`whoami`
: Muestra el nombre del usuario conectado.


## Servicios
% ==================================================================
% \label{sec:services}

Los servicios son programas en segundo plano (que arrancan normalmente el iniciar el
sistema) que se encuentran bajo el control del SO que no se ejecutan directamente por
los usuarios y se encargan de tareas específicas: firewall, sonido, bluetooth, etc.,
servidores: web, ssh, etc. u otras tareas de gestión: registro de eventos del sistema,
montaje de dispositivos de almacenamiento, etc.

Actualmente muchas distribuciones GNU/Linux usan `systemd`, pero aquí vamos a ver
los comandos `legacy` que son compatibles.

`sudo service ---status-all`
: Muestra el estado de todos los servicios instalados.

`sudo service <service>\ status`
: Muestra el estado del servicio indicado.

`sudo service <service>\ stop/start/restart`
: Para, arranca o reinicia el servicio indicado.



*[SO]:    Sistema Operativo
*[POSIX]: Portable Operating System Interface for uniX


% `seq` --- *sequence*
% : Escribe un rango de enteros. Puede usarse como variable de control de un bucle `for`.