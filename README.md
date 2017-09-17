# Panda

### Install
Add your Pandascore token in your env (.bashrc/.zshrc) as PANDASCORE_TOKEN="mytoken"

```
$ print 'export PANDASCORE_TOKEN="mytoken"' >> ~/.bashrc
OR
$ print 'export PANDASCORE_TOKEN="mytoken"' >> ~/.zshrc
```

Resource your shell with `source ~/.bashrc` or `source ~/.zshrc` or open a new shell.

Verify that your token is in your env with

```
$ echo $PANDASCORE_TOKEN
```
If you see your token you're ready to clone
````
$ git clone https://github.com/nayed/panda.git
$ cd panda
$ mix deps.get
````

