# ColorScheme2CSS

### Colo2CSS Converting color schemes of Vim to CSS files


Оговорка по тексту:
This is a machine translation of the Яandex service. I apologize for possible mistakes.
Для тех, кто думает по‐русски (говорит и пишет) ниже по тексту есть описание.


#### Table of contents

#### 1. Overview of the plugin
#### 2. Installing the plugin
#### 3. Using the plugin


Converting color schemes of the program Vim editor into ready-made CSS files.


===============================================================================
#### 1. Overview of the plugin

This plugin is designed to convert the current color scheme of the program Vim
editor into a ready-made Cascading Style Sheets (CSS) file. The CSS files
prepared by this plugin meet the requirements CSS Validation Service
(https://jigsaw.w3.org/css-validator/) and can be used to connect to an HTML or
XHTML document (web page).

The plugin can be used both for converting only the current color scheme, and
for batch processing of several files of color schemes of the Vim editor.

When converting a color scheme, you can set the desired background — dark or
light. It is also possible to specify the directory where the finished CSS files
will be written.

This plugin requires a program Vim version 8.2 or newer to work. To convert
color schemes, a variant of the program with support for a graphical user
interface (GUI) is used.

===============================================================================
#### 2. Installing the plugin

Before using this plugin, it is required to place the files supplied in its
package in the appropriate directories. The following files are included in the
package of this module:

colo2css.vim — is the main file of the plugin. Must be placed in the "autoload"
	       subdirectory of one of the directories specified in the value of
	       the 'runtimepath' parameter.
LnchC2C.vim  — file designed to run the main module file. Must be placed in the
	       "plugin" subdirectory of one of the directories specified in
	       the value of the 'runtimepath' parameter.
colo2css.txt - documentation file in English for this module. It should be
	       placed in the "doc" subdirectory.
colo2css.rux - the documentation file in Russian for this module. Must be
	       placed in the "doc" subdirectory.

If this plugin is received as a ready-made package colo2css.vba.zip, then the
installation of the specified files will be performed automatically. For more
information about using installation packages, see the section pi_vimball and
packages in on-line documentation of programm Vim.

If you install this plugin manually yourself, place the above files in the
appropriate directories, and restart the Vim program.

==============================================================================
#### 3. Using the plugin

After installing this plugin as described in the previous paragraph, the module
is ready for use. To run it, you need to type the command in the command line of
the Vim editor

>
	TOcss

After pressing the <ENTER> key, a CSS file for the current color scheme will be
created in the "Colo2CSS" subdirectory of the user's home directory.

To use this plugin in extended mode, you must specify the arguments supported
by this command. The command arguments are separated by a space.

Command arguments:

	:TOcss [[ALL | list_files] [dark | light] [outdir]] ~

where
 ALL		    Convert all color scheme files located in the "color"
		    subdirectory and located in the directories specified in the
		    'runtimepath' and 'packpath' parameter.
 list_files	    Is a list of color scheme files that you want to convert
		    to CSS files. If more than one file is specified, the files
		    are separated by a comma without spaces. Commas and spaces
		    are not allowed in the file names.
 dark or light	    Background used for color schemes when they are loaded into
		    the Vim editor and then converted.
 outdir		    Directory for ready-made CSS files. Set as an absolute
		    route. The directory must exist and be writable. By default,
		    the automatically created "Colo2CSS" subdirectory in the
		    user's directory is used.

Examples:

>
	TOcss light

The current color scheme will be converted using a light background. The result
will be saved to the ~/Colo2CSS directory (if this directory is missing, it will
be created automatically in the user's home directory).

>
	TOcss ALL d:\project\myhomepage\css

All color scheme files will be converted, and the finished CSS files will be
saved to the "css" directory located along route d:\project\myhomepage. The ALL
argument is specified only in uppercase letters. The directory must already
exist and be writable. If this directory does not exist, the result will be
saved in the directory C:\Users\<username>\Colo2CSS.

>
	TOcss darkblue.vim,mustang,PaperColor.vim,desert dark e:\colorscheme

The conversion of the specified files with the dark background enabled will be
performed, and the result will be saved in "e:\colorscheme". The names of the
color scheme files can be specified with or without the ".vim" extension. Files
are separated from each other by a comma, spaces and commas in the file names
are not allowed. There should be no space between the file name and the comma
symbol.


# ColorScheme2CSS

### Colo2CSS Преобразование цветовых схем программы Vim в файлы CSS


Disclaimer on the text:
The English text is located above the text


#### Содержание

#### 1. Обзор подключаемого модуля
#### 2. Установка подключаемого модуля
#### 3. Использование подключаемого модуля


Преобразования цветовых схем программы «Редактор Vim» в готовые файлы CSS.


==============================================================================
#### 1. Обзор подключаемого модуля

Данный подключаемый модуль предназначен для преобразования текущей цветовой
схемы программы «Редактор Vim» в готовый файл «каскадной таблицы стилей»
(Cascading Style Sheets, CSS). Файлы CSS, подготовленные этим подключаемым
модулем, соответствуют требованиям CSS Validation Service
(https://jigsaw.w3.org/css-validator/) и могут быть использованы для подключения
к документу (веб‐странице) HTML или XHTML. 

Подключаемый модуль может быть использован как для преобразования только текущей
цветовой схемы, так и для пакетной обработки нескольких файлов цветовых схем
редактора Vim.

При конвертации цветовой схемы можно задать требуемый фон — тёмный или светлый
(dark or light). Также возможно указать каталог, куда будут записаны готовые
файлы CSS.

Для работы этого подключаемого модуля требуется программа Vim версии 8.2 или
старше. Для преобразования цветовых схем используется вариант программы с
поддержкой графического интерфейса пользователя (ГИП, graphical user interface,
GUI).

==============================================================================
#### 2. Установка подключаемого модуля

Перед началом использования данного подключаемого модуля требуется разместить
поставляемые в его комплекте файлы в соответствующие каталоги. В комплект
поставки этого модуля входят следующие файлы:

colo2css.vim — основной файл подключаемого модуля. Должен быть размещён в
	       подкаталоге «autoload» одного из каталогов, указанных в значении
	       параметра 'runtimepath';
LnchC2C.vim  — файл, предназначенный для запуска основного файла модуля. Должен
	       быть размещён в подкаталоге «plugin» одного из каталогов,
	       указанных в значении параметра 'runtimepath';
colo2css.txt — файл документации на английском языке к этому модулю. Должен быть
	       размещён в подкаталоге «doc».
colo2css.rux — файл документации на русском языке к этому модулю. Должен быть
	       размещён в подкаталоге «doc».

Если этот подключаемый модуль получен в виде готового пакета colo2css.vba.zip,
то установка указанных файлов будет выполнена автоматически. Подробнее об
использовании установочных пакетов смотрите раздел pi_vimball и packages
встроенной документации программы Vim.

При самостоятельной установке этого подключаемого модуля вручную, разместите
указанные выше файлы в соответствующие каталоги, и перезапустите программу Vim.

==============================================================================
#### 3. Использование подключаемого модуля

После установки этого подключаемого модуля как описано в предыдущем параграфе,
модуль готов к использованию. Для его запуска необходимо в командной строке
редактора Vim набрать команду

>
	TOcss

После нажатия клавиши <ENTER> будет создан файл CSS для текущей цветовой схемы в
подкаталоге «Colo2CSS» домашнего каталога пользователя.

Чтобы использовать этот подключаемый модуль в расширенном режиме, необходимо
указать поддерживаемые этой командой аргументы. Аргументы команды разделяются
пробелом.

Аргументы команды:

	:TOcss [[ALL | list_files] [dark | light] [outdir]] ~
где
 ALL		    Преобразовать все файлы цветовых схем, находящиеся в
		    подкаталоге «color» и расположенном в каталогах, указанных
		    в параметре 'runtimepath' и 'packpath'.
 list_files	    Перечень файлов цветовых схем, которые требуется
		    преобразовать в файлы CSS. Если указано более одного файла,
		    то файлы разделяются символом запятой без пробелов. В
		    наименовании файлов не допускаются запятые и пробелы.
 dark или light	    Фон, применяемый для цветовых схем при их загрузке в
		    редактор Vim и последующей конвертации.
 outdir		    Каталог для готовых файлов CSS. Задаётся как абсолютный
		    маршрут. Каталог должен существовать и быть доступен для
		    записи. По умолчанию используется автоматически создаваемый
		    подкаталог «Colo2CSS» в каталоге пользователя.

Примеры:

>
	TOcss light

Будет выполнено преобразование текущей цветовой схемы с использованием светлого
фона. Результат будет сохранён в каталог ~/Colo2CSS (если этот каталог
отсутствует, то он будет создан автоматически в домашнем каталоге пользователя).

>
	TOcss ALL d:\project\myhomepage\css

Будет выполнено преобразование всех файлов цветовых схем, а готовые файлы CSS
сохранены в каталог «css», расположенный по маршруту d:\project\myhomepage.
Аргумент ALL указывается только прописными буквами. Каталог должен уже
существовать и быть доступен для записи. Если этого каталога нет, то результат
будет сохранён в каталоге C:\Users\<username>\Colo2CSS.

>
	TOcss darkblue.vim,mustang,PaperColor.vim,desert dark e:\colorscheme

Будет выполнено преобразование указанных файлов с включённым тёмным фоном, и
результат сохранён в «e:\colorscheme». Наименования файлов цветовых схем можно
указывать как с расширением «.vim», так и без него. Файлы отделяются друг от
друга символом запятой, пробелы и запятые в наименовании файлов не допустимы.
Между наименованием файла и символом запятой не должно быть пробела.

