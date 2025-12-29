# Raylib-Gizmo Bindings for Jai

Consult the [original repository](https://github.com/cloudofoz/raylib-gizmo) 
for more information.  


**Note:** I only used it on Linux. If it doesn't work on Windows or Mac, send me 
a patch, or more information what exactly did not work.


## Note Copyright / Licenses
The MIT license only affects code written in `raygizmo/generate.jai` and `examples/*.jai`.  

Code written in `src/raylib-gizmo` and `third-party/raylib-jai` have different licenses, 
which you can consult in the submodules.  

Assets in `examples/resources` are copyright by Claudio Z. (@cloudofoz)


## Build

### raygizmo
This repository contains submodules which must be initialized after cloning it:  
```
git submodule update --init --recursive
```

It clones [raylib-gizmo](https://github.com/cloudofoz/raylib-gizmo) and 
[raylib-jai](https://github.com/ahmedqarmout2/raylib-jai).  

(To generate the bindings, you only need `raylib-gizmo`. `raylib-jai` is only needed 
for building the examples.)

Generate the bindings with:  

```
cd raygizmo
jai generate.jai
```

Then you can add/symlink the `raygizmo` directory to your projects `modules` directory.  


#### Note on static libs
Currently, it only builds a static library.


### Examples
You can build the examples via:  

```
cd examples
jai build_examples.jai
```


## Contribution
Send me a patch via mail to `dev [at] ptrace [dot] dev`.


## Dev

### Sub Modules
Init submodules
```bash
git submodule update --init --recursive
```

#### Update Submodule
```bash
cd third-party/<module>
git pull origin main
cd ../..
git add third-party/<module>
git commit -m "Updated <module> submodule"
```

#### Add Submodule
```bash
git submodule add <repository-url> third-party/<module>
git submodule update --init --recursive
git add third-party/<module>
git commit -m "Added <module> submodule"
```

