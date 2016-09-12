Playbook to setup complete rails stack on AWS ElasticBeanstalk.  One prod and one staging multi-az, autoscaling, RDS-backed EB environment each in their own VPCs.

Playbook will create infrastructure and create config files for deployment
# Create the AWS infrastructure
```sh
$ ansible-playbook main.yml
```

# Create .ebextensions directory in your rails app:
```sh
$ mkdir $RAILS_ROOT/.ebextensions
$ mkdir $RAILS_ROOT/.elasticbeanstalk
$ cp output/packages.config $RAILS_ROOT/.ebextensions/
$ cp output/option_settings.config $RAILS_ROOT/.ebextensions/
$ cp output/config.yml $RAILS_ROOT/.elasticbeanstalk
$ cd $RAILS_ROOT
```

# Create an EB 'environment'
```sh
$ eb create
```
Choose type = 'application' and add a prefix to the enviroment name e.g. staging or prod)
This will create the resources but the deploy will fail because the rails app needs ENV variables which are missing.
# Configure your rails app to read db settings from ENV
```ruby
production:
  adapter: postgresql
    encoding: unicode
      database: <%= ENV['RDS_DB_NAME'] %>
        username: <%= ENV['RDS_USERNAME'] %>
          password: <%= ENV['RDS_PASSWORD'] %>
            host: <%= ENV['RDS_HOSTNAME'] %>
              port: <%= ENV['RDS_PORT'] %>
              ```
              # Make sure your app has a root route for the health check.
              i.e. `GET '/'` returns something`

# Commit your changes
```sh
$ git add .
$ git commit 'Add EB config/read prod db conn info from ENV'
```
# Set all the necessary ENV variables
```sh
$ eb setenv SECRET_KEY_BASE=`rake secret` \
RDS_DB_NAME=<value> \
RDS_USERNAME=<value> \
RDS_PASSWORD=<value> \
RDS_HOSTNAME=<value> \
RDS_PORT=<value>
```

This change in ENV will automatically trigger a deploy. View your app:
```sh
$ eb open
```

