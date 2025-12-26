# uv (Python virtual environment の作成)

## インストール済み Python バージョンを確認

```sh
uv python list
```

[Viewing Python installations](https://docs.astral.sh/uv/guides/install-python/#viewing-python-installations)

## Python のインストール

```sh
uv python install 3.12
```

[Installing a specific version](https://docs.astral.sh/uv/guides/install-python/#installing-a-specific-version)

## 仮想環境の作成

```sh
uv init AdventureWorks --python 3.13
uv sync
```

[Working on projects](https://docs.astral.sh/uv/guides/projects/)
