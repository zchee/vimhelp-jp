# vimhelp-jp
[![Build Status](https://travis-ci.org/zchee/vimhelp-jp.svg?branch=master)](https://travis-ci.org/zchee/vimhelp-jp)

A bot for vim help written ruby.  
Original repository is [osyo-manga/vimhelp-jp](https://github.com/osyo-manga/vimhelp-jp)

Support language
- Japanense
- English


## Requirements
- docker
- docker-compose

Install plugin repository managed by `git submodule` and `docker volume`  
See https://github.com/zchee/vimhelp-jp-submodules

## Build and run
Build use docker and docker-compose

```bash
$ docker-compose build
$ docker-compoes up -d
```

### Optional
- [h2o-proxy](https://github.com/zchee/h2o-proxy)
  - Edit of https://github.com/zchee/vimhelp-jp/blob/master/docker-compose.yml#L5-7 in [docker-compose.yml](./docker-compose.yml)
  - `docker run -d --name h2o-proxy -p 80:80 --privileged --restart unless-stopped -v /var/run/docker.sock:/tmp/docker.sock zchee/h2o-proxy`
  - Build and run [Dockerfile](./Dockerfile)
  - Finish. Will be autoreverse proxy to `VIRTUAL_HOST`


## License
Conform to original repository.


## Author
- osyo-manga
- [zchee](http://github.com/zchee)
  - mail: k at zchee.io
  - twitter: [`_zchee_`](http://twitter.com/_zchee_)
