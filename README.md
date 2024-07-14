Examples
---------

```
curl -fsSL https://raw.githubusercontent.com/WildePizza/kubernetes-center/HEAD/run.sh | bash -s <args>
```

| Option   | Possible Values                                                            | Required |
|----------|----------------------------------------------------------------------------|----------|
| --action | install, unistall                                                          | false    |
| --args   | repo args                                                                  | false    |
| --repo   | mysql-kubernetes, docker-registry, kubernetes-dashboard, ollama-kubernetes | true     |