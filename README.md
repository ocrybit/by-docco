By-Docco
=============

A Bystander plugin to auto-generate Docco documents after file change events.  
Note it only works with CoffeeScript for now, and has to be used in conjunction with [by-coffeescript](http://tomoio.github.com/by-coffeescript/) plugin.

Installation
------------

To install **by-docco**,

    sudo npm install -g by-docco

Options
-------

> `doccoSources` : comma separated paths for docco sources  
> `doccoCSS` : the docco `css` option  
> `doccoOutput` : the docco `output` option  
> `doccoTemplate` : the docco `template` option

See the [github Docco repo](https://github.com/jashkenas/docco) for details on docco options.

#### Examples

Auto-generate docco documents from `src` directory into `docs` directory. Note `doccoOutput` defaults to `./docs`, so we don't need to set the option for output derectory here.

    // .bystander config file
	.....
	.....
      "plugins" : ["by-coffeescript", "by-docco"],
      "by" : {
        "docco" : {
          "doccoSources" : ["src/*.coffee"]
        }
      },
    .....
	.....

`doccoSources` will be resolved against the project root path.

Broadcasted Events for further hacks
------------------------

> `docco` : successfully generated docco documents.

See the [annotated source](docs/by-docco.html) for details.

Running Tests
-------------

Run tests with [mocha](http://mochajs.org/)

    make
	
License
-------
**By-Docco** is released under the **MIT License**. - see the [LICENSE](https://raw.github.com/tomoio/by-docco/master/LICENSE) file

