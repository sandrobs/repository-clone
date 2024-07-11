import boto3
import git
import os
import shutil
import tempfile
from github import Github
import json

# Configurações AWS
s3_bucket_name = 'repositoriosgithub19932903'
aws_region = 'us-east-1'

# Configuração GitHub (substitua 'your_github_token' pelo seu token do GitHub)
#github_token = 'your_github_token'
#g = Github(github_token)

# Inicializa clientes AWS
s3 = boto3.client('s3', region_name=aws_region)

def clone_repo_to_s3(repo_url):
    repo_name = repo_url.split('/')[-1]
    with tempfile.TemporaryDirectory() as temp_dir:
        repo_path = os.path.join(temp_dir, repo_name)
        
        # Clonar o repositório do GitHub
        git.Repo.clone_from(repo_url, repo_path)
        
        # Compactar o repositório clonado
        archive_path = shutil.make_archive(repo_path, 'zip', repo_path)
        
        # Enviar para o S3
        s3_key = f"{repo_name}.zip"
        s3.upload_file(archive_path, s3_bucket_name, s3_key)

def lambda_handler(event, context):
    try:
        message_body = json.loads(event['Records'][0]['body'])
        repo_url = message_body['repo_url']
    except KeyError as e:
        print(f'Erro ao extrair repo_url: {e}')
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'repo_url não encontrado no evento'})
        }
    
    # Chamar função para clonar e enviar para o S3
    clone_repo_to_s3(repo_url)
    
    return {
        'statusCode': 200,
        'body': json.dumps({'message': f'Repositório {repo_url} clonado e enviado para o S3.'})
    }
