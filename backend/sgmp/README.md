# SGMP Backend Server
## Installing

We recommend installing the dependencies in a virtual environment (e.g. virtualenv, pyenv, etc.) to prevent conflicts.

```
pip install -r requirements.txt
```

## Configuration

Please copy `config.example.yaml` to `config.yaml` and fill in the values.

## Running

To run the dev server, run:

```
python main.py
```

optionally specify a port, for example:

```
PORT=8888 python main.py
```