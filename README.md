# Cloud portfolio - AWS & Terraform ☁️

## 📖 Project Overview
This project is a serverless resume website deployed on AWS. It demonstrates a full-stack cloud architecture using Infrastructure as Code (IaC) and CI/CD automation.


## 🏗️ Architecture
The website follows a serverless architecture to keep costs to literally 0$ and scalability high.

1.  **Frontend:** Static HTML/CSS resume hosted on **Amazon S3** (configured as a static website).
2.  **Visitor Counter:** A JavaScript snippet on the frontend fetches the visitor count.
3.  **API Layer:** **AWS API Gateway** receives the request and triggers a Lambda function.
4.  **Compute:** **AWS Lambda** (Python) executes the logic to update the count.
5.  **Database:** **Amazon DynamoDB** stores the visitor count.
6.  **Infrastructure:** All resources are provisioned using **Terraform**.
7.  **CI/CD:** **GitHub Actions** automatically deploys changes to the S3 bucket when code is pushed.

## 🛠️ Tech Stack
-   **Cloud Provider:** AWS (S3, Lambda, API Gateway, DynamoDB)
-   **IaC:** Terraform
-   **CI/CD:** GitHub Actions
-   **Backend:** Python (boto3)
-   **Frontend:** HTML, CSS, JavaScript

## 🚀 How to Deploy

### Prerequisites
-   AWS CLI installed and configured.
-   Terraform installed.
-   Git installed.

### Steps
1.  **Clone the Repository**
    ```bash
    git clone [https://github.com/ashwath2398/cloud-project.git](https://github.com/ashwath2398/cloud-project.git)
    cd cloud-project
    ```

2.  **Initialize Terraform**
    Initialize the backend and download provider plugins.
    ```bash
    terraform init
    ```

3.  **Plan & Apply Infrastructure**
    Review the changes and provision the AWS resources.
    ```bash
    terraform plan
    terraform apply --auto-approve
    ```

4.  **Upload Frontend Code**
    Push changes to the `main`/`master` branch. GitHub Actions will automatically detect the commit and upload `index.html` and your .pdf file to the S3 bucket.

## 🔄 CI/CD Pipeline
The project includes a GitHub Actions workflow (`.github/workflows/front-end-cicd.yml`) that runs on every push to the `main`/`master` branch.
1.  Checks out the code.
2.  Configures AWS Credentials (stored in GitHub Secrets).
3.  Syncs the HTML and PDF files to the S3 bucket.

Note when making live (if you dont mind sharing you personal info all over the internet) - 
1. Add this command in .yml file `aws s3 cp resume.pdf s3://${{ secrets.S3_BUCKET_NAME }}/` 
2. Save your personal file as `resume.pdf` in this cloned folder. 
3. If you branch is `main` change this in .yml also.