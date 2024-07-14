Examples
---------

Example to install mysql-kubernetes:
```
curl -fsSL https://raw.githubusercontent.com/WildePizza/kubernetes-center/HEAD/run.sh | bash -s repo=mysql-kubernetes args='root root' action=install
```

| Option   | Possible Values                                                            | Required |
|----------|----------------------------------------------------------------------------|----------|
| --action | install, unistall                                                          | false    |
| --args   | repo args                                                                  | false    |
| --repo   | mysql-kubernetes, docker-registry, kubernetes-dashboard, ollama-kubernetes | true     |
