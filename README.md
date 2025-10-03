# Background
This repo has Dockerfiles for setting up various Linux based development environments. There are different variants, layered as best as possible:

## Dockerfile variants
- **u24** - Ubuntu 24.04 LTS Base, with CLI utilities and Bash customization themes
- **u24_Py** - Based on u22 image and Miniconda installed. Accepts command line arguments for installing Conda environments (e.g ML, Pytorch, Tensorflow, etc.)


# How to use
Customizations can be done using command line arguments when building the Docker image using the `docker build` command.

## List of arguments available
### Both `u24` and `u24_Py` variants
- `IMAGE_TAG` - Base image tag (default: `ubuntu:noble`)
- `CUSTOM_DIR_SRC` - Source directory (on Host OS) for customizations (default: `../image_customizations`)
- `CUSTOM_DIR_DST` - Destination directory (within container) where to copy over stuff from `CUSTOM_DIR_SRC` (default: `/shadowbox`)
- `APP_INSTALL_DIR` - Directory where to install apps like Conda, etc.

### Only `u24_Py` variant
- `MINICONDA_FILE` - Which miniconda version to install (default: `Miniconda3-latest-Linux-x86_64.sh`)
    - Internally, it will download `https://repo.anaconda.com/miniconda/$MINICONDA_FILE`
- `INSTALL_CONDA_ENVS_LATEST` - Use this option to install Conda environments from YAML files that don't include specific version numbers.
    - This is convenient when we'd like to install latest versions of our favourite packages. 
    - Example: `INSTALL_CONDA_ENVS_LATEST="pt_latest tf_latest"` 
    - This **must** be a string seperated by spaces. 
    - Each such string must have a corresponding  Conda environment YAML file of the format `<ENV_NAME>_env.yml` located in `CUSTOM_DIR_SRC/conda_envs/latest` directory. 
    - Example: `/shadowbox/conda_envs/latest/pt_latest_env.yml`, `/shadowbox/conda_envs/latest/tf_latest_env.yml`
    - NOTE: Ensure that the YAML files don't have pinned versions, otherwise the purpose is defeated!

- `INSTALL_CONDA_ENVS_PINNED` - Use this option to recreated Conda environments from YAML files that include specific version.
    - This is convenient if we want to replicate a project environment exactly for working in a group, CI / CD, etc.
    - Example: `INSTALL_CONDA_ENVS_PINNED="pt_20250620 tf_20250620"`
    - This **must** be a string seperated by spaces. 
    - Each such string must have a corresponding  Conda environment YAML file of the format `<ENV_NAME>_env.yml` located in `CUSTOM_DIR_SRC/conda_envs/latest` directory. 
    - Example: `/shadowbox/conda_envs/latest/pt_20250620_env.yml`, `/shadowbox/conda_envs/latest/tf_20250620_env.yml`
    - NOTE: Ensure that the YAML files have pinned versions, otherwise the purpose is defeated!


```bash
docker build -t u24_py_dl:$(date -u +"%Y%m%d") --build-arg INSTALL_CONDA_ENVS_LATEST="pt_latest tf_latest" -f Dockerfile_u24_Py .
```
