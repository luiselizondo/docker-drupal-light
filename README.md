docker-drupal-light
=============

Light stack consisting of Nginx, PHP, MySQL and Drupal.

### Build
```bash
docker build -t="somename" .
```

### Run
There are three ways to run it:

1. Using fig. There's a fig.yml file that can help you get started.
2. Using run which will ask you for some input to build the docker command for you
3. Using the docker command:

```
docker run -d -p 8000:80 -p 3306:3306 --volumes-from=SOMEVOLUME -v /var/www/mydrupalwebsite:/var/www -v /var/log/docker:/var/log/supervisor --name container_name image_name
```

If you don't want to expose the MySQL port, you can safetly remove it.

After a few seconds you need to do 

```
docker logs containerid
```

To retrieve the MySQL information that was used.

Point your browser to http://localhost:8000