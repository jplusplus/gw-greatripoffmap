# Global Witness: Anon Shell

[Download](https://github.com/jplusplus/gw-greatripoffmap/archive/gh-pages.zip) • [Fork](https://github.com/jplusplus/gw-greatripoffmap) • [License](https://github.com/jplusplus/gw-greatripoffmap/blob/master/LICENSE)

## Installation

Install `node` and `npm` then run:

```bash
make install
```

You can now start serving static files with Grunt!

```bash
make run
```

**Note: the first time you launch the application you have to prefetch the data from the API. See instructions bellow.**

## Prefetch data from [Detective.io](https://detective.io)

Firstly, set environement variables containing Detective.io credidentials:

```bash
# You can put this into .env file
DIO_USER=bill
DIO_PASS=strongpassword
```

Then launch this command:

```bash
make prefetch
```

## Deploy on production server

Simply run this command:

```bash
make deploy
```

## Technical stack

This small application uses the following tools and opensource projects:

* [Detective.io](https://detective.io) API
* [AngularJS](https://angularjs.org/) - Javascript Framework
* [Yeoman: Angular Generator](https://github.com/yeoman/generator-angular) - Static app generator
* [Leaflet: Angular Directive](http://tombatossals.github.io/angular-leaflet-directive/) - Leaflet Map with Angular
* [UI Router](https://github.com/angular-ui/ui-router/) - Application states manager
* [LoDash](http://lodash.com/) - Utility library
* [Restangular](https://github.com/mgonto/restangular) - RestAPI with Angular
* [Bootwtrap](http://getbootstrap.com/) - HTML and CSS framework
* [Less](http://lesscss.org/) - CSS pre-processor
* [CoffeeScript](http://coffeescript.org/)
