# Poetry (Python virtual environment の作成)

利用しているバージョンを確認。

```shell
$ pyenv versions
  system
  3.8.12
  3.10.9
* 3.11.6 (set by /home/zunda/.pyenv/version)
```

（追加で異なるバージョンをインストールしたい時）インストール可能なバージョン一覧を表示。

```shell
$ pyenv update
$ pyenv install -l | grep "3\.11\."
  3.11.0
  3.11.1
  3.11.2
  3.11.3
  3.11.4
  3.11.5
  3.11.6
  3.11.7
  miniconda3-3.8-23.11.0-1
  miniconda3-3.8-23.11.0-2
  miniconda3-3.9-23.11.0-1
  miniconda3-3.9-23.11.0-2
  miniconda3-3.10-23.11.0-1
  miniconda3-3.10-23.11.0-2
  miniconda3-3.11-23.11.0-1
  miniconda3-3.11-23.11.0-2
```

（追加で異なるバージョンをインストールしたい時）指定バージョンをインストール。

```shell
$ pyenv install 3.11.7
```

利用したいバージョンを指定。

```shell
$ pyenv local 3.11.7
  system
  3.8.12
  3.10.9
  3.11.6
* 3.11.7 (set by /home/zunda/work/zunda-horizon/.python-version)
$ python --version
Python 3.11.7
```

Poetry プロジェクトを作成（既にプロジェクトがある場合）。

```sh
$ poetry init
$
$ # いろいろ訊かれるが、利用したい Python バージョンの質問のみ正確に答えれば良し
$
$ cat ./pyproject.toml
[tool.poetry]
name = "zunda-horizon"
version = "0.1.0"
description = ""
authors = ["Your Name <you@example.com>"]
readme = "README.md"

[tool.poetry.dependencies]
python = "3.11.7"


[build-system]
requires = ["poetry-core"]
build-backend = "poetry.core.masonry.api"
```

true であることを確認。

```shell
$ poetry config --list | grep "virtualenvs.in-project"
virtualenvs.in-project = true
```

仮想環境を作成。

```shell
$ poetry env use 3.11.7
```

確認。

```shell
$ poetry shell
(zunda-horizon-py3.11) $ which python
/home/zunda/work/zunda-horizon/.venv/bin/python
(zunda-horizon-py3.11) $ python --version
Python 3.11.7
```
