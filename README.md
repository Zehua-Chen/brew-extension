# Brew Extension

All commands contain the following named parameters
- `--path`: the path where cached information is stored; default is `~/.brew-extension`

## Commands

```
brew-extension sync
```

### Uninstallation

```
brew-extension uninstall <name>
```

- `--yes`: whether to authroize uninstall; default is false

### Label

```
brew-extension label <formulae> <label>
```

- `--remove`: will remove the label when set to `true`, default is `false`

```
brew-extension remove label
```

```
brew-extension remove label <label>
```
