# Brew Extension

All commands contain the following named parameters
- `--path`: the path where cached information is stored; default is `~/.brew-extension`

## Commands

```
brew-extension sync
```

### Remove

```
brew-extension remove formulae <formulae>
```

Remove (uninstall) a formulae

- `--yes`: whether to authroize uninstall; default is false

```
brew-extension remove label <label>
```

Remove a label

```
brew-extension remove cache
```

Delete all the caches. If this "path" is used, `brew-extension sync` must be used
before any other "paths"

### Label

```
brew-extension label <formulae> <label>
```

Give a formulae a label

```
brew-extension unlabel <formulae> <label>
```

Remove a label from a formulae
