# dotfiles
This is my go-to repository for setting up & managing my development 
environment.

## How to install the repository
This repository contains a script `install_dotfiles.sh` inside of 
`.custom/bash/install_dotfiles.sh`. For ease of setup, all you need to run is:

```bash
curl -Lks https://github.com/vmarcella/dotfiles/blob/master/.custom/bash/install_dotfiles.sh | /bin/bash
```

This will fetch the install script as a string and feed it into bash. This will 
only fetch configuration files and all other repository content, but will not 
install anything for your machine. You will most likely need to restart your 
shell to see the effects of these changes. This script will also backup all 
of the current dotfiles to: `~/.dotfiles-backup` in the event that you'd like
to restore your environment.

## How to install the complete environment
I currently do a lot of work on Ubuntu & Manjaro and thus only test my dev 
environment on those platforms. For these two environments, I've made two 
scripts that will install all of my environment from the ground up. Assuming 
that you have this repository installed, you can simply run the following 
scripts below.

### Manjaro
```bash
./.custom/manjaro/install.sh
```

### Ubuntu
```bash
./.custom/ubuntu/install.sh
```
Tested on: 
  * Ubuntu 18.04 
  * Ubuntu 20.04
  * Ubuntu 21.04
