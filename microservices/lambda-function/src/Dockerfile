FROM public.ecr.aws/lambda/python:3.9

# Instalar Git
RUN yum install -y git

# Copiar arquivos necessários
COPY lambda_function.py ${LAMBDA_TASK_ROOT}
COPY requirements.txt  .

# Instalar dependências Python
RUN pip install -r requirements.txt -t ${LAMBDA_TASK_ROOT}

CMD ["lambda_function.lambda_handler"]
