#lang scribble/manual

@(require "mb-tools.rkt" scribble/eval pollen/setup (for-label (except-in racket ...) pollen/setup))

@(define my-eval (make-base-eval))
@(my-eval `(require pollen pollen/file))


@title[#:tag "raco-pollen"]{Using @exec{raco pollen}}


Racket provides centralized command-line options through @exec{raco} (short for @exec{racket command}, see @other-doc['(lib "scribblings/raco/raco.scrbl")]). 

Once you install Pollen, you can access the following Pollen-specific commands through @racket[raco] using the subcommand @exec{raco pollen}.

@section{Making sure @exec{raco pollen} works}

Open a terminal window and type:

@terminal{
> raco pollen test}

If @exec{raco pollen} is installed correctly, you'll see:

@terminal{raco pollen is installed correctly}

But if you get:

@terminal{raco: Unrecognized command: pollen}

You'll need to fix the problem before proceeding, most likely by reinstalling Pollen (see @secref["Installation" #:doc '(lib "pollen/scribblings/pollen.scrbl")]).

If your error is like this:

@terminal{Unrecognized command: raco}

You have a deeper problem with your Racket installation (often a misconfiguration of @code{PATH}).

@section{@exec{raco pollen}}

Same as @exec{raco pollen help}.

@section{@exec{raco pollen help}}

Displays a list of available commands.


@section{@exec{raco pollen start}}

Start the project server from the current directory using the default port, which is the value of the parameter @racket[current-server-port] (by default, port @id[default-project-server-port]).

This command can be invoked with two optional arguments, and two optional switches.

@racket[raco pollen start _path] will start the project server from @racket[_path] rather than the current directory (making @racket[_path] its root directory).

@terminal{
> raco pollen start ~/path/to/project/}

@racket[raco pollen start _path _port] will start the project server in @racket[_path] using @racket[_port] rather than @racket[current-server-port]. This is useful if you want to have multiple project servers running simultaneously.

@terminal{
> raco pollen start ~/path/to/project/
> raco pollen start ~/path/to/project/scribblings 8088}

If you want to start in the current directory but with a different port, use @litchar{.} as the path:

@terminal{
> raco pollen start . 8088}

Adding the optional @exec{-l} or @exec{--launch} switch will open the main project dashboard in your web browser after the project server starts.

Adding the optional @exec{--local} switch will restrict the project server to responding to requests from localhost. (By default, the project server will respond to requests from any client.)


@section{@exec{raco pollen render}}

This command can be invoked two ways: in source mode or directory mode.

In both modes, the optional @exec{--dry-run} or @exec{-d} switch prints the paths that would be rendered by this command without actually doing so.


@bold{Source mode}: @racket[raco pollen render _source ...] will render only the source paths specified in @racket[_source ...]. Consistent with the usual command-line idiom, this can be a single path, a list of paths, or a pattern:

@terminal{
> raco pollen render foo.html.pm
> raco pollen render foo.html.pm bar.html.pm zam.css.pp
> raco pollen render *.html.pm}

Paths can also be specified as output rather than input paths, and the corresponding source paths will be discovered:

@terminal{
> raco pollen render foo.html
> raco pollen render foo.html bar.html zam.css}

The optional @exec{--target} or @exec{-t} switch specifies the render target for multi-output source files. If the target is omitted, the renderer will use whatever target appears first in @racket[(setup:poly-targets)].

@terminal{
> raco pollen render -t pdf foo.poly.pm}

See also @seclink["raco-pollen-render-poly"].

The optional @exec{--parallel} or @exec{-p} switch creates a set of parallel rendering jobs equal to the number of processing cores on the system. On a multi-core machine, this will usually make your rendering job finish faster. The order of rendering is not guaranteed, of course, so if your project depends on a certain order of rendering, don't use this option.

@terminal{
> raco pollen render -p foo.html bar.html zam.css
}

The alternative @exec{--jobs <count>} or @exec{-j <count>} switch does the same thing, but takes one argument that creates @racket[<count>] parallel jobs (which can be more or less than the number of processing cores).

@terminal{
> raco pollen render -j 4 foo.html bar.html zam.css
}

As a rule of thumb, parallel rendering works best if you do @exec{raco setup} first, which updates Pollen's disk caches:

@terminal{
> raco setup -p
> raco pollen render -p 
}


@italic{Warning}: In all cases, the newly rendered output file will overwrite any previous output file.


@bold{Directory mode}: @racket[raco pollen render _directory] renders all preprocessor source files and then all pagetree files found in the specified directory. If none of these files are found, a pagetree will be generated for the directory (which will include all source files) and then rendered. If the @racket[_directory] argument is omitted, the command defaults to the current directory.

In directory mode, this command can be invoked with two other optional arguments (in addition to the @exec{--target}, @exec{--parallel}, and  @exec{--jobs} switches mentioned above):

The @exec{--subdir} or @exec{-s} switch also renders subdirectories. @racket[current-project-root] remains fixed at the initial directory, just as it would be in the project server after invoking @racket[raco pollen start]. 

Certain subdirectories are automatically ignored, including Racket and Pollen private directories (like @tt{compiled}) and source-control directories (like @tt{.git} and @tt{.svn}). You can omit other paths by overriding @racket[default-omitted-path?]. You can override these omissions — that is, force a path to be included in a recursive render — by overriding @racket[default-extra-path?].

The @exec{--recursive} or @exec{-r} switch renders subdirectories recursively. Meaning, each subdirectory is treated like an independent subproject, and @racket[current-project-root] moves around accordingly. In many projects, there won't be any difference between the @exec{-s} and @exec{-r} switches. But if the difference matters in your project, you have them both.




@section{@exec{raco pollen publish}}

Make a copy of the project directory on the desktop, but without any source files or other Pollen-related files. (This function is pretty lame, and I invite suggestions for improvement.)

@racket[raco pollen publish _project-dir] will publish the project in @racket[_project-dir] onto the desktop in a folder called @racket[publish]. @bold{Warning}: if @racket[publish] already exists on the desktop, it will be overwritten.

@racket[raco pollen publish _project-dir _dest-dir] will publish the project in @racket[_project-dir] to @racket[_dest-dir] rather than the desktop. @bold{Warning}: if @racket[_dest-dir] already exists, it will be overwritten by the newly published directory.

If you're already in your project directory and want to publish somewhere other than the desktop, use @racket[raco pollen publish _. _dest-dir].

By default, this command will automatically overwrite the destination directory. Adding the optional @exec{-c} or @exec{--confirm} switch will ask for confirmation if the destination already exists.

You can determine the default publishing destination for a project by overriding @racket[default-publish-directory].

Certain files and directories are automatically omitted from the published directory, including Racket and Pollen sources, Pollen caches, and source-control directories (like @tt{.git} and @tt{.svn}). You can omit other files by overriding @racket[default-omitted-path?]. You can override these omissions — that is, force a path to be published — by overriding @racket[default-extra-path?].


@section{@exec{raco pollen setup}}

Finds Pollen source files in the current directory, compiles them, and loads the results into the @seclink["Cache" #:doc '(lib "pollen/scribblings/pollen.scrbl")]. This will give you the snappiest performance during an interactive session with the project server. 

Can also be invoked as @racket[raco pollen setup _directory], which will set up the files in @racket[_directory].

The optional @exec{--parallel} or @exec{-p} switch creates a set of parallel setup jobs equal to the number of processing cores on the system. On a multi-core machine, this will usually make your setup finish faster.

@terminal{
> raco pollen setup -p
}

The alternative @exec{--jobs <count>} or @exec{-j <count>} switch does the same thing, but takes one argument that creates @racket[<count>] parallel jobs (which can be more or less than the number of processing cores).

@terminal{
> raco pollen setup -j 4
}

The optional @exec{--dry-run} or @exec{-d} switch prints the paths that would be compiled by this command without actually doing so.


@section{@exec{raco pollen reset}}

Resets Pollen's @seclink["Cache" #:doc '(lib "pollen/scribblings/pollen.scrbl")] by deleting the cache directories, including @tt{compiled} directories created by Racket. Use this when you need a fresh start in life.

Can also be invoked as @racket[raco pollen reset _directory], which will reset a different project @racket[_directory].

@section{@exec{raco pollen version}}

Would you believe this prints the Pollen version number.

@section{The @exec{POLLEN} environment variable}

Pollen recognizes a @exec{POLLEN} environment variable on the command line, which can be used to pass through any value you like. This value can be used within your project files with @racket[(getenv "POLLEN")], which if not set, returns @racket[#f]. Take this file, for instance:

@fileblock["test.txt.pp" @codeblock{
#lang pollen
Result is ◊or[(getenv "POLLEN")]{nothing}
}]

The @exec{POLLEN} environment variable will change how it's rendered:

@terminal{
> raco pollen render test.txt ; cat test.txt
rendering test.txt.pp
rendering: /test.txt.pp as /test.txt
Result is nothing

> POLLEN=DEBUG raco pollen render test.txt ; cat test.txt
rendering test.txt.pp
rendering: /test.txt.pp as /test.txt
Result is DEBUG

}


