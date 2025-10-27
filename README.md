# Background
This repo has Dockerfiles for setting up various Linux based development environments. There are different variants, layered as best as possible:

## Dockerfile variants
- **u24** - Ubuntu 24.04 LTS Base, with CLI utilities and Bash customization themes
- **u24_Py** - Based on u24 image and Miniconda installed. Accepts command line arguments for installing Conda environments (e.g ML, Pytorch, Tensorflow, etc.)


# How to use
Customizations can be done using command line arguments when building the Docker image using the `docker build` command.

## List of arguments available
### Both `u24` and `u24_Py` variants
- `IMAGE_TAG` - Base image tag (default: `ubuntu:noble`)
- `CUSTOM_DIR_SRC` - Source directory (on Host OS) for customizations (default: `../image_customizations`)
- `CUSTOM_DIR_DST` - Destination directory (within container) where to copy over stuff from `CUSTOM_DIR_SRC` (default: `/shadowbox`)
- `APP_INSTALL_DIR` - Directory (within container) where to install apps like Conda, etc.
- `BUILD_INFO_DIR` - Directory (within container) where to log build related information, such as summary, Conda environment YML files etc.

### Only `u24_Py` variant
- `MINICONDA_FILE` - Which miniconda version to install (default: `Miniconda3-latest-Linux-x86_64.sh`)
    - Internally, it will download `https://repo.anaconda.com/miniconda/$MINICONDA_FILE`
- `INSTALL_CONDA_ENVS_LATEST` - Use this option to install Conda environments from YAML files that don't include specific version numbers.
    - This is convenient when we'd like to install latest versions of our favourite packages. 
    - Example: `INSTALL_CONDA_ENVS_LATEST="pt_latest tf_latest"` 
    - This **must** be a string seperated by spaces. 
    - Each such string must have a corresponding Conda environment YAML file of the format `<ENV_NAME>_env.yml` located in `CUSTOM_DIR_SRC/conda_envs/latest` directory
    - Example: `/shadowbox/conda_envs/latest/pt_latest_env.yml`, `/shadowbox/conda_envs/latest/tf_latest_env.yml`
    - **NOTE:** Ensure that the YAML files don't have pinned versions, otherwise the purpose is defeated!

- `INSTALL_CONDA_ENVS_PINNED` - Use this option to recreated Conda environments from YAML files that include specific version.
    - This is convenient if we want to replicate a project environment exactly for working in a group, CI / CD, etc.
    - Example: `INSTALL_CONDA_ENVS_PINNED="pt_20250620 tf_20250620"`
    - This **must** be a string seperated by spaces. 
    - Each such string must have a corresponding  Conda environment YAML file of the format `<ENV_NAME>_env.yml` located in `CUSTOM_DIR_SRC/conda_envs/latest` directory. 
    - Example: `/shadowbox/conda_envs/latest/pt_20250620_env.yml`, `/shadowbox/conda_envs/latest/tf_20250620_env.yml`
    - **NOTE:** Ensure that the YAML files have pinned versions, otherwise the purpose is defeated!

## Usage
The following examples must be run from the same directory where the Dockerfiles are located.
### Example 1: Simple, custom Ubuntu image
```bash
# bash
docker build \
  -t u24:$(date -u +"%Y%m%d") \
  -f .\Dockerfile_u24 .
```
```cmd
REM Windows CMD
docker build ^
  -t u24:$(date -u +"%Y%m%d") ^
  -f .\Dockerfile_u24 .
```
The above command will create an image with the following:
- Name `u24_py:<UTC_DATE>`
- Miniconda and UV are not pre-installed

### Example 2: Simple Python (Miniconda + UV) image
```bash
# bash
docker build \
  -t u24_py:$(date -u +"%Y%m%d") \
  -f .\Dockerfile_u24_Py .
```
```cmd
REM Windows CMD
docker build ^
  -t u24_py:$(date -u +"%Y%m%d") ^
  -f .\Dockerfile_u24_Py .
```
The above command will create an image with the following:
- Name `u24_py:<UTC_DATE>`
- No conda environments are installed 

### Example 3: Auto-install Necessary Conda envs
```bash
# bash
docker build \
  -t u24_py_dl:$(date -u +"%Y%m%d") \
  --build-arg INSTALL_CONDA_ENVS_LATEST="pt_latest tf_latest" \
  --build-arg INSTALL_CONDA_ENVS_PINNED="ml_20251027" \
  -f .\Dockerfile_u24_Py .
```
```cmd
REM Windows CMD
docker build ^
  -t u24_py_dl:$(date -u +"%Y%m%d") ^
  --build-arg INSTALL_CONDA_ENVS_LATEST="pt_latest tf_latest" ^
  --build-arg INSTALL_CONDA_ENVS_PINNED="ml_20251027" ^
  -f .\Dockerfile_u24_Py .
```
The above command will create an image with the following:
- Name `u24_py_dl:<UTC_DATE>`
- Automatically install two conda environments from the files `pt_latest_env.yml` and `tf_latest_env.yml` in `$CUSTOM_DIR_DST/conda_envs/latest/` directory
- Automatically install another conda environment from the file `ml_20251027_env.yml` in `$CUSTOM_DIR_DST/conda_envs/pinned/` directory <br>

**NOTE:** In the container, the actual name of the installed Conda environments may not be the same as `pt_latest` etc. since it will be picked up from the `name` field in the YML files

# Other details
## Understanding auto-installation of Conda envs (`u24_py` only)
As described above, Conda environments can be auto-installed during building the images using the `INSTALL_CONDA_ENVS_LATEST` or `INSTALL_CONDA_ENVS_PINNED` ARGs. There are tree types of names involved internally, viz.
- `ENV_FILE_PATH_SRC`
    - Path of the YML file to install the conda environment from
    - Must end with the suffix `"_env.yml"`
    - Prefixed with `$CUSTOM_DIR_DST/conda_envs/latest/` or `$CUSTOM_DIR_DST/conda_envs/pinned/` directory paths, depending on which build ARG was used
- `ENV_NAME_INSTALLED`  
    - The actual name of the conda environment that is created
    - Taken from the `name` field within the `ENV_FILE_PATH_SRC` file
- `ENV_FILE_PATH_DST`
    - After successful creation of the Conda environment, this is the path where the installed specs of the environment is to be exported
    - The path is prefixed with `$CUSTOM_DIR_DST/conda_envs/installed/`
    - The name of the file automatically is prefixed with `ENV_NAME_INSTALLED` and suffixed with `"_env.yml"`
    - Specifically, the format is `"<ENV_NAME_INSTALLED>_<DATE_STAMP>_env.yml"`

Given that the names of the installed conda environments is as per the `name` field within the respective YML file (which could be anything!) here are a few suggestions for naming:
- Decide the desired name (preferrably short) that you want to use with `conda activate`, once the container is ready, e.g. `pt` for PyTorch
- Set this as the `name` filed of the corresponding YML file
    - This gets treated as `ENV_NAME_INSTALLED`
- Keep this name (`pt`) as the prefix for the name of this YML file itself, e.g. `pt_latest_env.yml` / `pt_20251027_env.yml` / `pt_env.yml`, etc.
    - **IMPORTANT:** Make sure to have the `_env.yml` suffix, in the file name, otherwise it will be ignored!
    - The path of this file is treated as `ENV_FILE_PATH_SRC`
- When using the Dockerfile to build a new image, pass the names _**without the `_env.yml` suffix**_
    - E.g. `INSTALL_CONDA_ENVS_LATEST="pt_latest"` etc.
    - This will look for a file named `pt_latest_env.yml` in the `$CUSTOM_DIR_DST/conda_envs/latest/` directory
    - Since the file itself has a `name` filed as `pt`, the installed conda environment will have the same name as `pt`
    - After installation, the environment details will be exported to a file located in `$CUSTOM_DIR_DST/conda_envs/installed/` with a name format `"pt_<DATE_STAMP>_env.yml"`

## Build Information Capture
Both variants automatically create a directory by name `$BUILD_INFO_DIR` (`/.build_info` by default) that has files containing comprehensive version information for deterministic builds. This file includes:
- Build timestamp (image build time)
- Docker image build time ARGs
- ENV variables    
- Oh-My-Posh version
- Zsh version
- uv version    (`u24_py` version only)
- Python version (`u24_py` version only)
- Conda version (`u24_py` version only)
- Complete conda environment specifications for all installed environments (`u24_py` version only)

This enables us to recreate identical builds in the future by referencing the exact versions used.

## Version Derivation Guide

### Miniconda Version
To derive the correct `MINICONDA_FILE` value:
1. Check the Python version you want: `python --version` (e.g., Python 3.11.0)
2. Check the Conda version you want: `conda --version` (e.g., 23.10.0)
3. Visit https://repo.anaconda.com/miniconda/ to find the matching installer
4. Example: `Miniconda3-py311_23.10.0-1-Linux-x86_64.sh`

### Pinned Conda Environments
To create pinned conda environment files:
1. Create your environment with specific versions: `conda create -n my_env python=3.11 numpy=1.24.0 pandas=2.0.0`
2. Export with exact versions: `conda env export -n my_env --no-builds > my_env.yml`
3. Place the file in `CUSTOM_DIR_SRC/conda_envs/pinned/` as `<env_name>_env.yml`
4. Use in build: `--build-arg INSTALL_CONDA_ENVS_PINNED="my_env"`

## Zsh Support
Both `u24` and `u24_Py` variants now include Zsh with Oh-My-Posh theme support:
- Zsh is installed and configured with the same theme as Bash
- Switch to Zsh: `chsh -s $(which zsh)`
- Both shells share the same Oh-My-Posh configuration and terminal logo script

## uv Package Installer
The `u24_Py` variant includes the uv package installer for faster Python package management:
- Installed globally and available as `uv` command

## Implementation Notes & Removed Code Patterns

The following sections document code patterns and configurations that were removed or commented out during optimization efforts. This information is retained for reference in case these approaches need to be revisited.

### Conda Environment Activation Variables
**Removed from:** `Dockerfile_u24_Py` (lines 65-66, 171-172)

Original approach attempted to set `LD_LIBRARY_PATH` for TensorFlow compatibility:
```bash
mkdir -p $HOME/miniconda3/etc/conda/activate.d
echo 'export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/miniconda3/lib/' > $HOME/miniconda3/etc/conda/activate.d/env_vars.sh
```

**Reason for removal:** This configuration broke `apt-get` functionality in subsequent build steps. Modern TensorFlow and conda installations handle library paths automatically through conda's activation scripts.

**When to re-enable:** If you encounter TensorFlow library loading errors (e.g., `libcuda.so.1` not found), uncomment these lines and test in isolation before the main package installation steps.

### Azure CLI Installation
**Removed from:** `Dockerfile_u24_Py` (lines 175-177)

Original code:
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
az extension add -n ml -y
```

**Reason for removal:** Azure CLI adds significant image size (~500MB) and is not universally needed. Users requiring Azure CLI can install it in their own derived images or as a separate optional layer.

**When to re-enable:** If your development workflow requires Azure CLI, create a separate `Dockerfile_u24_Py_azure` variant that extends the base `u24_Py` image.

### CONDA_PREFIX Environment Variable
**Removed from:** `Dockerfile_u24_Py` (line 166)

Original code:
```bash
ENV CONDA_PREFIX="$HOME/miniconda3" PATH=$CONDA_PREFIX/bin/:$PATH
```

**Reason for removal:** Conda's initialization scripts (`conda init bash`) automatically set `CONDA_PREFIX` and update `PATH`. Explicit setting can cause conflicts with conda's environment activation mechanism.

**When to re-enable:** Only if you need to override conda's default behavior for specific use cases (e.g., using a non-standard conda installation path).

- Provides faster alternative to pip for Python package installation
