# uv

## インストール済み Python バージョンを確認

```sh
uv python list
```

[Viewing Python installations](https://docs.astral.sh/uv/guides/install-python/#viewing-python-installations)

## Python のインストール

```sh
uv python install x.x.x
```

[Installing a specific version](https://docs.astral.sh/uv/guides/install-python/#installing-a-specific-version)

## 仮想環境の作成

カレントディレクトリを root として作成。

```sh
uv init --python x.x.x
```

hogehoge ディレクトリを作成。

```sh
uv init hogehoge --python x.x.x
uv sync
```

[Working on projects](https://docs.astral.sh/uv/guides/projects/)

## requirements.txt

```shell
uv add --requirements requirements.txt
```

```shell
uv export --format requirements.txt > requirements.txt
```
