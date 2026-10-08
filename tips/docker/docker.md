# Docker

## Windows

以下より rootless-docker を WSL 環境にインストールする。

```sh
make run-install-scripts
```

## macOS

### Install

Colima (軽量な Docker 互換のコンテナランタイム) をインストール。

```sh
brew install colima
```

[Installation | Colima](https://colima.run/docs/installation/#homebrew-recommended)

Docker 関連のモジュール一式をインストール。

```sh
brew install docker docker-compose docker-buildx

mkdir -p ~/.docker/cli-plugins
ln -sfn $(brew --prefix)/opt/docker-compose/bin/docker-compose ~/.docker/cli-plugins/docker-compose
ln -sfn $(brew --prefix)/opt/docker-buildx/bin/docker-buildx ~/.docker/cli-plugins/docker-buildx
```

[All-in-One Docker Setup | Colima](https://colima.run/docs/installation/#all-in-one-docker-setup)

### Colima 自動起動設定

Colima をバックグラウンドで起動させる。

```sh
brew services start colima
```

確認。

```sh
brew services list
colima status
```

[Does Colima support autostart? | Colima](https://colima.run/docs/faq/#does-colima-support-autostart)

### 動作確認

```sh
docker run --rm hello-world
```
