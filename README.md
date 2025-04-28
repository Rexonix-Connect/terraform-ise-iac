# terraform-ise-iac

TBD | sorry :)

# Development
Regenerate module files with:
```bash
# get source code
git clone <repository-url>
cd <directory-name>
# create virtual environment
python3.11 -m venv <venv-name>
source <venv-name>/bin/activate
pip install -r gen/requirements.txt
#
# < You contributing to the code here >
#
# optional cleanup of auto-generated files
#    module resource files
rm -rf ./ise_*.tf
#    example model-data
rm -rf ./examples/auto-generated/model-data
#    example user-defaults
rm -rf ./examples/auto-generated/user-defaults
#    module defaults
rm -rf ./defaults
# file regeneration
./gen/generate_module.py
```
