# chef_nginx_simple
Installs Nginx via repositories and starts the service.
Recipes / templates include a very basic way for configuring a webserver
or a webproxy.

## Recipes

  `server` - This will add a repository, install Nginx and enable the service  
  `proxy` - This recipe includes a basic way for configuring a web proxy

## Attributes

## Requirements

Add certificates like described in the [certificate cookbook](https://supermarket.chef.io/cookbooks/certificate).
For test and dev environments a wildcard certificate should do.


## License and Author

License: [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html)

Author: [Michael Haas](https://github.com/hmix)

