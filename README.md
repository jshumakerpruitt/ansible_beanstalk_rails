Playbook to setup complete rails stack on AWS ElasticBeanstalk.  One prod and one staging multi-az, autoscaling, RDS-backed EB environment each in their own VPCs.

Playbook will create infrastructure and create config files for deployment

Create .ebextensions directory in your rails app:
```sh
$ mkdir $RAILS_ROOT/.ebextensions
$ cp output/packages.config $RAILS_ROOT/.ebextensions/
$ cp output/option_settings.config $RAILS_ROOT/.ebextensions/
$ cd $RAILS_ROOT
$ eb init
```
$ eb setenv RDS_DB_NAME=<value>
$ eb setenv RDS_USERNAME=<value>
$ eb setenv RDS_PASSWORD=<value>
$ eb setenv RDS_HOSTNAME=<value>
$ eb setenv RDS_PORT=<value>

# Configure your rails app to read db settings from ENV
production:
  adapter: postgresql
  encoding: unicode
  database: <%= ENV['RDS_DB_NAME'] %>
  username: <%= ENV['RDS_USERNAME'] %>
  password: <%= ENV['RDS_PASSWORD'] %>
  host: <%= ENV['RDS_HOSTNAME'] %>
  port: <%= ENV['RDS_PORT'] %>

```sh
$ git add .
$ git commit 'Add EB config/read prod db conn info from ENV'
$ eb create
```
