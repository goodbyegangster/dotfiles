# textlint

textlint 向けの独自プロジェクト。

textlint コンフィグを非グローバルに管理しつつ、[.bashrc](../../bash/.bash_aliases) で以下を設定して、グローバルで利用できるようにしている。

```sh
function textlint() {
	NODE_PATH="$HOME/dotfiles/.config/textlint/node_modules" \
	"$HOME/dotfiles/.config/textlint/node_modules/.bin/textlint" \
	--config "$HOME/dotfiles/.config/textlint/config.json" \
	"$@"
}
```
