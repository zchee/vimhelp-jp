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


## List of plugins (2016-01-18 05:47:42 JST)
| Commit Hash                              | Repository                                    |
|------------------------------------------|-----------------------------------------------|
| 0fbdcbe8a7d1fbf4e59e5e8bf16b39f54089cdff | Shougo/deoplete.nvim (heads/master)           |
| 0d5a0e28a8cd1761c06498df134e233dae9fdc64 | Shougo/neco vim (heads/master)                |
| 0433510865a53b3750b53b7859aaf777b7ef2b10 | Shougo/neobundle.vim (heads/master)           |
| 33ef6422753f469bdebfa23184b02a05b348cb33 | Shougo/neocomplete.vim (heads/master)         |
| a444952e7bfc1443815dde9ab72a2e2b843e5d20 | Shougo/neosnippet-snippets.vim (heads/master) |
| 76c6bbc54eebc9c351bf5eb311f4c2602a1c825f | Shougo/neosnippet.vim (heads/master)          |
| 766d921e859eb54a7ac7c45c4052df7121ea6347 | Shougo/unite-outline.vim (heads/master)       |
| 0022b2294ca0b8b434db07187b7f0a4781d01399 | Shougo/unite.vim (heads/master)               |
| 0e6f615df4fb53783cc35d6aa07b6f9937a7583e | Shougo/vimfiler.vim (heads/master)            |
| aa075b9b56839e1adb08421d2e9837f90e59acad | Shougo/vimproc.vim (heads/master)             |
| a5b3d99ba84e76cf94195c37ab762aef5f7b6e25 | Shougo/vimshell.vim (heads/master)            |
| 0fb2c58353ee041500eb67fb5bde2377bf486417 | ctrlpvim/ctrlp.vim (heads/master)             |
| 625c568b1249db8c5f1b06a1f9371c06ba2d08b5 | davidhalter/jedi-vim (heads/master)           |
| cb3d593c48d7d3aef829b5aff49ddade24417a9f | h1mesuke/vim-alignta (heads/master)           |
| 1345a556a321a092716e149d4765a5e17c0e9f0f | kana/vim-operator replace (0.0.5)             |
| c3dfd41c1ed516b4b901c97562e644de62c367aa | kana/vim-operator user (0.1.0)                |
| 947d768785e2d1e7484c5d729cd0e5a8e53e9584 | kana/vim-textobj fold (0.1.4)                 |
| deb76867c302f933c8f21753806cbf2d8461b548 | kana/vim-textobj indent (0.0.6)               |
| 686aa837e3aa649b16572d5d55eb2d8c7fc6c78a | kana/vim-textobj lastpat (0.0.2)              |
| a3054162c09bcf732624f43ddacbd85dad09713b | kana/vim-textobj user (0.7.1)                 |
| e6c52907ad7e909fde7d4b16cf8f9cdce61731c8 | lambdalisue/vim-gista (heads/master)          |
| 03fc1123a4ac3a3b9d92d43edfadcb66eaa4a2f9 | lambdalisue/vim-gita (heads/master)           |
| dddbf9c5fa061cb03d6b6240ac6610b68b9304f5 | neovim (nightly 4773 gdddbf9c)                |
| 239d9edf6d2d250b4be2511a15fcec077e10314f | t9md/vim-quickhl (heads/master)               |
| da5328d0aec495e4dc25232fd769a8a2e56d8f7d | thinca/vim-quickrun (heads/master)            |
| 007b0ac409100cf2b83eb7dace5c8235e3737fef | thinca/vim-ref (heads/master)                 |
| 79eb95aa4dd24a818799f770c346cd995f06dd10 | thinca/vim-themis (heads/master)              |
| 8312733b08330191358af14832d9959f19739eda | tyru/open-browser github.vim (heads/master)   |
| fcbdcc938513a30ab8f4271ee99149ac3ce5b9bf | tyru/open-browser.vim (heads/master)          |
| 9bbf63dbf8286fadc0cd6b3428010abb67b1b64d | vim (v7.4.1054 57 g9bbf63d)                   |
| cca38217809f61698a24420493fb4cfd7d25189c | vim jp/vimdoc-ja (heads/master)               |
| 65c9afb0799cb950cbaf9258aefc6c3ad700a98f | vim jp/vital.vim (heads/master)               |



## License
Conform to original repository.


## Author
- osyo-manga
- [zchee](http://github.com/zchee)
  - mail: k at zchee.io
  - twitter: [_zchee_](http://twitter.com/_zchee_)
