# ez-docker

A lazy way to use Docker.

## Installation

It is recommended that you review the code before executing it.

### Method 1: Creating an alias

Add this line to your shell `.*rc` configuration file.
e.g: add this to your `.bashrc`, if your shell is `bash`:

```bash
alias ez-docker="$(curl -fsSL https://github.com/r-jb/ez-docker/raw/main/ez-docker.sh | bash)"
```

### Method 2: Download the script and run it

Using `wget`:

```bash
wget https://github.com/r-jb/ez-docker/raw/main/ez-docker.sh
chmod +x ez-docker.sh
./ez-docker.sh
```

Using `curl`:

```bash
curl -O https://github.com/r-jb/ez-docker/raw/main/ez-docker.sh
chmod +x ez-docker.sh
./ez-docker.sh
```
