![ubuntu.png](https://github.com/ThinGuy/show-me/blob/main/docs/ubuntu.png?raw=true)
# Show Me
----
> Ubuntu Show Me provides various self-contained demonstrations of Canonical Products running on Ubuntu.
> The initial Show Me demonstration is for [Canonical Landscape](https://landscape.canonical.com/), more, including [MAAS](https://maas.io/), are planned.
> Currently, the demonstrations are on AWS but more substrates are possible.
----

# Show Me Landscape

How to launch the Show Me Landscape demostration on AWS

1. **Select the AMI from the AWS Market Place**

![ami-1.png](https://github.com/ThinGuy/show-me/blob/main/docs/ami-1.png?raw=true)


  1.1. Search for Ubuntu Show Me Landscape

    *or*  

  1.2. Choose a link below
    + [us-west-1](https://console.aws.amazon.com/ec2/v2/home?region=us-west-1#LaunchInstanceWizard:ami=ami-0510b2fed91725dc5) N. California
    + [us-east-1](https://console.aws.amazon.com/ec2/v2/home?region=ca-central-1#LaunchInstanceWizard:ami=ami-04ae43d248daf4a4e) Canada
    + [us-east-1](https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#LaunchInstanceWizard:ami=ami-0fc749ac2e9baf9fc) N. Virginia
    + [eu-west-2](https://console.aws.amazon.com/ec2/v2/home?region=eu-west-2#LaunchInstanceWizard:ami=ami-08dc4ca0d790b5dfa) London
    + [eu-central-1](https://console.aws.amazon.com/ec2/v2/home?region=eu-central-1#LaunchInstanceWizard:ami=ami-0b054c91f11cd9fb8) Frankfurt
    + [ap-southeast-2](https://console.aws.amazon.com/ec2/v2/home?region=ap-southeast-2#LaunchInstanceWizard:ami=ami-0458f5f08b5f0a7cd) Sydney
    + [sa-east-1](https://console.aws.amazon.com/ec2/v2/home?region=sa-east-1#LaunchInstanceWizard:ami=ami-0f44f06e094cb8b90) São Paulo  

2. **Launch an instance**
  2.1. Instance Type
    + Minimal:  t2.large
    + **Best Price/Performace:**  **t3.large**
    + Canonical Recommended:  m5.large

  | Type     | vCPU | CPU                                                         | Arch   | RAM (GiB) | Storage (GB) | Storage Type | Linux pricing |
  | -------- | ---- | ----------------------------------------------------------- | ------ | --------- | ------------ | ------------ | ------------- |
  | t2.large | 2    | Intel Xeon (Legacy)                                         | x86_64 | 8         | 20           | EBS          | 0.0928 USD/hr |
  | t3.large | 2    | 1st Gen Intel Xeon Scalable (Skylake, Cascade Lake)         | x86_64 | 8         | 20           | EBS          | 0.0832 USD/hr |
  | m5.large | 2    | 2nd Gen Intel Xeon Platinum 8000 (Skylake-SP, Cascade Lake) | x86_64 | 8         | 20           | EBS          | 0.096 USD/hr  |  

  2.2. Key pair
    + Create or Use Existing
    + Key pair type:  Both RSA/ED25519 are acceptable

  2.3. Networking
    + VPC:  Use Existing or Create New
        + Must have a publicly accessible subnet
        + If creating new, use the wizards as the defaults are sane
        + Important part is that there a publicly accessible subnets
    + Auto-assign public IP:  Yes
    + Firewall (security groups)
      + SSH (TCP, 22, 0.0.0.0/0)
        + Used for management of Landscape Server
      + HTTP (TCP, 80, 0.0.0.0/0)
        + Used by Landscape clients to check in with the server
      + HTTPS (TCP,443, 0.0.0.0/0)
        + Used by the Landscape API and Web UI
  2.4. Advanced Details  
    + Hostname type:  Resource Name
    + DNS Hostname: Enable resource-based IPV4 (A record) DNS requests  

3. **Find your machine under "Instances"**

  3.1. Look for the Public IPv4 DNS

  3.2. Copy just the hostname (everything before the first period) 

  ![aws-hostname.png](https://github.com/ThinGuy/show-me/blob/main/docs/aws-hostname.png)   

  3.3. Once the machine has passed its "Instance Status Checks",  point your browser to:  

    + *your-aws-hostname*.landscape.ubuntu-show.me
    + Where *your-aws-hostname* is replaced by part you just copied

  ![navigate-to.png](https://github.com/ThinGuy/show-me/blob/main/docs/navigate-to.png)

  3.4. You should be presented with a login screen for landscape

  ![landscape-1.png](https://github.com/ThinGuy/show-me/blob/main/docs/landscape-1.png)

4. **Login to Landsacpe**  

  4.1. Credentials are as follows:
    + E-mail address: lsadmin@landscape.ubuntu-show.me
    + Password: ubuntu

  4.2. After logging in, you should be presented with the main dash board

  ![landscape-2.png](https://github.com/ThinGuy/show-me/blob/main/docs/landscape-2.png)  

  4.3. The Landscape demonstrations comes with pre-initiated [LXD ](https://linuxcontainers.org/lxd/introduction/)containers to act as clients  

  ![landscape-3.png](https://github.com/ThinGuy/show-me/blob/main/docs/landscape-3.png)  

  4.4. Other notable items about this demonstration
    + The server has also registered itself as well
    + You can automatically add more clients using either `add-landscape-clients-numbered.sh` or `add-landscape-clients-petnames.sh` scripts
    + These scripts are located in `/usr/local/bin`

  4.4. You can also register any Ubuntu instance by following the instruction link on the left side of the dashboard.

  ![register-new.png](https://github.com/ThinGuy/show-me/blob/main/docs/register-new.png)

**Have fun exploring Canonical Landscape**

![landscape-4.png](https://github.com/ThinGuy/show-me/blob/main/docs/landscape-4.png)

