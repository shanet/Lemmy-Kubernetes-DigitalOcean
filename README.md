Lemmy + Kubernetes + DigitalOcean
=================================

A Terraform project for running Lemmy on a DigitalOcean Kubernetes cluster.

## Resources Used

This project hosts Lemmy using the following resources:

* Managed Postgres database
* Kubernetes cluster with the following pods:
  * Nginx
  * Lemmy
  * Lemmy UI
  * Pict-rs
* Managed load balancer
* AWS SES for sending email

## Costs

This certainly isn't the cheapest way to run Lemmy. But it is highly scalable and requires the least amount of maintenance.

The costs for running Lemmy this way are:

* Database: $15/month
* Kubernetes node: $12/month
* Load balancer: $12/month
* Spaces storage: $5/month (up to 250gb then $0.02/gb/month)
* AWS SES: Negligible unless sending absurd amounts of email ($0.10/1,000 emails)

Total monthly costs are therefore around $44 USD.

These resources are overkill for small instances with a handful of users (it's already at the lowest possible levels) and accordingly could handle a good amount of traffic before needing to be scaled up further. If necessary though, increasing the size of the database/load balancer and adding nodes to the Kubernetes cluster would allow this architecture to scale quite far.

## Usage

### tfvars

First, edit `terraform/enviroments/production/terraform.tfvars.default` and fill in the following values there:

* DigitalOcean Spaces Access Key and Secret Access Key (generate at https://cloud.digitalocean.com/account/api/spaces)
* The domain the Lemmy instance will be hosted at
  * The domains nameserver records must be pointing at DigitalOcean. See https://docs.digitalocean.com/tutorials/dns-registrars/ for docs on that.
* The name of the AWS profile to be used, if not `default`

### Credentials

Two cloud providers are used: DigitalOcean and AWS. Thus, credentials needs to be configured for both of these.

* DigitalOcean: A personal access token can be generated here: https://cloud.digitalocean.com/account/api/tokens. This should be set in an environment variable named `DIGITALOCEAN_TOKEN`.
* AWS: An access key and secret access key should be set in `~/.aws/credentials` for Terraform to read from.

### Running

Then, run the following:

```
cd terraform/environments/production
cp terraform.tfvars.default terraform.tfvars
terraform init
terraform apply
```

This will take a while to create all of the necessary resources. Assuming Terraform ran successfully, your Lemmy instance should be running at the provided domain. Visit it to finish the setup.

## Minikube

The Kubernetes configuration for Lemmy is written using the Terraform provider, but this repo also contains normal Kubernetes YAML files. These were used to test everything locally with Minikube, but are not currently maintained. If you're looking to test locally first these could be used, possibly with some tweaking.

### Usage

This assumes Minikube is already installed.

```
minikube start
kubectl apply -f minikube
minikube service --url nginx
```

## License

MIT
