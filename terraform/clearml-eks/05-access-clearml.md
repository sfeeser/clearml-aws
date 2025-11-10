# Access ClearML
The cluster is built! But how do you talk to it? And how do you find the ClearML web dashboard? This lab connects your local kubectl client to the cluster and shows you how to find the URL.

### Lab Objective
You will configure kubectl to access your new cluster and retrieve the public hostname for the ClearML dashboard.

### Procedure

1. Configure kubectl The terraform apply command finished by printing an output named configure_kubectl. This is a pre-built command that will automatically configure your local kubectl to talk to the new EKS cluster.

    `student@bchd:~$` `aws eks update-kubeconfig --name clearml-dev --region us-east-1`

    `student@bchd:~$` `terraform output configure_kubectl`

0. Wait for the Load Balancer. The apply is done, but AWS needs an extra 2-5 minutes (maybe even more so be patient) to provision the Application Load Balancer (ALB) and assign it a DNS name.

0. Get Your URL. Run this kubectl command to get the public URL from the Ingress resource. If it's empty, wait another minute and try again. 

    `student@bchd:~$` `kubectl get ingress clearml-webserver -n clearml -o jsonpath='{.status.load_balancer.ingress[0].hostname}'`

0. Log In. The command will print a long URL (e.g., k8s-clearml-....elb.amazonaws.com). Paste this URL into your browser, adding http:// to the front, to see your ClearML dashboard!
