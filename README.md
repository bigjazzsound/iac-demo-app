# A demo app for deploying nginx in AWS

A Makefile is provided to deploy the resources:

```bash
make init
make plan
make apply
```

And to verify that the endpoint of the application is working:

```bash
make verify
```

And to tear down the app:

```bash
make destroy
make apply
```

## Enhancements

This is just a simple example of how you can use IaC to perform basic systems Devops/SRE tasks.

If the number of users using this app were to increase in size, then there are several options how to handle the increase in traffic:

* Increase the size of the instance
* Increase the number of instances
* Replace the instance(s) with an autoscaling group and a launch configuration
