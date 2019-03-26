# spree-docker-demo
### 1) Install heroku plugin

```bash
heroku plugins:install dockhero
```
### 2) Create container

```bash
heroku dh:compose up -d
```

#### Check the logs with

```bash
heroku logs --tail -p dockhero
```

#### To see the app via Dockhero URL

```bash
heroku dh:open 
```
