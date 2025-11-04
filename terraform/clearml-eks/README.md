## How to Use

1. **Save all files** in a folder `clearml-eks/`
2. **Initialize Terraform**:
   ```bash
   cd clearml-eks
   terraform init
   ```

3. **Review plan**:
   ```bash
   terraform plan
   ```

4. **Apply**:
   ```bash
   terraform apply
   ```

5. **Wait ~15–20 mins**  
   Then run:
   ```bash
   aws eks update-kubeconfig --name clearml-dev --region us-east-1
   kubectl get pods -n clearml
   ```

6. **Access ClearML**:
   ```
   http://clearml.clearml-dev.eks.amazonaws.com
   ```

---

## Security Notes

- **Change `ssh_cidr`** in `variables.tf` to your IP:  
  ```hcl
  default = "YOUR.IP.ADD.RESS/32"
  ```
- For production: enable MongoDB/Redis auth, ACM HTTPS, IAM OIDC, backups.

---

## Next Steps (Optional)

Let me know if you want:
- HTTPS with ACM + Route53 domain
- Autoscaling (HPA + Cluster Autoscaler)
- External MongoDB (RDS)
- Monitoring (Prometheus/Grafana)
- Backup to S3

