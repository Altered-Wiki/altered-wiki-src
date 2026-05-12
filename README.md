# altered-wiki-src

Source files for the MediaWiki modules, templates, and styles powering
[altered.wiki](https://altered.wiki).

## Layout

| File | Wiki page |
|---|---|
| `modules/legal-status.lua` | `Module:LegalStatus` |
| `common/common.css` | `MediaWiki:Common.css` |
| `common/common.js` | `MediaWiki:Common.js` |
| `templates/substance.wikitext` | `Template:Substance` |
| `templates/legal-status.wikitext` | `Template:Legal status` |

## Deployment

Changes pushed to `main` are automatically synced to the wiki via the deploy
webhook from [altered-wiki-tools](https://github.com/altered-wiki/altered-wiki-tools).

To sync manually, point the deploy tool at this repo:

```sh
REPO_PATH=/path/to/altered-wiki-src python3 webhook.py sync-all
```

## License

MIT — see [LICENSE](LICENSE).
