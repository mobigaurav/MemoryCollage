FROM public.ecr.aws/lambda/python:3.12-arm64

COPY services/api/requirements.txt ${LAMBDA_TASK_ROOT}/requirements.txt
RUN pip install --no-cache-dir -r ${LAMBDA_TASK_ROOT}/requirements.txt

COPY services/api/mb_api ${LAMBDA_TASK_ROOT}/mb_api
RUN chmod -R a+rX ${LAMBDA_TASK_ROOT}/mb_api

CMD ["mb_api.handler.lambda_handler"]
