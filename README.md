\# AWS K3s CI/CD Project



A hands-on DevOps project demonstrating an end-to-end CI/CD pipeline using \*\*GitHub Actions, AWS, Docker, Amazon ECR, AWS Systems Manager (SSM), and K3s/Kubernetes\*\*.



\## Architecture



```text

Developer

&#x20;   |

&#x20;   | git push

&#x20;   v

GitHub Repository

&#x20;   |

&#x20;   v

GitHub Actions

&#x20;   |

&#x20;   +---- AWS OIDC Authentication

&#x20;   |

&#x20;   +---- Docker Build

&#x20;   |

&#x20;   +---- Push Image to Amazon ECR

&#x20;   |

&#x20;   +---- AWS SSM

&#x20;            |

&#x20;            v

&#x20;       K3s Server

&#x20;            |

&#x20;            +---- Refresh ECR Registry Secret

&#x20;            |

&#x20;            +---- Update Kubernetes Deployment

&#x20;            |

&#x20;            +---- Rolling Update

&#x20;            |

&#x20;            v

&#x20;      K3s Kubernetes Cluster

&#x20;         /            \\

&#x20;        /              \\

&#x20;   K3s Server       K3s Worker

&#x20;      Pod              Pod

&#x20;        \\              /

&#x20;         \\            /

&#x20;          Kubernetes Service

&#x20;                |

&#x20;                v

&#x20;            Application

```



\## Technologies Used



\* AWS

\* Terraform

\* GitHub

\* GitHub Actions

\* GitHub Actions OIDC

\* Docker

\* Amazon ECR

\* AWS Systems Manager (SSM)

\* K3s

\* Kubernetes

\* Linux / Ubuntu

\* Python / Flask

\* YAML

\* Git



\## Project Structure



```text

aws-kubernetes-devops-project/

│

├── .github/

│   └── workflows/

│       └── cicd.yml

│

├── aws-k3s-cicd/

│   ├── app/

│   │   ├── app.py

│   │   └── requirements.txt

│   │

│   ├── k8s/

│   │   ├── deployment.yaml

│   │   ├── service.yaml

│   │   └── ec2-trust-policy.json

│   │

│   ├── Dockerfile

│   └── .dockerignore

│

├── terraform/

│   ├── ec2.tf

│   ├── internet-gateway.tf

│   ├── outputs.tf

│   ├── provider.tf

│   ├── route-tables.tf

│   ├── security-group.tf

│   ├── subnets.tf

│   ├── variables.tf

│   └── vpc.tf

│

├── application/

├── artifacts/

├── jenkins/

├── kubernetes/

├── scripts/

│

└── README.md

```



\## AWS Infrastructure



The infrastructure was created using Terraform.



The environment includes:



\* VPC

\* Internet Gateway

\* Public and private subnets

\* Route tables

\* Security groups

\* EC2 instances

\* K3s server

\* K3s worker



The Kubernetes cluster runs across two EC2 instances.



\## Kubernetes Cluster



The K3s cluster contains:



```text

K3s Server

Private IP: 10.0.1.85



K3s Worker

Private IP: 10.0.2.117

```



Both nodes are running and registered with the K3s cluster.



The application deployment uses two replicas:



```yaml

replicas: 2

```



This allows Kubernetes to maintain two application pods.



\## Application



The project contains a simple Flask application.



Application container port:



```text

5000

```



The application is exposed through a Kubernetes NodePort service:



```text

NodePort: 30080

```



The application can be accessed through:



```text

http://<K3s-server-public-ip>:30080

```



\## Docker



The application is containerized using Docker.



Example:



```bash

docker build -t aws-k3s-cicd:1.0 ./aws-k3s-cicd

```



The resulting image is pushed to Amazon ECR.



\## Amazon ECR



The Docker image is stored in an Amazon ECR repository.



Images are tagged using the Git commit SHA.



Example:



```text

aws-k3s-cicd:<git-commit-sha>

```



This provides traceability between:



```text

Git Commit → Docker Image → Kubernetes Deployment

```



\## GitHub Actions CI/CD



The CI/CD workflow is located at:



```text

.github/workflows/cicd.yml

```



The pipeline is triggered when code is pushed to the `main` branch.



\### Pipeline Flow



```text

1\. Checkout source code

&#x20;       |

2\. Authenticate to AWS using OIDC

&#x20;       |

3\. Login to Amazon ECR

&#x20;       |

4\. Build Docker image

&#x20;       |

5\. Push image to ECR

&#x20;       |

6\. Send deployment command using AWS SSM

&#x20;       |

7\. Refresh ECR image pull secret

&#x20;       |

8\. Update Kubernetes deployment image

&#x20;       |

9\. Wait for Kubernetes rollout

&#x20;       |

10\. Return deployment result to GitHub Actions

```



\## AWS OIDC Authentication



The GitHub Actions workflow uses AWS IAM OIDC authentication.



No long-lived AWS access keys are stored in GitHub.



The workflow assumes an IAM role:



```text

GitHubActionsK3sDeployRole

```



The trust relationship restricts access to the project's GitHub repository and `main` branch.



This provides temporary AWS credentials to the GitHub Actions runner.



\## AWS Systems Manager Deployment



The Kubernetes API is not exposed directly to GitHub Actions.



Instead, GitHub Actions uses AWS Systems Manager:



```text

GitHub Actions

&#x20;     |

&#x20;     | SSM SendCommand

&#x20;     v

K3s Server

&#x20;     |

&#x20;     | kubectl

&#x20;     v

Kubernetes

```



The deployment command performs:



```bash

aws ecr get-login-password

```



Then refreshes the Kubernetes ECR registry secret.



The deployment image is updated using:



```bash

kubectl set image

```



Finally, the workflow waits for:



```bash

kubectl rollout status

```



\## Deployment Validation



The GitHub Actions workflow does not simply submit the SSM command and finish.



It captures the SSM command ID and polls the command status.



The workflow succeeds only when SSM reports:



```text

Success

```



If SSM reports:



```text

Failed

TimedOut

Cancelled

```



the GitHub Actions job fails.



This ensures the CI/CD pipeline validates the actual deployment result.



\## Kubernetes Deployment



The application deployment contains two replicas:



```text

aws-k3s-cicd

├── Pod 1

└── Pod 2

```



The deployment uses an ECR image:



```text

926909119009.dkr.ecr.ap-south-1.amazonaws.com/aws-k3s-cicd:<commit-sha>

```



The Kubernetes service exposes the application using NodePort:



```text

80:30080

```



\## Verification



Kubernetes deployment can be checked using:



```bash

sudo k3s kubectl get nodes -o wide

```



Check the deployment:



```bash

sudo k3s kubectl get deployment aws-k3s-cicd -o wide

```



Check pods:



```bash

sudo k3s kubectl get pods -o wide

```



Check the service:



```bash

sudo k3s kubectl get service aws-k3s-cicd-service

```



Check the application:



```bash

curl http://<K3s-server-public-ip>:30080

```



Expected response:



```text

Hello from AWS K3s CI/CD! Version 1.0

```



\## Key DevOps Concepts Demonstrated



\### Infrastructure as Code



Terraform is used to define AWS infrastructure.



\### Containerization



Docker packages the Flask application into a portable container.



\### Container Registry



Amazon ECR stores Docker images.



\### Continuous Integration



GitHub Actions automatically builds the application whenever code is pushed.



\### Continuous Deployment



GitHub Actions automatically deploys the new image to Kubernetes.



\### Secure Cloud Authentication



GitHub Actions uses AWS OIDC instead of storing long-lived AWS credentials.



\### Remote Deployment



AWS SSM is used to execute deployment commands on the K3s server.



\### Kubernetes Rolling Update



The deployment is updated using:



```bash

kubectl set image

```



and validated using:



```bash

kubectl rollout status

```



\### Version Traceability



Docker images use Git commit SHA tags, allowing a deployment to be traced back to the exact source-code commit.



\## End-to-End Flow



The complete deployment process is:



```text

Developer changes code

&#x20;       ↓

git push

&#x20;       ↓

GitHub

&#x20;       ↓

GitHub Actions

&#x20;       ↓

AWS OIDC

&#x20;       ↓

Docker Build

&#x20;       ↓

Amazon ECR

&#x20;       ↓

AWS SSM

&#x20;       ↓

K3s Server

&#x20;       ↓

Kubernetes Deployment

&#x20;       ↓

Rolling Update

&#x20;       ↓

2 Running Pods

&#x20;       ↓

Application Available

```



\## Future Improvements



Possible future enhancements:



\* Add Kubernetes liveness and readiness probes

\* Add automated application tests

\* Add monitoring using Prometheus and Grafana

\* Add centralized logging

\* Add HTTPS/TLS

\* Add an AWS Load Balancer

\* Improve ECR authentication using an ECR credential provider

\* Add separate development and production environments

\* Add deployment notifications

\* Add security scanning for Docker images

\* Add Terraform remote state using Amazon S3



